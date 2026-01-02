# Step-by-Step Guide: Firebase Cloud Functions for Background Notifications

## Overview
This guide will help you set up Firebase Cloud Functions so users receive notifications even when the app is completely closed.

---

## STEP 1: Install Firebase CLI

### Windows (PowerShell):
```powershell
# Install Node.js first (if not installed)
# Download from: https://nodejs.org/

# Install Firebase CLI
npm install -g firebase-tools

# Verify installation
firebase --version
```

**Expected Output:**
```
13.0.0 (or similar version)
```

---

## STEP 2: Login to Firebase

```powershell
firebase login
```

**What Happens:**
1. Browser opens
2. Select your Google account
3. Grant permissions
4. You'll see: "✔ Success! Logged in as your-email@gmail.com"

---

## STEP 3: Initialize Cloud Functions

```powershell
# Navigate to your project
cd "D:\my work place\PetrolMate"

# Initialize Firebase Functions
firebase init functions
```

**Questions You'll See:**

**1. "Please select an option:"**
```
→ Use an existing project
```

**2. "Select a default Firebase project:"**
```
→ fuelmate-73aaf (or your project name)
```

**3. "What language would you like to use?"**
```
→ JavaScript
```

**4. "Do you want to use ESLint?"**
```
→ Yes
```

**5. "Do you want to install dependencies now?"**
```
→ Yes
```

**Wait for installation to complete...**

---

## STEP 4: Update Cloud Functions Code

After initialization, you'll have a `functions` folder. Now update the code:

### Open: `functions/index.js`

Replace the entire content with:

```javascript
const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

// ============================================
// FUNCTION 1: Send notification on new quote
// ============================================
exports.onQuoteCreated = functions.firestore
  .document('quotes/{quoteId}')
  .onCreate(async (snap, context) => {
    try {
      const quote = snap.data();
      const requestId = quote.requestId;
      
      console.log('📝 New quote created:', quote.id);
      
      // Get request to find needy user
      const requestDoc = await admin.firestore()
        .collection('petrolRequests')
        .doc(requestId)
        .get();
      
      if (!requestDoc.exists) {
        console.log('❌ Request not found:', requestId);
        return null;
      }
      
      const request = requestDoc.data();
      const needyId = request.userId;
      
      console.log('👤 Sending notification to needy:', needyId);
      
      // Get needy's FCM token
      const userDoc = await admin.firestore()
        .collection('users')
        .doc(needyId)
        .get();
      
      if (!userDoc.exists) {
        console.log('❌ User not found:', needyId);
        return null;
      }
      
      const user = userDoc.data();
      const fcmToken = user.fcmToken;
      
      if (!fcmToken) {
        console.log('⚠️ No FCM token for user:', needyId);
        return null;
      }
      
      // Send FCM notification
      const message = {
        token: fcmToken,
        notification: {
          title: '💰 New Quote Received',
          body: `${quote.providerName} sent a quote: ${quote.currency} ${quote.price}`
        },
        data: {
          type: 'new_quote',
          quoteId: quote.id,
          requestId: requestId,
          providerName: quote.providerName || 'Provider',
          price: quote.price.toString(),
          currency: quote.currency
        },
        android: {
          priority: 'high',
          notification: {
            sound: 'default',
            channelId: 'new_quotes'
          }
        }
      };
      
      await admin.messaging().send(message);
      console.log('✅ Quote notification sent successfully');
      
      return null;
    } catch (error) {
      console.error('❌ Error sending quote notification:', error);
      return null;
    }
  });

// ============================================
// FUNCTION 2: Send notification on new message
// ============================================
exports.onMessageCreated = functions.firestore
  .document('petrolRequests/{requestId}/messages/{messageId}')
  .onCreate(async (snap, context) => {
    try {
      const message = snap.data();
      const requestId = context.params.requestId;
      
      console.log('💬 New message created:', message.id);
      
      // Get request to find participants
      const requestDoc = await admin.firestore()
        .collection('petrolRequests')
        .doc(requestId)
        .get();
      
      if (!requestDoc.exists) {
        console.log('❌ Request not found:', requestId);
        return null;
      }
      
      const request = requestDoc.data();
      const needyId = request.userId;
      const providerId = request.acceptedBy;
      
      // Determine recipient (not the sender)
      const recipientId = message.senderId === needyId ? providerId : needyId;
      
      if (!recipientId) {
        console.log('⚠️ No recipient found');
        return null;
      }
      
      console.log('👤 Sending notification to:', recipientId);
      
      // Get recipient's FCM token
      const userDoc = await admin.firestore()
        .collection('users')
        .doc(recipientId)
        .get();
      
      if (!userDoc.exists) {
        console.log('❌ User not found:', recipientId);
        return null;
      }
      
      const user = userDoc.data();
      const fcmToken = user.fcmToken;
      
      if (!fcmToken) {
        console.log('⚠️ No FCM token for user:', recipientId);
        return null;
      }
      
      // Send FCM notification
      const fcmMessage = {
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
        },
        android: {
          priority: 'high',
          notification: {
            sound: 'default',
            channelId: 'new_messages'
          }
        }
      };
      
      await admin.messaging().send(fcmMessage);
      console.log('✅ Message notification sent successfully');
      
      return null;
    } catch (error) {
      console.error('❌ Error sending message notification:', error);
      return null;
    }
  });

// ============================================
// FUNCTION 3: Send notification on new request (for providers)
// ============================================
exports.onRequestCreated = functions.firestore
  .document('petrolRequests/{requestId}')
  .onCreate(async (snap, context) => {
    try {
      const request = snap.data();
      
      console.log('🚨 New request created:', request.id);
      
      // Send to all providers (using topic)
      const message = {
        topic: 'role_provider',
        notification: {
          title: '🚨 New Petrol Request',
          body: `${request.needyName || request.name || 'Someone'} needs petrol`
        },
        data: {
          type: 'new_request',
          requestId: request.id,
          needyName: request.needyName || request.name || 'Someone',
          message: request.message || '',
          latitude: request.latitude?.toString() || '',
          longitude: request.longitude?.toString() || ''
        },
        android: {
          priority: 'high',
          notification: {
            sound: 'default',
            channelId: 'new_requests'
          }
        }
      };
      
      await admin.messaging().send(message);
      console.log('✅ Request notification sent to providers');
      
      return null;
    } catch (error) {
      console.error('❌ Error sending request notification:', error);
      return null;
    }
  });
```

