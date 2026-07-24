import uuid
from datetime import datetime, timezone
from typing import Optional
from fastapi import APIRouter, Query, status
from app.schemas.ai import (
    BioProduct,
    ChatHistoryResponse,
    FarmerQueryRequest,
    FarmerQueryResponse,
    STTRequest,
    STTResponse,
    TTSRequest,
    TTSResponse,
    WeatherInfo,
)
from app.services.bio_recommendation_service import bio_recommendation_service
from app.services.chat_memory_service import chat_memory_service
from app.services.gemini_service import gemini_service
from app.services.language_service import LANGUAGE_MAP, language_service
from app.services.speech_service import speech_service
from app.services.weather_service import weather_service

router = APIRouter()


@router.post("/query", response_model=FarmerQueryResponse, summary="Farmer AI Advisory Query")
async def farmer_ai_query(request: FarmerQueryRequest):
    """Unified endpoint processing farmer voice/text queries, language auto-detection, weather context, and bio recommendations."""
    session_id = request.session_id if request.session_id else str(uuid.uuid4())
    
    # 1. Speech-to-Text if audio is provided
    query_text = request.query_text
    if request.audio_base64 and not query_text:
        query_text, _ = speech_service.speech_to_text_base64(request.audio_base64)
    
    if not query_text:
        query_text = "What bio-fertilizer should I use for my crop?"

    # 2. Language Auto-Detection & Selection
    if request.target_language and request.target_language in LANGUAGE_MAP:
        detected_lang = request.target_language
        lang_name = LANGUAGE_MAP[detected_lang]
    else:
        detected_lang, lang_name = language_service.detect_language(query_text)

    # 3. Weather context if GPS coordinates provided
    weather_info: Optional[WeatherInfo] = None
    if request.latitude is not None and request.longitude is not None:
        weather_info = weather_service.get_weather(request.latitude, request.longitude)

    # 4. Biological Product Recommendations
    bio_recs = bio_recommendation_service.get_recommendations(
        crop_type=request.crop_type,
        query_text=query_text
    )

    # 5. Conversation Memory context
    memory_context = chat_memory_service.build_context_prompt(session_id)
    chat_memory_service.add_message(session_id, role="user", content=query_text, language=detected_lang)

    # 6. Gemini AI Advisory Generation
    advisory_english = gemini_service.generate_agricultural_advisory(
        query=query_text,
        language_name="English",
        crop_type=request.crop_type,
        weather=weather_info,
        recommendations=bio_recs,
        context_memory=memory_context
    )

    # 7. Translation into Target Language if non-English
    if detected_lang != "en":
        final_advisory = language_service.translate_text(advisory_english, source_lang="en", target_lang=detected_lang)
    else:
        final_advisory = advisory_english

    # 8. Record AI response in memory
    chat_memory_service.add_message(session_id, role="assistant", content=final_advisory, language=detected_lang)

    # 9. Text-to-Speech Generation
    audio_base64 = speech_service.text_to_speech_base64(final_advisory, language=detected_lang)

    return FarmerQueryResponse(
        session_id=session_id,
        response_text=final_advisory,
        detected_language=detected_lang,
        language_name=lang_name,
        audio_response_base64=audio_base64,
        weather_info=weather_info,
        biological_recommendations=bio_recs,
        created_at=datetime.now(timezone.utc)
    )


@router.post("/stt", response_model=STTResponse, summary="Speech to Text")
async def speech_to_text(request: STTRequest):
    """Convert input voice audio base64 to text transcript."""
    transcript, detected_lang = speech_service.speech_to_text_base64(request.audio_base64, request.language)
    return STTResponse(transcript=transcript, detected_language=detected_lang)


@router.post("/tts", response_model=TTSResponse, summary="Text to Speech")
async def text_to_speech(request: TTSRequest):
    """Convert input text to base64 audio MP3."""
    audio_base64 = speech_service.text_to_speech_base64(request.text, request.language)
    return TTSResponse(audio_base64=audio_base64, language=request.language)


@router.get("/weather", response_model=WeatherInfo, summary="Get Weather & Advisory")
async def get_weather(
    lat: float = Query(..., description="GPS Latitude"),
    lon: float = Query(..., description="GPS Longitude")
):
    """Get live weather info and farming advisory for given coordinates."""
    return weather_service.get_weather(lat, lon)


@router.get("/recommendations", summary="Biological Product Recommendations")
async def get_recommendations(
    crop: Optional[str] = Query(None, description="Crop name"),
    query: Optional[str] = Query(None, description="Pest, disease, or symptom query")
):
    """Get biological product recommendations for organic farming."""
    return bio_recommendation_service.get_recommendations(crop_type=crop, query_text=query)


@router.get("/history/{session_id}", response_model=ChatHistoryResponse, summary="Get Chat Memory History")
async def get_chat_history(session_id: str):
    """Retrieve multi-turn conversation memory for a chat session."""
    messages = chat_memory_service.get_history(session_id)
    return ChatHistoryResponse(session_id=session_id, messages=messages)
