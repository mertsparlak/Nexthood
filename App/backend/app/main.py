from fastapi import FastAPI
from . import models, database
from .routers import auth, events, browsing_logs, analytics, notifications

# Initialize tables (for dev only, prefer Alembic for prod)
# models.Base.metadata.create_all(bind=database.engine)

app = FastAPI(title="Mahalle-Connect API", version="0.2.0")

# Auth (token endpoint — prefix yok)
app.include_router(auth.router)

# API v1 routers
app.include_router(events.router, prefix="/api/v1")
app.include_router(browsing_logs.router, prefix="/api/v1")
app.include_router(analytics.router, prefix="/api/v1")
app.include_router(notifications.router, prefix="/api/v1")


@app.get("/")
async def root():
    return {"message": "Welcome to Mahalle-Connect API"}
