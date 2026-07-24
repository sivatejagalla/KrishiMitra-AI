from datetime import datetime, timezone
from typing import List, Optional
from app.core.logger import logger
from app.schemas.agri import MarketPrice, MarketPriceResponse
from app.services.language_service import language_service


# Realistic Agmarknet-like offline data for demonstration
_MARKET_DATA = {
    "rice": [
        MarketPrice(crop_name="Rice", mandi_name="Kothapet Mandi", state="Telangana", min_price_inr=1800, max_price_inr=2200, modal_price_inr=2050, unit="Quintal", fetched_at=datetime.now(timezone.utc)),
        MarketPrice(crop_name="Rice", mandi_name="Nizamabad Mandi", state="Telangana", min_price_inr=1750, max_price_inr=2150, modal_price_inr=1980, unit="Quintal", fetched_at=datetime.now(timezone.utc)),
    ],
    "paddy": [
        MarketPrice(crop_name="Paddy", mandi_name="Nalgonda Mandi", state="Telangana", min_price_inr=1400, max_price_inr=1650, modal_price_inr=1520, unit="Quintal", fetched_at=datetime.now(timezone.utc)),
    ],
    "cotton": [
        MarketPrice(crop_name="Cotton", mandi_name="Warangal Mandi", state="Telangana", min_price_inr=5200, max_price_inr=6200, modal_price_inr=5700, unit="Quintal", fetched_at=datetime.now(timezone.utc)),
        MarketPrice(crop_name="Cotton", mandi_name="Adilabad Mandi", state="Telangana", min_price_inr=5000, max_price_inr=6000, modal_price_inr=5500, unit="Quintal", fetched_at=datetime.now(timezone.utc)),
    ],
    "maize": [
        MarketPrice(crop_name="Maize", mandi_name="Medak Mandi", state="Telangana", min_price_inr=1600, max_price_inr=1900, modal_price_inr=1750, unit="Quintal", fetched_at=datetime.now(timezone.utc)),
    ],
    "tomato": [
        MarketPrice(crop_name="Tomato", mandi_name="Bowenpally Mandi", state="Telangana", min_price_inr=800, max_price_inr=2500, modal_price_inr=1400, unit="Quintal", fetched_at=datetime.now(timezone.utc)),
    ],
    "wheat": [
        MarketPrice(crop_name="Wheat", mandi_name="Karimnagar Mandi", state="Telangana", min_price_inr=2100, max_price_inr=2400, modal_price_inr=2250, unit="Quintal", fetched_at=datetime.now(timezone.utc)),
    ],
    "soybean": [
        MarketPrice(crop_name="Soybean", mandi_name="Nagpur Mandi", state="Maharashtra", min_price_inr=3800, max_price_inr=4500, modal_price_inr=4150, unit="Quintal", fetched_at=datetime.now(timezone.utc)),
    ],
}


class MarketPriceService:
    """Service providing mandi market price information and selling advisory for Indian farmers."""

    def get_prices(self, crop_name: str, state: Optional[str] = None, language: str = "en") -> MarketPriceResponse:
        """Retrieve market prices and provide AI-driven selling advisory."""
        detected_lang, _ = language_service.detect_language(crop_name)
        crop_key = crop_name.lower().strip()
        prices = _MARKET_DATA.get(crop_key, [])

        if not prices:
            # Fuzzy fallback: check partial match
            for key, data in _MARKET_DATA.items():
                if key in crop_key or crop_key in key:
                    prices = data
                    break

        if not prices:
            prices = [
                MarketPrice(crop_name=crop_name, mandi_name="Central Mandi (Estimated)", state=state or "Telangana",
                            min_price_inr=1500, max_price_inr=3000, modal_price_inr=2200, unit="Quintal",
                            fetched_at=datetime.now(timezone.utc))
            ]

        modal = prices[0].modal_price_inr
        trend, selling_advice, window = self._generate_advisory(crop_name, modal)

        return MarketPriceResponse(
            crop_name=crop_name,
            prices=prices,
            price_trend=trend,
            selling_advice=selling_advice,
            best_selling_window=window,
            detected_language=language
        )

    def _generate_advisory(self, crop: str, modal: float):
        crop_l = crop.lower()
        if "cotton" in crop_l:
            return "Stable", "Cotton prices are stable. Wait 10-14 days after harvest to clean and grade before selling to improve price.", "October – December post-harvest"
        elif "paddy" in crop_l or "rice" in crop_l:
            return "Rising", "Paddy MSP has increased. Sell to government procurement centres (PACS) for guaranteed minimum support price.", "November – January"
        elif "tomato" in crop_l:
            return "Falling", "Tomato prices are volatile. Consider cold storage or processing tie-ups to reduce distress selling.", "Year-round, peak Jan – March"
        elif "wheat" in crop_l:
            return "Stable", "Wheat MSP is fixed. Register with PM-AASHA scheme for price support. Sell in April-May post Rabi harvest.", "April – May"
        else:
            return "Stable", f"Monitor {crop} prices daily at Agmarknet. Hold stock for 1-2 weeks post-harvest for better pricing if storage is available.", "Post-harvest window"


market_price_service = MarketPriceService()
