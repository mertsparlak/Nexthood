from fastapi import HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from typing import Optional
from uuid import UUID

from repositories.event_repository import EventRepository
from geoalchemy2.shape import from_shape
from shapely.geometry import Point
import models


class EventService:
    def __init__(self, db: AsyncSession):
        self.repo = EventRepository(db)

    async def list_events(
        self,
        category: Optional[str] = None,
        search_query: Optional[str] = None,
        lat: Optional[float] = None,
        lng: Optional[float] = None,
        radius_km: float = 10.0,
        offset: int = 0,
        limit: int = 20,
    ):
        events, total = await self.repo.list_events(
            category=category,
            search_query=search_query,
            lat=lat,
            lng=lng,
            radius_km=radius_km,
            offset=offset,
            limit=limit,
        )
        return {"events": events, "total": total, "offset": offset, "limit": limit}

    async def get_event(self, event_id: UUID):
        event = await self.repo.get_by_id(event_id)
        if not event:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Event not found")
        rsvp_counts = await self.repo.get_rsvp_count(event_id)
        return {"event": event, "rsvp_counts": rsvp_counts}

    async def create_event(self, user: models.User, **kwargs) -> models.Event:
        # Convert lat/lng to PostGIS point if provided
        lat = kwargs.pop("lat", None)
        lng = kwargs.pop("lng", None)
        if lat is not None and lng is not None:
            kwargs["location"] = from_shape(Point(lng, lat), srid=4326)

        return await self.repo.create(creator_id=user.id, **kwargs)

    async def update_event(self, event_id: UUID, user: models.User, **kwargs) -> models.Event:
        event = await self.repo.get_by_id(event_id)
        if not event:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Event not found")

        # Only creator or admin can update
        if event.creator_id != user.id and user.role != "admin":
            raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Not authorized")

        lat = kwargs.pop("lat", None)
        lng = kwargs.pop("lng", None)
        if lat is not None and lng is not None:
            kwargs["location"] = from_shape(Point(lng, lat), srid=4326)

        return await self.repo.update(event, **kwargs)

    async def delete_event(self, event_id: UUID, user: models.User) -> dict:
        event = await self.repo.get_by_id(event_id)
        if not event:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Event not found")

        if event.creator_id != user.id and user.role != "admin":
            raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Not authorized")

        await self.repo.soft_delete(event)
        return {"message": "Event deleted"}

    async def rsvp(self, user_id: UUID, event_id: UUID, rsvp_status: str) -> models.EventRSVP:
        event = await self.repo.get_by_id(event_id)
        if not event:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Event not found")
        return await self.repo.upsert_rsvp(user_id, event_id, rsvp_status)

    async def log_interaction(self, user_id: UUID, event_id: UUID, action: str):
        event = await self.repo.get_by_id(event_id)
        if not event:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Event not found")
        return await self.repo.log_interaction(user_id, event_id, action)
