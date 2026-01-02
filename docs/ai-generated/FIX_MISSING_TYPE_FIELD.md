# Fix Existing Request - Add Type Field

## Problem
The existing request in Firestore is missing the `type` field, so quote buttons don't show.

## Solution Options

### Option 1: Manual Fix in Firebase Console (RECOMMENDED)
1. Go to: https://console.firebase.google.com/project/fuelmate-73aaf/firestore/data/~2FpetrolRequests
2. Click on your request: `req_1767281176017_BrlUirKxF`
3. Click "+ Add field"
4. Field name: `type`
5. Field value: `request`
6. Click "Save"

### Option 2: Delete and Recreate (EASIER)
1. In the app, the request won't show until indexes are ready anyway
2. Once indexes are created, delete the old request
3. Create a new request - it will have the `type` field automatically

### Option 3: Update via Code (AUTOMATIC)
I've already updated the code, so:
- **New requests** will automatically have `type: 'request'`
- **Old requests** will default to `type: 'request'` when read from Firestore

---

## What Changed in Code

**File: `firestore_request_service.dart`**

### When Creating Requests:
```dart
'type': 'request', // ✅ Now added automatically
```

### When Reading Requests:
```dart
type: data['type'] ?? 'request', // ✅ Defaults to 'request' if missing
```

---

## Next Steps

### Immediate:
1. **Hot restart your app** (press `R` in terminal or `Ctrl+R` in VS Code)
2. The existing request should now show buttons (even without the field in Firestore)

### After Indexes Are Created:
1. Delete the old request in Firebase Console
2. Create a new request in the app
3. It will have all correct fields including `type`

---

## Why This Matters

The UI code checks:
```dart
if (userRole == 'provider' && 
    request.status == 'pending' && 
    request.type == 'request') {
  // Show "Quick Quote" and "Custom Quote" buttons
}
```

Without `type == 'request'`, the buttons don't appear!

---

## Status: ✅ FIXED

Your app is now updated. Just hot restart and the buttons should appear!

