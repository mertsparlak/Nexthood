"""Analytics router — Kullanıcı ilgi analizi ve bölgesel trend endpoint'leri.

Yönetim paneli için bölge-kategori trend verilerini sunar.
Kullanıcıya kendi ilgi profilini gösterir.
"""
from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession
from typing import Optional

from .. import database, models, schemas
from ..dependencies import get_current_user
from ..services import analytics_service

router = APIRouter(prefix="/analytics", tags=["Analytics"])


@router.get("/user/insights", response_model=schemas.UserInsight)
async def get_user_insights(
    db: AsyncSession = Depends(database.get_db),
    current_user: models.User = Depends(get_current_user),
):
    """Kullanıcının kendi ilgi analizini döner.
    
    En çok ilgilendiği kategoriler, toplam görüntülediği etkinlik sayısı
    ve en aktif olduğu ekran bilgisini içerir.
    """
    categories = await analytics_service.get_user_category_interests(db, current_user.id)
    total_viewed = await analytics_service.get_user_total_events_viewed(db, current_user.id)
    active_screen = await analytics_service.get_user_most_active_screen(db, current_user.id)

    return schemas.UserInsight(
        top_categories=[schemas.CategoryInterest(**c) for c in categories],
        total_events_viewed=total_viewed,
        most_active_screen=active_screen,
    )


@router.get("/trends", response_model=list[schemas.DistrictCategoryTrend])
async def get_trends(
    district: Optional[str] = Query(None, description="Bölge filtresi (opsiyonel)"),
    days: int = Query(30, ge=1, le=365, description="Kaç günlük veri"),
    db: AsyncSession = Depends(database.get_db),
    current_user: models.User = Depends(get_current_user),
):
    """Bölge-kategori bazlı trend verilerini döner.
    
    Yönetim tarafında hangi bölgede hangi etkinlik revaçta bilgisini sunar.
    district parametresi verilmezse tüm bölgelerin trendleri listelenir.
    """
    trends = await analytics_service.get_district_category_trends(db, district=district, days=days)
    return [schemas.DistrictCategoryTrend(**t) for t in trends]


@router.get("/municipality-report", response_model=schemas.MunicipalityReport)
async def get_municipality_report(
    district: str = Query(..., description="Bölge adı (zorunlu)"),
    days: int = Query(30, ge=1, le=365, description="Kaç günlük veri"),
    db: AsyncSession = Depends(database.get_db),
    current_user: models.User = Depends(get_current_user),
):
    """Belediye öneri raporu üretir.
    
    Belirli bir bölge için kategori bazlı popülerlik, toplam görüntüleme
    ve benzersiz kullanıcı sayısını içeren detaylı rapor döner.
    """
    report = await analytics_service.get_municipality_report(db, district=district, days=days)
    report["top_categories"] = [schemas.DistrictCategoryTrend(**t) for t in report["top_categories"]]
    return schemas.MunicipalityReport(**report)
