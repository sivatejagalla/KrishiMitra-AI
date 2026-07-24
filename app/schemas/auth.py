from datetime import datetime
from typing import Optional
from pydantic import BaseModel, ConfigDict, EmailStr, Field


class Token(BaseModel):
    """Access token response schema."""
    access_token: str
    token_type: str = "bearer"
    expires_in: int = 3600


class TokenPayload(BaseModel):
    """JWT token payload schema."""
    sub: Optional[str] = None
    exp: Optional[datetime] = None


class UserCreate(BaseModel):
    """User registration request schema."""
    email: EmailStr
    password: str = Field(..., min_length=6, description="Password must be at least 6 characters")
    full_name: Optional[str] = Field(None, max_length=100)


class LoginRequest(BaseModel):
    """User login request schema."""
    email: EmailStr
    password: str


class FirebaseLoginRequest(BaseModel):
    """Firebase ID token login request schema."""
    id_token: str


class UserResponse(BaseModel):
    """User response schema."""
    id: str
    email: EmailStr
    full_name: Optional[str] = None
    is_active: bool = True
    is_superuser: bool = False
    created_at: Optional[datetime] = None

    model_config = ConfigDict(from_attributes=True)


class HealthCheckResponse(BaseModel):
    """Health check endpoint response schema."""
    status: str = "healthy"
    project_name: str
    version: str
    environment: str = "development"
    timestamp: datetime
