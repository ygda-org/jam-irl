
import docker
import re
import os
from typing import List
import json

docker_client = docker.from_env()

def get_used_ports() -> List[int]:
    """Get list of ports currently in use by GIS containers"""
    containers = docker_client.containers.list(filters={"name": "gis-"})
    used_ports = []
    for container in containers:
        match = re.search(r'gis-(\d+)', container.name)
        if match:
            used_ports.append(int(match.group(1)))
    return used_ports

def get_available_ports(exclude: List[int] = []) -> List[int]:
    """Find an available port for a new GIS container"""
    start, end = 10000, 10100
    d = {i: True for i in range(start, end)}
    used_ports = get_used_ports()
    for p in used_ports:
        d[p] = False
    for p in exclude:
        d[p] = False

    l = []
    for i in range(start, end):
        if d[i]:
            l.append(i)
    return l

async def start_gsi_on_port(port: int, code: str, match_id: str) -> str:
    """Start a new GIS container and return its websocket URL"""
    container_name = f"gis-{port}"
    
    # Start the container with port forwarding and code
    container = docker_client.containers.run(
        os.getenv("GIS_IMAGE"),  # Use the image built from the Dockerfile
        name=container_name,
        detach=True,
        ports={'9999': port},
        command=["./project.x86_64", "--server", "--headless", "--code", code, "--match-id", match_id]
    )
    
    # Return the websocket URL
    return f"ws://localhost:{port}"

async def start_gsi(code: str, match_id: str) -> str:
    ports = get_available_ports()
    for port in ports:
        try:
            res = await start_gsi_on_port(port, code, match_id)
            return res
        except Exception as e:
            print(e)
            continue
    
    raise Exception("No available ports")

async def kill_gsi(port: int):
    container = docker_client.containers.get(f"gis-{port}")
    container.stop()
    container.remove(force=True)
