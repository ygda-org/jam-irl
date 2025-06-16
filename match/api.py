from fastapi import APIRouter
from routes import user, match

router = APIRouter()

router.include_router(user.router, prefix="/user", tags=["users"])
router.include_router(match.router, prefix="/match", tags=["matches"])

@router.get("/")
async def health_check():
    return {"status": "healthy"}

