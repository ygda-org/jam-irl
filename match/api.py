from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from prisma import Prisma
import random
import string
import docker
import os
import re
from typing import List

router = APIRouter()
prisma = Prisma()
docker_client = docker.from_env()

def get_used_ports() -> List[int]:
    """Get list of ports currently in use by GIS containers"""
    containers = docker_client.containers.list(filters={"name": "gis-"})
    used_ports = []
    for container in containers:
        # Extract port from container name (gis-XXXX)
        match = re.search(r'gis-(\d+)', container.name)
        if match:
            used_ports.append(int(match.group(1)))
    return used_ports

def get_available_port() -> int:
    """Find an available port for a new GIS container"""
    used_ports = get_used_ports()
    used_ports.sort()
    
    port = 10000
    if port not in used_ports:
        return port

    for i in range(1, len(used_ports)):
        if used_ports[i] - used_ports[i-1] > 1:
            return used_ports[i-1] + 1

    if used_ports[-1] < 10100-1:
        return used_ports[-1] + 1
    else:
        raise Exception("No available ports in range 10000-10100")

def generate_match_code() -> str:
    """Generate a random 6-character code for the match"""
    return ''.join(random.choices(string.ascii_uppercase + string.digits, k=6))

async def start_gis_container(port: int, code: str) -> str:
    """Start a new GIS container and return its websocket URL"""
    container_name = f"gis-{port}"
    
    # Start the container with port forwarding and code
    container = docker_client.containers.run(
        "ygda-jam-irl-gis:latest",  # Use the image built from the Dockerfile
        name=container_name,
        detach=True,
        ports={'9999/tcp': port},
        command=f"--server --headless --code {code}"
    )
    
    # Return the websocket URL
    return f"ws://{os.getenv('HOST_IP')}:{port}"

# Pydantic models for request/response
class UserCreate(BaseModel):
    pass

class UserResponse(BaseModel):
    userId: str

class MatchCreateRequest(BaseModel):
    userId: str

class MatchJoinRequest(BaseModel):
    userId: str
    code: str

class MatchDeleteRequest(BaseModel):
    userId: str

@router.get("/")
async def health_check():
    return {"status": "healthy"}

@router.post("/user", response_model=UserResponse)
async def create_user():
    user = await prisma.user.create(
        data={
            "matchIds": []
        }
    )
    return {"userId": user.id}

@router.post("/match/create")
async def create_match(request: MatchCreateRequest):
    # Verify user exists
    user = await prisma.user.find_unique(where={"id": request.userId})
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    # Generate match code and get available port
    match_code = generate_match_code()
    port = get_available_port()
    
    try:
        # Start GIS container
        gsi_url = await start_gis_container(port, match_code)
        
        # Create a new match
        match = await prisma.match.create(
            data={
                "status": "CREATED",
                "creatorId": request.userId,
                "playerIds": [request.userId],
                "gsiUrl": gsi_url,
                "code": match_code  # Store the code in the match
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

        return {"match": match}
    except Exception as e:
        # If anything fails, try to clean up the container
        try:
            container = docker_client.containers.get(f"gis-{port}")
            container.remove(force=True)
        except:
            pass
        raise HTTPException(status_code=500, detail=f"Failed to create match: {str(e)}")

@router.post("/match/join")
async def join_match(request: MatchJoinRequest):
    # Verify user exists
    user = await prisma.user.find_unique(where={"id": request.userId})
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    # Find match by code
    match = await prisma.match.find_first(
        where={
            "id": request.code,
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

@router.delete("/match")
async def delete_match(request: MatchDeleteRequest):
    # Find match where user is creator
    match = await prisma.match.find_first(
        where={
            "creatorId": request.userId,
            "status": "CREATED"
        }
    )
    if not match:
        raise HTTPException(status_code=404, detail="No active match found for user")

    # Delete the match
    await prisma.match.delete(where={"id": match.id})

    # Update all players' matchIds
    for player_id in match.playerIds:
        await prisma.user.update(
            where={"id": player_id},
            data={
                "matchIds": {
                    "set": [mid for mid in match.playerIds if mid != match.id]
                }
            }
        )

    return {"match": match} 


@router.get("/match/{match_id}")
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

    return {"match": match}

