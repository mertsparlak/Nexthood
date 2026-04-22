from pydantic import BaseModel, Field
from typing import Optional, List
from datetime import datetime
from uuid import UUID


class EventCreate(BaseModel):
    title: str = Field(..., min_length=3, max_length=255)
    description: Optional[str] = None
    category: str = Field(..., max_length=100)
    start_date: datetime
    end_date: Optional[datetime] = None
    location_name: Optional[str] = None
    lat: Optional[float] = Field(None, ge=-90, le=90)
    lng: Optional[float] = Field(None, ge=-180, le=180)
    image_url: Optional[str] = None
    is_free: bool = True
    event_url: Optional[str] = None


class EventUpdate(BaseModel):
    title: Optional[str] = Field(None, min_length=3, max_length=255)
    description: Optional[str] = None
    category: Optional[str] = None
    start_date: Optional[datetime] = None
    end_date: Optional[datetime] = None
    location_name: Optional[str] = None
    lat: Optional[float] = Field(None, ge=-90, le=90)
    lng: Optional[float] = Field(None, ge=-180, le=180)
    image_url: Optional[str] = None
    is_free: Optional[bool] = None


class EventResponse(BaseModel):
    id: UUID
    creator_id: Optional[UUID] = None
    title: str
    description: Optional[str] = None
    image_url: Optional[str] = None
    is_free: bool
    start_date: datetime
    end_date: Optional[datetime] = None
    location_name: Optional[str] = None
    category: str
    event_url: Optional[str] = None
    status: str
    created_at: datetime
    updated_at: datetime

    model_config = {"from_attributes": True}


class EventListResponse(BaseModel):
    events: List[EventResponse]
    total: int
    offset: int
    limit: int


class RSVPRequest(BaseModel):
    status: str = Field(..., pattern=r"^(attending|interested|declined)$")


class RSVPResponse(BaseModel):
    id: UUID
    user_id: UUID
    event_id: UUID
    status: str
    created_at: datetime

    model_config = {"from_attributes": True}


class InteractionLogRequest(BaseModel):
    action: str = Field(..., pattern=r"^(view|click|dismiss)$")
