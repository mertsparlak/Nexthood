from pydantic import BaseModel, EmailStr, Field
from typing import Optional, List
from datetime import datetime
from uuid import UUID

# --- User Schemas ---
class UserBase(BaseModel):
    email: EmailStr
    full_name: str

class UserCreate(UserBase):
    password: str

class UserUpdate(BaseModel):
    full_name: Optional[str] = None
    is_active: Optional[bool] = None

class User(UserBase):
    id: UUID
    is_active: bool
    role: str
    last_password_change: Optional[datetime]
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True

# --- ScrapedSource Schemas ---
class ScrapedSourceBase(BaseModel):
    source_name: str
    url: str
    is_active: bool = True
    scrape_interval_hours: int = 24

class ScrapedSourceCreate(ScrapedSourceBase):
    pass

class ScrapedSource(ScrapedSourceBase):
    id: UUID
    last_scraped_at: Optional[datetime]
    created_at: datetime

    class Config:
        from_attributes = True

# --- Event Schemas ---
class EventBase(BaseModel):
    title: str
    description: Optional[str] = None
    start_date: datetime
    end_date: Optional[datetime] = None
    location_name: Optional[str] = None
    category: str
    event_url: Optional[str] = None
    status: str = "active"

class EventCreate(EventBase):
    source_id: Optional[UUID] = None
    # Location coordinates would be handled by geocoding backend logic, not directly inputted by user usually

class Event(EventBase):
    id: UUID
    source_id: Optional[UUID]
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True

# --- Token Schemas ---
class Token(BaseModel):
    access_token: str
    token_type: str

class TokenData(BaseModel):
    email: Optional[str] = None

class PasswordChangeRequest(BaseModel):
    old_password: str
    new_password: str
