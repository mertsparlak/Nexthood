from fastapi import FastAPI
from . import models, database
from .routers import auth

# Initialize tables (for dev only, prefer Alembic for prod)
# models.Base.metadata.create_all(bind=database.engine)

app = FastAPI(title="Mahalle-Connect API", version="0.1.0")

app.include_router(auth.router)

@app.get("/")
async def root():
    return {"message": "Welcome to Mahalle-Connect API"}
