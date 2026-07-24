from fastapi import APIRouter, Depends, status
from fastapi.security import OAuth2PasswordRequestForm
from app.api.deps import get_current_user
from app.schemas.auth import FirebaseLoginRequest, LoginRequest, Token, UserCreate, UserResponse
from app.services.auth_service import auth_service

router = APIRouter()


@router.post("/register", response_model=UserResponse, status_code=status.HTTP_201_CREATED, summary="Register User")
async def register(user_in: UserCreate):
    """Register a new user with email and password."""
    return auth_service.register_user(user_in)


@router.post("/login", response_model=Token, summary="User Login (JSON)")
async def login(login_data: LoginRequest):
    """Authenticate user with email/password and return JWT access token."""
    user = auth_service.authenticate_user(login_data)
    return auth_service.create_user_token(user.id)


@router.post("/login/access-token", response_model=Token, summary="OAuth2 Form Login (Swagger UI)")
async def login_access_token(form_data: OAuth2PasswordRequestForm = Depends()):
    """OAuth2 compatible token login, for Swagger UI compatibility."""
    login_data = LoginRequest(email=form_data.username, password=form_data.password)
    user = auth_service.authenticate_user(login_data)
    return auth_service.create_user_token(user.id)


@router.post("/firebase-login", response_model=Token, summary="Firebase Token Login")
async def firebase_login(request_data: FirebaseLoginRequest):
    """Authenticate user with Firebase ID token and return JWT access token."""
    user = auth_service.authenticate_firebase_token(request_data.id_token)
    return auth_service.create_user_token(user.id)


@router.get("/me", response_model=UserResponse, summary="Get Current User Profile")
async def get_me(current_user: UserResponse = Depends(get_current_user)):
    """Fetch current authenticated user profile."""
    return current_user
