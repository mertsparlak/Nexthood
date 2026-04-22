from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from core.dependencies import get_db, get_current_active_user
from services.auth_service import AuthService
from schemas.auth import RegisterRequest, LoginRequest, TokenResponse, RefreshRequest, PasswordChangeRequest
import models

router = APIRouter(prefix="/auth", tags=["Authentication"])


@router.post("/register", response_model=TokenResponse, status_code=201)
async def register(data: RegisterRequest, db: AsyncSession = Depends(get_db)):
    """Register a new user account and return access + refresh tokens."""
    service = AuthService(db)
    return await service.register(data)


@router.post("/login", response_model=TokenResponse)
async def login(data: LoginRequest, db: AsyncSession = Depends(get_db)):
    """Authenticate with email + password and return tokens."""
    service = AuthService(db)
    return await service.login(data)


@router.post("/refresh", response_model=TokenResponse)
async def refresh(data: RefreshRequest, db: AsyncSession = Depends(get_db)):
    """Exchange a valid refresh token for a new token pair."""
    service = AuthService(db)
    return await service.refresh(data)


@router.post("/change-password")
async def change_password(
    data: PasswordChangeRequest,
    current_user: models.User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db),
):
    """Change password. Invalidates all existing sessions via token_version."""
    service = AuthService(db)
    return await service.change_password(current_user, data)
