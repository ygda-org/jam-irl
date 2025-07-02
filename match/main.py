from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
import uvicorn
from dotenv import load_dotenv
from api import router
from lib.db import prisma
from lib.error_middleware import ErrorLoggingMiddleware
import os

# Load environment variables
load_dotenv()

app = FastAPI(
    title="YGDA Jam-IRL API",
    description="YGDA Jam-IRL API",
    version="v0.0.1",
    debug=True  # Enable debug mode to get stack traces
)

# Add error logging middleware FIRST
app.add_middleware(ErrorLoggingMiddleware)

# Configure CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allows all origins
    allow_credentials=True,
    allow_methods=["*"],  # Allows all methods
    allow_headers=["*"],  # Allows all headers
)


# Include the API router
app.include_router(router)

@app.on_event("startup")
async def startup():
    await prisma.connect()

@app.on_event("shutdown")
async def shutdown():
    await prisma.disconnect()

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=int(os.getenv("MS_PORT"))) 