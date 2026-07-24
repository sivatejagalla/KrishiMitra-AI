"""Root entrypoint for Agrolith-AI Backend deployment across Render, Railway, Docker, and Localhost."""
import os
import sys

# Ensure root directory is in sys.path
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
if BASE_DIR not in sys.path:
    sys.path.insert(0, BASE_DIR)

from app.main import app, create_application  # noqa: E402

application = app
__all__ = ["app", "application", "create_application"]

if __name__ == "__main__":
    import uvicorn
    port = int(os.environ.get("PORT", 8000))
    uvicorn.run("main:app", host="0.0.0.0", port=port, reload=False)
