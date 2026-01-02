# 🚀 Quick Reference - Cloud Functions & Notifications

## 📋 Current Status

✅ **App Works When OPEN**
- Real-time quote notifications ✓
- Real-time message notifications ✓
- Unread message count badges ✓
- Sound and vibration alerts ✓

⏳ **Pending: App Closed Notifications**
- Requires Firebase Blaze plan upgrade
- Requires Cloud Functions deployment

---

## 🔥 Deploy Cloud Functions (3 Steps)

### Step 1: Upgrade Firebase (5 minutes)

Visit: https://console.firebase.google.com/project/fuelmate-73aaf/usage/details

1. Click "Upgrade Project"
2. Add billing info (credit card)
3. Confirm upgrade

**Cost**: $0/month for small apps (free tier included!)

### Step 2: Deploy Functions (2 minutes)

```powershell
cd "D:\my work place\PetrolMate"
firebase deploy --only functions
```

### Step 3: Test (5 minutes)

1. Close app completely
2. Send message from another device
3. Verify notification received

---

## 📁 Important Files

### Cloud Functions
- `functions/index.js` - All Cloud Functions code
- `functions/package.json` - Dependencies

### Flutter App
- `lib/services/fcm_service.dart` - FCM service
- `lib/services/notification_service.dart` - Local notifications
- `lib/providers/user_provider.dart` - User management + FCM token

### Documentation
- `docs/ai-generated/DEPLOYMENT_STATUS.md` - Current status
- `docs/ai-generated/FIREBASE_UPGRADE_GUIDE.md` - Upgrade guide
- `docs/ai-generated/COMPLETE_NOTIFICATION_SETUP.md` - Complete guide

### Scripts
- `scripts/DEPLOY_CLOUD_FUNCTIONS.ps1` - Deployment script

---

## 🔔 Notification Types

| Type | Trigger | Recipient | When App Closed |
|------|---------|-----------|-----------------|
| **Message** | New chat message | Other person in chat | ✅ After deployment |
| **Quote** | Provider submits quote | Needy user | ✅ After deployment |
| **New Request** | Needy creates request | All providers | ✅ After deployment |
| **Quote Accepted** | Needy accepts quote | Provider | ✅ After deployment |
| **Request Completed** | Status → completed | Needy user | ✅ After deployment |

---

## 🧪 Testing Commands

### View Logs
```powershell
firebase functions:log
```

### Deploy Functions
```powershell
firebase deploy --only functions
```

### Run App
```powershell
cd flutter_app
flutter run
```

### Build Release APK
```powershell
cd flutter_app
flutter build apk --release
```

### Build Release AAB
```powershell
cd flutter_app
flutter build appbundle --release
```

---

## 🔍 Debugging

### Check FCM Token in App Logs
```
I/flutter: 🔑 FCM Token: dOgqWkoDSvmvozW5N_PymT:APA91b...
```

### Check FCM Token in Firestore
- Collection: `users`
- Document: `{userId}`
- Field: `fcmToken`

### Check Cloud Function Logs
- Firebase Console → Functions → Select function → Logs

### Test Notification Manually
- Firebase Console → Cloud Messaging → Send test message

---

## 💰 Cost Breakdown

### Free Tier (Included in Blaze)
- Cloud Functions: 2M invocations/month
- FCM: Unlimited notifications
- Firestore: 50K reads/day

### Estimated Cost
- **0-1K users**: $0/month
- **1K-10K users**: $1-5/month
- **10K+ users**: $5-20/month

---

## 📊 Monitoring

### Firebase Console
```
https://console.firebase.google.com/project/fuelmate-73aaf
```

### Google Cloud Console (Billing)
```
https://console.cloud.google.com/billing
```

### Set Budget Alert
1. Go to Google Cloud Console
2. Billing → Budgets & alerts
3. Create budget: $10/month
4. Set alerts: 50%, 90%, 100%

---

## 🆘 Common Issues

### Issue: "Project must be on Blaze plan"
**Solution**: Upgrade at https://console.firebase.google.com/project/fuelmate-73aaf/usage/details

### Issue: "FCM token not found"
**Solution**: Check Firestore `/users/{userId}` document has `fcmToken` field

### Issue: "Notification not received when app closed"
**Solution**: 
1. Verify Cloud Functions deployed
2. Check Cloud Function logs
3. Verify FCM token saved in Firestore

### Issue: "ESLint errors during deployment"
**Solution**: Already fixed! Just deploy again.

---

## ✅ Pre-Deployment Checklist

- [ ] Firebase upgraded to Blaze plan
- [ ] Billing information added
- [ ] Budget alerts set up ($10/month)
- [ ] Cloud Functions code reviewed
- [ ] ESLint errors fixed (already done!)
- [ ] Ready to deploy!

---

## 🎯 Post-Deployment Checklist

- [ ] Cloud Functions deployed successfully
- [ ] Tested message notifications (app closed)
- [ ] Tested quote notifications (app closed)
- [ ] Tested new request notifications (app closed)
- [ ] Checked Cloud Function logs (no errors)
- [ ] Verified FCM tokens in Firestore
- [ ] Set up monitoring/alerts
- [ ] Documented any issues

---

## 📞 Support

### Firebase Support
- Docs: https://firebase.google.com/docs
- Community: https://firebase.google.com/community
- Support: https://firebase.google.com/support

### Cloud Functions
- Docs: https://firebase.google.com/docs/functions
- Samples: https://github.com/firebase/functions-samples

---

## 🎉 Success Criteria

After deployment, you should have:

✅ Notifications work when app is OPEN  
✅ Notifications work when app is CLOSED  
✅ Sound and vibration alerts  
✅ Unread message count badges  
✅ Notification tap navigation  
✅ Topic-based notifications  
✅ User-specific notifications  

**Your notification system is complete!** 🚀

---

**Last Updated**: January 3, 2026  
**Quick Start**: Upgrade Firebase → Deploy Functions → Test
