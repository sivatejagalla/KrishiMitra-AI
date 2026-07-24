"""Agrolith-AI Backend Package."""
import os
import sys

# Ensure root directory is in sys.path
ROOT_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
if ROOT_DIR not in sys.path:
    sys.path.insert(0, ROOT_DIR)

from app.main import app, create_application  # noqa: E402

application = app
__version__ = "1.0.0"
__all__ = ["app", "application", "create_application"]
