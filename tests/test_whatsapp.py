import pytest
from fastapi.testclient import TestClient
from app.main import app
from app.core.config import settings
from app.services.whatsapp_service import whatsapp_service

client = TestClient(app)


def test_whatsapp_webhook_verification_success():
    """Test successful GET webhook verification by Meta Cloud API."""
    params = {
        "hub.mode": "subscribe",
        "hub.verify_token": settings.VERIFY_TOKEN,
        "hub.challenge": "1234567890_challenge_str",
    }
    response = client.get("/api/v1/whatsapp/webhook", params=params)
    assert response.status_code == 200
    assert response.text == "1234567890_challenge_str"


def test_whatsapp_webhook_verification_failure():
    """Test GET webhook verification with invalid token returns 403."""
    params = {
        "hub.mode": "subscribe",
        "hub.verify_token": "INVALID_TOKEN_123",
        "hub.challenge": "1234567890_challenge_str",
    }
    response = client.get("/api/v1/whatsapp/webhook", params=params)
    assert response.status_code == 403


def test_whatsapp_post_text_message():
    """Test POST webhook receiver with an incoming WhatsApp text message."""
    payload = {
        "object": "whatsapp_business_account",
        "entry": [
            {
                "id": "100000000000001",
                "changes": [
                    {
                        "field": "messages",
                        "value": {
                            "messaging_product": "whatsapp",
                            "metadata": {
                                "display_phone_number": "15555555555",
                                "phone_number_id": "10987654321",
                            },
                            "contacts": [{"profile": {"name": "Farmer Joe"}, "wa_id": "919876543210"}],
                            "messages": [
                                {
                                    "from": "919876543210",
                                    "id": "wamid.HBgLOTE5ODc2NTQzMjEw",
                                    "timestamp": "1700000000",
                                    "text": {"body": "What is the market price of rice in mandi?"},
                                    "type": "text",
                                }
                            ],
                        },
                    }
                ],
            }
        ],
    }
    response = client.post("/api/v1/whatsapp/webhook", json=payload)
    assert response.status_code == 200
    assert response.json()["status"] == "ok"


def test_whatsapp_post_image_message():
    """Test POST webhook receiver with an incoming WhatsApp crop image."""
    payload = {
        "object": "whatsapp_business_account",
        "entry": [
            {
                "id": "100000000000001",
                "changes": [
                    {
                        "field": "messages",
                        "value": {
                            "messaging_product": "whatsapp",
                            "metadata": {"phone_number_id": "10987654321"},
                            "messages": [
                                {
                                    "from": "919876543210",
                                    "id": "wamid.img_001",
                                    "timestamp": "1700000000",
                                    "type": "image",
                                    "image": {
                                        "caption": "Yellow leaf spots in paddy field",
                                        "mime_type": "image/jpeg",
                                        "sha256": "abcdef1234567890",
                                        "id": "media_id_image_123",
                                    },
                                }
                            ],
                        },
                    }
                ],
            }
        ],
    }
    response = client.post("/api/v1/whatsapp/webhook", json=payload)
    assert response.status_code == 200
    assert response.json()["status"] == "ok"


def test_whatsapp_post_voice_message():
    """Test POST webhook receiver with an incoming WhatsApp voice note."""
    payload = {
        "object": "whatsapp_business_account",
        "entry": [
            {
                "id": "100000000000001",
                "changes": [
                    {
                        "field": "messages",
                        "value": {
                            "messaging_product": "whatsapp",
                            "metadata": {"phone_number_id": "10987654321"},
                            "messages": [
                                {
                                    "from": "919876543210",
                                    "id": "wamid.voice_001",
                                    "timestamp": "1700000000",
                                    "type": "voice",
                                    "voice": {
                                        "mime_type": "audio/ogg; codecs=opus",
                                        "id": "media_id_voice_456",
                                    },
                                }
                            ],
                        },
                    }
                ],
            }
        ],
    }
    response = client.post("/api/v1/whatsapp/webhook", json=payload)
    assert response.status_code == 200
    assert response.json()["status"] == "ok"


@pytest.mark.asyncio
async def test_whatsapp_service_intent_routing():
    """Test WhatsAppService text message intent routing logic."""
    sender = "919876543210"
    session_id = f"whatsapp_{sender}"

    # Weather intent
    weather_reply = await whatsapp_service._handle_text_message("What is the weather today?", sender, session_id)
    assert "Weather" in weather_reply or "Temperature" in weather_reply

    # Mandi Price intent
    price_reply = await whatsapp_service._handle_text_message("Mandi rate for wheat", sender, session_id)
    assert "Mandi" in price_reply or "Market" in price_reply or "Price" in price_reply

    # Scheme intent
    scheme_reply = await whatsapp_service._handle_text_message("PM Kisan scheme details", sender, session_id)
    assert "Scheme" in scheme_reply or "PM-KISAN" in scheme_reply

    # Soil Health intent
    soil_reply = await whatsapp_service._handle_text_message("Soil pH and urea fertilizer advice", sender, session_id)
    assert "Soil" in soil_reply or "pH" in soil_reply
