"""Bildirim servisi — Kullanıcı gezinme loglarına dayanarak AI tabanlı
kişiselleştirilmiş uygulama içi bildirimler üretir.

Günde 1 kez çalışır. Kullanıcının en çok ilgi gösterdiği kategori ve
bölge bilgisine göre bildirim mesajı oluşturur.
"""
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from sqlalchemy import func, distinct, desc, and_
from datetime import datetime, timedelta
from uuid import UUID
from typing import Optional, List

from .. import models
from .analytics_service import get_user_category_interests, get_district_category_trends


# Kategori bazlı bildirim şablonları
NOTIFICATION_TEMPLATES = {
    "sports": {
        "title": "🏃 Spor etkinlikleri ilgini çekiyor!",
        "body": "{district} bölgesinde spor etkinlikleri çok ilgi görüyor. Bir spor etkinliği planlamak ister misin?",
    },
    "music": {
        "title": "🎵 Müzik etkinlikleri seni bekliyor!",
        "body": "{district} bölgesinde müzik etkinlikleri popüler. Yakınındaki konserleri keşfetmeye ne dersin?",
    },
    "community": {
        "title": "👥 Topluluk etkinlikleri revaçta!",
        "body": "{district} bölgesinde topluluk etkinlikleri çok ilgi görüyor. Sen de bir topluluk etkinliği düzenle!",
    },
    "technology": {
        "title": "💻 Teknoloji buluşmaları popüler!",
        "body": "{district} bölgesinde teknoloji etkinlikleri trend. Bir tech meetup planlamak ister misin?",
    },
    "workshop": {
        "title": "🎨 Atölye etkinlikleri ilgi çekiyor!",
        "body": "{district} bölgesinde atölye etkinlikleri popüler. Yaratıcı bir atölye düzenle!",
    },
    "concert": {
        "title": "🎤 Konser etkinlikleri çok sevildi!",
        "body": "{district} bölgesinde konser etkinlikleri büyük ilgi görüyor. Yakınındaki konserleri kaçırma!",
    },
}

DEFAULT_TEMPLATE = {
    "title": "✨ İlgini çekebilecek etkinlikler var!",
    "body": "{district} bölgesinde {category} etkinlikleri çok ilgi görüyor. Keşfetmeye ne dersin?",
}


async def has_notification_today(db: AsyncSession, user_id: UUID) -> bool:
    """Kullanıcıya bugün zaten bildirim gönderilmiş mi kontrol eder."""
    today_start = datetime.utcnow().replace(hour=0, minute=0, second=0, microsecond=0)
    result = await db.execute(
        select(func.count(models.Notification.id))
        .where(
            models.Notification.user_id == user_id,
            models.Notification.created_at >= today_start,
        )
    )
    count = result.scalar() or 0
    return count > 0


async def generate_daily_notification(
    db: AsyncSession,
    user_id: UUID,
) -> Optional[models.Notification]:
    """Kullanıcı için günlük AI tabanlı bildirim üretir.
    
    1. Kullanıcının en çok ilgilendiği kategoriyi bulur
    2. O kategorinin en popüler olduğu bölgeyi bulur
    3. Kişiselleştirilmiş bildirim mesajı oluşturur
    
    Bugün zaten bildirim varsa None döner.
    """
    # Bugün zaten bildirim gönderilmiş mi?
    if await has_notification_today(db, user_id):
        return None

    # Kullanıcının kategori ilgilerini al
    interests = await get_user_category_interests(db, user_id)
    if not interests:
        return None

    top_category = interests[0]["category"]

    # Bu kategorinin en popüler olduğu bölgeyi bul
    top_district = await _get_top_district_for_category(db, top_category)
    district_name = top_district or "Çevren"

    # Şablondan bildirim mesajı oluştur
    template = NOTIFICATION_TEMPLATES.get(top_category, DEFAULT_TEMPLATE)
    title = template["title"]
    body = template["body"].format(
        district=district_name,
        category=top_category,
    )

    # Bildirimi kaydet
    notification = models.Notification(
        user_id=user_id,
        title=title,
        body=body,
        notification_type="event_suggestion",
        related_category=top_category,
        related_district=district_name,
    )
    db.add(notification)
    await db.commit()
    await db.refresh(notification)
    return notification


async def _get_top_district_for_category(
    db: AsyncSession,
    category: str,
    days: int = 30,
) -> Optional[str]:
    """Belirli bir kategorinin en popüler olduğu bölgeyi döner."""
    since = datetime.utcnow() - timedelta(days=days)
    result = await db.execute(
        select(
            models.EventBrowsingLog.event_location_name,
            func.count(models.EventBrowsingLog.id).label("cnt"),
        )
        .where(
            models.EventBrowsingLog.event_category == category,
            models.EventBrowsingLog.event_location_name.isnot(None),
            models.EventBrowsingLog.created_at >= since,
        )
        .group_by(models.EventBrowsingLog.event_location_name)
        .order_by(desc("cnt"))
        .limit(1)
    )
    row = result.first()
    return row.event_location_name if row else None


async def get_user_notifications(
    db: AsyncSession,
    user_id: UUID,
    limit: int = 20,
    unread_only: bool = False,
) -> List[models.Notification]:
    """Kullanıcının bildirimlerini listeler."""
    query = (
        select(models.Notification)
        .where(models.Notification.user_id == user_id)
        .order_by(desc(models.Notification.created_at))
        .limit(limit)
    )
    if unread_only:
        query = query.where(models.Notification.is_read == False)

    result = await db.execute(query)
    return result.scalars().all()


async def mark_notification_read(
    db: AsyncSession,
    notification_id: UUID,
    user_id: UUID,
) -> Optional[models.Notification]:
    """Bildirimi okundu olarak işaretler."""
    result = await db.execute(
        select(models.Notification).where(
            models.Notification.id == notification_id,
            models.Notification.user_id == user_id,
        )
    )
    notification = result.scalar_one_or_none()
    if notification:
        notification.is_read = True
        await db.commit()
        await db.refresh(notification)
    return notification
