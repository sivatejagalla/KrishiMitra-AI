import uuid
from typing import List, Optional
from app.schemas.ai import BioProduct


CATALOG: List[BioProduct] = [
    BioProduct(
        id="bio-001",
        product_name="Azospirillum & Rhizobium Bio-Fertilizer",
        category="Bio-Fertilizer",
        target_crops=["Paddy", "Wheat", "Maize", "Pulses", "Groundnut"],
        target_pest_disease="Nitrogen Deficiency & Poor Root Growth",
        composition="Nitrogen-fixing bacteria (Azospirillum brasilense / Rhizobium spp.)",
        dosage="500g per acre or 10ml per kg seed treatment",
        application_method="Seed treatment or soil application mixed with organic farmyard manure (FYM).",
        benefits=["Fixes atmospheric nitrogen", "Promotes vigorous root expansion", "Reduces chemical urea dependency by 25%"]
    ),
    BioProduct(
        id="bio-002",
        product_name="Trichoderma Viride Bio-Fungicide",
        category="Bio-Fungicide",
        target_crops=["Cotton", "Paddy", "Chilli", "Tomato", "Sugarcane", "Pulses"],
        target_pest_disease="Root Rot, Wilt, Damping-off, Sheath Blight",
        composition="Trichoderma viride 1.0% WP (Spore count 2x10^6 cfu/g)",
        dosage="1 kg per acre mixed with 100 kg compost",
        application_method="Soil drenching or seed treatment before sowing.",
        benefits=["Suppresses soil-borne fungal pathogens", "Enhances plant immunity", "Eco-friendly and non-toxic to pollinators"]
    ),
    BioProduct(
        id="bio-003",
        product_name="Pseudomonas Fluorescens Bio-Pesticide",
        category="Bio-Pesticide / Bio-Control",
        target_crops=["Paddy", "Vegetables", "Banana", "Citrus", "Spices"],
        target_pest_disease="Bacterial Leaf Blight, Soft Rot, Root-Knot Nematodes",
        composition="Pseudomonas fluorescens 1.0% W.P.",
        dosage="1 kg per acre or 5g per litre of water for foliar spray",
        application_method="Foliar spray during early morning or late afternoon.",
        benefits=["Systemic biocontrol against bacteria & fungi", "Promotes plant growth hormones", "Safe for beneficial insects"]
    ),
    BioProduct(
        id="bio-004",
        product_name="Neem Kernel Cake & Cold-Pressed Neem Oil (10,000 PPM)",
        category="Organic Bio-Pesticide",
        target_crops=["All Crops", "Paddy", "Cotton", "Vegetables", "Fruits"],
        target_pest_disease="Sucking Pests, Aphids, Thrips, Whiteflies, Caterpillar larvae",
        composition="Azadirachtin 10,000 PPM (1% EC)",
        dosage="3ml to 5ml per litre water",
        application_method="Foliar spray with emulsifier (soap nut extract).",
        benefits=["Natural anti-feedant and pest repellent", "Prevents egg hatching", "No chemical residue"]
    ),
    BioProduct(
        id="bio-005",
        product_name="VAM (Vesicular Arbuscular Mycorrhiza) Bio-Inoculant",
        category="Bio-Fertilizer",
        target_crops=["Paddy", "Maize", "Cotton", "Millets", "Horticultural Crops"],
        target_pest_disease="Phosphorus Lock-up & Drought Stress",
        composition="Glomus intraradices mycorrhizal spores & infected root fragments",
        dosage="4 kg per acre soil application",
        application_method="Apply directly near the root zone during transplanting/sowing.",
        benefits=["Mobilizes insoluble phosphorus & micronutrients", "Increases drought tolerance", "Improves soil structure"]
    )
]


class BioRecommendationService:
    """Recommendation engine for organic farming and biological agriculture inputs."""

    def get_recommendations(
        self,
        crop_type: Optional[str] = None,
        query_text: Optional[str] = None
    ) -> List[BioProduct]:
        """Match products based on crop type or query keywords (pest/disease/symptoms)."""
        if not crop_type and not query_text:
            return CATALOG[:2]

        matches: List[BioProduct] = []
        search_str = f"{crop_type or ''} {query_text or ''}".lower()

        for prod in CATALOG:
            # Check crop match
            crop_match = any(c.lower() in search_str for c in prod.target_crops)
            # Check disease/pest symptom match
            symptom_keywords = ["yellow", "rot", "wilt", "blight", "pests", "insect", "nitrogen", "worm", "fungus", "fertilizer"]
            symptom_match = any(k in search_str for k in symptom_keywords if k in prod.target_pest_disease.lower() or k in prod.product_name.lower())

            if crop_match or symptom_match:
                matches.append(prod)

        return matches if matches else CATALOG[:3]


bio_recommendation_service = BioRecommendationService()
