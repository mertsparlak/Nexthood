from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession

from core.dependencies import get_db, get_current_active_user
from repositories.recommendation_repository import RecommendationRepository
from schemas.recommendation import RecommendationListResponse
import models

router = APIRouter(prefix="/recommendations", tags=["Recommendations"])


@router.get("", response_model=RecommendationListResponse)
async def get_my_recommendations(
    limit: int = Query(20, ge=1, le=100),
    offset: int = Query(0, ge=0),
    current_user: models.User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db),
):
    """Get AI-powered event recommendations for the current user."""
    repo = RecommendationRepository(db)
    recommendations = await repo.get_for_user(current_user.id, limit=limit, offset=offset)
    return {"recommendations": recommendations}
