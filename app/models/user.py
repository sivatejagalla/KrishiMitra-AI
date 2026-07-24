from datetime import datetime, timezone
from typing import Dict, Optional
from pydantic import BaseModel, Field


class UserModel(BaseModel):
    """User entity data model representation."""
    id: str
    email: str
    hashed_password: str
    full_name: Optional[str] = None
    is_active: bool = True
    is_superuser: bool = False
    created_at: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))


# In-Memory user store for demonstration and fast operational state
class UserStore:
    """Thread-safe in-memory store for user persistence operations."""
    def __init__(self):
        self._users: Dict[str, UserModel] = {}
        self._email_index: Dict[str, str] = {}

    def get_by_id(self, user_id: str) -> Optional[UserModel]:
        return self._users.get(user_id)

    def get_by_email(self, email: str) -> Optional[UserModel]:
        user_id = self._email_index.get(email.lower())
        if user_id:
            return self._users.get(user_id)
        return None

    def create(self, user: UserModel) -> UserModel:
        self._users[user.id] = user
        self._email_index[user.email.lower()] = user.id
        return user


user_store = UserStore()
