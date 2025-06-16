# YGDA Jam-IRL Matchmaking Server

A FastAPI-based matchmaking server for the YGDA Jam-IRL project. This server handles user creation, match creation, and match joining functionality.

## Prerequisites

- Python 3.8+
- MongoDB instance
- Prisma CLI

## Setup

1. Create a virtual environment:
```bash
python -m venv venv
source venv/bin/activate  # On Windows, use: venv\Scripts\activate
```

2. Install dependencies:
```bash
pip install -r requirements.txt
```

3. Set up environment variables:
Create a `.env` file in the root directory with:
```
MONGODB_URI=your_mongodb_connection_string
```

4. Generate Prisma client:
```bash
prisma generate
```

## Running the Server

To run the server in development mode:
```bash
uvicorn main:app --reload
```

The server will start at `http://localhost:8000`

## API Documentation

Once the server is running, you can access:
- Interactive API documentation (Swagger UI): `http://localhost:8000/docs`
- Alternative API documentation (ReDoc): `http://localhost:8000/redoc`

## API Endpoints

### User Management
- `POST /user`
  - Creates a new user
  - Response: `{ userId: string }`

### Match Management
- `POST /match/create`
  - Creates a new match
  - Request: `{ userId: string }`
  - Response: `{ match: Match }`

- `POST /match/join`
  - Joins an existing match
  - Request: `{ userId: string, code: string }`
  - Response: `{ match: Match }`

- `DELETE /room`
  - Deletes a match (only for match creator)
  - Request: `{ userId: string }`
  - Response: `{ match: Match }`

## Match Status

Matches can have the following statuses:
- `CREATED`: Initial state when match is created
- `STARTED`: Match has started
- `FINISHED`: Match has ended

## Development

### Project Structure
```
match/
├── main.py          # Server setup and configuration
├── api.py           # API routes and business logic
├── prisma/          # Prisma configuration
│   └── schema.prisma # Database schema
├── requirements.txt # Python dependencies
└── .env            # Environment variables
```

### Adding New Features
1. Update the Prisma schema if needed
2. Run `prisma generate` to update the client
3. Add new routes in `api.py`
4. Test using the Swagger UI

## Error Handling

The API includes error handling for common scenarios:
- User not found (404)
- Match not found (404)
- Match is full (400)
- No active match found (404)
