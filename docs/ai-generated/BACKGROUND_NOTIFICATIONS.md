# Background Notifications with Firebase Cloud Messaging

## Overview

Implemented **Firebase Cloud Messaging (FCM)** to enable notifications even when the app is **completely closed**. Users will receive bells/notifications for quotes, messages, and requests without opening the app.

## How It Works

### Architecture

```
Event occurs (quote/message) 
        ↓
Backend/Firestore triggers
        ↓
FCM sends push notification
        ↓
Device receives (even if app closed)
        ↓
Bell rings + Notification shows
        ↓
User taps → App opens to relevant screen
```

### Three Notification States

**1. Foreground (App Open):**
- FCM message received
- Local notification shown
- Bell rings immediately

**2. Background (App Minimized):**
- FCM message received
- System shows notification
- Bell rings
- Tap opens app

**3. Terminated (App Closed):**
- FCM message received by system
- System shows notification
- Bell rings
- Tap launches app

## Implementation

### 1. Added Firebase Messaging

**`pubspec.yaml`:**
```yaml
dependencies:
  firebase_messaging: ^14.7.10
```

### 2. Created FCM Service

**`lib/services/fcm_service.dart`:**
- Handles FCM token generation
- Manages message handlers
- Shows local notifications
- Handles notification taps

### 3. Background Message Handler

**`lib/main.dart`:**
```dart
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Handles messages when app is terminated
  debugPrint('Background message: ${message.notification?.title}');
}
```

### 4. Updated Permissions

**`AndroidManifest.xml`:**
```xml
<uses-permission android:name="android.permission.WAKE_LOCK"/>
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
```

## Message Format

### Quote Notification
```json
{
  "notification": {
    "title": "💰 New Quote Received",
    "body": "Ali sent a quote: PKR 390"
  },
  "data": {
    "type": "new_quote",
    "quoteId": "quote_123",
    "requestId": "req_123",
    "providerName": "Ali",
    "price": "390",
    "currency": "PKR"
  }
}
```

### Message Notification
```json
{
  "notification": {
    "title": "💬 Ali",
    "body": "On my way!"
  },
  "data": {
    "type": "new_message",
    "requestId": "req_123",
    "senderName": "Ali",
    "message": "On my way!"
  }
}
```

### Request Notification
```json
{
  "notification": {
    "title": "🚨 New Petrol Request",
    "body": "John needs petrol (2.5 km away)"
  },
  "data": {
    "type": "new_request",
    "requestId": "req_123",
    "needyName": "John",
    "message": "Need 10L urgently",
    "distance": "2.5"
  }
}
```

## Backend Integration Required

### Option 1: Cloud Functions (Recommended)

Create Firebase Cloud Functions to send FCM notifications:

**`functions/index.js`:**
```javascript
const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

// Trigger on new quote
exports.onQuoteCreated = functions.firestore
  .document('quotes/{quoteId}')
  .onCreate(async (snap, context) => {
    const quote = snap.data();
    const requestId = quote.requestId;
    
    // Get request to find needy user
    const request = await admin.firestore()
      .collection('petrolRequests')
      .doc(requestId)
      .get();
    
    const needyId = request.data().userId;
    
    // Get needy's FCM token
    const user = await admin.firestore()
      .collection('users')
      .doc(needyId)
      .get();
    
    const fcmToken = user.data().fcmToken;
    
    if (fcmToken) {
      // Send FCM notification
      await admin.messaging().send({
        token: fcmToken,
        notification: {
          title: '💰 New Quote Received',
          body: `${quote.providerName} sent a quote: ${quote.currency} ${quote.price}`
        },
        data: {
          type: 'new_quote',
          quoteId: quote.id,
          requestId: requestId,
          providerName: quote.providerName,
          price: quote.price.toString(),
          currency: quote.currency
        }
      });
    }
  });

// Trigger on new message
exports.onMessageCreated = functions.firestore
  .document('petrolRequests/{requestId}/messages/{messageId}')
  .onCreate(async (snap, context) => {
    const message = snap.data();
    const requestId = context.params.requestId;
    
    // Get request participants
    const request = await admin.firestore()
      .collection('petrolRequests')
      .doc(requestId)
      .get();
    
    const requestData = request.data();
    const needyId = requestData.userId;
    const providerId = requestData.acceptedBy;
    
    // Determine recipient (not the sender)
    const recipientId = message.senderId === needyId ? providerId : needyId;
    
    // Get recipient's FCM token
    const user = await admin.firestore()
      .collection('users')
      .doc(recipientId)
      .get();
    
    const fcmToken = user.data().fcmToken;
    
    if (fcmToken) {
      // Send FCM notification
      await admin.messaging().send({
        token: fcmToken,
        notification: {
          title: `💬 ${message.senderName}`,
          body: message.message
        },
        data: {
          type: 'new_message',
          requestId: requestId,
          senderName: message.senderName,
          message: message.message
        }
      });
    }
  });
```

