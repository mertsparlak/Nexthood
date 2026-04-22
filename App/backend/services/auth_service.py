from fastapi import HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from datetime import datetime, timezone

from repositories.user_repository import UserRepository
from core.security import verify_password, get_password_hash, create_access_token, create_refresh_token, decode_token
from schemas.auth import RegisterRequest, LoginRequest, TokenResponse, RefreshRequest, PasswordChangeRequest
import models


class AuthService:
    def __init__(self, db: AsyncSession):
        self.repo = UserRepository(db)

    def _create_tokens(self, user: models.User) -> TokenResponse:
        token_data = {"sub": str(user.id), "token_version": user.token_version}
        return TokenResponse(
            access_token=create_access_token(token_data),
            refresh_token=create_refresh_token(token_data),
        )

    async def register(self, data: RegisterRequest) -> TokenResponse:
        # Check if email already exists
        existing = await self.repo.get_by_email(data.email)
        if existing:
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="Email already registered",
            )

        # Check if username already exists
        if data.username:
            existing_username = await self.repo.get_by_username(data.username)
            if existing_username:
                raise HTTPException(
                    status_code=status.HTTP_409_CONFLICT,
                    detail="Username already taken",
                )

        user = await self.repo.create(
            email=data.email,
            hashed_password=get_password_hash(data.password),
            full_name=data.full_name,
            username=data.username,
        )

        return self._create_tokens(user)

    async def login(self, data: LoginRequest) -> TokenResponse:
        user = await self.repo.get_by_email(data.email)
        if not user:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid email or password",
            )

        # Check if account is locked (brute-force protection)
        if user.locked_until and user.locked_until > datetime.now(timezone.utc):
            raise HTTPException(
                status_code=status.HTTP_423_LOCKED,
                detail="Account temporarily locked. Try again later.",
            )

        # Check if account is soft-deleted
        if user.is_deleted:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid email or password",
            )

        if not user.hashed_password or not verify_password(data.password, user.hashed_password):
            await self.repo.increment_failed_login(user)
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid email or password",
            )

        # Successful login — reset failed attempts
        if user.failed_login_attempts > 0:
            await self.repo.reset_failed_login(user)

        return self._create_tokens(user)

    async def refresh(self, data: RefreshRequest) -> TokenResponse:
        payload = decode_token(data.refresh_token)
        if payload is None:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid or expired refresh token",
            )

        if payload.get("token_type") != "refresh":
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid token type",
            )

        from uuid import UUID
        user = await self.repo.get_by_id(UUID(payload["sub"]))
        if not user or user.is_deleted:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="User not found",
            )

        # Verify token_version matches (invalidates old tokens after password change)
        token_version = payload.get("token_version")
        if token_version is not None and token_version != user.token_version:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Token has been revoked",
            )

        return self._create_tokens(user)

    async def change_password(self, user: models.User, data: PasswordChangeRequest) -> dict:
        if not user.hashed_password or not verify_password(data.old_password, user.hashed_password):
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Current password is incorrect",
            )

        user.hashed_password = get_password_hash(data.new_password)
        user.token_version += 1  # Invalidate all existing tokens
        user.last_password_change = datetime.now(timezone.utc)
        await self.repo.update(user)

        return {"message": "Password changed successfully"}
