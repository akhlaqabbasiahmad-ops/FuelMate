# FuelMate Mobile App

React Native mobile application for FuelMate platform.

## Prerequisites

- Node.js 16+
- Expo CLI: `npm install -g expo-cli`
- For Android: Android Studio
- For iOS: Xcode (macOS only)

## Installation

```bash
npm install
```

## Running the app

```bash
# Start Expo development server
npm start

# Run on Android
npm run android

# Run on iOS
npm run ios

# Run on web
npm run web
```

## Configuration

Update API URL in `src/services/api.ts`:

```typescript
const API_BASE_URL = __DEV__
  ? 'http://YOUR_LOCAL_IP:3000'  // Change this to your local IP
  : 'https://your-production-api.com';
```

For Android emulator, use `http://10.0.2.2:3000`
For iOS simulator, use `http://localhost:3000`

## Features

- Role selection (Needy/Provider)
- AI-powered chat interface
- Location-based matching
- Real-time request tracking
- Action buttons for quick actions

## Project Structure

```
src/
├── screens/          # App screens
│   ├── RoleSelectionScreen.tsx
│   └── ChatScreen.tsx
├── services/         # API services
│   └── api.ts
└── context/          # React contexts
    ├── LocationContext.tsx
    └── UserRoleContext.tsx
```

