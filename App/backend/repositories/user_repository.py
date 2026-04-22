from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from sqlalchemy import update, delete
from typing import Optional, List
from uuid import UUID
from datetime import datetime, timezone

import models


class UserRepository:
    def __init__(self, db: AsyncSession):
        self.db = db

    async def get_by_id(self, user_id: UUID) -> Optional[models.User]:
        result = await self.db.execute(
            select(models.User).where(
                models.User.id == user_id,
                models.User.is_deleted == False,
            )
        )
        return result.scalar_one_or_none()

    async def get_by_email(self, email: str) -> Optional[models.User]:
        result = await self.db.execute(
            select(models.User).where(models.User.email == email)
        )
        return result.scalar_one_or_none()

    async def get_by_username(self, username: str) -> Optional[models.User]:
        result = await self.db.execute(
            select(models.User).where(models.User.username == username)
        )
        return result.scalar_one_or_none()

    async def create(self, **kwargs) -> models.User:
        user = models.User(**kwargs)
        self.db.add(user)
        await self.db.commit()
        await self.db.refresh(user)
        return user

    async def update(self, user: models.User, **kwargs) -> models.User:
        for key, value in kwargs.items():
            if value is not None:
                setattr(user, key, value)
        await self.db.commit()
        await self.db.refresh(user)
        return user

    async def soft_delete(self, user: models.User) -> None:
        user.is_deleted = True
        user.deleted_at = datetime.now(timezone.utc)
        user.is_active = False
        await self.db.commit()

    async def increment_failed_login(self, user: models.User) -> None:
        user.failed_login_attempts += 1
        if user.failed_login_attempts >= 5:
            from datetime import timedelta
            user.locked_until = datetime.now(timezone.utc) + timedelta(minutes=15)
        await self.db.commit()

    async def reset_failed_login(self, user: models.User) -> None:
        user.failed_login_attempts = 0
        user.locked_until = None
        await self.db.commit()

    async def get_interests(self, user_id: UUID) -> List[models.UserInterest]:
        result = await self.db.execute(
            select(models.UserInterest).where(models.UserInterest.user_id == user_id)
        )
        return result.scalars().all()

    async def update_interests(self, user_id: UUID, interests: List[str]) -> List[models.UserInterest]:
        # Delete existing interests
        await self.db.execute(
            delete(models.UserInterest).where(models.UserInterest.user_id == user_id)
        )
        # Create new interests
        new_interests = []
        for interest_name in interests:
            interest = models.UserInterest(user_id=user_id, interest=interest_name)
            self.db.add(interest)
            new_interests.append(interest)
        await self.db.commit()
        return new_interests
