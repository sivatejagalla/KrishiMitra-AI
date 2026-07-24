from datetime import datetime, timezone
from typing import List, Optional
from app.schemas.agri import SoilHealthRequest, SoilHealthResponse
from app.services.language_service import language_service


_PH_TABLE = {
    "acidic": (0, 5.5, "Soil is acidic (pH < 5.5). Liming is recommended."),
    "slightly_acidic": (5.5, 6.5, "Soil is slightly acidic (pH 5.5–6.5). Ideal for most crops."),
    "neutral": (6.5, 7.5, "Soil is neutral (pH 6.5–7.5). Excellent for all crops."),
    "alkaline": (7.5, 14.0, "Soil is alkaline (pH > 7.5). Gypsum or acidifying agents needed.")
}

_SOIL_AMENDMENTS = {
    "acidic": [
        "Apply agricultural lime (Calcium Carbonate) at 1–2 tons/acre",
        "Use dolomite lime to supply Mg along with pH correction",
        "Mix organic compost to buffer acidity over time"
    ],
    "alkaline": [
        "Apply gypsum (calcium sulphate) at 500 kg/acre",
        "Use ferrous sulphate 20 kg/acre for micronutrient correction",
        "Incorporate green manures like Dhaincha (Sesbania) for bio-acidification"
    ],
    "neutral": [
        "Maintain with regular FYM/compost at 5–10 tonnes/acre per season",
        "Apply Azospirillum + PSB bio-fertilizer for nutrient efficiency"
    ]
}


class SoilHealthService:
    """Service providing soil health analysis and organic amendment advisory."""

    def analyze(self, request: SoilHealthRequest) -> SoilHealthResponse:
        detected_lang, _ = language_service.detect_language(request.query_text)
        ph_interp: Optional[str] = None
        amendments: List[str] = []
        ph_category = "neutral"

        if request.ph_level is not None:
            ph = request.ph_level
            if ph < 5.5:
                ph_category = "acidic"
            elif ph < 6.5:
                ph_category = "slightly_acidic"
            elif ph <= 7.5:
                ph_category = "neutral"
            else:
                ph_category = "alkaline"

            _, _, ph_interp = _PH_TABLE.get(ph_category, _PH_TABLE["neutral"])
            amendments = _SOIL_AMENDMENTS.get(ph_category, _SOIL_AMENDMENTS["neutral"])

        # Detect deficiency from query keywords
        deficiencies = []
        q = request.query_text.lower()
        if "yellow" in q or "nitrogen" in q:
            deficiencies.append("Nitrogen deficiency – apply Azospirillum bio-fertilizer + 15 kg urea/acre")
        if "purple" in q or "phosphorus" in q:
            deficiencies.append("Phosphorus deficiency – apply PSB (Phosphate Solubilising Bacteria) + rock phosphate")
        if "tip burn" in q or "potassium" in q:
            deficiencies.append("Potassium deficiency – apply SOP (Sulphate of Potash) 25 kg/acre")
        if "pale" in q or "iron" in q or "chlorosis" in q:
            deficiencies.append("Iron deficiency – apply ferrous sulphate foliar spray 0.5% solution")

        bio_advice = (
            "Apply a combination of Azospirillum (N-fixing), PSB (P-solubilising), and VAM Mycorrhiza "
            "at 4 kg/acre during sowing for a complete biological nutrient package. "
            "Supplement with vermicompost at 2–3 tonnes/acre for enhanced soil microbial activity."
        )

        soil_note = f" Soil type ({request.soil_type}) is noted." if request.soil_type else ""
        crop_note = f" For your {request.crop_type} crop, ensure adequate calcium and sulphur nutrition." if request.crop_type else ""

        general_advice = (
            f"Soil health is the foundation of good yield.{soil_note}{crop_note} "
            "Regular soil testing every 2 years is recommended. Avoid burning crop residues and instead incorporate them as mulch."
        )

        return SoilHealthResponse(
            ph_interpretation=ph_interp,
            deficiency_detected=deficiencies,
            organic_amendments=amendments,
            bio_fertilizer_advice=bio_advice,
            general_advice=general_advice,
            detected_language=detected_lang,
            created_at=datetime.now(timezone.utc)
        )


soil_health_service = SoilHealthService()
