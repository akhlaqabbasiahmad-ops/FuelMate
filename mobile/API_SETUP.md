# API Setup Guide

## Current Configuration

The app is configured to connect to the backend API automatically based on the platform:

- **Android Emulator**: `http://10.0.2.2:3000` (automatically uses this)
- **iOS Simulator**: `http://localhost:3000` (automatically uses this)
- **Physical Device**: You need to update the IP address manually

## For Physical Device Testing

If you're testing on a physical Android/iOS device, you need to:

1. **Find your computer's local IP address**:
   ```powershell
   ipconfig
   ```
   Look for "IPv4 Address" (e.g., `192.168.1.100`)

2. **Update the API URL** in `mobile/src/services/api.ts`:
   ```typescript
   // Change this line for physical device:
   return 'http://YOUR_LOCAL_IP:3000';  // e.g., 'http://192.168.1.100:3000'
   ```

3. **Make sure backend is running**:
   ```powershell
   cd backend
   npm run start:dev
   ```

4. **Ensure same WiFi network**:
   - Your computer and phone must be on the same WiFi network
   - Check Windows Firewall allows connections on port 3000

## Testing the Connection

1. Start the backend server:
   ```powershell
   cd backend
   npm run start:dev
   ```
   Should see: `FuelMate API is running on: http://localhost:3000`

2. Start the mobile app:
   ```powershell
   cd mobile
   npx expo start --clear
   ```

3. Test the connection:
   - Select a role (Needy/Provider)
   - Send a message in the chat
   - Should receive AI agent response

## Troubleshooting

### "Failed to connect to server"

1. **Check backend is running**:
   - Open browser: `http://localhost:3000`
   - Should see NestJS welcome page or 404 (which is normal)

2. **Check API URL**:
   - Android Emulator: Must use `10.0.2.2:3000`
   - Physical Device: Must use your computer's IP (not localhost)

3. **Check Firewall**:
   - Windows Firewall might be blocking port 3000
   - Allow Node.js through firewall

4. **Check Network**:
   - Physical device and computer must be on same WiFi
   - Try disabling VPN if active

### Test Backend Directly

Test the backend API directly:
```powershell
curl -X POST http://localhost:3000/api/agent/process -H "Content-Type: application/json" -d "{\"role\":\"needy\",\"latitude\":24.8607,\"longitude\":67.0011,\"message\":\"I need petrol\"}"
```

If this works, the backend is fine and the issue is with mobile app connection.

