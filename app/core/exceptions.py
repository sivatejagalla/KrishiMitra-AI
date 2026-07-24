from fastapi import HTTPException, Request, status
from fastapi.responses import JSONResponse
from app.core.logger import logger


class AgrolithException(Exception):
    """Base application exception."""
    def __init__(self, message: str, status_code: int = status.HTTP_400_BAD_REQUEST):
        self.message = message
        self.status_code = status_code
        super().__init__(message)


class AuthenticationException(AgrolithException):
    """Exception raised for authentication errors."""
    def __init__(self, message: str = "Could not validate credentials"):
        super().__init__(message=message, status_code=status.HTTP_401_UNAUTHORIZED)


class NotFoundException(AgrolithException):
    """Exception raised when a requested resource is not found."""
    def __init__(self, message: str = "Resource not found"):
        super().__init__(message=message, status_code=status.HTTP_404_NOT_FOUND)


class UserAlreadyExistsException(AgrolithException):
    """Exception raised when attempting to create a duplicate user."""
    def __init__(self, message: str = "User with this email already exists"):
        super().__init__(message=message, status_code=status.HTTP_409_CONFLICT)


async def agrolith_exception_handler(request: Request, exc: AgrolithException) -> JSONResponse:
    """Global handler for custom Agrolith exceptions."""
    logger.warning(f"Handled Exception [{exc.status_code}]: {exc.message} on {request.url.path}")
    return JSONResponse(
        status_code=exc.status_code,
        content={
            "success": False,
            "error": {
                "type": exc.__class__.__name__,
                "message": exc.message
            }
        }
    )


async def global_exception_handler(request: Request, exc: Exception) -> JSONResponse:
    """Fallback handler for unhandled internal server errors."""
    logger.error(f"Unhandled Exception on {request.url.path}: {str(exc)}", exc_info=True)
    return JSONResponse(
        status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
        content={
            "success": False,
            "error": {
                "type": "InternalServerError",
                "message": "An internal server error occurred. Please try again later."
            }
        }
    )
