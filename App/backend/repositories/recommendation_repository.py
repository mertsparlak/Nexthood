from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from sqlalchemy.orm import selectinload
from typing import List
from uuid import UUID

import models


class RecommendationRepository:
    def __init__(self, db: AsyncSession):
        self.db = db

    async def get_for_user(self, user_id: UUID, limit: int = 20, offset: int = 0) -> List[models.Recommendation]:
        result = await self.db.execute(
            select(models.Recommendation)
            .options(selectinload(models.Recommendation.event))
            .where(models.Recommendation.user_id == user_id)
            .order_by(models.Recommendation.score.desc())
            .offset(offset)
            .limit(limit)
        )
        return result.scalars().all()
