import re
from typing import Dict, Tuple
from app.core.logger import logger

# Supported language codes & native names
LANGUAGE_MAP: Dict[str, str] = {
    "en": "English",
    "hi": "Hindi (हिंदी)",
    "te": "Telugu (తెలుగు)",
    "ta": "Tamil (தமிழ்)",
    "mr": "Marathi (मराठी)",
}


class LanguageService:
    """Service for language auto-detection and translation between English, Hindi, Telugu, Tamil, and Marathi."""

    def detect_language(self, text: str) -> Tuple[str, str]:
        """Automatically detect language of the given text using Unicode ranges or pattern matching."""
        if not text or not text.strip():
            return "en", LANGUAGE_MAP["en"]

        # Check Telugu Unicode range (0x0C00 - 0x0C7F)
        if re.search(r'[\u0C00-\u0C7F]', text):
            return "te", LANGUAGE_MAP["te"]

        # Check Tamil Unicode range (0x0B80 - 0x0BFF)
        if re.search(r'[\u0B80-\u0BFF]', text):
            return "ta", LANGUAGE_MAP["ta"]

        # Check Devanagari Unicode range (0x0900 - 0x097F) for Hindi & Marathi
        if re.search(r'[\u0900-\u097F]', text):
            # Differentiate Marathi specific characters if present, default to Hindi
            if re.search(r'[ळ]', text):
                return "mr", LANGUAGE_MAP["mr"]
            return "hi", LANGUAGE_MAP["hi"]

        # Default fallback to English
        return "en", LANGUAGE_MAP["en"]

    def translate_text(self, text: str, source_lang: str, target_lang: str) -> str:
        """Translate text from source_lang to target_lang."""
        if not text or source_lang == target_lang:
            return text

        try:
            # Simple online translation request using free Google Translate endpoint
            import httpx
            from urllib.parse import quote
            encoded_text = quote(text, safe="")
            url = (
                f"https://translate.googleapis.com/translate_a/single"
                f"?client=gtx&sl={source_lang}&tl={target_lang}&dt=t&q={encoded_text}"
            )
            response = httpx.get(url, timeout=5.0)
            if response.status_code == 200:
                result = response.json()
                translated_sentences = [segment[0] for segment in result[0] if segment and segment[0]]
                return "".join(translated_sentences)
        except Exception as e:
            logger.warning(f"Translation API request failed ({source_lang}->{target_lang}): {e}")

        return text


language_service = LanguageService()
