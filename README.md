# FuelMate - Complete AI Agent Platform

FuelMate is an on-demand petrol delivery platform connecting Petrol Needers with Petrol Providers, powered by an intelligent AI agent.

## Project Structure

```
PetrolMate/
├── backend/          # NestJS backend API
│   ├── src/
│   │   ├── agent/   # AI agent module
│   │   ├── location/# Location matching service
│   │   └── safety/  # Safety validation
│   └── package.json
│
└── mobile/          # React Native mobile app
    ├── src/
    │   ├── screens/ # App screens
    │   ├── services/# API services
    │   └── context/ # React contexts
    └── package.json
```

## Features

- 🤖 **AI Agent**: Natural language understanding (English/Urdu)
- 📍 **Location Matching**: Find nearest users based on coordinates
- ✅ **Safety Validation**: Legal compliance and safety checks
- 💬 **Chat Interface**: User-friendly mobile chat UI
- 🎯 **Intent Detection**: Smart intent classification
- 🔄 **Role-Based Actions**: Different actions for Needers and Providers

## Backend Setup (NestJS)

```bash
cd backend
npm install
npm run start:dev
```

The API will run on `http://localhost:3000`

### API Endpoint

**POST** `/api/agent/process`

Request body:
```json
{
  "role": "needy" | "provider",
  "latitude": 24.8607,
  "longitude": 67.0011,
  "message": "I need petrol urgently"
}
```

Response:
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

## Mobile App Setup (React Native)

```bash
cd mobile
npm install
npm start
```

Then press:
- `a` for Android
- `i` for iOS
- `w` for web

### Prerequisites

- Node.js 16+
- Expo CLI (`npm install -g expo-cli`)
- Android Studio (for Android) or Xcode (for iOS)

## Intent Types

- `create_petrol_request` - Create a new petrol request
- `accept_petrol_request` - Accept a delivery request
- `cancel_request` - Cancel a request
- `update_location` - Update user location
- `find_nearest_provider` - Find nearby providers
- `find_nearest_needy` - Find nearby needers
- `track_request` - Track request status
- `complete_delivery` - Mark delivery as complete
- `unknown_intent` - Fallback intent

## Safety Features

- Message validation for unsafe content
- Role-based action validation
- Legal compliance checks
- Response sanitization

## Development

### Backend
- TypeScript
- NestJS framework
- Geolib for location calculations
- Class-validator for request validation

### Mobile
- React Native with Expo
- TypeScript
- React Navigation
- Expo Location
- Axios for API calls

## License

MIT
