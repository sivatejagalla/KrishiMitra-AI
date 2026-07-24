from datetime import datetime, timezone
from typing import List, Optional
from app.schemas.agri import GovernmentScheme, SchemeQueryRequest, SchemeQueryResponse
from app.services.language_service import language_service


# ── Government Scheme Knowledge Base ───────────────────────────────────────────
SCHEMES: List[GovernmentScheme] = [
    GovernmentScheme(
        scheme_id="pm-kisan",
        scheme_name="PM-KISAN (Pradhan Mantri Kisan Samman Nidhi)",
        ministry="Ministry of Agriculture & Farmers Welfare",
        target_beneficiary="All small and marginal landholding farmer families",
        benefit_description="₹6,000 per year in three equal instalments of ₹2,000 directly into farmer's bank account.",
        eligibility=["Must own cultivable agricultural land", "Aadhaar card and land records required", "Excludes income taxpayers and government employees"],
        documents_required=["Aadhaar card", "Land ownership records (Pahani/ROR)", "Bank account details", "Mobile number"],
        application_process="Register via pmkisan.gov.in or nearest Common Service Centre (CSC). Verify via State Nodal Officer.",
        official_website="https://pmkisan.gov.in",
        helpline="011-23381092",
        crops_covered=[]
    ),
    GovernmentScheme(
        scheme_id="pmfby",
        scheme_name="PM Fasal Bima Yojana (Pradhan Mantri Fasal Bima Yojana)",
        ministry="Ministry of Agriculture & Farmers Welfare",
        target_beneficiary="All farmers growing notified crops in notified areas",
        benefit_description="Crop insurance covering yield losses, post-harvest losses due to natural calamities, pests, and diseases at highly subsidised premium (2% Kharif, 1.5% Rabi).",
        eligibility=["Must have land documents or tenancy agreement", "Register before sowing deadline", "Crop must be notified under scheme for the district"],
        documents_required=["Aadhaar / Voter ID", "Bank passbook", "Sowing certificate from Patwari", "Land records (7/12 or Pahani)"],
        application_process="Apply through nearest bank, PACS, or CSC before the notified cut-off date. Also available on PMFBY app and portal.",
        official_website="https://pmfby.gov.in",
        helpline="1800-180-1551",
        crops_covered=["Paddy", "Wheat", "Maize", "Cotton", "Groundnut", "Soybean", "Sugarcane", "Millets"]
    ),
    GovernmentScheme(
        scheme_id="kcc",
        scheme_name="Kisan Credit Card (KCC)",
        ministry="Ministry of Agriculture & Farmers Welfare / NABARD",
        target_beneficiary="Farmers, fishermen, self-help groups for agricultural credit",
        benefit_description="Short-term credit up to ₹3 lakh at 4-7% interest rate for crop inputs, allied activities and maintenance.",
        eligibility=["All farmers, tenant farmers, oral lessees", "Self-help groups and joint liability groups", "Valid land documents"],
        documents_required=["Aadhaar card", "Land ownership certificate", "Passport-size photo", "Bank account details"],
        application_process="Apply at any nationalised bank, Regional Rural Bank (RRB), or cooperative bank. NABARD provides refinance support.",
        official_website="https://www.nabard.org/kisan-credit-card",
        helpline="1800-200-0101",
        crops_covered=[]
    ),
    GovernmentScheme(
        scheme_id="pkvy",
        scheme_name="Paramparagat Krishi Vikas Yojana (PKVY) – Organic Farming",
        ministry="Ministry of Agriculture & Farmers Welfare",
        target_beneficiary="Farmers adopting organic and natural farming practices",
        benefit_description="₹50,000 per hectare over 3 years for organic inputs, certification, and marketing support.",
        eligibility=["Farmer clusters of 50 farmers each covering 50 acres", "Commit to 3-year organic conversion period", "Willing to form Farmer Groups"],
        documents_required=["Aadhaar card", "Land ownership records", "Group formation certificate"],
        application_process="Apply via State Agriculture Department. Form a Cluster under PKVY guidelines and apply for certification through PGS-India.",
        official_website="https://pgsindia-ncof.gov.in",
        helpline="011-23382477",
        crops_covered=["All Crops", "Paddy", "Wheat", "Vegetables", "Millets", "Spices"]
    ),
    GovernmentScheme(
        scheme_id="pm-aasha",
        scheme_name="PM-AASHA (Pradhan Mantri Annadata Aay SanraksHan Abhiyan)",
        ministry="Ministry of Agriculture & Farmers Welfare",
        target_beneficiary="Farmers growing oilseeds, pulses, and copra",
        benefit_description="Price support and price deficiency payment when market prices fall below MSP for notified commodities.",
        eligibility=["Farmers of notified commodities", "Registered in State Agriculture portals", "Valid bank and land records"],
        documents_required=["Aadhaar", "Bank account", "Land records", "Crop cultivation certificate"],
        application_process="Register on State Government e-NAM or procurement portal. Eligible when mandi price falls below MSP.",
        official_website="https://enam.gov.in",
        helpline="1800-270-0224",
        crops_covered=["Soybean", "Groundnut", "Sunflower", "Mustard", "Pulses", "Copra"]
    ),
]

_KEYWORD_MAP = {
    "insurance": ["pmfby"],
    "bima": ["pmfby"],
    "crop insurance": ["pmfby"],
    "loan": ["kcc"],
    "credit": ["kcc"],
    "kisan card": ["kcc"],
    "subsidy": ["pkvy", "pm-kisan"],
    "organic": ["pkvy"],
    "natural farming": ["pkvy"],
    "income": ["pm-kisan"],
    "samman": ["pm-kisan"],
    "payment": ["pm-kisan"],
    "msp": ["pm-aasha"],
    "price support": ["pm-aasha"],
    "oilseed": ["pm-aasha"],
}


class GovernmentSchemeService:
    """Service for matching and explaining Indian government agriculture schemes to farmers."""

    def query_schemes(self, request: SchemeQueryRequest) -> SchemeQueryResponse:
        query_l = request.farmer_query.lower()
        detected_lang, _ = language_service.detect_language(request.farmer_query)
        crop_l = (request.crop_type or "").lower()

        matched_ids = set()

        # Keyword matching
        for keyword, ids in _KEYWORD_MAP.items():
            if keyword in query_l:
                matched_ids.update(ids)

        # Crop matching
        if crop_l:
            for scheme in SCHEMES:
                if any(c.lower() in crop_l or crop_l in c.lower() for c in scheme.crops_covered):
                    matched_ids.add(scheme.scheme_id)

        # Collect matched schemes (preserve order)
        matched = [s for s in SCHEMES if s.scheme_id in matched_ids]

        # Default top 3 if nothing matched
        if not matched:
            matched = SCHEMES[:3]

        summary = (
            f"Found {len(matched)} relevant government scheme(s) for your query. "
            f"Key schemes include: {', '.join(s.scheme_name for s in matched[:2])}. "
            f"Contact your nearest Krishi Vigyan Kendra (KVK) or Common Service Centre (CSC) for application assistance."
        )

        return SchemeQueryResponse(
            matched_schemes=matched,
            summary=summary,
            detected_language=detected_lang,
            created_at=datetime.now(timezone.utc)
        )


government_scheme_service = GovernmentSchemeService()
