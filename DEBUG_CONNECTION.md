# Debug Connection Issues

## Current Error
```
Network Error when connecting to http://10.0.2.2:3000
```

## Step-by-Step Debugging

### Step 1: Verify Backend is Running

```powershell
cd backend
npm run start:dev
```

**Expected output:**
```
FuelMate API is running on:
  - http://localhost:3000
  - http://0.0.0.0:3000
  - Accessible from network on your local IP
```

### Step 2: Test Backend Health Endpoint

Open browser or PowerShell:

```powershell
# Test health endpoint
curl http://localhost:3000/health

# Or in browser:
http://localhost:3000/health
```

**Expected response:**
```json
{
  "status": "ok",
  "message": "FuelMate API is running",
  "timestamp": "..."
}
```

### Step 3: Test from PowerShell Script

```powershell
cd backend
.\TEST_CONNECTION.ps1
```

This will test if backend is accessible.

### Step 4: Check Android Emulator Network

The Android emulator uses `10.0.2.2` to access host machine's `localhost`.

**Verify:**
1. Backend is running on `0.0.0.0:3000` ✅ (already fixed)
2. Backend is accessible from browser ✅
3. Check Windows Firewall isn't blocking

### Step 5: Check Windows Firewall

```powershell
# Check if port 3000 is listening
netstat -ano | findstr :3000
```

Should show Node.js process listening.

**If blocked by firewall:**
1. Open Windows Defender Firewall
2. Allow Node.js through firewall
3. Or create inbound rule for port 3000

### Step 6: Test API Endpoint Directly

```powershell
# Test the actual API endpoint
curl -X POST http://localhost:3000/api/agent/process `
  -H "Content-Type: application/json" `
  -d '{\"role\":\"needy\",\"latitude\":24.8607,\"longitude\":67.0011,\"message\":\"test\"}'
```

## Common Solutions

### Solution 1: Backend Not Running
**Fix:** Start backend server
```powershell
cd backend
npm run start:dev
```

### Solution 2: Backend Not Listening on 0.0.0.0
**Fix:** Already fixed! Backend now listens on `0.0.0.0`

### Solution 3: Firewall Blocking
**Fix:** Allow Node.js through Windows Firewall

### Solution 4: Wrong URL in Mobile App
**Fix:** Check `mobile/src/services/api.ts` - should use `10.0.2.2:3000` for Android

### Solution 5: CORS Issues
**Fix:** Already configured! CORS allows all origins

## Quick Test Commands

```powershell
# 1. Test backend health
curl http://localhost:3000/health

# 2. Test API endpoint
curl -X POST http://localhost:3000/api/agent/process -H "Content-Type: application/json" -d '{\"role\":\"needy\",\"latitude\":24.8607,\"longitude\":67.0011,\"message\":\"test\"}'

# 3. Check what's listening on port 3000
netstat -ano | findstr :3000

# 4. Test connection script
cd backend
.\TEST_CONNECTION.ps1
```

## What I Added

1. **Health Endpoint** (`/health`) - Easy way to test if backend is running
2. **Better Connection Test** - Uses health endpoint instead of API endpoint
3. **Test Script** - `TEST_CONNECTION.ps1` to verify backend accessibility
4. **Improved CORS** - Added OPTIONS method and headers

## Next Steps

1. **Restart Backend:**
   ```powershell
   cd backend
   npm run start:dev
   ```

2. **Test Health Endpoint:**
   ```powershell
   curl http://localhost:3000/health
   ```

3. **Check Mobile App:**
   - Should now show connection test results
   - Check console for health check logs

4. **If Still Failing:**
   - Check Windows Firewall
   - Verify backend is actually running
   - Check `netstat -ano | findstr :3000`