### Option 2: Backend API

If you have a custom backend, send FCM notifications via REST API:

```javascript
const axios = require('axios');

async function sendFCMNotification(fcmToken, title, body, data) {
  const serverKey = 'YOUR_FIREBASE_SERVER_KEY';
  
  await axios.post('https://fcm.googleapis.com/fcm/send', {
    to: fcmToken,
    notification: { title, body },
    data: data
  }, {
    headers: {
      'Authorization': `key=${serverKey}`,
      'Content-Type': 'application/json'
    }
  });
}
```

### Option 3: Firestore Triggers (Simplified)

Use Firestore triggers in your backend to detect changes and send notifications.

## Setup Steps

### 1. Install Dependencies
```bash
cd flutter_app
flutter pub get
```

### 2. Setup Firebase Cloud Messaging

**In Firebase Console:**
1. Go to Project Settings → Cloud Messaging
2. Note your **Server Key** (for backend)
3. Download `google-services.json` (already done)

### 3. Deploy Cloud Functions (Optional)

```bash
cd functions
npm install
firebase deploy --only functions
```

### 4. Save FCM Tokens

When user logs in, save their FCM token:

```dart
final fcmService = FCMService();
await fcmService.initialize();
await fcmService.saveFCMTokenToFirestore(userId);
await fcmService.subscribeToUserTopic(userId);
await fcmService.subscribeToRoleTopic(userRole);
```

## Testing

### Test Foreground Notifications
1. Open app
2. Have someone send message/quote
3. **Expected:** Bell rings, notification shows

### Test Background Notifications
1. Minimize app (home button)
2. Have someone send message/quote
3. **Expected:** Bell rings, notification appears in tray

### Test Terminated Notifications
1. Close app completely (swipe away)
2. Have someone send message/quote
3. **Expected:** Bell rings, notification appears
4. Tap notification → app launches

### Manual Test with FCM

Use Firebase Console to send test message:
1. Go to Cloud Messaging → Send test message
2. Add FCM token (from app logs)
3. Send notification
4. **Expected:** Notification received even if app closed

## Current Status

**✅ Implemented:**
- FCM service setup
- Background message handler
- Foreground message handler
- Local notification integration
- Permission handling
- Topic subscriptions

**⚠️ Requires Backend:**
- Cloud Functions to trigger FCM on Firestore changes
- OR Backend API to send FCM notifications
- OR Manual FCM sending for testing

**Without backend, notifications work when:**
- App is open (foreground)
- App is minimized (background)

**With backend, notifications work:**
- ✅ App is open
- ✅ App is minimized
- ✅ **App is completely closed** ← This is what you want!

## Next Steps

### Option A: Quick Test (Manual)
1. Get FCM token from app logs
2. Use Firebase Console to send test notification
3. Verify it works when app is closed

### Option B: Production Setup (Recommended)
1. Create Firebase Cloud Functions
2. Add triggers for quotes/messages/requests
3. Deploy functions
4. Test end-to-end

### Option C: Custom Backend
1. Integrate FCM REST API in your backend
2. Send notifications on events
3. Test thoroughly

## Logs to Watch

```
🔑 FCM Token: fXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
✅ User granted FCM permission
✅ Subscribed to topic: user_needy_needy
✅ Subscribed to topic: role_needy
🔔 Foreground message received: msg_123
🔔 Background message opened: msg_456
```

## Performance

**Battery Impact:** Minimal (FCM uses system services)
**Network Usage:** Very low (push notifications are tiny)
**Latency:** < 1 second from event to notification

## Security

- FCM tokens are device-specific
- Tokens expire and refresh automatically
- Server key must be kept secret
- Validate all notification data

## Troubleshooting

**No FCM token:**
- Check permissions granted
- Check Firebase setup
- Check google-services.json

**Notifications not received when closed:**
- Need backend to send FCM messages
- Check Cloud Functions deployed
- Check FCM token saved to Firestore

**Notifications work in foreground only:**
- This is expected without backend
- Implement Cloud Functions or backend API

## Summary

**What's Done:**
- ✅ FCM service implemented
- ✅ Background handler setup
- ✅ Local notifications integrated
- ✅ Permissions configured

**What's Needed:**
- ⚠️ Backend to send FCM notifications
- ⚠️ Cloud Functions or API integration
- ⚠️ FCM token storage in Firestore

**Result:**
Once backend is setup, users will receive notifications **even when app is completely closed**! 🎉

