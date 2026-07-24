import os
import sys
from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse

# Ensure root directory is in sys.path
ROOT_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
if ROOT_DIR not in sys.path:
    sys.path.insert(0, ROOT_DIR)

from app.api.router import api_router  # noqa: E402
from app.api.endpoints import whatsapp  # noqa: E402
from app.core.config import settings  # noqa: E402
from app.core.exceptions import (  # noqa: E402
    AgrolithException,
    global_exception_handler,
    agrolith_exception_handler,
)
from app.core.firebase import initialize_firebase  # noqa: E402
from app.core.logger import logger  # noqa: E402
from app.middleware.logging_middleware import LoggingMiddleware  # noqa: E402


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Application startup and shutdown lifespan context manager."""
    logger.info("Initializing Agrolith-AI Backend Services...")
    initialize_firebase()

    logger.info("==================================================")
    logger.info("REGISTERED FASTAPI ROUTES AUDIT")
    logger.info("==================================================")
    for route in app.routes:
        methods = getattr(route, "methods", None)
        path = getattr(route, "path", None)
        name = getattr(route, "name", None)
        logger.info(f"Route -> Path: '{path}' | Methods: {methods} | Name: '{name}'")
    logger.info("==================================================")

    yield
    logger.info("Shutting down Agrolith-AI Backend Services...")


def create_application() -> FastAPI:
    """Build and configure the FastAPI application instance."""
    application = FastAPI(
        title=settings.PROJECT_NAME,
        version=settings.VERSION,
        openapi_url=f"{settings.API_V1_STR}/openapi.json",
        docs_url="/docs",
        redoc_url="/redoc",
        lifespan=lifespan,
    )

    # CORS Middleware
    if settings.BACKEND_CORS_ORIGINS:
        application.add_middleware(
            CORSMiddleware,
            allow_origins=[str(origin) for origin in settings.BACKEND_CORS_ORIGINS],
            allow_credentials=True,
            allow_methods=["*"],
            allow_headers=["*"],
        )

    # Logging Middleware
    application.add_middleware(LoggingMiddleware)

    # Global Exception Handlers
    application.add_exception_handler(AgrolithException, agrolith_exception_handler)
    application.add_exception_handler(Exception, global_exception_handler)

    # Include Main API Router (/api/v1)
    application.include_router(api_router, prefix=settings.API_V1_STR)

    # Direct Webhook Routers for flexible URL access (include_in_schema=False avoids duplicate OpenAPI IDs)
    application.include_router(whatsapp.router, prefix="/whatsapp", include_in_schema=False)
    application.include_router(whatsapp.router, include_in_schema=False)

    # OpenAPI schema direct endpoint for root /openapi.json
    @application.get("/openapi.json", include_in_schema=False)
    async def openapi_json_root():
        return application.openapi()

    # Root and Health check endpoints
    @application.get("/", tags=["Health"])
    @application.get("/health", tags=["Health"])
    @application.get(f"{settings.API_V1_STR}", tags=["Health"])
    @application.get(f"{settings.API_V1_STR}/", tags=["Health"])
    async def root_health_check():
        return {"status": "healthy", "project_name": settings.PROJECT_NAME, "version": settings.VERSION}

    return application


app = create_application()
application = app