---

## STEP 5: Update Package.json (Optional but Recommended)

Open: `functions/package.json`

Make sure it has:

```json
{
  "name": "functions",
  "description": "Cloud Functions for FuelMate",
  "scripts": {
    "serve": "firebase emulators:start --only functions",
    "shell": "firebase functions:shell",
    "start": "npm run shell",
    "deploy": "firebase deploy --only functions",
    "logs": "firebase functions:log"
  },
  "engines": {
    "node": "18"
  },
  "main": "index.js",
  "dependencies": {
    "firebase-admin": "^11.8.0",
    "firebase-functions": "^4.3.1"
  },
  "devDependencies": {
    "eslint": "^8.15.0"
  },
  "private": true
}
```

---

## STEP 6: Deploy Cloud Functions

```powershell
cd functions
firebase deploy --only functions
```

**What You'll See:**
```
=== Deploying to 'fuelmate-73aaf'...

i  deploying functions
i  functions: ensuring required API cloudfunctions.googleapis.com is enabled...
i  functions: ensuring required API cloudbuild.googleapis.com is enabled...
✔  functions: required API cloudfunctions.googleapis.com is enabled
✔  functions: required API cloudbuild.googleapis.com is enabled
i  functions: preparing functions directory for uploading...
i  functions: packaged functions (XX.XX KB) for uploading
✔  functions: functions folder uploaded successfully
i  functions: creating Node.js 18 function onQuoteCreated...
i  functions: creating Node.js 18 function onMessageCreated...
i  functions: creating Node.js 18 function onRequestCreated...
✔  functions[onQuoteCreated]: Successful create operation.
✔  functions[onMessageCreated]: Successful create operation.
✔  functions[onRequestCreated]: Successful create operation.

✔  Deploy complete!
```

**⏱️ This takes 2-5 minutes**

---

## STEP 7: Update App to Save FCM Token

Now we need to save the FCM token when users log in.

### Open: `flutter_app/lib/providers/user_provider.dart`

Find the `initializeApp()` method and add FCM token saving:

