# Quick Test Steps - Two Real Users

## ⚡ Quick Test Process

### Step 1: Start Backend
```powershell
cd backend
npm run start:dev
```

**Watch for logs:**
- `FuelMate API is running on: http://localhost:3000`

### Step 2: User 1 (Needy) - Create Request

**On Device 1:**
1. Open app → Select "I Need Petrol"
2. Go to Chat screen
3. Send message: **"I need petrol urgently"**
4. Tap **"Create Petrol Request"** button
5. Should see: "Request created! ID: req_..."

**Check Backend Logs:**
```
📝 Creating request for user: needy_...
📍 Location: 31.497, 74.415
✅ Request created: req_...
```

### Step 3: User 2 (Provider) - Find Requests

**On Device 2:**
1. Open app → Select "I Provide Petrol"
2. Go to Chat screen
3. Send message: **"Show me nearest requests"**
4. Tap **"Find Nearest Requests"** button
5. Should navigate to Requests screen
6. Should see the request from User 1

**Check Backend Logs:**
```
🔍 Provider searching for requests: ...
📍 Provider location registered: provider_...
📊 Total requests in system: 1
📋 Pending requests: 1
📍 Requests within 50km: 1
✅ Returning 1 requests
```

## 🔍 Debugging - Check Backend Logs

### If No Requests Showing:

**Check these logs in backend terminal:**

1. **Request Creation:**
   ```
   📝 Creating request for user: needy_...
   ✅ Request created: req_...
   ```

2. **Provider Search:**
   ```
   📊 Total requests in system: X
   📋 Pending requests: X
   📍 Requests within 50km: X
   ```

3. **Provider Registration:**
   ```
   📍 Provider location registered: provider_...
   ```

### If Still No Results:

1. **Check distance:**
   - Max distance is set to 50km
   - Check if users are within 50km of each other
   - Check backend logs for distance calculation

2. **Check request status:**
   - Only "pending" requests are shown
   - Check backend logs: "📋 Pending requests: X"

3. **Check location registration:**
   - Provider location must be registered
   - Check logs: "📍 Provider location registered"

## 🧪 Manual Test Commands

### Create a Test Request:
```powershell
curl -X POST http://192.168.1.4:3000/api/requests/create `
  -H "Content-Type: application/json" `
  -d '{\"latitude\":31.497,\"longitude\":74.415,\"message\":\"Test request\",\"urgency\":\"urgent\",\"userId\":\"test_needy\"}'
```

### Search for Requests:
```powershell
curl "http://192.168.1.4:3000/api/requests/nearest?latitude=31.497&longitude=74.415&maxDistance=50&limit=10&providerId=test_provider"
```

### Check All Requests (Debug):
Look at backend console - it shows:
- Total requests created
- Pending requests count
- Requests within distance
- Distance calculations

## ✅ Success Indicators

**Backend Logs Show:**
- ✅ Request created successfully
- ✅ Provider location registered
- ✅ Requests found within distance
- ✅ Distance calculated correctly

**Mobile App Shows:**
- ✅ Requests screen displays requests
- ✅ Distance shown for each request
- ✅ Urgency badges visible
- ✅ Accept button works

## 🐛 Common Issues

### Issue: "No requests found"

**Check:**
1. Is request actually created? (Check backend logs)
2. Is request status "pending"? (Only pending shown)
3. Are users within 50km? (Check distance in logs)
4. Is provider location registered? (Check logs)

**Fix:**
- Increase maxDistance in RequestsScreen (already 50km)
- Check backend console for detailed logs
- Verify request creation succeeded

### Issue: "Provider not finding requests"

**Check:**
1. Request exists (backend logs: "Total requests: X")
2. Provider location registered (logs: "Provider location registered")
3. Distance calculation (logs show distance)

**Fix:**
- Check backend logs show provider registration
- Verify request is "pending" status
- Check distance is within 50km

## 📱 Testing Checklist

- [ ] Backend running and showing logs
- [ ] User 1 creates request successfully
- [ ] Backend logs show request created
- [ ] User 2 searches for requests
- [ ] Backend logs show provider registered
- [ ] Backend logs show requests found
- [ ] User 2 sees request in app
- [ ] Distance displayed correctly
- [ ] Accept button works

