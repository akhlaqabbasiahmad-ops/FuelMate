# FuelMate Backend API

NestJS backend for FuelMate AI Agent system.

## Installation

```bash
npm install
```

## Running the app

```bash
# development
npm run start:dev

# production mode
npm run start:prod
```

## API Documentation

### POST /api/agent/process

Process user message and return AI agent response.

**Request:**
```json
{
  "role": "needy" | "provider",
  "latitude": 24.8607,
  "longitude": 67.0011,
  "message": "I need petrol urgently"
}
```

**Response:**
```json
{
  "intent": "create_petrol_request",
  "actions": [
    {
      "title": "Create Petrol Request",
      "description": "Create a new request for petrol delivery",
      "apiEndpoint": "/api/requests/create",
      "payload": {
        "latitude": 24.8607,
        "longitude": 67.0011
      }
    }
  ],
  "naturalResponse": "I'll help you create a petrol request. Finding nearby providers..."
}
```

## Project Structure

```
src/
├── agent/              # AI Agent module
│   ├── dto/           # Data Transfer Objects
│   ├── agent.controller.ts
│   ├── agent.service.ts
│   └── intent-detector.service.ts
├── location/          # Location matching service
├── safety/           # Safety validation
└── main.ts           # Application entry point
```

## Database Setup

This project uses **PostgreSQL** as the database.

### 1. Install PostgreSQL

Download and install PostgreSQL from: https://www.postgresql.org/download/

### 2. Create Database

```sql
CREATE DATABASE fuelmate;
```

### 3. Environment Variables

Create a `.env` file in the `backend` directory:

```env
# PostgreSQL Database Configuration
DB_HOST=localhost
DB_PORT=5432
DB_USERNAME=postgres
DB_PASSWORD=your_postgres_password
DB_NAME=fuelmate

# Environment
NODE_ENV=development
PORT=3000
```

**Note:** Replace `your_postgres_password` with your actual PostgreSQL password.

### 4. Run Migrations

The database tables will be automatically created when you start the server (synchronize is enabled in development mode).

## Environment Variables

Required environment variables:
- `DB_HOST` - PostgreSQL host (default: localhost)
- `DB_PORT` - PostgreSQL port (default: 5432)
- `DB_USERNAME` - PostgreSQL username (default: postgres)
- `DB_PASSWORD` - PostgreSQL password (default: postgres)
- `DB_NAME` - Database name (default: fuelmate)
- `NODE_ENV` - Environment (development/production)
- `PORT` - Server port (default: 3000)