```dart
import '../services/fcm_service.dart';

// In initializeApp() method, after user is loaded:
Future<void> initializeApp() async {
  try {
    await _loadUserData();
    
    // Save FCM token if user is logged in
    if (_userId != null) {
      final fcmService = FCMService();
      await fcmService.saveFCMTokenToFirestore(_userId!);
      await fcmService.subscribeToUserTopic(_userId!);
      if (_userRole != null) {
        await fcmService.subscribeToRoleTopic(_userRole!);
      }
    }
    
    notifyListeners();
  } catch (e) {
    print('Error initializing app: $e');
  }
}
```

### Update FCM Service to Actually Save Token

Open: `flutter_app/lib/services/fcm_service.dart`

Update the `saveFCMTokenToFirestore` method:

```dart
Future<void> saveFCMTokenToFirestore(String userId) async {
  if (_fcmToken == null) return;
  
  try {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .set({
      'fcmToken': _fcmToken,
      'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    
    debugPrint('✅ FCM token saved for user: $userId');
  } catch (e) {
    debugPrint('❌ Error saving FCM token: $e');
  }
}
```

---

## STEP 8: Test Everything!

### Test 1: Check FCM Token Saved

1. **Hot reload** your app (press `r`)
2. Check logs for:
   ```
   🔑 FCM Token: fXXXXXXXXXXXXXXXXXXXXXX
   ✅ FCM token saved for user: needy_needy
   ```
3. Check Firestore Console:
   - Go to `users` collection
   - Find your user document
   - Should see `fcmToken` field

### Test 2: Test Quote Notification (App Closed)

1. **Close your app completely** (swipe away from recent apps)
2. Have another device send a quote
3. **Expected:** Bell rings, notification appears!

### Test 3: Test Message Notification (App Closed)

1. **Close your app completely**
2. Have another user send a message
3. **Expected:** Bell rings, notification appears!

### Test 4: Test Request Notification (Provider)

1. Provider closes app completely
2. Needy creates a request
3. **Expected:** Provider gets notification!

---

## STEP 9: View Cloud Function Logs

To see if functions are working:

```powershell
firebase functions:log
```

**You'll see:**
```
📝 New quote created: quote_123
👤 Sending notification to needy: needy_needy
✅ Quote notification sent successfully
```

---

## STEP 10: Monitor in Firebase Console

1. Go to: https://console.firebase.google.com/
2. Select your project: `fuelmate-73aaf`
3. Click **Functions** in left menu
4. You'll see:
   - `onQuoteCreated` ✅
   - `onMessageCreated` ✅
   - `onRequestCreated` ✅

Click on any function to see:
- Execution count
- Error rate
- Execution time
- Logs

---

## Troubleshooting

### Issue: "Firebase CLI not found"
**Solution:**
```powershell
npm install -g firebase-tools
```

### Issue: "Permission denied"
**Solution:**
```powershell
firebase login --reauth
```

### Issue: "Functions not deploying"
**Solution:**
```powershell
cd functions
npm install
firebase deploy --only functions
```

### Issue: "No FCM token"
**Solution:**
- Check app permissions granted
- Check logs for FCM initialization
- Restart app

### Issue: "Notifications not received when closed"
**Solution:**
- Check Cloud Functions deployed
- Check FCM token saved in Firestore
- Check function logs: `firebase functions:log`

---

## Summary Checklist

- [ ] Install Firebase CLI
- [ ] Login to Firebase
- [ ] Initialize Cloud Functions
- [ ] Update `functions/index.js`
- [ ] Deploy functions
- [ ] Update app to save FCM token
- [ ] Hot reload app
- [ ] Test with app closed
- [ ] Check function logs
- [ ] Monitor in Firebase Console

---

## What Happens Now

**Before (Current):**
```
App closed → No notifications ❌
```

**After (With Cloud Functions):**
```
Quote created → Cloud Function triggers → FCM sends notification
→ Device receives → Bell rings → Notification shows ✅

Even when app is COMPLETELY CLOSED! 🎉
```

---

## Cost

**Firebase Functions Free Tier:**
- 2 million invocations/month
- 400,000 GB-seconds/month
- 200,000 CPU-seconds/month

**Your usage (estimated):**
- ~100 notifications/day = 3,000/month
- **Well within free tier!** ✅

---

## Next Steps After Setup

1. Test thoroughly
2. Monitor function logs
3. Check error rates
4. Optimize if needed
5. Deploy to production

---

**Need Help?** Check the logs or ask me! 🚀

