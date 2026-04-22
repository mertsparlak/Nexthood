from pydantic import BaseModel, EmailStr, Field
from typing import Optional, List
from datetime import datetime
from uuid import UUID


class UserResponse(BaseModel):
    id: UUID
    username: Optional[str] = None
    full_name: str
    email: EmailStr
    profile_picture_url: Optional[str] = None
    role: str
    is_active: bool
    created_at: datetime
    updated_at: datetime

    model_config = {"from_attributes": True}


class UserPublicResponse(BaseModel):
    """Public profile — no email or sensitive data."""
    id: UUID
    username: Optional[str] = None
    full_name: str
    profile_picture_url: Optional[str] = None

    model_config = {"from_attributes": True}


class UserUpdate(BaseModel):
    full_name: Optional[str] = Field(None, min_length=2, max_length=150)
    username: Optional[str] = Field(None, min_length=3, max_length=50, pattern=r"^[a-zA-Z0-9_]+$")
    profile_picture_url: Optional[str] = None


class InterestUpdate(BaseModel):
    interests: List[str] = Field(..., min_length=1, max_length=20)
