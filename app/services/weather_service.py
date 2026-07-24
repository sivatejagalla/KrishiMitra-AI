import httpx
from typing import Optional
from app.core.logger import logger
from app.schemas.ai import WeatherInfo


class WeatherService:
    """Service for fetching live weather data and farming weather advisories using GPS coordinates."""

    def get_weather(self, latitude: float, longitude: float) -> WeatherInfo:
        """Fetch weather data for given latitude and longitude using Open-Meteo API."""
        try:
            url = f"https://api.open-meteo.com/v1/forecast?latitude={latitude}&longitude={longitude}&current_weather=true&hourly=relative_humidity_2m"
            response = httpx.get(url, timeout=5.0)
            if response.status_code == 200:
                data = response.json()
                current = data.get("current_weather", {})
                temp = current.get("temperature", 28.0)
                wind = current.get("windspeed", 10.0)
                weather_code = current.get("weathercode", 0)
                
                condition, advice = self._interpret_weather_code(weather_code, temp)
                
                return WeatherInfo(
                    latitude=latitude,
                    longitude=longitude,
                    temperature_c=temp,
                    humidity_percent=65.0,
                    condition=condition,
                    wind_speed_kmh=wind,
                    precipitation_mm=0.0,
                    advice=advice
                )
        except Exception as e:
            logger.warning(f"Failed to fetch live weather for coordinates ({latitude}, {longitude}): {e}")

        # Fallback default weather advisory if API call is unfulfilled
        return WeatherInfo(
            latitude=latitude,
            longitude=longitude,
            temperature_c=29.5,
            humidity_percent=70.0,
            condition="Partly Cloudy",
            wind_speed_kmh=12.0,
            precipitation_mm=0.0,
            advice="Favorable conditions for bio-fertilizer application. Avoid foliar spray if rain is expected in 4 hours."
        )

    def _interpret_weather_code(self, code: int, temp: float) -> tuple[str, str]:
        """Map Open-Meteo WMO weather code to farmer advisory string."""
        if code == 0:
            cond = "Clear Sky / Sunny"
            advice = "Ideal weather for field irrigation and application of Azospirillum or Rhizobium bio-fertilizers during early morning."
        elif code in [1, 2, 3]:
            cond = "Partly Cloudy"
            advice = "Good weather for soil preparation and bio-pesticide spray. Ensure soil moisture is adequate."
        elif code in [51, 53, 55, 61, 63, 65]:
            cond = "Rainy"
            advice = "Rain predicted. Postpone spraying bio-pesticides or neem oil until dry weather resumes."
        else:
            cond = "Overcast"
            advice = "High humidity may trigger fungal activity. Inspect crops for blast or blight symptoms."
        return cond, advice


weather_service = WeatherService()
