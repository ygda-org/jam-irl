from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
import random
import string
import docker
import asyncio
import re
from typing import List
from lib.db import prisma
import os

router = APIRouter()
docker_client = docker.from_env()

class MatchCreateRequest(BaseModel):
    userId: str

class MatchJoinRequest(BaseModel):
    userId: str
    code: str

class MatchEndRequest(BaseModel):
    userId: str
    matchId: str

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
        os.getenv("GIS_IMAGE"),  # Use the image built from the Dockerfile
        name=container_name,
        detach=True,
        ports={'9999': port},
        command=["./project.x86_64", "--server", "--headless", "--code", code]
    )
    
    # Return the websocket URL
    return f"ws://localhost:{port}"

async def stop_gis_container(port: int):
    container = docker_client.containers.get(f"gis-{port}")
    container.stop()
    container.remove()

@router.post("/create")
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
                "gsiUrl": gsi_url,
                "code": match_code
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
            container.stop()
            container.remove()
        except:
            pass
        raise HTTPException(status_code=500, detail=f"Failed to create match: {str(e)}")

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
    
    if match.creator.id != request.userId:
        raise HTTPException(status_code=403, detail="Only match creator can delete the match")

    try:
        port = int(match.gsiUrl.split(":")[2])
        await stop_gis_container(port)

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

    return {"match": match} 