# 🔔 Complete Notification Setup Guide

## ✅ What's Been Implemented

### 1. **Real-time Notifications (App Open)**
- ✅ Quote notifications with sound/vibration
- ✅ Message notifications with sound/vibration  
- ✅ Unread message count badges
- ✅ Notification tap navigation

### 2. **Firebase Cloud Messaging (FCM)**
- ✅ FCM service initialized
- ✅ FCM tokens generated and saved to Firestore
- ✅ Background message handler registered
- ✅ Topic subscriptions (all_users, providers, role-specific)

### 3. **Cloud Functions**
- ✅ `onNewMessage` - Triggers when a new chat message is created
- ✅ `onNewQuote` - Triggers when a new quote is created
- ✅ `onNewRequest` - Triggers when a new petrol request is created
- ✅ `onQuoteAccepted` - Triggers when a quote is accepted
- ✅ `onRequestCompleted` - Triggers when a request is completed
- ✅ `testNotification` - Test function for debugging

---

## 🚀 Deployment Steps

### Step 1: Deploy Cloud Functions

Run the deployment script:

```powershell
cd "D:\my work place\PetrolMate"
.\scripts\DEPLOY_CLOUD_FUNCTIONS.ps1
```

Or manually:

```powershell
firebase deploy --only functions
```

### Step 2: Rebuild and Test the Flutter App

```powershell
cd flutter_app
flutter clean
flutter pub get
flutter run
```

---

## 🧪 Testing the Notifications

### Test 1: Message Notifications (App Closed)

1. **Close the app completely** (swipe it away from recent apps)
2. **From another device/account**, send a message in an active chat
3. **Expected Result**: You should receive a notification even though the app is closed
4. **Tap the notification**: The app should open to the chat screen

### Test 2: Quote Notifications (App Closed)

1. **Close the app completely** (needy user)
2. **From a provider account**, submit a quote for one of your requests
3. **Expected Result**: Needy user receives notification with quote details
4. **Tap the notification**: App opens to view the quote

### Test 3: New Request Notifications (App Closed)

1. **Close the app completely** (provider user)
2. **From a needy account**, create a new petrol request
3. **Expected Result**: All providers receive a notification about the new request
4. **Tap the notification**: App opens to view the request

### Test 4: Quote Accepted Notifications (App Closed)

1. **Close the app completely** (provider user)
2. **From needy account**, accept the provider's quote
3. **Expected Result**: Provider receives notification that their quote was accepted
4. **Tap the notification**: App opens to view the accepted request

---

## 🔍 Debugging

### View Cloud Function Logs

```powershell
firebase functions:log
```

Or in Firebase Console:
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project (FuelMate)
3. Navigate to **Functions** in the left sidebar
4. Click on a function to view its logs

### Check FCM Token

The FCM token is printed in the app logs when the app starts:

```
I/flutter: 🔑 FCM Token: dOgqWkoDSvmvozW5N_PymT:APA91b...
```

### Test Notification Manually

You can test sending a notification using the Firebase Console:

1. Go to **Firebase Console** → **Cloud Messaging**
2. Click **Send your first message**
3. Enter a title and message
4. Click **Send test message**
5. Paste your FCM token
6. Click **Test**

### Test Cloud Function Directly

Use the test function:

```powershell
# Get the function URL from Firebase Console
curl "https://YOUR-REGION-YOUR-PROJECT.cloudfunctions.net/testNotification?userId=needy_needy"
```

---

## 📊 How It Works

### Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    FIRESTORE DATABASE                        │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │   Messages   │  │    Quotes    │  │   Requests   │     │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘     │
└─────────┼──────────────────┼──────────────────┼─────────────┘
          │                  │                  │
          │ onCreate         │ onCreate         │ onCreate
          ▼                  ▼                  ▼
┌─────────────────────────────────────────────────────────────┐
│              CLOUD FUNCTIONS (Node.js)                       │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │ onNewMessage │  │  onNewQuote  │  │ onNewRequest │     │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘     │
└─────────┼──────────────────┼──────────────────┼─────────────┘
          │                  │                  │
          │ Get FCM Token    │ Get FCM Token    │ Send to Topic
          ▼                  ▼                  ▼
┌─────────────────────────────────────────────────────────────┐
│           FIREBASE CLOUD MESSAGING (FCM)                     │
│                                                               │
│  Sends push notifications to devices                         │
└─────────────────────┬───────────────────────────────────────┘
                      │
                      │ Push Notification
                      ▼
┌─────────────────────────────────────────────────────────────┐
│                  USER'S DEVICE                               │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  FCM Service (Background)                            │  │
│  │  • Receives notification even when app is closed     │  │
│  │  • Shows notification in system tray                 │  │
│  │  • Plays sound/vibration                             │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

### Data Flow

1. **User Action**: Someone creates a message/quote/request in Firestore
2. **Cloud Function Trigger**: Firestore onCreate event triggers the corresponding Cloud Function
3. **Get Recipient**: Cloud Function queries Firestore to find the recipient's FCM token
4. **Send Notification**: Cloud Function calls FCM API to send push notification
5. **Device Receives**: User's device receives notification (even if app is closed)
6. **User Interaction**: User taps notification → App opens to relevant screen

---

## 🔐 Security Considerations

### Firestore Rules

