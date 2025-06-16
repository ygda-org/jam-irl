from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
import random
import string
from lib.db import prisma

router = APIRouter()

class UserCreate(BaseModel):
    pass

class UserResponse(BaseModel):
    userId: str

@router.post("/", response_model=UserResponse)
async def create_user():
    user = await prisma.user.create(
        data={
            "matchIds": []
        }
    )
    return {"userId": user.id} 

@router.get("/{user_id}")
async def get_user(user_id: str):
    user = await prisma.user.find_unique(
        where={"id": user_id},
        include={"matches": True, "createdMatches": True}
    )
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return user
