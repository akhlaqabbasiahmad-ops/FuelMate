# FuelMate Quick Start Guide

## Prerequisites

- Node.js 16+ installed
- npm or yarn package manager
- For mobile: Expo CLI (`npm install -g expo-cli`)
- For Android: Android Studio
- For iOS: Xcode (macOS only)

## Step 1: Setup Backend

```bash
cd backend
npm install
npm run start:dev
```

Backend will run on `http://localhost:3000`

## Step 2: Setup Mobile App

Open a new terminal:

```bash
cd mobile
npm install
```

### Configure API URL

Edit `mobile/src/services/api.ts` and update the API_BASE_URL:

```typescript
const API_BASE_URL = __DEV__
  ? 'http://YOUR_LOCAL_IP:3000'  // Replace with your local IP address
  : 'https://your-production-api.com';
```

**Important:** 
- For Android Emulator: Use `http://10.0.2.2:3000`
- For iOS Simulator: Use `http://localhost:3000`
- For Physical Device: Use your computer's local IP (e.g., `http://192.168.1.100:3000`)

### Start Mobile App

```bash
npm start
```

Then press:
- `a` for Android
- `i` for iOS  
- `w` for web

## Step 3: Test the App

1. **Select Role**: Choose "I Need Petrol" or "I Provide Petrol"
2. **Grant Location Permission**: Allow location access when prompted
3. **Start Chatting**: Try messages like:
   - "I need petrol urgently"
   - "Find nearby providers"
   - "Show me nearest needers" (if provider)
   - "Track my request"

## Troubleshooting

### Backend not connecting?
- Check if backend is running on port 3000
- Verify API URL in `mobile/src/services/api.ts`
- Check firewall settings

### Location not working?
- Ensure location permissions are granted
- For iOS: Check Info.plist permissions
- For Android: Check AndroidManifest.xml permissions

### Build errors?
- Clear node_modules and reinstall: `rm -rf node_modules && npm install`
- Clear Expo cache: `expo start -c`

## Next Steps

- Add database integration (MongoDB/PostgreSQL)
- Implement real-time updates (WebSockets)
- Add user authentication
- Deploy backend to cloud (Heroku, AWS, etc.)
- Build and publish mobile app

