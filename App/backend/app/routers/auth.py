from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from datetime import timedelta
from .. import database, models, security, schemas

router = APIRouter(tags=["Authentication"])


@router.post("/register", response_model=schemas.User, status_code=status.HTTP_201_CREATED)
async def register(user_data: schemas.UserCreate, db: AsyncSession = Depends(database.get_db)):
    """Yeni kullanıcı kaydı oluşturur."""
    # E-posta kontrolü
    existing = await db.execute(select(models.User).where(models.User.email == user_data.email))
    if existing.scalar_one_or_none():
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Email already registered",
        )

    user = models.User(
        full_name=user_data.full_name,
        email=user_data.email,
        hashed_password=security.get_password_hash(user_data.password),
    )
    db.add(user)
    await db.commit()
    await db.refresh(user)
    return user


@router.post("/token", response_model=schemas.Token)
async def login_for_access_token(form_data: OAuth2PasswordRequestForm = Depends(), db: AsyncSession = Depends(database.get_db)):
    result = await db.execute(select(models.User).where(models.User.email == form_data.username))
    user = result.scalar_one_or_none()
    
    if not user or not security.verify_password(form_data.password, user.hashed_password):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect username or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    access_token_expires = timedelta(minutes=security.ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = security.create_access_token(
        data={"sub": user.email}, expires_delta=access_token_expires
    )
    return {"access_token": access_token, "token_type": "bearer"}
