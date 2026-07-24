import json
from typing import List, Union
from pydantic import field_validator
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """Production application settings and configuration schema."""

    PROJECT_NAME: str = "Agrolith AI Production Backend"
    VERSION: str = "1.0.0"
    API_V1_STR: str = "/api/v1"

    # Security & JWT Settings
    SECRET_KEY: str = "09d25e094faa6ca2556c818166b7a9563b93f7099f6f0f4caa6cf63b88e8d3e7"
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60

    # CORS Origins (Union allows string env vars like "*" or "http://a,http://b" without SettingsError)
    BACKEND_CORS_ORIGINS: Union[List[str], str] = ["*"]

    # Firebase Credentials Path
    FIREBASE_CREDENTIALS: str = "serviceAccountKey.json"

    # Database URL
    DATABASE_URL: str = "sqlite:///./agrolith.db"

    # AI & External APIs Config
    GEMINI_API_KEY: str = "MOCK_GEMINI_KEY"
    OPENWEATHER_API_KEY: str = ""
    DEFAULT_LANGUAGE: str = "en"
    SUPPORTED_LANGUAGES: Union[List[str], str] = ["en", "hi", "te", "ta", "mr"]

    # WhatsApp Cloud API Settings
    WHATSAPP_TOKEN: str = ""
    PHONE_NUMBER_ID: str = ""
    VERIFY_TOKEN: str = "agrolith_whatsapp_verify_token_2026"

    @field_validator("BACKEND_CORS_ORIGINS", "SUPPORTED_LANGUAGES", mode="before")
    @classmethod
    def assemble_list(cls, v: Union[str, List[str]]) -> List[str]:
        if isinstance(v, str):
            v_str = v.strip()
            if v_str.startswith("[") and v_str.endswith("]"):
                try:
                    return json.loads(v_str)
                except Exception:
                    pass
            return [i.strip() for i in v_str.split(",") if i.strip()]
        return v

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        case_sensitive=True,
        extra="ignore"
    )


settings = Settings()
