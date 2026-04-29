"""Notifications router — Uygulama içi bildirim endpoint'leri.

Kullanıcıya günde 1 kez AI tabanlı kişiselleştirilmiş bildirim üretir.
Bildirim listesi ve okundu işaretleme endpoint'leri sunar.
"""
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.ext.asyncio import AsyncSession
from typing import List
from uuid import UUID

from .. import database, models, schemas
from ..dependencies import get_current_user
from ..services import notification_service

router = APIRouter(prefix="/notifications", tags=["Notifications"])


@router.get("/", response_model=list[schemas.NotificationResponse])
async def get_notifications(
    limit: int = Query(20, ge=1, le=100),
    unread_only: bool = Query(False, description="Sadece okunmamış bildirimleri getir"),
    db: AsyncSession = Depends(database.get_db),
    current_user: models.User = Depends(get_current_user),
):
    """Kullanıcının bildirimlerini listeler."""
    notifications = await notification_service.get_user_notifications(
        db, current_user.id, limit=limit, unread_only=unread_only
    )
    return notifications


@router.post("/generate", response_model=schemas.NotificationResponse | None)
async def generate_notification(
    db: AsyncSession = Depends(database.get_db),
    current_user: models.User = Depends(get_current_user),
):
    """Kullanıcı için günlük AI tabanlı bildirim üretir.
    
    Kullanıcı uygulamaya girdiğinde çağrılır. Bugün zaten bildirim
    üretilmişse None döner (günde 1 kez kuralı).
    """
    notification = await notification_service.generate_daily_notification(
        db, current_user.id
    )
    if notification is None:
        return None
    return notification


@router.patch("/{notification_id}", response_model=schemas.NotificationResponse)
async def mark_as_read(
    notification_id: UUID,
    db: AsyncSession = Depends(database.get_db),
    current_user: models.User = Depends(get_current_user),
):
    """Bildirimi okundu olarak işaretler."""
    notification = await notification_service.mark_notification_read(
        db, notification_id, current_user.id
    )
    if notification is None:
        raise HTTPException(status_code=404, detail="Notification not found")
    return notification
