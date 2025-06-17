# jam-irl

A real-time multiplayer game platform built for YGDA Jam-IRL, featuring a Godot game client, FastAPI matchmaking server, and containerized game instance servers.

## Project Structure

```
jam-irl/
├── client/          # Web client for serving game files
├── game/            # Godot game client
├── match/           # FastAPI matchmaking server
└── server/          # Docker configuration for game instance servers
```

## Components

### 🎮 Game Client (`game/`)
- **Engine**: Godot 4.x
- **Features**: 
  - Multiplayer networking with WebSocket support
  - Automated server/client mode detection via command line args
  - HTTP request abstraction for matchmaking API communication
  - Scene management and UI systems
- **Key Files**:
  - `game.tscn` - Main game scene
  - `globals/` - Global singletons for networking, logging, and HTTP requests
  - `addons/awaitable_http_request/` - HTTP request plugin

### 🌐 Matchmaking Server (`match/`)
- **Framework**: FastAPI with MongoDB/Prisma
- **Features**:
  - User management and session handling
  - Match creation with unique codes
  - Game Instance Server (GIS) container orchestration
  - Docker container lifecycle management
  - Comprehensive error handling and logging middleware
- **API Endpoints**:
  - `POST /user/` - Create new user session
  - `POST /match/create` - Create new match and start GIS container
  - `POST /match/join` - Join existing match by code
  - `POST /match/end` - End match and cleanup GIS container
  - `GET /match/{id}` - Get match details

### 🐳 Game Instance Servers (`server/`)
- **Technology**: Dockerized Godot headless servers
- **Features**:
  - Automatic port allocation (10000-10100 range)
  - Dynamic container creation/destruction
  - WebSocket game server hosting
  - Match code integration

### 📁 Web Client (`client/`)
- Simple web server for serving game files

## Quick Start

### Prerequisites
- Python 3.8+
- Docker and Docker Compose
- MongoDB instance
- Godot 4.x (for development)

### 1. Setup Matchmaking Server
```bash
cd match/
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate
pip install -r requirements.txt

# Configure environment
cp .env.example .env
# Edit .env with your MongoDB URI and GIS image name

# Setup database
prisma generate
python main.py
```

### 2. Build Game Instance Server Image
```bash
cd server/
chmod +x scripts/build.sh
./scripts/build.sh
```

### 3. Run Game Client
```bash
cd game/
# Open in Godot editor and run, or export and run executable
```

## Architecture

### Match Flow
1. **User Registration**: Client requests user ID from matchmaking server
2. **Match Creation**: User creates match, server starts GIS container with unique code
3. **Match Joining**: Other users join via match code
4. **Game Session**: Players connect to GIS WebSocket server
5. **Match Cleanup**: Creator ends match, GIS container is destroyed

### Networking
- **Client ↔ Matchmaking**: HTTP/REST API
- **Client ↔ GIS**: WebSocket for real-time game data
- **Matchmaking ↔ GIS**: Docker container management

### Error Handling
The matchmaking server includes comprehensive error handling:
- Custom middleware catches all exceptions at ASGI level
- Detailed error responses with stack traces in debug mode
- Proper HTTP status codes and error types
- Automatic container cleanup on failures

## Development

### Game Client Development
```bash
cd game/
# Open project.godot in Godot Editor
# Use --server flag for headless server mode
# Use --port and --code flags for direct server connection
```

### API Development
```bash
cd match/
uvicorn main:app --reload
# Access API docs at http://localhost:8000/docs
```

### Testing Match Flow
1. Start matchmaking server
2. Create user: `POST /user/`
3. Create match: `POST /match/create` with userId
4. Join match: `POST /match/join` with userId and match code
5. Connect game clients to the returned GIS WebSocket URL

## Configuration

### Environment Variables (`match/.env`)
```
MONGODB_URI=mongodb://localhost:27017/jam-irl
GIS_IMAGE=jam-irl-gis:latest
```

### Game Configuration
- Match codes: 6-character alphanumeric
- Port range: 10000-10100 for GIS containers
- WebSocket protocol for real-time communication

## API Reference

### User Endpoints
- `POST /user/` - Create user session
  - Response: `{"userId": "string"}`

### Match Endpoints
- `POST /match/create` - Create new match
  - Body: `{"userId": "string"}`
  - Response: `{"match": {...}}`

- `POST /match/join` - Join existing match
  - Body: `{"userId": "string", "code": "string"}`
  - Response: `{"match": {...}}`

- `POST /match/end` - End match (creator only)
  - Body: `{"userId": "string", "matchId": "string"}`
  - Response: `{"match": {...}}`

- `GET /match/{matchId}` - Get match details
  - Response: `{"match": {...}}`

## Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open Pull Request

## License

This project is part of the YGDA Jam-IRL event.
