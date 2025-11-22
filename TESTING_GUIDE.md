# Testing Guide - Two Real Users

## Setup for Testing

### User 1: Needy (Needs Petrol)
1. Open app on Device 1
2. Select "I Need Petrol"
3. Grant location permission
4. Go to Chat screen

### User 2: Provider (Provides Petrol)
1. Open app on Device 2
2. Select "I Provide Petrol"
3. Grant location permission
4. Go to Chat screen

## Step-by-Step Test

### Step 1: Needy Creates Request

**On Device 1 (Needy):**
1. In Chat, send message: **"I need petrol urgently"**
2. AI will respond with action buttons
3. Tap **"Create Petrol Request"** button
4. Request is created and stored

**Expected:**
- Request created successfully
- Message: "Request created! ID: req_..."
- Can navigate to Requests screen

### Step 2: Provider Searches for Requests

**On Device 2 (Provider):**
1. In Chat, send message: **"Show me nearest requests"** or **"Find requests"**
2. AI will respond with action button
3. Tap **"Find Nearest Requests"** button
4. Navigate to Requests screen

**Expected:**
- Requests screen opens
- Shows request from Device 1 (if within 50km)
- Shows distance, message, urgency

### Step 3: Provider Accepts Request

**On Device 2 (Provider):**
1. In Requests screen, see the request
2. Tap **"Accept Request"** button
3. Request status changes to "accepted"

**Expected:**
- Request accepted successfully
- Alert: "Request accepted! Contact the needy user."
- Request disappears from list (or shows as accepted)

## Debugging Tips

### Check Backend Logs

Look for these logs in backend terminal:

```
📝 Creating request for user: needy_...
📍 Location: 31.497, 74.415
✅ Request created: req_...

🔍 Provider searching for requests: ...
📍 Provider location registered: provider_...
📊 Total requests in system: 1
📋 Pending requests: 1
📍 Requests within 50km: 1
✅ Returning 1 requests
```

### Check Mobile App Logs

Look for these in Expo/Metro logs:

```
📍 Location registered for: needy_...
📝 Creating request: ...
✅ Request created: req_...

📍 Location registered for: provider_...
🔍 Provider fetching requests...
✅ Received requests: 1
```

## Common Issues

### Issue 1: No Requests Showing

**Check:**
1. Is request actually created? Check backend logs
2. Are both users within 50km? (increased from 10km for testing)
3. Is provider location registered? Check backend logs

**Fix:**
- Increase maxDistance in RequestsScreen.tsx (already set to 50km)
- Check backend console for request creation logs
- Verify both devices have location permissions

### Issue 2: Request Not Created

**Check:**
1. Backend is running
2. API endpoint `/api/requests/create` is accessible
3. Location is available

**Fix:**
- Test endpoint: `curl -X POST http://192.168.1.4:3000/api/requests/create -H "Content-Type: application/json" -d '{"latitude":31.497,"longitude":74.415,"message":"test"}'
- Check backend logs for errors

### Issue 3: Provider Not Finding Requests

**Check:**
1. Request exists (check backend logs)
2. Provider location is registered
3. Distance calculation is correct

**Fix:**
- Check backend logs: "Total requests in system: X"
- Verify provider location registration
- Check distance calculation in logs

## Testing Checklist

- [ ] Backend running (`npm run start:dev`)
- [ ] Device 1: Needy role selected
- [ ] Device 2: Provider role selected
- [ ] Both devices have location permissions
- [ ] Device 1 creates request successfully
- [ ] Device 2 can see request in Requests screen
- [ ] Device 2 can accept request
- [ ] Backend logs show request creation
- [ ] Backend logs show request search

## Quick Test Commands

### Test Request Creation
```powershell
curl -X POST http://192.168.1.4:3000/api/requests/create `
  -H "Content-Type: application/json" `
  -d '{\"latitude\":31.497,\"longitude\":74.415,\"message\":\"Test request\",\"urgency\":\"urgent\"}'
```

### Test Finding Requests
```powershell
curl "http://192.168.1.4:3000/api/requests/nearest?latitude=31.497&longitude=74.415&maxDistance=50&limit=10&providerId=test_provider"
```

### Check All Requests (Debug)
Look at backend console - it will show:
- Total requests created
- Pending requests
- Requests within distance
- Providers registered

