# How to Run FuelMate Backend and Mobile App

## Prerequisites

1. **Node.js** (v16 or higher) - [Download here](https://nodejs.org/)
2. **npm** (comes with Node.js)
3. **Expo CLI** (for mobile app) - Install globally: `npm install -g expo-cli`

## Step-by-Step Instructions

### Option 1: Manual Setup (Recommended for first time)

#### **Terminal 1: Backend Server**

1. Open PowerShell or Command Prompt
2. Navigate to backend directory:
   ```powershell
   cd "D:\my work place\PetrolMate\backend"
   ```
3. Install dependencies (first time only):
   ```powershell
   npm install
   ```
4. Start the backend server:
   ```powershell
   npm run start:dev
   ```
5. Wait for message: `FuelMate API is running on: http://localhost:3000`

#### **Terminal 2: Mobile App**

1. Open a **NEW** PowerShell or Command Prompt window
2. Navigate to mobile directory:
   ```powershell
   cd "D:\my work place\PetrolMate\mobile"
   ```
3. Install dependencies (first time only):
   ```powershell
   npm install
   ```
4. **Important**: Update API URL in `mobile/src/services/api.ts`:
   - For Android Emulator: Use `http://10.0.2.2:3000`
   - For iOS Simulator: Use `http://localhost:3000`
   - For Physical Device: Use your computer's local IP (e.g., `http://192.168.1.100:3000`)
   
   To find your local IP:
   - Windows: Run `ipconfig` in PowerShell and look for IPv4 Address
   - Example: `http://192.168.1.100:3000`

5. Start the mobile app:
   ```powershell
   npm start
   ```
6. In the Expo menu, press:
   - `a` - Run on Android emulator
   - `i` - Run on iOS simulator (macOS only)
   - `w` - Run in web browser
   - Scan QR code with Expo Go app on your phone

### Option 2: Using PowerShell Scripts

I've created helper scripts for Windows. See `run-backend.ps1` and `run-mobile.ps1` files.

## Quick Commands Reference

### Backend
```powershell
cd backend
npm install          # First time only
npm run start:dev    # Start development server
```

### Mobile
```powershell
cd mobile
npm install          # First time only
npm start            # Start Expo development server
```

## Troubleshooting

### Backend Issues

**Port 3000 already in use:**
- Change port in `backend/src/main.ts` or kill the process using port 3000
- Windows: `netstat -ano | findstr :3000` then `taskkill /PID <pid> /F`

**Dependencies not installing:**
- Delete `node_modules` folder and `package-lock.json`
- Run `npm install` again

### Mobile Issues

**Cannot connect to backend:**
- Make sure backend is running on port 3000
- Check API URL in `mobile/src/services/api.ts`
- For physical device, ensure phone and computer are on same WiFi network
- Check Windows Firewall settings

**Expo not starting:**
- Clear cache: `expo start -c`
- Reinstall: Delete `node_modules` and run `npm install` again

**Location permission denied:**
- Android: Check app permissions in Settings
- iOS: Check Info.plist permissions

## Testing the Apps

1. **Backend Test:**
   - Open browser: `http://localhost:3000`
   - Should see NestJS welcome page or 404 (which is normal)

2. **API Test:**
   - Use Postman or curl to test:
   ```powershell
   curl -X POST http://localhost:3000/api/agent/process -H "Content-Type: application/json" -d '{\"role\":\"needy\",\"latitude\":24.8607,\"longitude\":67.0011,\"message\":\"I need petrol\"}'
   ```

3. **Mobile App Test:**
   - Select role (Needy/Provider)
   - Grant location permission
   - Send message: "I need petrol urgently"
   - Should receive AI agent response

## Development Tips

- **Backend auto-reloads** when you change code (thanks to `--watch` flag)
- **Mobile app hot-reloads** automatically when you save files
- Keep both terminals open while developing
- Check console logs for errors

