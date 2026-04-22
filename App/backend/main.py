from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy import text

from core.config import get_settings
from routers import auth, users, events, recommendations
from database import engine

settings = get_settings()

app = FastAPI(
    title=settings.APP_NAME,
    version="1.0.0",
    description="Hyperlocal event discovery and community engagement platform",
)

# CORS — allow mobile app and local dev
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Tighten for production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Register routers
app.include_router(auth.router)
app.include_router(users.router)
app.include_router(events.router)
app.include_router(recommendations.router)


@app.get("/", tags=["Root"])
async def root():
    return {"message": "Welcome to Nexthood API", "version": "1.0.0"}


@app.get("/health", tags=["Root"])
async def health_check():
    """Health check endpoint — verifies database connectivity."""
    try:
        async with engine.connect() as conn:
            await conn.execute(text("SELECT 1"))
        return {"status": "healthy", "database": "connected"}
    except Exception as e:
        return {"status": "unhealthy", "database": str(e)}
