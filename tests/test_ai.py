def test_ai_query_english(client):
    """Test farmer advisory query in English."""
    payload = {
        "query_text": "What is the best bio-fertilizer for Rice crop?",
        "crop_type": "Rice",
        "target_language": "en",
        "latitude": 17.3850,
        "longitude": 78.4867
    }
    response = client.post("/api/v1/ai/query", json=payload)
    assert response.status_code == 200
    data = response.json()
    assert "session_id" in data
    assert data["detected_language"] == "en"
    assert "response_text" in data
    assert data["weather_info"]["latitude"] == 17.3850
    assert len(data["biological_recommendations"]) > 0


def test_ai_query_multilingual_telugu(client):
    """Test farmer advisory query with Telugu auto-detection."""
    payload = {
        "query_text": "వరి పంటలో పురుగులు మరియు నల్ల తెగులు నివారణకు ఎలాంటి ఆర్గానిక్ ఔషధం వాడాలి?",
        "crop_type": "Paddy"
    }
    response = client.post("/api/v1/ai/query", json=payload)
    assert response.status_code == 200
    data = response.json()
    assert data["detected_language"] == "te"
    assert data["language_name"] == "Telugu (తెలుగు)"
    assert "response_text" in data


def test_stt_and_tts_endpoints(client):
    """Test STT and TTS endpoints."""
    # Test TTS
    tts_payload = {"text": "Namaste farmer", "language": "hi"}
    tts_response = client.post("/api/v1/ai/tts", json=tts_payload)
    assert tts_response.status_code == 200
    assert "audio_base64" in tts_response.json()

    # Test STT
    stt_payload = {"audio_base64": "U3BlZWNoVGVzdA=="}
    stt_response = client.post("/api/v1/ai/stt", json=stt_payload)
    assert stt_response.status_code == 200
    assert "transcript" in stt_response.json()


def test_weather_and_recommendations(client):
    """Test Weather and Bio product recommendation endpoints."""
    # Weather
    weather_res = client.get("/api/v1/ai/weather?lat=16.5062&lon=80.6480")
    assert weather_res.status_code == 200
    assert weather_res.json()["latitude"] == 16.5062

    # Bio Recommendations
    bio_res = client.get("/api/v1/ai/recommendations?crop=Cotton&query=wilt")
    assert bio_res.status_code == 200
    assert len(bio_res.json()) > 0


def test_chat_memory_history(client):
    """Test multi-turn chat history endpoint."""
    session_id = "test-session-12345"
    payload = {
        "query_text": "How much compost per acre?",
        "session_id": session_id
    }
    client.post("/api/v1/ai/query", json=payload)

    history_res = client.get(f"/api/v1/ai/history/{session_id}")
    assert history_res.status_code == 200
    data = history_res.json()
    assert data["session_id"] == session_id
    assert len(data["messages"]) >= 2
