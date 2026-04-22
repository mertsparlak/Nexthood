from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from typing import List

from core.dependencies import get_db, get_current_active_user
from repositories.user_repository import UserRepository
from schemas.user import UserResponse, UserPublicResponse, UserUpdate, InterestUpdate
import models

router = APIRouter(prefix="/users", tags=["Users"])


@router.get("/me", response_model=UserResponse)
async def get_my_profile(
    current_user: models.User = Depends(get_current_active_user),
):
    """Get the current authenticated user's full profile."""
    return current_user


@router.patch("/me", response_model=UserResponse)
async def update_my_profile(
    data: UserUpdate,
    current_user: models.User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db),
):
    """Update the current user's profile fields."""
    repo = UserRepository(db)

    # Check username uniqueness if being updated
    if data.username and data.username != current_user.username:
        existing = await repo.get_by_username(data.username)
        if existing:
            from fastapi import HTTPException, status
            raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail="Username already taken")

    updated = await repo.update(
        current_user,
        **data.model_dump(exclude_unset=True),
    )
    return updated


@router.put("/me/interests")
async def update_my_interests(
    data: InterestUpdate,
    current_user: models.User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db),
):
    """Replace the current user's interests list."""
    repo = UserRepository(db)
    interests = await repo.update_interests(current_user.id, data.interests)
    return {"interests": [i.interest for i in interests]}


@router.get("/me/interests")
async def get_my_interests(
    current_user: models.User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db),
):
    """Get the current user's interests."""
    repo = UserRepository(db)
    interests = await repo.get_interests(current_user.id)
    return {"interests": [i.interest for i in interests]}


@router.delete("/me", status_code=204)
async def delete_my_account(
    current_user: models.User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db),
):
    """Soft-delete the current user's account."""
    repo = UserRepository(db)
    await repo.soft_delete(current_user)


@router.get("/{user_id}", response_model=UserPublicResponse)
async def get_user_profile(
    user_id: str,
    db: AsyncSession = Depends(get_db),
):
    """Get a user's public profile by ID."""
    from uuid import UUID
    from fastapi import HTTPException, status
    repo = UserRepository(db)
    user = await repo.get_by_id(UUID(user_id))
    if not user:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found")
    return user
