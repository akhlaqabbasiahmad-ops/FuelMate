# Quick Fix for Connection Error

## ⚡ IMMEDIATE FIX

### Step 1: Start Backend Server

Open a **NEW** PowerShell terminal and run:

```powershell
cd "D:\my work place\PetrolMate\backend"
npm run start:dev
```

**Wait for this message:**
```
FuelMate API is running on: http://localhost:3000
```

### Step 2: Verify Backend is Running

Open your browser and go to:
```
http://localhost:3000
```

You should see a page (even if it's a 404, that's fine - means server is running).

### Step 3: Check Mobile App

The app now shows:
- **Error banner** at the top if backend is not connected
- **Detailed error messages** in the chat
- **Console logs** with connection details

## 🔍 What I Added

1. **Better Error Messages**: Shows exactly what's wrong
2. **Connection Test**: Automatically tests connection on app start
3. **Detailed Logging**: Console shows full error details
4. **Error Banner**: Visual indicator if backend is not connected

## 📱 Check Console Logs

Look for these in your Expo/Metro logs:

- 🌐 **API Request**: Shows the URL being used
- ✅ **API Response**: Shows successful connections
- ❌ **API Error Details**: Shows full error information
- 🔗 **Connection test**: Shows if backend is reachable

## 🛠️ Common Solutions

### If you see "Cannot connect to backend server":

1. **Backend not running?**
   ```powershell
   cd backend
   npm run start:dev
   ```

2. **Wrong URL?**
   - Android Emulator: Should use `http://10.0.2.2:3000`
   - Check console logs for actual URL being used

3. **Firewall blocking?**
   - Allow Node.js through Windows Firewall
   - Or temporarily disable firewall to test

### If you see "ECONNREFUSED":

- Backend is definitely not running
- Start backend server first

### If you see "ERR_NETWORK":

- Network issue
- Check WiFi connection
- Check if using VPN (disable it)
- For physical device: Ensure same WiFi network

## ✅ Success Indicators

When everything works, you'll see:
- ✅ No error banner
- ✅ API Response received in console
- ✅ Messages get AI responses
- ✅ No connection errors

## 🚀 Test It Now

1. Start backend: `cd backend && npm run start:dev`
2. Open mobile app
3. Check for error banner (should be gone if backend is running)
4. Send a test message: "I need petrol"
5. Should get AI response!

