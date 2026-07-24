import os
from typing import Any, Dict, Optional
from app.core.config import settings
from app.core.logger import logger

_firebase_app = None


def get_firebase_app():
    """Return the current Firebase app instance (evaluated at call time, not import time)."""
    return _firebase_app


def initialize_firebase() -> None:
    """Initialize Firebase Admin SDK if credentials exist."""
    global _firebase_app
    cred_path = settings.FIREBASE_CREDENTIALS
    
    if os.path.exists(cred_path):
        try:
            import firebase_admin
            from firebase_admin import credentials
            
            if not firebase_admin._apps:
                cred = credentials.Certificate(cred_path)
                _firebase_app = firebase_admin.initialize_app(cred)
                logger.info("Firebase Admin SDK initialized successfully.")
        except Exception as e:
            logger.error(f"Failed to initialize Firebase Admin SDK: {e}")
    else:
        logger.info(f"Firebase credentials file '{cred_path}' not found. Firebase features operating in fallback mode.")


def verify_firebase_id_token(id_token: str) -> Optional[Dict[str, Any]]:
    """Verify Firebase ID token, returning decoded payload or None."""
    try:
        import firebase_admin
        from firebase_admin import auth
        
        if firebase_admin._apps:
            decoded_token = auth.verify_id_token(id_token)
            return decoded_token
        else:
            logger.warning("Firebase app not initialized. Token verification fallback.")
            return {"uid": f"mock_uid_{id_token[:8]}", "email": "mock_user@agrolith.ai"}
    except Exception as e:
        logger.error(f"Error verifying Firebase ID token: {e}")
        return None
