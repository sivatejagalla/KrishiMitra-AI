from datetime import datetime, timezone
from typing import Any, Dict, List, Optional
from pydantic import BaseModel, ConfigDict, Field


class WeatherInfo(BaseModel):
    """Weather information payload."""
    latitude: float
    longitude: float
    temperature_c: float
    humidity_percent: float
    condition: str
    wind_speed_kmh: Optional[float] = None
    precipitation_mm: Optional[float] = None
    advice: Optional[str] = None


class BioProduct(BaseModel):
    """Biological agriculture product recommendation model."""
    id: str
    product_name: str
    category: str  # Bio-fertilizer, Bio-pesticide, Bio-fungicide, Organic Amendment
    target_crops: List[str]
    target_pest_disease: str
    composition: str
    dosage: str
    application_method: str
    benefits: List[str]


class FarmerQueryRequest(BaseModel):
    """Request payload for AI farming advisor query."""
    query_text: Optional[str] = Field(None, description="Text question asked by the farmer")
    audio_base64: Optional[str] = Field(None, description="Base64 encoded audio question")
    latitude: Optional[float] = Field(None, description="GPS Latitude")
    longitude: Optional[float] = Field(None, description="GPS Longitude")
    crop_type: Optional[str] = Field(None, description="Crop name e.g. Rice, Wheat, Cotton")
    target_language: Optional[str] = Field(None, description="Language code e.g. hi, te, ta, mr, en")
    session_id: Optional[str] = Field(None, description="Session ID for chat memory context")


class FarmerQueryResponse(BaseModel):
    """Response payload from AI farming advisor."""
    session_id: str
    response_text: str
    detected_language: str
    language_name: str
    audio_response_base64: Optional[str] = None
    weather_info: Optional[WeatherInfo] = None
    biological_recommendations: List[BioProduct] = Field(default_factory=list)
    created_at: datetime


class STTRequest(BaseModel):
    """Speech-to-text request."""
    audio_base64: str
    language: Optional[str] = None


class STTResponse(BaseModel):
    """Speech-to-text response."""
    transcript: str
    detected_language: str


class TTSRequest(BaseModel):
    """Text-to-speech request."""
    text: str
    language: str = "en"


class TTSResponse(BaseModel):
    """Text-to-speech response."""
    audio_base64: str
    language: str


class ChatMessage(BaseModel):
    """Individual chat message item."""
    role: str  # "user" or "assistant"
    content: str
    language: str
    timestamp: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))


class ChatHistoryResponse(BaseModel):
    """Chat history for a given session."""
    session_id: str
    messages: List[ChatMessage]
