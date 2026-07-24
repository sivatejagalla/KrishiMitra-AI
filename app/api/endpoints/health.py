from datetime import datetime, timezone
from fastapi import APIRouter
from app.core.config import settings
from app.schemas.auth import HealthCheckResponse

router = APIRouter()


@router.get("/health", response_model=HealthCheckResponse, summary="Health Check")
async def health_check():
    """Detailed health check endpoint returning system status and metadata."""
    return HealthCheckResponse(
        status="healthy",
        project_name=settings.PROJECT_NAME,
        version=settings.VERSION,
        environment="development",
        timestamp=datetime.now(timezone.utc)
    )
