from fastapi.testclient import TestClient
from app.main import app
from app.core.config import settings

client = TestClient(app)


def test_root_endpoint():
    """Verify GET / returns 200 OK and healthy status."""
    response = client.get("/")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "healthy"
    assert data["project_name"] == settings.PROJECT_NAME


def test_health_alias_endpoint():
    """Verify GET /health returns 200 OK and healthy status."""
    response = client.get("/health")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "healthy"


def test_api_v1_health_endpoint():
    """Verify GET /api/v1/health returns 200 OK and detailed status."""
    response = client.get("/api/v1/health")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "healthy"


def test_swagger_docs_endpoint():
    """Verify GET /docs returns 200 OK with Swagger UI HTML."""
    response = client.get("/docs")
    assert response.status_code == 200
    assert "<html" in response.text.lower() or "swagger" in response.text.lower()


def test_openapi_schema_endpoint():
    """Verify GET /api/v1/openapi.json returns 200 OK with OpenAPI schema."""
    response = client.get(f"{settings.API_V1_STR}/openapi.json")
    assert response.status_code == 200
    data = response.json()
    assert "openapi" in data


def test_root_openapi_json_endpoint():
    """Verify GET /openapi.json returns 200 OK (following redirect) with OpenAPI schema."""
    response = client.get("/openapi.json", follow_redirects=True)
    assert response.status_code == 200
    data = response.json()
    assert "openapi" in data



def test_whatsapp_webhook_verification_endpoints():
    """Verify GET /api/v1/whatsapp/webhook, /whatsapp/webhook, and /webhook respond to Meta verification challenge."""
    params = {
        "hub.mode": "subscribe",
        "hub.verify_token": settings.VERIFY_TOKEN,
        "hub.challenge": "meta_test_challenge_999",
    }

    endpoints = [
        "/api/v1/whatsapp/webhook",
        "/whatsapp/webhook",
        "/webhook",
    ]

    for ep in endpoints:
        response = client.get(ep, params=params)
        assert response.status_code == 200, f"Failed on endpoint {ep}"
        assert response.text == "meta_test_challenge_999", f"Challenge mismatch on {ep}"
        assert response.headers["content-type"].startswith("text/plain")
