from typing import Optional
from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from app.core.exceptions import AuthenticationException
from app.core.security import decode_access_token
from app.models.user import UserModel, user_store
from app.schemas.auth import UserResponse

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/api/v1/auth/login")


async def get_current_user(token: str = Depends(oauth2_scheme)) -> UserResponse:
    """Validate access token and return current authenticated user."""
    payload = decode_access_token(token)
    if not payload or "sub" not in payload:
        raise AuthenticationException("Could not validate credentials")
        
    user_id = payload["sub"]
    user = user_store.get_by_id(user_id)
    if not user:
        raise AuthenticationException("User not found")
        
    if not user.is_active:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Inactive user"
        )
        
    return UserResponse(
        id=user.id,
        email=user.email,
        full_name=user.full_name,
        is_active=user.is_active,
        is_superuser=user.is_superuser,
        created_at=user.created_at
    )
