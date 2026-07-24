import base64


def test_disease_detection_paddy(client):
    """Test disease detection for paddy crop (fallback KB mode)."""
    # Create a minimal valid base64 JPEG header
    fake_image = base64.b64encode(b"fake-image-bytes").decode()
    payload = {
        "image_base64": fake_image,
        "crop_type": "Paddy",
        "language": "en"
    }
    response = client.post("/api/v1/agri/disease-detection", json=payload)
    assert response.status_code == 200
    data = response.json()
    assert "detected_disease" in data
    assert "general_advice" in data
    assert data["detected_language"] == "en"


def test_market_price_rice(client):
    """Test market price lookup for Rice."""
    payload = {"crop_name": "Rice", "state": "Telangana", "language": "en"}
    response = client.post("/api/v1/agri/market-price", json=payload)
    assert response.status_code == 200
    data = response.json()
    assert data["crop_name"] == "Rice"
    assert len(data["prices"]) > 0
    assert "price_trend" in data
    assert "selling_advice" in data


def test_government_schemes_insurance(client):
    """Test government scheme advisor for crop insurance query."""
    payload = {"farmer_query": "How to get crop insurance for my paddy field?", "crop_type": "Paddy"}
    response = client.post("/api/v1/agri/schemes", json=payload)
    assert response.status_code == 200
    data = response.json()
    assert len(data["matched_schemes"]) > 0
    scheme_ids = [s["scheme_id"] for s in data["matched_schemes"]]
    assert "pmfby" in scheme_ids


def test_government_schemes_pm_kisan(client):
    """Test government scheme for PM-KISAN income support query."""
    payload = {"farmer_query": "I want information about farmer income support and direct payment scheme"}
    response = client.post("/api/v1/agri/schemes", json=payload)
    assert response.status_code == 200
    data = response.json()
    assert len(data["matched_schemes"]) > 0


def test_soil_health_nitrogen_deficiency(client):
    """Test soil health analysis for nitrogen deficiency symptoms."""
    payload = {
        "query_text": "My paddy leaves are turning yellow, looks like nitrogen deficiency",
        "crop_type": "Paddy",
        "ph_level": 6.2
    }
    response = client.post("/api/v1/agri/soil-health", json=payload)
    assert response.status_code == 200
    data = response.json()
    assert "ph_interpretation" in data
    assert len(data["deficiency_detected"]) > 0
    assert "bio_fertilizer_advice" in data


def test_soil_health_alkaline_ph(client):
    """Test soil health for alkaline soil advisory."""
    payload = {
        "query_text": "My cotton field has high pH soil and leaves look pale",
        "crop_type": "Cotton",
        "soil_type": "Black Cotton",
        "ph_level": 8.2
    }
    response = client.post("/api/v1/agri/soil-health", json=payload)
    assert response.status_code == 200
    data = response.json()
    assert "alkaline" in data["ph_interpretation"].lower()
    assert len(data["organic_amendments"]) > 0
