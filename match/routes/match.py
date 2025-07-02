from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
import random
import string
from lib.db import prisma
from lib.gsi import start_gsi, kill_gsi, get_logs

router = APIRouter()

class MatchCreateRequest(BaseModel):
    userId: str

class MatchJoinRequest(BaseModel):
    userId: str
    code: str

class MatchEndRequest(BaseModel):
    code: str
    matchId: str

def generate_match_code() -> str:
    """Generate a random 6-character code for the match"""
    return ''.join(random.choices(string.ascii_uppercase + string.digits, k=6))

@router.post("/create")
async def create_match(request: MatchCreateRequest):
    try: 
        # Verify user exists
        user = await prisma.user.find_unique(where={"id": request.userId})
        if not user:
            raise HTTPException(status_code=404, detail="User not found")

        # Generate match code and get available port
       
        try:
            match_code = generate_match_code()

            match = await prisma.match.create(
                data={
                    "status": "CREATED",
                    "creator": {
                        "connect": {
                            "id": request.userId
                        }
                    },
                    "players": {
                        "connect": [{
                            "id": request.userId
                        }]
                    },
                    "gsiUrl": "",
                    "code": match_code
                }
            )

            gsi_url = await start_gsi(match_code, match.id)
            port = int(gsi_url.split(":")[2])

            match = await prisma.match.update(
                where={"id": match.id},
                data={"gsiUrl": gsi_url}
            )

            # Update user's matchIds
            await prisma.user.update(
                where={"id": request.userId},
                data={
                    "matchIds": {
                        "push": match.id
                    }
                }
            )

            return {"match": match}
        except Exception as e:
            # If anything fails, try to clean up the container
            try:
                await kill_gsi(port)
            except:
                pass
            raise HTTPException(status_code=500, detail=f"Failed to create match: {str(e)}")
    except Exception as e:
        print(str(e))
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/join")
async def join_match(request: MatchJoinRequest):
    # Verify user exists
    user = await prisma.user.find_unique(where={"id": request.userId})
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    # Find match by code
    match = await prisma.match.find_first(
        where={
            "code": request.code,
            "status": "CREATED"
        }
    )
    if not match:
        raise HTTPException(status_code=404, detail="Match not found")

    # Check if match is full (2 players)
    if len(match.playerIds) >= 2:
        raise HTTPException(status_code=400, detail="Match is full")

    # Add user to match
    updated_match = await prisma.match.update(
        where={"id": match.id},
        data={
            "status": "STARTED",
            "playerIds": {
                "push": request.userId
            }
        }
    )

    # Update user's matchIds
    await prisma.user.update(
        where={"id": request.userId},
        data={
            "matchIds": {
                "push": match.id
            }
        }
    )

    return {"match": updated_match}

@router.post("/end")
async def end_match(request: MatchEndRequest):
    # Find match and verify user is creator
    match = await prisma.match.find_unique(
        where={
            "id": request.matchId,
            "status": {"not": "FINISHED"}
        },
        include={
            "creator": True,
            "players": True
        }
    )

    if not match:
        raise HTTPException(status_code=404, detail="Match not found")
    
    if match.code != request.code:
        raise HTTPException(status_code=403, detail="Invalid code")

    try:
        port = int(match.gsiUrl.split(":")[2])
        await kill_gsi(port)

        match = await prisma.match.update(
            where={"id": request.matchId},
            data={"status": "FINISHED"},
            include={
                "creator": True,
                "players": True
            }
        )

        return {"match": match}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to delete match: {str(e)}")

@router.get("/{match_id}")
async def get_match(match_id: str):
    # Find match with the given ID, including related creator and players data
    match = await prisma.match.find_unique(
        where={
            "id": match_id
        },
        include={
            "creator": True,
            "players": True
        }
    )

    if not match:
        raise HTTPException(status_code=404, detail="Match not found")

    logs = await get_logs(int(match.gsiUrl.split(":")[2]))

    return {"match": match, "logs": logs}