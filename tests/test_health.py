from app.core.config import settings


def test_health_endpoint(client):
    """Test that health check endpoint returns 200 OK and valid status."""
    response = client.get("/api/v1/health")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "healthy"
    assert data["project_name"] == settings.PROJECT_NAME
    assert "timestamp" in data
