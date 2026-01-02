# Network Setup Guide

## Problem
Backend is running on `localhost` which mobile app can't access. Backend needs to listen on all network interfaces.

## ✅ Solution Applied

I've updated the backend to listen on `0.0.0.0` (all network interfaces) instead of just `localhost`.

## Quick Start

### Step 1: Find Your IP Address

Run this script:
```powershell
cd backend
.\FIND_IP.ps1
```

Or manually:
```powershell
ipconfig
```
Look for "IPv4 Address" (e.g., `192.168.1.100`)

### Step 2: Start Backend (Updated)

The backend now listens on all interfaces. Start it:

```powershell
cd backend
npm run start:dev
```

You'll see:
```
FuelMate API is running on:
  - http://localhost:3000
  - http://0.0.0.0:3000
  - Accessible from network on your local IP
```

### Step 3: Configure Mobile App

The mobile app automatically uses:
- **Android Emulator**: `http://10.0.2.2:3000` ✅ (works automatically)
- **iOS Simulator**: `http://localhost:3000` ✅ (works automatically)
- **Physical Device**: Needs your computer's IP

#### For Physical Device:

1. Find your IP (run `backend/FIND_IP.ps1`)
2. Update `mobile/src/services/api.ts`:

```typescript
// In getApiUrl() function, change:
if (Platform.OS === 'android') {
  return 'http://YOUR_IP_HERE:3000'; // e.g., 'http://192.168.1.100:3000'
}
```

## Testing Connection

### Test Backend from Browser
```
http://localhost:3000
```
Should show NestJS page or 404 (means server is running)

### Test from Mobile App
1. Start backend: `cd backend && npm run start:dev`
2. Start mobile app: `cd mobile && npm start`
3. Check console logs for connection test
4. Send a test message

## Troubleshooting

### Still Can't Connect?

1. **Check Backend is Running:**
   ```powershell
   # Should see process listening on port 3000
   netstat -ano | findstr :3000
   ```

2. **Check Firewall:**
   - Windows Firewall might block port 3000
   - Allow Node.js through firewall
   - Or temporarily disable firewall to test

3. **Check Network:**
   - Physical device and computer must be on same WiFi
   - Disable VPN if active
   - Try ping from device to computer IP

4. **Check CORS:**
   - Backend already has CORS enabled for all origins
   - Should work automatically

### For Android Emulator

Should work automatically with `10.0.2.2:3000`. If not:
- Check backend is running
- Check backend listens on `0.0.0.0` (already fixed)
- Restart emulator

### For Physical Device

1. Find computer IP: `ipconfig` or `backend/FIND_IP.ps1`
2. Update mobile app API URL with that IP
3. Ensure same WiFi network
4. Check firewall allows connections

## What Changed

1. **Backend (`backend/src/main.ts`):**
   - Changed from `app.listen(port)` to `app.listen(port, '0.0.0.0')`
   - Now listens on all network interfaces
   - Mobile app can connect from emulator or physical device

2. **Mobile App (`mobile/src/services/api.ts`):**
   - Already configured for Android emulator (`10.0.2.2`)
   - Already configured for iOS simulator (`localhost`)
   - Just needs IP update for physical device

## Quick Commands

```powershell
# Find your IP
cd backend
.\FIND_IP.ps1

# Start backend (listens on all interfaces)
cd backend
npm run start:dev

# Start mobile app
cd mobile
npm start
```

## Success Indicators

✅ Backend shows "listening on 0.0.0.0"  
✅ Mobile app connects without errors  
✅ Messages get AI responses  
✅ No "Failed to connect" errors  

