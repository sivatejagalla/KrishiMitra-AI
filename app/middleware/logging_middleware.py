import time
from typing import Callable
from starlette.middleware.base import BaseHTTPMiddleware
from starlette.requests import Request
from starlette.responses import Response
from app.core.logger import logger


class LoggingMiddleware(BaseHTTPMiddleware):
    """HTTP Request/Response logging middleware with execution timing."""

    async def dispatch(self, request: Request, call_next: Callable) -> Response:
        start_time = time.time()
        client_host = request.client.host if request.client else "unknown"
        
        logger.info(f"Incoming Request: {request.method} {request.url.path} from {client_host}")
        
        try:
            response = await call_next(request)
            process_time = (time.time() - start_time) * 1000
            response.headers["X-Process-Time-Ms"] = f"{process_time:.2f}"
            
            logger.info(
                f"Completed Response: {request.method} {request.url.path} "
                f"- Status: {response.status_code} - Duration: {process_time:.2f}ms"
            )
            return response
        except Exception as exc:
            process_time = (time.time() - start_time) * 1000
            logger.error(
                f"Failed Request: {request.method} {request.url.path} "
                f"- Error: {str(exc)} - Duration: {process_time:.2f}ms"
            )
            raise exc
