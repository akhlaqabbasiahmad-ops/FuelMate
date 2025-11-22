# Connection Troubleshooting Guide

## Quick Fix Steps

### Step 1: Check Backend is Running

Open a **NEW** terminal window and run:

```powershell
cd backend
npm run start:dev
```

**Expected output:**
```
FuelMate API is running on: http://localhost:3000
```

### Step 2: Verify Backend is Accessible

Open your browser and go to:
```
http://localhost:3000
```

You should see:
- NestJS welcome page, OR
- A 404 page (this is normal - means server is running)

### Step 3: Check Mobile App Connection

The app now shows detailed error messages. Check the console/logs for:
- 🌐 API Request details
- ❌ API Error Details with full error information

## Common Issues & Solutions

### Issue 1: "Cannot connect to backend server"

**Cause:** Backend is not running

**Solution:**
1. Start backend in a separate terminal:
   ```powershell
   cd backend
   npm run start:dev
   ```
2. Wait for "FuelMate API is running on: http://localhost:3000"
3. Try sending a message again

### Issue 2: "ECONNREFUSED" or "ERR_NETWORK"

**Cause:** Network/firewall blocking connection

**Solutions:**

**For Android Emulator:**
- Should automatically use `http://10.0.2.2:3000`
- If not working, check `mobile/src/services/api.ts` has correct URL

**For Physical Device:**
1. Find your computer's IP:
   ```powershell
   ipconfig
   ```
   Look for "IPv4 Address" (e.g., `192.168.1.100`)

2. Update `mobile/src/services/api.ts`:
   ```typescript
   // In getApiUrl() function, add:
   if (Platform.OS === 'android' && !__DEV__) {
     return 'http://192.168.1.100:3000'; // Your IP
   }
   ```

3. Ensure same WiFi network:
   - Computer and phone must be on same WiFi
   - Disable VPN if active

**For Windows Firewall:**
1. Open Windows Defender Firewall
2. Allow Node.js through firewall
3. Or temporarily disable firewall to test

### Issue 3: "Server error: 404"

**Cause:** Wrong API endpoint

**Solution:**
- Check backend route is `/api/agent/process`
- Verify backend controller is set up correctly
- Check `backend/src/agent/agent.controller.ts`

### Issue 4: "Timeout" error

**Cause:** Backend is slow or not responding

**Solution:**
1. Check backend logs for errors
2. Restart backend server
3. Check backend is not stuck processing

## Testing the Connection

### Test Backend Directly (PowerShell)

```powershell
# Test if backend responds
curl http://localhost:3000

# Test the API endpoint
curl -X POST http://localhost:3000/api/agent/process `
  -H "Content-Type: application/json" `
  -d '{\"role\":\"needy\",\"latitude\":24.8607,\"longitude\":67.0011,\"message\":\"test\"}'
```

### Test from Mobile App

1. Open the app
2. Check console/logs for connection test
3. Send a test message
4. Check error details in console

## Debug Information

The app now logs detailed information:

- **🌐 API Request:** Shows URL, platform, and request data
- **✅ API Response:** Shows successful responses
- **❌ API Error Details:** Shows full error information including:
  - Error code
  - Error message
  - Response status (if any)
  - Request URL

## Step-by-Step Debugging

1. **Check Backend Status:**
   ```powershell
   # Terminal 1 - Backend
   cd backend
   npm run start:dev
   ```

2. **Check Mobile App Logs:**
   ```powershell
   # Terminal 2 - Mobile
   cd mobile
   npx expo start
   # Look for connection test logs
   ```

3. **Check Network:**
   - Android Emulator: Should use `10.0.2.2:3000`
   - Physical Device: Check IP address matches

4. **Check Firewall:**
   - Windows Firewall might block port 3000
   - Allow Node.js through firewall

## Still Not Working?

1. **Restart Everything:**
   - Stop backend (Ctrl+C)
   - Stop mobile app (Ctrl+C)
   - Restart backend
   - Restart mobile app

2. **Check Port 3000:**
   ```powershell
   netstat -ano | findstr :3000
   ```
   Should show Node.js process

3. **Try Different Port:**
   - Change backend port in `backend/src/main.ts`
   - Update mobile API URL accordingly

4. **Check Backend Logs:**
   - Look for CORS errors
   - Look for route registration
   - Check if `/api/agent/process` route exists

## Quick Checklist

- [ ] Backend is running (`npm run start:dev`)
- [ ] Backend accessible in browser (`http://localhost:3000`)
- [ ] Mobile app shows connection test in logs
- [ ] Correct API URL for your platform
- [ ] Same WiFi network (for physical device)
- [ ] Firewall allows port 3000
- [ ] No VPN interfering

