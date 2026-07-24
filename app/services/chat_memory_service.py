import uuid
from datetime import datetime, timezone
from typing import Any, Dict, List, Optional
from app.core.firebase import get_firebase_app
from app.core.logger import logger
from app.schemas.ai import ChatMessage


class ChatMemoryService:
    """Service managing conversation memory and multi-turn chat history (Firebase + In-Memory fallback)."""

    def __init__(self):
        self._memory_store: Dict[str, List[ChatMessage]] = {}

    def get_history(self, session_id: str) -> List[ChatMessage]:
        """Fetch chat history for a session."""
        # Try fetching from Firebase Firestore if initialized
        if get_firebase_app():
            try:
                from firebase_admin import firestore
                db = firestore.client()
                docs = db.collection("chat_sessions").document(session_id).collection("messages").order_by("timestamp").stream()
                messages = []
                for doc in docs:
                    data = doc.to_dict()
                    messages.append(ChatMessage(
                        role=data.get("role", "user"),
                        content=data.get("content", ""),
                        language=data.get("language", "en"),
                        timestamp=datetime.fromisoformat(data.get("timestamp")) if isinstance(data.get("timestamp"), str) else datetime.now(timezone.utc)
                    ))
                if messages:
                    return messages
            except Exception as e:
                logger.warning(f"Error reading chat history from Firebase for session {session_id}: {e}")

        # Fallback to local memory
        return self._memory_store.get(session_id, [])

    def add_message(
        self,
        session_id: str,
        role: Any,
        content: Optional[str] = None,
        language: str = "en",
    ) -> ChatMessage:
        """Append a message to the session chat history."""
        if isinstance(role, ChatMessage):
            msg = role
        else:
            msg = ChatMessage(
                role=role,
                content=content or "",
                language=language,
                timestamp=datetime.now(timezone.utc),
            )

        if session_id not in self._memory_store:
            self._memory_store[session_id] = []
        self._memory_store[session_id].append(msg)

        # Store in Firebase Firestore if initialized
        if get_firebase_app():
            try:
                from firebase_admin import firestore
                db = firestore.client()
                db.collection("chat_sessions").document(session_id).collection("messages").add({
                    "role": msg.role,
                    "content": msg.content,
                    "language": msg.language,
                    "timestamp": msg.timestamp.isoformat()
                })
            except Exception as e:
                logger.warning(f"Error persisting chat message to Firebase for session {session_id}: {e}")

        return msg

    def build_context_prompt(self, session_id: str, max_turns: int = 4) -> str:
        """Construct context string from recent chat memory."""
        history = self.get_history(session_id)
        if not history:
            return ""

        recent = history[-max_turns:]
        context_str = "\nPrevious Conversation Context:\n"
        for msg in recent:
            context_str += f"{msg.role.capitalize()}: {msg.content}\n"
        return context_str


chat_memory_service = ChatMemoryService()
