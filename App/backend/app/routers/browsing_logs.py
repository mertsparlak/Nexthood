"""Browsing Logs router — Kullanıcı etkinlik gezinme loglarını kaydeder.

Mobil uygulama her etkinlik tıklamasında bu endpoint'lere log gönderir.
Tekil ve toplu (batch) gönderim destekler.
"""
from fastapi import APIRouter, Depends, Query, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from sqlalchemy import desc
from typing import List
from uuid import UUID

from .. import database, models, schemas
from ..dependencies import get_current_user

router = APIRouter(prefix="/logs", tags=["Browsing Logs"])


@router.post("/browse", response_model=schemas.BrowsingLogResponse, status_code=status.HTTP_201_CREATED)
async def create_browsing_log(
    log_data: schemas.BrowsingLogCreate,
    db: AsyncSession = Depends(database.get_db),
    current_user: models.User = Depends(get_current_user),
):
    """Tekil gezinme logu kaydeder.
    
    Kullanıcı bir etkinliğe tıkladığında bu endpoint çağrılır.
    """
    log = models.EventBrowsingLog(
        user_id=current_user.id,
        event_id=log_data.event_id,
        action=log_data.action,
        event_category=log_data.event_category,
        event_location_name=log_data.event_location_name,
        source_screen=log_data.source_screen,
    )
    db.add(log)
    await db.commit()
    await db.refresh(log)
    return log


@router.post("/browse/batch", status_code=status.HTTP_201_CREATED)
async def create_browsing_logs_batch(
    batch: schemas.BrowsingLogBatch,
    db: AsyncSession = Depends(database.get_db),
    current_user: models.User = Depends(get_current_user),
):
    """Toplu gezinme logları kaydeder.
    
    Mobil uygulama buffer'daki logları toplu olarak gönderir.
    """
    logs = []
    for log_data in batch.logs:
        log = models.EventBrowsingLog(
            user_id=current_user.id,
            event_id=log_data.event_id,
            action=log_data.action,
            event_category=log_data.event_category,
            event_location_name=log_data.event_location_name,
            source_screen=log_data.source_screen,
        )
        logs.append(log)

    db.add_all(logs)
    await db.commit()
    return {"message": f"{len(logs)} logs created successfully", "count": len(logs)}


@router.get("/browse/me", response_model=list[schemas.BrowsingLogResponse])
async def get_my_browsing_logs(
    skip: int = Query(0, ge=0),
    limit: int = Query(50, ge=1, le=100),
    db: AsyncSession = Depends(database.get_db),
    current_user: models.User = Depends(get_current_user),
):
    """Kullanıcının kendi gezinme log geçmişini listeler."""
    result = await db.execute(
        select(models.EventBrowsingLog)
        .where(models.EventBrowsingLog.user_id == current_user.id)
        .order_by(desc(models.EventBrowsingLog.created_at))
        .offset(skip)
        .limit(limit)
    )
    return result.scalars().all()
