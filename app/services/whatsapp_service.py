import base64
import re
from typing import Any, Dict, Optional
import httpx
from app.core.config import settings
from app.core.logger import logger
from app.services.gemini_service import gemini_service
from app.services.crop_disease_service import crop_disease_service
from app.services.weather_service import weather_service
from app.services.market_price_service import market_price_service
from app.services.government_scheme_service import government_scheme_service
from app.services.soil_health_service import soil_health_service
from app.services.speech_service import speech_service
from app.services.language_service import language_service
from app.services.chat_memory_service import chat_memory_service
from app.schemas.ai import ChatMessage


class WhatsAppService:
    """Service providing Meta WhatsApp Cloud API communication and intelligent AI routing."""

    def __init__(self):
        self.graph_url = "https://graph.facebook.com/v18.0"

    def get_headers(self) -> Dict[str, str]:
        """Return authorization headers for Meta Graph API."""
        return {
            "Authorization": f"Bearer {settings.WHATSAPP_TOKEN}",
            "Content-Type": "application/json",
        }

    async def send_text_message(self, to_phone: str, text: str) -> bool:
        """Send a text message to a WhatsApp user via Meta Cloud API."""
        if not settings.WHATSAPP_TOKEN or not settings.PHONE_NUMBER_ID:
            logger.warning(f"[WhatsApp Mock Send] To: {to_phone} | Message: {text[:100]}...")
            return True

        url = f"{self.graph_url}/{settings.PHONE_NUMBER_ID}/messages"
        payload = {
            "messaging_product": "whatsapp",
            "recipient_type": "individual",
            "to": to_phone,
            "type": "text",
            "text": {"preview_url": False, "body": text},
        }

        try:
            async with httpx.AsyncClient(timeout=10.0) as client:
                resp = await client.post(url, json=payload, headers=self.get_headers())
                if resp.status_code == 200:
                    logger.info(f"WhatsApp text message sent successfully to {to_phone}")
                    return True
                else:
                    logger.error(f"WhatsApp API error ({resp.status_code}): {resp.text}")
                    return False
        except Exception as e:
            logger.error(f"Failed to send WhatsApp text message: {e}")
            return False

    async def download_media(self, media_id: str) -> Optional[bytes]:
        """Fetch media URL from Meta Graph API and download binary bytes."""
        if not settings.WHATSAPP_TOKEN:
            logger.warning("WHATSAPP_TOKEN unconfigured. Unable to download live WhatsApp media.")
            return None

        headers = {"Authorization": f"Bearer {settings.WHATSAPP_TOKEN}"}
        url_meta = f"{self.graph_url}/{media_id}"

        try:
            async with httpx.AsyncClient(timeout=15.0) as client:
                # 1. Get media URL
                resp = await client.get(url_meta, headers=headers)
                if resp.status_code != 200:
                    logger.error(f"Failed to retrieve media metadata ({resp.status_code}): {resp.text}")
                    return None

                media_url = resp.json().get("url")
                if not media_url:
                    return None

                # 2. Download media binary bytes
                media_resp = await client.get(media_url, headers=headers)
                if media_resp.status_code == 200:
                    return media_resp.content
                else:
                    logger.error(f"Failed to download media binary ({media_resp.status_code})")
                    return None

        except Exception as e:
            logger.error(f"Error downloading WhatsApp media ID '{media_id}': {e}")
            return None

    async def process_incoming_message(self, message: Dict[str, Any], sender_phone: str) -> None:
        """Parse incoming WhatsApp Cloud API message payload and route to appropriate AI service."""
        msg_type = message.get("type", "text")
        session_id = f"whatsapp_{sender_phone}"

        logger.info(f"Processing WhatsApp message from {sender_phone} of type: {msg_type}")

        # ── 1. Image / Disease Detection ──────────────────────────────────────
        if msg_type == "image":
            image_info = message.get("image", {})
            media_id = image_info.get("id")
            caption = image_info.get("caption", "")

            reply_text = await self._handle_image_message(media_id, caption, sender_phone)
            await self.send_text_message(sender_phone, reply_text)

        # ── 2. Voice Note / Audio Message ──────────────────────────────────────
        elif msg_type in ["voice", "audio"]:
            audio_info = message.get(msg_type, {})
            media_id = audio_info.get("id")

            await self._handle_voice_message(media_id, sender_phone, session_id)

        # ── 3. Document Message ────────────────────────────────────────────────
        elif msg_type == "document":
            doc_info = message.get("document", {})
            media_id = doc_info.get("id")
            caption = doc_info.get("caption", "") or "Soil report / document query"

            reply_text = await self._handle_document_message(media_id, caption, sender_phone, session_id)
            await self.send_text_message(sender_phone, reply_text)

        # ── 4. Text Message (Intent Routing) ──────────────────────────────────
        else:
            text_body = message.get("text", {}).get("body", "").strip()
            if not text_body:
                return

            reply_text = await self._handle_text_message(text_body, sender_phone, session_id)
            await self.send_text_message(sender_phone, reply_text)

    async def _handle_image_message(self, media_id: Optional[str], caption: str, sender_phone: str) -> str:
        """Download crop image, convert to base64, run Gemini Vision disease detection."""
        lang_code, _ = language_service.detect_language(caption or "Crop disease check")

        image_bytes = None
        if media_id:
            image_bytes = await self.download_media(media_id)

        if not image_bytes:
            # Fallback mock image bytes for demonstration/testing
            image_bytes = b"MOCK_PLANT_IMAGE_BYTES"

        base64_img = base64.b64encode(image_bytes).decode("utf-8")
        from app.schemas.agri import DiseaseDetectionRequest
        result = crop_disease_service.analyze_image(
            DiseaseDetectionRequest(
                image_base64=base64_img,
                crop_type=caption if caption else None,
                language=lang_code,
            )
        )

        disease_info = result.detected_disease
        if disease_info:
            response_md = (
                f"🔬 *Crop Disease Analysis Report*\n\n"
                f"🌱 *Disease*: {disease_info.disease_name}\n"
                f"⚠️ *Severity*: {disease_info.severity} ({disease_info.confidence_pct:.1f}% confidence)\n\n"
                f"📋 *Symptoms*:\n• " + "\n• ".join(disease_info.symptoms[:3]) + "\n\n"
                f"🌿 *Organic Treatments*:\n• " + "\n• ".join(disease_info.organic_treatments[:3]) + "\n\n"
                f"💊 *Chemical Treatments*:\n• " + "\n• ".join(disease_info.chemical_treatments[:3]) + "\n\n"
                f"💡 *General Advice*: {result.general_advice}"
            )
        else:
            response_md = f"🌱 *Crop Health Report*\n\n{result.general_advice}"

        return language_service.translate_text(response_md, "en", lang_code)

    async def _handle_voice_message(self, media_id: Optional[str], sender_phone: str, session_id: str) -> None:
        """Download voice note, transcribe to text using Gemini STT, generate advisory response."""
        audio_bytes = None
        if media_id:
            audio_bytes = await self.download_media(media_id)

        if not audio_bytes:
            audio_bytes = b"MOCK_VOICE_AUDIO_BYTES"

        base64_audio = base64.b64encode(audio_bytes).decode("utf-8")
        transcript, detected_lang = speech_service.speech_to_text_base64(base64_audio)

        logger.info(f"Voice note transcribed: '{transcript}' (Detected: {detected_lang})")

        # Process transcript through advisory engine
        response_text = await self._handle_text_message(transcript, sender_phone, session_id)

        # Send text transcript & reply confirmation
        voice_ack = (
            f"🎙️ *Voice Message Received*\n"
            f"📝 *Transcript*: \"{transcript}\"\n\n"
            f"🤖 *Agrolith Reply*:\n{response_text}"
        )
        await self.send_text_message(sender_phone, voice_ack)

    async def _handle_document_message(
        self, media_id: Optional[str], caption: str, sender_phone: str, session_id: str
    ) -> str:
        """Handle incoming soil report or scheme document."""
        lang_code, _ = language_service.detect_language(caption)
        
        from app.schemas.agri import SoilHealthRequest
        # Analyze as soil health request
        soil_res = soil_health_service.analyze(
            SoilHealthRequest(query_text=caption or "Soil report review", language=lang_code)
        )

        doc_reply = (
            f"📄 *Document & Soil Report Review*\n\n"
            f"🧪 *Soil Diagnosis*: {soil_res.ph_interpretation or 'Analyzed'}\n"
            f"⚠️ *Deficiencies*: {', '.join(soil_res.deficiency_detected) if soil_res.deficiency_detected else 'None'}\n"
            f"🌿 *Bio-Fertilizer Advice*: {soil_res.bio_fertilizer_advice}\n\n"
            f"💡 *General Advice*: {soil_res.general_advice}"
        )
        return language_service.translate_text(doc_reply, "en", lang_code)

    async def _handle_text_message(self, text: str, sender_phone: str, session_id: str) -> str:
        """Identify query intent (Weather, Prices, Schemes, Soil, AI Chat) and return translated reply."""
        lang_code, lang_name = language_service.detect_language(text)
        lower_text = text.lower()

        # Load chat history
        history = chat_memory_service.get_history(session_id)
        chat_memory_service.add_message(session_id, ChatMessage(role="user", content=text, language=lang_code))

        reply_text = ""

        # ── Intent 1: Weather ──────────────────────────────────────────────────
        if any(w in lower_text for w in ["weather", "mausam", "rain", "barish", "temperature", "forecast"]):
            weather = weather_service.get_weather(latitude=17.3850, longitude=78.4867)
            reply_text = (
                f"🌦️ *Live Weather Advisory*\n\n"
                f"🌡️ *Temperature*: {weather.temperature_c}°C ({weather.condition})\n"
                f"💧 *Humidity*: {weather.humidity_percent}%\n"
                f"💨 *Wind Speed*: {weather.wind_speed_kmh} km/h\n\n"
                f"🌾 *Farming Advice*: {weather.advice}"
            )

        # ── Intent 2: Mandi Market Prices ──────────────────────────────────────
        elif any(w in lower_text for w in ["mandi", "price", "rate", "bhav", "market", "quintal", "sell"]):
            # Extract crop name if present
            crop_match = re.search(r"\b(rice|paddy|wheat|cotton|maize|tomato|soybean)\b", lower_text)
            crop_name = crop_match.group(1).title() if crop_match else "Rice"

            prices_res = market_price_service.get_prices(crop_name=crop_name, language=lang_code)
            
            price_lines = []
            for p in prices_res.prices[:3]:
                price_lines.append(f"• *{p.mandi_name}*: ₹{p.modal_price_inr:.0f}/{p.unit} (Min ₹{p.min_price_inr:.0f} - Max ₹{p.max_price_inr:.0f})")

            reply_text = (
                f"💰 *Mandi Market Rates ({prices_res.crop_name})*\n\n"
                + "\n".join(price_lines) + "\n\n"
                f"📈 *Trend*: {prices_res.price_trend}\n"
                f"💡 *Selling Advice*: {prices_res.selling_advice}\n"
                f"🗓️ *Best Window*: {prices_res.best_selling_window}"
            )

        # ── Intent 3: Government Schemes & Subsidies ───────────────────────────
        elif any(w in lower_text for w in ["scheme", "subsidy", "pm kisan", "yojana", "bima", "insurance", "loan", "kcc"]):
            from app.schemas.agri import SchemeQueryRequest
            schemes_res = government_scheme_service.query_schemes(
                SchemeQueryRequest(farmer_query=text, language=lang_code)
            )
            
            scheme_lines = []
            for s in schemes_res.matched_schemes[:2]:
                scheme_lines.append(f"• *{s.scheme_name}*: {s.benefit_description}\n  🌐 Portal: {s.official_website}")

            reply_text = (
                f"🏛️ *Government Agriculture Schemes*\n\n"
                + "\n\n".join(scheme_lines) + "\n\n"
                f"💡 *Summary*: {schemes_res.summary}"
            )

        # ── Intent 4: Soil Health & Fertilizer ─────────────────────────────────
        elif any(w in lower_text for w in ["soil", "mitti", "ph", "fertilizer", "urea", "compost", "nitrogen"]):
            from app.schemas.agri import SoilHealthRequest
            soil_res = soil_health_service.analyze(SoilHealthRequest(query_text=text, language=lang_code))
            reply_text = (
                f"🌱 *Soil Health Diagnosis*\n\n"
                f"🧪 *pH Level*: {soil_res.ph_interpretation or 'Analyzed'}\n"
                f"⚠️ *Deficiencies*: {', '.join(soil_res.deficiency_detected) if soil_res.deficiency_detected else 'None'}\n"
                f"🌿 *Organic Amendments*:\n• " + "\n• ".join(soil_res.organic_amendments[:3]) + "\n\n"
                f"💡 *Bio-Fertilizer*: {soil_res.bio_fertilizer_advice}"
            )

        # ── Intent 5: General Gemini AI Advisory ───────────────────────────────
        else:
            history_tuples = [(m.role, m.content) for m in history[-6:]]
            raw_reply = gemini_service.generate_farmer_advisory(
                query_text=text,
                language=lang_code,
                history=history_tuples,
            )
            reply_text = f"🤖 *Agrolith AI Advisory*\n\n{raw_reply}"

        # Translate reply to user's native language if needed
        final_reply = language_service.translate_text(reply_text, "en", lang_code)
        
        # Save AI assistant message in memory
        chat_memory_service.add_message(session_id, ChatMessage(role="assistant", content=final_reply, language=lang_code))

        return final_reply


whatsapp_service = WhatsAppService()
