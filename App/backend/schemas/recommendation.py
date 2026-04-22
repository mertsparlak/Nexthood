from pydantic import BaseModel
from typing import Optional, List
from datetime import datetime
from uuid import UUID
from schemas.event import EventResponse


class RecommendationResponse(BaseModel):
    id: UUID
    user_id: UUID
    event_id: Optional[UUID] = None
    score: float
    model_version: Optional[str] = None
    created_at: datetime
    event: Optional[EventResponse] = None

    model_config = {"from_attributes": True}


class RecommendationListResponse(BaseModel):
    recommendations: List[RecommendationResponse]
