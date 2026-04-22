from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession
from typing import Optional
from uuid import UUID

from core.dependencies import get_db, get_current_active_user
from services.event_service import EventService
from schemas.event import (
    EventCreate, EventUpdate, EventResponse, EventListResponse,
    RSVPRequest, RSVPResponse, InteractionLogRequest,
)
import models

router = APIRouter(prefix="/events", tags=["Events"])


@router.get("", response_model=EventListResponse)
async def list_events(
    category: Optional[str] = Query(None),
    search: Optional[str] = Query(None),
    lat: Optional[float] = Query(None, ge=-90, le=90),
    lng: Optional[float] = Query(None, ge=-180, le=180),
    radius_km: float = Query(10.0, ge=0.1, le=100),
    offset: int = Query(0, ge=0),
    limit: int = Query(20, ge=1, le=100),
    db: AsyncSession = Depends(get_db),
):
    """List events with optional filtering by category, search, and location."""
    service = EventService(db)
    result = await service.list_events(
        category=category,
        search_query=search,
        lat=lat,
        lng=lng,
        radius_km=radius_km,
        offset=offset,
        limit=limit,
    )
    return result


@router.get("/{event_id}")
async def get_event(event_id: UUID, db: AsyncSession = Depends(get_db)):
    """Get a single event by ID with RSVP counts."""
    service = EventService(db)
    return await service.get_event(event_id)


@router.post("", response_model=EventResponse, status_code=201)
async def create_event(
    data: EventCreate,
    current_user: models.User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db),
):
    """Create a new event (authenticated)."""
    service = EventService(db)
    event = await service.create_event(
        current_user,
        **data.model_dump(),
    )
    return event


@router.patch("/{event_id}", response_model=EventResponse)
async def update_event(
    event_id: UUID,
    data: EventUpdate,
    current_user: models.User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db),
):
    """Update an event (creator or admin only)."""
    service = EventService(db)
    return await service.update_event(
        event_id,
        current_user,
        **data.model_dump(exclude_unset=True),
    )


@router.delete("/{event_id}")
async def delete_event(
    event_id: UUID,
    current_user: models.User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db),
):
    """Soft-delete an event (creator or admin only)."""
    service = EventService(db)
    return await service.delete_event(event_id, current_user)


@router.post("/{event_id}/rsvp", response_model=RSVPResponse)
async def rsvp_event(
    event_id: UUID,
    data: RSVPRequest,
    current_user: models.User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db),
):
    """Set RSVP status for an event (attending/interested/declined)."""
    service = EventService(db)
    return await service.rsvp(current_user.id, event_id, data.status)


@router.post("/{event_id}/log", status_code=204)
async def log_interaction(
    event_id: UUID,
    data: InteractionLogRequest,
    current_user: models.User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db),
):
    """Log a user interaction with an event (view/click/dismiss) for AI training."""
    service = EventService(db)
    await service.log_interaction(current_user.id, event_id, data.action)
