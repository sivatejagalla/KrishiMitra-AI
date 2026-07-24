from typing import List, Optional
from app.core.config import settings
from app.core.logger import logger
from app.schemas.ai import BioProduct, WeatherInfo


SYSTEM_PROMPT = """You are Agrolith AI (कृषि मित्र), an empathetic, highly knowledgeable agricultural expert AI dedicated to helping Indian farmers.
Your advice should be:
1. Clear, practical, simple to understand, and actionable for farmers.
2. Focused on organic, eco-friendly, and biological farming practices (bio-fertilizers, bio-pesticides, neem oil, compost, Trichoderma).
3. Tailored to local weather and crop conditions.
4. Structured step-by-step when explaining solutions or treatments.
5. Polite, supportive, and written directly in the requested language ({language_name}).

Do NOT give overly complex academic explanations. Focus on step-by-step instructions for the field.
"""


class GeminiService:
    """Service integrating Google Gemini API for intelligent farmer advisory."""

    def __init__(self):
        self._client = None
        self._initialize_gemini()

    def _initialize_gemini(self):
        """Initialize Google Gemini client if API key is present."""
        if settings.GEMINI_API_KEY and settings.GEMINI_API_KEY != "MOCK_GEMINI_KEY":
            try:
                from google import genai
                self._client = genai.Client(api_key=settings.GEMINI_API_KEY)
                logger.info("Google Gemini SDK Client initialized successfully.")
            except Exception as e:
                logger.warning(f"Could not initialize Google Gemini SDK Client: {e}")

    def generate_agricultural_advisory(
        self,
        query: str,
        language_name: str = "English",
        crop_type: Optional[str] = None,
        weather: Optional[WeatherInfo] = None,
        recommendations: Optional[List[BioProduct]] = None,
        context_memory: str = ""
    ) -> str:
        """Generate tailored advisory response using Gemini AI or structured fallback engine."""
        prompt = self._build_prompt(query, language_name, crop_type, weather, recommendations, context_memory)

        if self._client:
            try:
                response = self._client.models.generate_content(
                    model="gemini-2.5-flash",
                    contents=prompt
                )
                if response and response.text:
                    return response.text
            except Exception as e:
                logger.error(f"Gemini API call failed: {e}. Falling back to structured response.")

        # Structured expert response generator (fallback engine if API key is unconfigured)
        return self._generate_fallback_advisory(query, language_name, crop_type, weather, recommendations)

    def _build_prompt(
        self,
        query: str,
        language_name: str,
        crop_type: Optional[str],
        weather: Optional[WeatherInfo],
        recommendations: Optional[List[BioProduct]],
        context_memory: str
    ) -> str:
        system = SYSTEM_PROMPT.format(language_name=language_name)
        
        prompt = f"{system}\n"
        if context_memory:
            prompt += f"{context_memory}\n"
            
        prompt += f"Farmer Question: {query}\n"
        if crop_type:
            prompt += f"Target Crop: {crop_type}\n"
            
        if weather:
            prompt += f"Local Weather: {weather.condition}, Temp: {weather.temperature_c}°C, Humidity: {weather.humidity_percent}%. Weather Advice: {weather.advice}\n"
            
        if recommendations:
            recs_str = ", ".join([f"{p.product_name} ({p.dosage})" for p in recommendations])
            prompt += f"Recommended Biological Products: {recs_str}\n"

        prompt += f"\nPlease provide your advice in {language_name}:"
        return prompt

    def _generate_fallback_advisory(
        self,
        query: str,
        language_name: str,
        crop_type: Optional[str],
        weather: Optional[WeatherInfo],
        recommendations: Optional[List[BioProduct]]
    ) -> str:
        crop_str = f" for your {crop_type} crop" if crop_type else ""
        weather_advice = f" Weather note: {weather.advice}" if weather and weather.advice else ""
        
        bio_text = ""
        if recommendations:
            bio_text = "\n\nRecommended Bio Solutions:\n" + "\n".join(
                [f"• {p.product_name}: Apply {p.dosage} via {p.application_method}." for p in recommendations]
            )

        return (
            f"Dear Farmer, here is your practical guidance{crop_str}:\n\n"
            f"1. **Diagnosis & Observation**: Inspect your field during morning hours for early signs of nutrient deficiency or pest activity.\n"
            f"2. **Biological Care**: Use organic compost and biological agents to protect soil health and root vitality.{bio_text}\n"
            f"3. **Water & Weather Management**: Ensure proper field drainage.{weather_advice}\n\n"
            f"Stay healthy and happy farming!"
        )


gemini_service = GeminiService()
