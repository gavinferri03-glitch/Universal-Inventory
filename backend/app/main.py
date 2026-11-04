
from contextlib import asynccontextmanager

from fastapi import FastAPI

from app.db.session import Base, engine
from app.models import Organization, User, OrganizationMember
from app.api.auth import router as auth_router


@asynccontextmanager
async def lifespan(app: FastAPI):
    Base.metadata.create_all(bind=engine)
    yield


app = FastAPI(
    title="Universal Inventory API",
    version="0.1.0",
    lifespan=lifespan
)


app.include_router(auth_router)


@app.get("/")
def root():
    return {
        "app": "Universal Inventory",
        "status": "running",
        "version": "0.1.0"
    }


@app.get("/health")
def health():
    return {"status": "healthy"}