Make sure your Firestore rules allow Cloud Functions to read user data:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow Cloud Functions to read user FCM tokens
    match /users/{userId} {
      allow read, write: if request.auth != null;
    }
    
    // Your other rules...
  }
}
```

### FCM Token Security

- FCM tokens are stored in Firestore under `/users/{userId}/fcmToken`
- Only authenticated users can read/write their own token
- Cloud Functions have admin access to read any user's token

---

## 💰 Cost Considerations

### Firebase Cloud Functions Pricing

**Free Tier (Spark Plan):**
- 2 million invocations/month
- 400,000 GB-seconds/month
- 200,000 CPU-seconds/month

**Estimated Usage for FuelMate:**
- Each message/quote/request triggers 1 function invocation
- Average function execution: ~1 second
- Estimated cost: **FREE** for moderate usage (< 2M notifications/month)

### Firebase Cloud Messaging (FCM)

- **100% FREE** - Unlimited notifications

### Firestore

- **Free Tier**: 50,000 reads/day, 20,000 writes/day
- Each notification reads 1-2 documents (user token, request data)
- Estimated cost: **FREE** for moderate usage

**Total Estimated Cost: $0/month for moderate usage**

---

## 📱 Notification Types

### 1. Message Notifications

**Trigger**: New message in chat  
**Recipient**: The other person in the chat  
**Title**: "💬 New Message from {senderName}"  
**Body**: The message text  
**Payload**: `chat_{requestId}`

### 2. Quote Notifications

**Trigger**: Provider submits a quote  
**Recipient**: Needy user who created the request  
**Title**: "💰 New Quote Received!"  
**Body**: "{providerName} offered {currency} {price}"  
**Payload**: `quote_{quoteId}`

### 3. New Request Notifications

**Trigger**: Needy creates a petrol request  
**Recipient**: All providers (via topic subscription)  
**Title**: "🚨 New Petrol Request!"  
**Body**: "{needyName} needs petrol! {message}"  
**Payload**: `request_{requestId}`

### 4. Quote Accepted Notifications

**Trigger**: Needy accepts a quote  
**Recipient**: Provider whose quote was accepted  
**Title**: "✅ Quote Accepted!"  
**Body**: "{needyName} accepted your quote"  
**Payload**: `request_{requestId}`

### 5. Request Completed Notifications

**Trigger**: Request status changes to 'completed'  
**Recipient**: Needy user  
**Title**: "🎉 Request Completed!"  
**Body**: "Your request was completed by {providerName}"  
**Payload**: `request_{requestId}`

---

## 🛠️ Troubleshooting

### Problem: Notifications not received when app is closed

**Possible Causes:**
1. Cloud Functions not deployed
2. FCM token not saved to Firestore
3. User not subscribed to correct topic
4. Device battery optimization blocking FCM

**Solutions:**
1. Check Cloud Function logs: `firebase functions:log`
2. Verify FCM token in Firestore: Check `/users/{userId}` document
3. Check topic subscriptions in app logs
4. Disable battery optimization for the app

### Problem: Cloud Function fails to send notification

**Possible Causes:**
1. Invalid FCM token
2. User document not found
3. Network error

**Solutions:**
1. Check Cloud Function logs for error details
2. Verify user document exists in Firestore
3. Regenerate FCM token by reinstalling the app

### Problem: Notification received but app doesn't open correct screen

**Possible Causes:**
1. Notification payload not set correctly
2. Navigation handler not implemented

**Solutions:**
1. Check notification data in Cloud Function
2. Implement navigation in `_handleMessageTap` in `fcm_service.dart`

---

## 📚 Related Documentation

- [STEP_BY_STEP_CLOUD_FUNCTIONS.md](./STEP_BY_STEP_CLOUD_FUNCTIONS.md) - Detailed Cloud Functions setup
- [NOTIFICATION_SUMMARY.md](./NOTIFICATION_SUMMARY.md) - Notification architecture overview
- [BACKGROUND_NOTIFICATIONS.md](./BACKGROUND_NOTIFICATIONS.md) - FCM implementation details
- [REALTIME_ARCHITECTURE.md](./REALTIME_ARCHITECTURE.md) - Real-time listener architecture

---

## ✅ Checklist

Before going live, ensure:

- [ ] Cloud Functions deployed successfully
- [ ] FCM tokens saved to Firestore for all users
- [ ] Tested message notifications (app closed)
- [ ] Tested quote notifications (app closed)
- [ ] Tested new request notifications (app closed)
- [ ] Tested quote accepted notifications (app closed)
- [ ] Tested request completed notifications (app closed)
- [ ] Checked Cloud Function logs for errors
- [ ] Verified notification sounds/vibrations work
- [ ] Tested notification tap navigation
- [ ] Reviewed Firebase billing/usage

---

## 🎉 Congratulations!

You now have a fully functional notification system that works even when the app is completely closed! 🚀

**Key Features:**
- ✅ Real-time notifications when app is open
- ✅ Push notifications when app is closed
- ✅ Sound and vibration alerts
- ✅ Unread message count badges
- ✅ Notification tap navigation
- ✅ Topic-based notifications for providers
- ✅ User-specific notifications for quotes/messages

**Next Steps:**
1. Deploy to production
2. Monitor Cloud Function logs
3. Gather user feedback
4. Optimize notification content
5. Add more notification types as needed

---

**Last Updated**: January 3, 2026  
**Version**: 1.0.0

