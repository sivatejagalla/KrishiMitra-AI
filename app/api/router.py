from fastapi import APIRouter
from app.api.endpoints import agri, ai, auth, health, whatsapp

api_router = APIRouter()
api_router.include_router(health.router, tags=["Health"])
api_router.include_router(auth.router, prefix="/auth", tags=["Authentication"])
api_router.include_router(ai.router, prefix="/ai", tags=["AI Advisory & Voice Services"])
api_router.include_router(agri.router, prefix="/agri", tags=["Agriculture Intelligence"])
api_router.include_router(whatsapp.router, prefix="/whatsapp", tags=["WhatsApp Cloud API Assistant"])

