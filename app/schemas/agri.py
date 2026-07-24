from datetime import datetime
from typing import Any, Dict, List, Optional
from pydantic import BaseModel, Field


# ── Crop Disease Detection ──────────────────────────────────────────────────────

class DiseaseDetectionRequest(BaseModel):
    """Request for AI-powered crop disease detection from an image."""
    image_base64: str = Field(..., description="Base64 encoded crop/plant image (JPEG or PNG)")
    crop_type: Optional[str] = Field(None, description="Crop name to narrow diagnosis (e.g. Paddy, Tomato)")
    language: Optional[str] = Field("en", description="Response language code")


class DiseaseInfo(BaseModel):
    """Details of a detected crop disease."""
    disease_name: str
    severity: str        # Mild, Moderate, Severe
    confidence_pct: float
    symptoms: List[str]
    causes: List[str]
    organic_treatments: List[str]
    chemical_treatments: List[str]
    preventive_measures: List[str]


class DiseaseDetectionResponse(BaseModel):
    """Response from crop disease detection AI."""
    detected_disease: Optional[DiseaseInfo] = None
    is_healthy: bool = False
    general_advice: str
    detected_language: str
    created_at: datetime


# ── Market Price Advisory ───────────────────────────────────────────────────────

class MarketPrice(BaseModel):
    """Current market price for a crop at a mandi."""
    crop_name: str
    mandi_name: str
    state: str
    min_price_inr: float
    max_price_inr: float
    modal_price_inr: float
    unit: str = "Quintal"
    fetched_at: datetime


class MarketPriceRequest(BaseModel):
    """Request for market price lookup."""
    crop_name: str
    state: Optional[str] = Field("Telangana", description="State name for mandi search")
    language: Optional[str] = "en"


class MarketPriceResponse(BaseModel):
    """Market price advisory response."""
    crop_name: str
    prices: List[MarketPrice]
    price_trend: str           # Rising, Falling, Stable
    selling_advice: str
    best_selling_window: str
    detected_language: str


# ── Government Scheme Advisor ───────────────────────────────────────────────────

class GovernmentScheme(BaseModel):
    """Government agriculture scheme details."""
    scheme_id: str
    scheme_name: str
    ministry: str
    target_beneficiary: str
    benefit_description: str
    eligibility: List[str]
    documents_required: List[str]
    application_process: str
    official_website: str
    helpline: Optional[str] = None
    crops_covered: List[str] = Field(default_factory=list)


class SchemeQueryRequest(BaseModel):
    """Request for matching government schemes."""
    farmer_query: str = Field(..., description="Farmer's question about subsidies, schemes, or financial assistance")
    state: Optional[str] = None
    crop_type: Optional[str] = None
    language: Optional[str] = "en"


class SchemeQueryResponse(BaseModel):
    """Government scheme recommendation response."""
    matched_schemes: List[GovernmentScheme]
    summary: str
    detected_language: str
    created_at: datetime


# ── Soil Health Advisory ────────────────────────────────────────────────────────

class SoilHealthRequest(BaseModel):
    """Farmer's soil health query."""
    query_text: str
    crop_type: Optional[str] = None
    soil_type: Optional[str] = Field(None, description="e.g. Black Cotton, Red Loam, Sandy, Alluvial")
    ph_level: Optional[float] = Field(None, ge=0.0, le=14.0, description="Soil pH 0-14")
    language: Optional[str] = "en"


class SoilHealthResponse(BaseModel):
    """Soil health analysis and organic amendment advice."""
    ph_interpretation: Optional[str] = None
    deficiency_detected: List[str] = Field(default_factory=list)
    organic_amendments: List[str] = Field(default_factory=list)
    bio_fertilizer_advice: str
    general_advice: str
    detected_language: str
    created_at: datetime
