import uuid
from datetime import datetime, timezone
from typing import Optional
from app.core.exceptions import AuthenticationException, UserAlreadyExistsException
from app.core.firebase import verify_firebase_id_token
from app.core.logger import logger
from app.core.security import create_access_token, get_password_hash, verify_password
from app.models.user import UserModel, user_store
from app.schemas.auth import LoginRequest, Token, UserCreate, UserResponse


class AuthService:
    """Service handling user registration, authentication, and JWT token issuance."""

    def register_user(self, user_in: UserCreate) -> UserResponse:
        """Register a new user in the system."""
        existing_user = user_store.get_by_email(user_in.email)
        if existing_user:
            raise UserAlreadyExistsException(f"User with email {user_in.email} already exists")

        hashed_password = get_password_hash(user_in.password)
        user_id = str(uuid.uuid4())
        
        user = UserModel(
            id=user_id,
            email=user_in.email.lower(),
            hashed_password=hashed_password,
            full_name=user_in.full_name,
            is_active=True,
            created_at=datetime.now(timezone.utc)
        )
        
        saved_user = user_store.create(user)
        logger.info(f"Registered new user: {saved_user.email} (ID: {saved_user.id})")
        
        return UserResponse(
            id=saved_user.id,
            email=saved_user.email,
            full_name=saved_user.full_name,
            is_active=saved_user.is_active,
            is_superuser=saved_user.is_superuser,
            created_at=saved_user.created_at
        )

    def authenticate_user(self, login_data: LoginRequest) -> UserResponse:
        """Authenticate user credentials and return user profile."""
        user = user_store.get_by_email(login_data.email)
        if not user:
            raise AuthenticationException("Invalid email or password")
        
        if not verify_password(login_data.password, user.hashed_password):
            raise AuthenticationException("Invalid email or password")
            
        if not user.is_active:
            raise AuthenticationException("User account is inactive")
            
        return UserResponse(
            id=user.id,
            email=user.email,
            full_name=user.full_name,
            is_active=user.is_active,
            is_superuser=user.is_superuser,
            created_at=user.created_at
        )

    def authenticate_firebase_token(self, id_token: str) -> UserResponse:
        """Authenticate a Firebase ID token and return/provision user profile."""
        decoded = verify_firebase_id_token(id_token)
        if not decoded or "email" not in decoded:
            raise AuthenticationException("Invalid or expired Firebase ID token")
            
        email = decoded["email"].lower()
        user = user_store.get_by_email(email)
        
        if not user:
            user_id = str(uuid.uuid4())
            user = UserModel(
                id=user_id,
                email=email,
                hashed_password=get_password_hash(str(uuid.uuid4())),
                full_name=decoded.get("name", "Firebase User"),
                is_active=True,
                created_at=datetime.now(timezone.utc)
            )
            user_store.create(user)
            logger.info(f"Provisioned new user from Firebase Auth: {email}")

        return UserResponse(
            id=user.id,
            email=user.email,
            full_name=user.full_name,
            is_active=user.is_active,
            is_superuser=user.is_superuser,
            created_at=user.created_at
        )

    def create_user_token(self, user_id: str) -> Token:
        """Generate JWT access token for user."""
        access_token = create_access_token(subject=user_id)
        return Token(access_token=access_token, token_type="bearer")


auth_service = AuthService()
