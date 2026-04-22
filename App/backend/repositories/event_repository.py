from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from sqlalchemy import func, delete, and_, or_
from typing import Optional, List, Tuple
from uuid import UUID
from datetime import datetime

import models
from geoalchemy2.functions import ST_DWithin, ST_MakePoint, ST_SetSRID


class EventRepository:
    def __init__(self, db: AsyncSession):
        self.db = db

    async def list_events(
        self,
        category: Optional[str] = None,
        search_query: Optional[str] = None,
        lat: Optional[float] = None,
        lng: Optional[float] = None,
        radius_km: float = 10.0,
        start_after: Optional[datetime] = None,
        start_before: Optional[datetime] = None,
        offset: int = 0,
        limit: int = 20,
    ) -> Tuple[List[models.Event], int]:
        """Returns a paginated event list with total count."""
        query = select(models.Event).where(
            models.Event.is_deleted == False,
            models.Event.status == "active",
        )

        if category:
            query = query.where(models.Event.category == category)

        if search_query:
            query = query.where(
                models.Event.search_vector.match(search_query)
            )

        if lat is not None and lng is not None:
            point = ST_SetSRID(ST_MakePoint(lng, lat), 4326)
            query = query.where(
                ST_DWithin(
                    models.Event.location,
                    point,
                    radius_km * 1000,  # meters
                )
            )

        if start_after:
            query = query.where(models.Event.start_date >= start_after)

        if start_before:
            query = query.where(models.Event.start_date <= start_before)

        # Count total results
        count_query = select(func.count()).select_from(query.subquery())
        count_result = await self.db.execute(count_query)
        total = count_result.scalar()

        # Apply pagination and ordering
        query = query.order_by(models.Event.start_date.asc()).offset(offset).limit(limit)
        result = await self.db.execute(query)
        events = result.scalars().all()

        return events, total

    async def get_by_id(self, event_id: UUID) -> Optional[models.Event]:
        result = await self.db.execute(
            select(models.Event).where(
                models.Event.id == event_id,
                models.Event.is_deleted == False,
            )
        )
        return result.scalar_one_or_none()

    async def create(self, **kwargs) -> models.Event:
        event = models.Event(**kwargs)
        self.db.add(event)
        await self.db.commit()
        await self.db.refresh(event)
        return event

    async def update(self, event: models.Event, **kwargs) -> models.Event:
        for key, value in kwargs.items():
            if value is not None:
                setattr(event, key, value)
        await self.db.commit()
        await self.db.refresh(event)
        return event

    async def soft_delete(self, event: models.Event) -> None:
        from datetime import timezone
        event.is_deleted = True
        event.deleted_at = datetime.now(timezone.utc)
        event.status = "deleted"
        await self.db.commit()

    # --- RSVP ---

    async def get_rsvp(self, user_id: UUID, event_id: UUID) -> Optional[models.EventRSVP]:
        result = await self.db.execute(
            select(models.EventRSVP).where(
                models.EventRSVP.user_id == user_id,
                models.EventRSVP.event_id == event_id,
            )
        )
        return result.scalar_one_or_none()

    async def upsert_rsvp(self, user_id: UUID, event_id: UUID, status: str) -> models.EventRSVP:
        existing = await self.get_rsvp(user_id, event_id)
        if existing:
            existing.status = status
            await self.db.commit()
            await self.db.refresh(existing)
            return existing
        else:
            rsvp = models.EventRSVP(user_id=user_id, event_id=event_id, status=status)
            self.db.add(rsvp)
            await self.db.commit()
            await self.db.refresh(rsvp)
            return rsvp

    async def get_rsvp_count(self, event_id: UUID) -> dict:
        result = await self.db.execute(
            select(
                models.EventRSVP.status,
                func.count(models.EventRSVP.id),
            )
            .where(models.EventRSVP.event_id == event_id)
            .group_by(models.EventRSVP.status)
        )
        counts = {"attending": 0, "interested": 0, "declined": 0}
        for status_val, count in result.all():
            counts[status_val] = count
        return counts

    # --- Interaction Logging ---

    async def log_interaction(self, user_id: UUID, event_id: UUID, action: str) -> models.EventLog:
        log = models.EventLog(user_id=user_id, event_id=event_id, action=action)
        self.db.add(log)
        await self.db.commit()
        return log
