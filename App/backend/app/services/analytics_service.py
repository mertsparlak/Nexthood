"""Analytics servisi — Kullanıcı ilgi analizi ve bölgesel trend hesaplama.

Gezinme loglarından:
- Kullanıcının en çok ilgilendiği kategoriler
- Bölge bazlı en popüler etkinlik kategorileri
- Belediye öneri raporları
üretir.
"""
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from sqlalchemy import func, distinct, desc, cast, String
from datetime import datetime, timedelta
from uuid import UUID
from typing import Optional

from .. import models


async def get_user_category_interests(db: AsyncSession, user_id: UUID):
    """Kullanıcının kategori bazlı ilgi skorlarını hesaplar.
    
    İlgi skoru = görüntüleme sayısı * benzersiz etkinlik çeşitliliği ağırlığı
    """
    result = await db.execute(
        select(
            models.EventBrowsingLog.event_category,
            func.count(models.EventBrowsingLog.id).label("view_count"),
            func.count(distinct(models.EventBrowsingLog.event_id)).label("unique_events"),
        )
        .where(models.EventBrowsingLog.user_id == user_id)
        .group_by(models.EventBrowsingLog.event_category)
        .order_by(desc("view_count"))
    )
    rows = result.all()

    if not rows:
        return []

    max_views = max(r.view_count for r in rows)
    categories = []
    for r in rows:
        # Skor: normalize edilmiş view_count * unique_events çeşitliliği
        score = round((r.view_count / max_views) * 100, 1) if max_views > 0 else 0
        categories.append({
            "category": r.event_category,
            "view_count": r.view_count,
            "unique_events": r.unique_events,
            "interest_score": score,
        })
    return categories


async def get_user_most_active_screen(db: AsyncSession, user_id: UUID) -> Optional[str]:
    """Kullanıcının en çok log ürettiği ekranı döner."""
    result = await db.execute(
        select(
            models.EventBrowsingLog.source_screen,
            func.count(models.EventBrowsingLog.id).label("cnt"),
        )
        .where(
            models.EventBrowsingLog.user_id == user_id,
            models.EventBrowsingLog.source_screen.isnot(None),
        )
        .group_by(models.EventBrowsingLog.source_screen)
        .order_by(desc("cnt"))
        .limit(1)
    )
    row = result.first()
    return row.source_screen if row else None


async def get_user_total_events_viewed(db: AsyncSession, user_id: UUID) -> int:
    """Kullanıcının toplam benzersiz görüntülediği etkinlik sayısı."""
    result = await db.execute(
        select(func.count(distinct(models.EventBrowsingLog.event_id)))
        .where(models.EventBrowsingLog.user_id == user_id)
    )
    return result.scalar() or 0


async def get_district_category_trends(
    db: AsyncSession,
    district: Optional[str] = None,
    days: int = 30,
):
    """Bölge-kategori bazlı trend verilerini loglardan hesaplar.
    
    district=None ise tüm bölgeler için trend döner.
    """
    since = datetime.utcnow() - timedelta(days=days)

    query = (
        select(
            models.EventBrowsingLog.event_location_name.label("district"),
            models.EventBrowsingLog.event_category.label("category"),
            func.count(models.EventBrowsingLog.id).label("total_views"),
            func.count(distinct(models.EventBrowsingLog.user_id)).label("unique_viewers"),
        )
        .where(
            models.EventBrowsingLog.created_at >= since,
            models.EventBrowsingLog.event_location_name.isnot(None),
        )
        .group_by(
            models.EventBrowsingLog.event_location_name,
            models.EventBrowsingLog.event_category,
        )
        .order_by(desc("total_views"))
    )

    if district:
        query = query.where(models.EventBrowsingLog.event_location_name == district)

    result = await db.execute(query)
    rows = result.all()

    if not rows:
        return []

    max_views = max(r.total_views for r in rows)
    trends = []
    for r in rows:
        score = round((r.total_views / max_views) * 100, 1) if max_views > 0 else 0
        trends.append({
            "district": r.district,
            "category": r.category,
            "total_views": r.total_views,
            "unique_viewers": r.unique_viewers,
            "trend_score": score,
        })
    return trends


async def get_municipality_report(
    db: AsyncSession,
    district: str,
    days: int = 30,
):
    """Belediye için bölgesel etkinlik ilgi raporu üretir."""
    since = datetime.utcnow() - timedelta(days=days)

    # Bölge bazlı kategori trendleri
    trends = await get_district_category_trends(db, district=district, days=days)

    # Toplam görüntüleme
    total_views_result = await db.execute(
        select(func.count(models.EventBrowsingLog.id))
        .where(
            models.EventBrowsingLog.event_location_name == district,
            models.EventBrowsingLog.created_at >= since,
        )
    )
    total_views = total_views_result.scalar() or 0

    # Benzersiz kullanıcı sayısı
    unique_users_result = await db.execute(
        select(func.count(distinct(models.EventBrowsingLog.user_id)))
        .where(
            models.EventBrowsingLog.event_location_name == district,
            models.EventBrowsingLog.created_at >= since,
        )
    )
    unique_users = unique_users_result.scalar() or 0

    return {
        "district": district,
        "period": f"last_{days}_days",
        "top_categories": trends,
        "total_event_views": total_views,
        "total_unique_users": unique_users,
    }
