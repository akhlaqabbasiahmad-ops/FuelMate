# Physical Device Setup

## ✅ Your IP Address Found

Your computer's IP address: **192.168.1.4**

## Configuration Applied

I've updated `mobile/src/services/api.ts` to use your IP address for physical device testing.

## Quick Setup

### Step 1: Verify Configuration

The mobile app is now configured to use:
- **Physical Device**: `http://192.168.1.4:3000`
- **Emulator**: `http://10.0.2.2:3000` (when `USE_PHYSICAL_DEVICE = false`)

### Step 2: Make Sure Backend is Running

```powershell
cd backend
npm run start:dev
```

**Important:** Backend must be listening on `0.0.0.0` (already configured) so it's accessible from your network.

### Step 3: Test Connection

1. **Test from browser** (on your computer):
   ```
   http://192.168.1.4:3000/health
   ```
   Should return: `{"status":"ok","message":"FuelMate API is running",...}`

2. **Test from mobile app**:
   - Open the app
   - Check console logs for connection test
   - Should see: `🔗 Health check response: {status: 200, ...}`

### Step 4: Ensure Same WiFi Network

- Your computer and phone must be on the **same WiFi network**
- Check WiFi name matches on both devices
- Disable VPN if active (can interfere with local network)

## Switching Between Emulator and Physical Device

In `mobile/src/services/api.ts`, change:

```typescript
const USE_PHYSICAL_DEVICE = true;  // true = physical device, false = emulator
```

## Troubleshooting

### "Cannot connect" Error

1. **Check backend is running:**
   ```powershell
   # Should show Node.js process
   netstat -ano | findstr :3000
   ```

2. **Test backend from browser:**
   ```
   http://192.168.1.4:3000/health
   ```
   If this doesn't work, backend isn't accessible on network.

3. **Check Windows Firewall:**
   - Allow Node.js through firewall
   - Or create inbound rule for port 3000

4. **Verify WiFi network:**
   - Computer and phone on same WiFi
   - Try ping from phone to computer IP

### "Network Error" Still Appearing

1. **Restart backend:**
   ```powershell
   # Stop backend (Ctrl+C)
   cd backend
   npm run start:dev
   ```

2. **Check backend logs:**
   - Should see requests coming in
   - If no requests, firewall is blocking

3. **Test health endpoint:**
   ```powershell
   curl http://192.168.1.4:3000/health
   ```

## Quick Test Checklist

- [ ] Backend running (`npm run start:dev`)
- [ ] Backend accessible at `http://192.168.1.4:3000/health`
- [ ] Phone and computer on same WiFi
- [ ] `USE_PHYSICAL_DEVICE = true` in `mobile/src/services/api.ts`
- [ ] `PHYSICAL_DEVICE_IP = '192.168.1.4'` in `mobile/src/services/api.ts`
- [ ] Windows Firewall allows port 3000

## Success Indicators

✅ Health endpoint works: `http://192.168.1.4:3000/health`  
✅ Mobile app shows connection successful  
✅ No "Network Error" in console  
✅ Messages get AI responses  

## If IP Changes

If your IP address changes (e.g., different WiFi network):

1. Run `backend/FIND_IP.ps1` again
2. Update `PHYSICAL_DEVICE_IP` in `mobile/src/services/api.ts`
3. Restart mobile app

