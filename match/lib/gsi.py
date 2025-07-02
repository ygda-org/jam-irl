import docker
import re
import os
from typing import List
import json
import time
import asyncio

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
    start, end = int(os.getenv("GIS_PORT_RANGE_START")), int(os.getenv("GIS_PORT_RANGE_END"))
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

async def wait_for_container(container_name: str, max_retries: int = 5, retry_delay: float = 1.0) -> bool:
    """Wait for container to be running and healthy"""
    for r in range(max_retries):
        print(f"retry {r}")
        try:
            container = docker_client.containers.get(container_name)
            if container.status == "running":
                # Check if the container is actually ready by checking its logs
                logs = container.logs().decode('utf-8')
                print(logs)
                if "Started game instance" in logs:  # Adjust this based on your actual log message
                    return True
        except Exception as e:
            print("Exception in retry", e)
            pass
        await asyncio.sleep(retry_delay)
    return False

async def start_gsi_on_port(port: int, code: str, match_id: str) -> str:
    """Start a new GIS container and return its websocket URL"""
    container_name = f"gis-{port}"
    
    try:
        # Start the container with port forwarding and code
        container = docker_client.containers.run(
            os.getenv("GIS_IMAGE"),  # Use the image built from the Dockerfile
            name=container_name,
            detach=True,
            ports={'9999': port},
            command=["./project.x86_64", "--server", "--headless", "--code", code, "--match-id", match_id]
        )
        
        status = await wait_for_container(container_name)
        if not status:
            raise Exception("Container started but did not start game instance")

        # Return the websocket URL
        return f"ws://{os.getenv('GIS_CLUSTER_IP')}:{port}"
    except Exception as e:
        # Clean up on any error
        try:
            await kill_container(container_name)
        except:
            pass
        raise e

async def start_gsi(code: str, match_id: str) -> str:
    ports = get_available_ports()
    for port in ports:
        try:
            res = await start_gsi_on_port(port, code, match_id)
            return res
        except Exception as e:
            print(e)
            # continue
    
    raise Exception("No available ports")

async def get_logs(port: int) -> str:
    container = docker_client.containers.get(f"gis-{port}")
    return container.logs().decode('utf-8')

async def kill_gsi(port: int):
    await kill_container(f"gis-{port}")

async def kill_container(container_name: str):
    container = docker_client.containers.get(container_name)
    container.stop()
    container.remove(force=True)
