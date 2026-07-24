import base64
from datetime import datetime, timezone
from typing import Optional
from fastapi import APIRouter, Query
from app.schemas.agri import (
    DiseaseDetectionRequest,
    DiseaseDetectionResponse,
    MarketPriceRequest,
    MarketPriceResponse,
    SchemeQueryRequest,
    SchemeQueryResponse,
    SoilHealthRequest,
    SoilHealthResponse,
)
from app.services.crop_disease_service import crop_disease_service
from app.services.government_scheme_service import government_scheme_service
from app.services.market_price_service import market_price_service
from app.services.soil_health_service import soil_health_service

router = APIRouter()


@router.post("/disease-detection", response_model=DiseaseDetectionResponse, summary="Crop Disease Detection (AI Vision)")
async def detect_crop_disease(request: DiseaseDetectionRequest):
    """Analyse a base64-encoded crop image with Gemini Vision AI and return disease diagnosis + organic treatment plan."""
    return crop_disease_service.analyze_image(request)


@router.post("/market-price", response_model=MarketPriceResponse, summary="Mandi Market Price Advisory")
async def get_market_price(request: MarketPriceRequest):
    """Get current mandi market prices and selling advisory for a given crop and state."""
    return market_price_service.get_prices(
        crop_name=request.crop_name,
        state=request.state,
        language=request.language or "en"
    )


@router.post("/schemes", response_model=SchemeQueryResponse, summary="Government Scheme Advisor")
async def query_government_schemes(request: SchemeQueryRequest):
    """Match relevant Indian government agriculture schemes based on farmer's query (subsidies, insurance, loans)."""
    return government_scheme_service.query_schemes(request)


@router.post("/soil-health", response_model=SoilHealthResponse, summary="Soil Health Advisory")
async def analyze_soil_health(request: SoilHealthRequest):
    """Provide soil health analysis, pH interpretation, deficiency detection, and organic amendment recommendations."""
    return soil_health_service.analyze(request)
