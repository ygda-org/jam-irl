from starlette.middleware.base import BaseHTTPMiddleware
from starlette.responses import JSONResponse
import traceback
import logging

logger = logging.getLogger(__name__)

class ErrorLoggingMiddleware(BaseHTTPMiddleware):
    async def dispatch(self, request, call_next):
        try:
            response = await call_next(request)
            return response
        except Exception as exc:
            # Log the full exception details
            logger.error(f"Unhandled exception: {exc}")
            logger.error(f"Traceback: {traceback.format_exc()}")
            
            # Return detailed error response
            return JSONResponse(
                status_code=500,
                content={
                    "error": {
                        "type": exc.__class__.__name__,
                        "message": str(exc),
                        "trace": traceback.format_exc()
                    }
                }
            ) 