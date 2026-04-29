"""Events router — Temel etkinlik CRUD endpoint'leri.

Log sistemi bu endpoint'lere bağımlıdır; mobil uygulama event listesi ve
detaylarını bu endpoint'ler üzerinden alır.
"""
from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from sqlalchemy import desc
from typing import Optional
from uuid import UUID

from .. import database, models, schemas
from ..dependencies import get_current_user

router = APIRouter(prefix="/events", tags=["Events"])


@router.get("/", response_model=list[schemas.Event])
async def list_events(
    category: Optional[str] = Query(None, description="Kategori filtresi"),
    status_filter: Optional[str] = Query("active", alias="status", description="Durum filtresi"),
    skip: int = Query(0, ge=0),
    limit: int = Query(20, ge=1, le=100),
    db: AsyncSession = Depends(database.get_db),
):
    """Etkinlikleri listeler. Kategori ve durum bazlı filtreleme destekler."""
    query = select(models.Event).order_by(desc(models.Event.created_at))

    if category:
        query = query.where(models.Event.category == category)
    if status_filter:
        query = query.where(models.Event.status == status_filter)

    query = query.offset(skip).limit(limit)
    result = await db.execute(query)
    return result.scalars().all()


@router.get("/{event_id}", response_model=schemas.Event)
async def get_event(
    event_id: UUID,
    db: AsyncSession = Depends(database.get_db),
):
    """Tekil etkinlik detayı döner."""
    result = await db.execute(
        select(models.Event).where(models.Event.id == event_id)
    )
    event = result.scalar_one_or_none()
    if not event:
        raise HTTPException(status_code=404, detail="Event not found")
    return event


@router.post("/", response_model=schemas.Event, status_code=status.HTTP_201_CREATED)
async def create_event(
    event_data: schemas.EventCreate,
    db: AsyncSession = Depends(database.get_db),
    current_user: models.User = Depends(get_current_user),
):
    """Yeni etkinlik oluşturur (kimlik doğrulaması gerektirir)."""
    event = models.Event(
        title=event_data.title,
        description=event_data.description,
        start_date=event_data.start_date,
        end_date=event_data.end_date,
        location_name=event_data.location_name,
        category=event_data.category,
        event_url=event_data.event_url,
        status=event_data.status,
        source_id=event_data.source_id,
    )
    db.add(event)
    await db.commit()
    await db.refresh(event)
    return event
