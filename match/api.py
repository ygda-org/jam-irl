from fastapi import APIRouter
from routes import user, match
from lib.db import prisma
from lib.gsi import get_used_ports

router = APIRouter()

router.include_router(user.router, prefix="/user", tags=["users"])
router.include_router(match.router, prefix="/match", tags=["matches"])

@router.get("/")
async def health_check():

    try: 
        matches = await prisma.match.find_many(
            where={
                "status": {"not": "FINISHED"}
            },
        )

        used_ports = get_used_ports()
    except Exception as e:
        return {
            "status": "unhealthy",
            "error": str(e)
        }
    
    return {
        "status": "healthy",
        "ports": used_ports,
        "matches": [
            {
                "id": m.id,
                "code": m.code,
                "gsiUrl": m.gsiUrl
            }
            for m in matches
        ]
    }

