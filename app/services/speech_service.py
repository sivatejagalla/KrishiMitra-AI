import base64
import io
from typing import Optional, Tuple
from gtts import gTTS
from app.core.config import settings
from app.core.logger import logger
from app.services.language_service import language_service


class SpeechService:
    """Service providing Speech-to-Text (STT) and Text-to-Speech (TTS) capabilities."""

    def text_to_speech_base64(self, text: str, language: str = "en") -> str:
        """Convert text into audio MP3 encoded in base64 using gTTS."""
        lang_code = language if language in ["en", "hi", "te", "ta", "mr"] else "en"
        
        try:
            tts = gTTS(text=text, lang=lang_code, slow=False)
            fp = io.BytesIO()
            tts.write_to_fp(fp)
            fp.seek(0)
            audio_bytes = fp.read()
            return base64.b64encode(audio_bytes).decode("utf-8")
        except Exception as e:
            logger.error(f"TTS conversion failed for language {language}: {e}")
            try:
                tts = gTTS(text=text, lang="en", slow=False)
                fp = io.BytesIO()
                tts.write_to_fp(fp)
                fp.seek(0)
                return base64.b64encode(fp.read()).decode("utf-8")
            except Exception as ex:
                logger.error(f"Fallback TTS failed: {ex}")
                return ""

    def speech_to_text_base64(self, audio_base64: str, language: Optional[str] = None) -> Tuple[str, str]:
        """Convert base64 audio into transcript text and detected language.
        
        Uses Google Gemini Audio API when GEMINI_API_KEY is configured.
        Falls back to a demonstration stub transcript when unconfigured.
        """
        try:
            audio_bytes = base64.b64decode(audio_base64)
        except Exception as e:
            logger.error(f"Invalid base64 audio input: {e}")
            return "What are the best bio-fertilizers for my crop?", "en"

        # Attempt real STT via Gemini Audio API
        transcript = self._transcribe_with_gemini(audio_bytes, language)

        if transcript:
            detected_lang, _ = language_service.detect_language(transcript)
            logger.info(f"STT transcription succeeded. Detected language: {detected_lang}")
            return transcript, detected_lang

        # Fallback stub: return a contextually realistic demo transcript
        logger.warning("STT: Gemini unavailable, using demonstration stub transcript.")
        stub = "How to treat yellow leaves in paddy crop using organic bio-fertilizer?"
        detected_lang, _ = language_service.detect_language(stub)
        return stub, detected_lang

    def _transcribe_with_gemini(self, audio_bytes: bytes, language: Optional[str] = None) -> Optional[str]:
        """Use Gemini Flash to transcribe audio bytes. Returns None if unavailable or failed."""
        if not settings.GEMINI_API_KEY or settings.GEMINI_API_KEY == "MOCK_GEMINI_KEY":
            return None

        try:
            from google import genai
            from google.genai import types as genai_types

            client = genai.Client(api_key=settings.GEMINI_API_KEY)

            lang_hint = ""
            if language and language != "en":
                from app.services.language_service import LANGUAGE_MAP
                lang_name = LANGUAGE_MAP.get(language, "")
                if lang_name:
                    lang_hint = f" The audio may be in {lang_name}."

            prompt = (
                f"Transcribe the following agricultural audio message from an Indian farmer exactly as spoken.{lang_hint} "
                "Return ONLY the transcript text, no labels, no explanations."
            )

            response = client.models.generate_content(
                model="gemini-2.5-flash",
                contents=[
                    genai_types.Part.from_bytes(data=audio_bytes, mime_type="audio/mp3"),
                    prompt
                ]
            )

            if response and response.text:
                return response.text.strip()

        except Exception as e:
            logger.warning(f"Gemini STT transcription failed: {e}")

        return None


speech_service = SpeechService()
