# 🔥 Firebase Upgrade Guide - Blaze Plan

## ⚠️ Important Notice

To deploy Cloud Functions, your Firebase project must be upgraded from the **Spark (Free)** plan to the **Blaze (Pay-as-you-go)** plan.

---

## 💰 Cost Information

### Good News: It's Still FREE for Small Apps!

The Blaze plan includes the same free tier as the Spark plan, PLUS you can use Cloud Functions.

### Free Tier Limits (Blaze Plan)

**Cloud Functions:**
- ✅ 2 million invocations/month - FREE
- ✅ 400,000 GB-seconds/month - FREE
- ✅ 200,000 CPU-seconds/month - FREE
- ✅ 5 GB network egress/month - FREE

**Firebase Cloud Messaging (FCM):**
- ✅ Unlimited notifications - FREE

**Firestore:**
- ✅ 50,000 reads/day - FREE
- ✅ 20,000 writes/day - FREE
- ✅ 20,000 deletes/day - FREE
- ✅ 1 GB storage - FREE

**Firebase Authentication:**
- ✅ Unlimited users - FREE

### Estimated Monthly Cost for FuelMate

For a moderate usage app (< 1000 active users):
- **Estimated Cost: $0/month** (stays within free tier)

For a growing app (1000-10,000 active users):
- **Estimated Cost: $1-5/month**

**You only pay if you exceed the free tier limits!**

---

## 🚀 How to Upgrade

### Step 1: Go to Firebase Console

Click this link or visit manually:
```
https://console.firebase.google.com/project/fuelmate-73aaf/usage/details
```

### Step 2: Click "Upgrade Project"

1. You'll see a comparison of Spark vs Blaze plans
2. Click the **"Upgrade"** button

### Step 3: Add Billing Information

1. You'll be redirected to Google Cloud Console
2. Click **"Set up billing account"**
3. Enter your billing information (credit card)
4. Accept the terms and conditions

### Step 4: Confirm Upgrade

1. Return to Firebase Console
2. Confirm that your project is now on the **Blaze** plan
3. You should see "Blaze" badge next to your project name

---

## 🛡️ Set Up Budget Alerts (Recommended)

To avoid unexpected charges, set up budget alerts:

### Step 1: Go to Google Cloud Console

```
https://console.cloud.google.com/billing
```

### Step 2: Create Budget Alert

1. Click **"Budgets & alerts"** in the left sidebar
2. Click **"Create Budget"**
3. Select your project: **fuelmate-73aaf**
4. Set budget amount: **$10/month** (or your preferred limit)
5. Set alert thresholds:
   - 50% of budget ($5)
   - 90% of budget ($9)
   - 100% of budget ($10)
6. Add your email for notifications
7. Click **"Finish"**

Now you'll receive email alerts if your usage approaches your budget!

---

## 📊 Monitor Your Usage

### Firebase Console

```
https://console.firebase.google.com/project/fuelmate-73aaf/usage
```

Here you can see:
- Cloud Functions invocations
- Firestore reads/writes
- Storage usage
- Network egress

### Google Cloud Console

```
https://console.cloud.google.com/billing
```

Here you can see:
- Detailed billing reports
- Cost breakdown by service
- Usage trends over time

---

## 🔒 Cost Control Tips

### 1. Optimize Cloud Functions

- Use efficient queries (avoid reading entire collections)
- Cache frequently accessed data
- Set appropriate timeout limits
- Use Cloud Functions v2 (more efficient than v1)

### 2. Optimize Firestore

- Use indexes for complex queries
- Batch writes when possible
- Delete old/unused data
- Use Firestore offline persistence

### 3. Optimize FCM

- Don't send duplicate notifications
- Use topics instead of individual tokens when possible
- Batch notifications when appropriate

### 4. Monitor Regularly

- Check Firebase Console weekly
- Review Google Cloud billing monthly
- Set up budget alerts (as described above)

---

## ❓ Frequently Asked Questions

### Q: Will I be charged immediately after upgrading?

**A:** No! You only pay if you exceed the free tier limits. Most small apps stay within the free tier.

### Q: Can I downgrade back to Spark plan?

**A:** No, once you upgrade to Blaze, you cannot downgrade. However, if you stay within free tier limits, you won't be charged.

### Q: What happens if I exceed the free tier?

**A:** You'll be charged for the excess usage at the rates shown in the Firebase Console. This is why setting up budget alerts is important!

### Q: How can I reduce costs if they're too high?

**A:** 
1. Optimize your Cloud Functions (reduce invocations)
2. Optimize Firestore queries (reduce reads/writes)
3. Cache data in the app to reduce Firestore calls
4. Use Cloud Functions only for critical notifications

### Q: Is there a way to test Cloud Functions without upgrading?

**A:** Yes! You can use the Firebase Emulator Suite to test Cloud Functions locally without deploying them. However, for production use, you need the Blaze plan.

---

## 🧪 Alternative: Use Firebase Emulator (Local Testing)

If you want to test Cloud Functions without upgrading, you can use the Firebase Emulator:

```powershell
cd "D:\my work place\PetrolMate"
firebase emulators:start
```

This will run Cloud Functions locally on your computer for testing. However, this won't send real notifications to devices.

---

## ✅ After Upgrading

Once you've upgraded to the Blaze plan, run:

```powershell
cd "D:\my work place\PetrolMate"
firebase deploy --only functions
```

Or use the deployment script:

```powershell
.\scripts\DEPLOY_CLOUD_FUNCTIONS.ps1
```

---

## 📞 Need Help?

If you have questions about billing or upgrading:

- **Firebase Support**: https://firebase.google.com/support
- **Google Cloud Support**: https://cloud.google.com/support
- **Firebase Community**: https://firebase.google.com/community

---

## 🎯 Summary

1. **Upgrade to Blaze plan** (required for Cloud Functions)
2. **Set up budget alerts** (recommended for cost control)
3. **Monitor usage regularly** (Firebase Console + Google Cloud Console)
4. **Stay within free tier** (most small apps do!)
5. **Deploy Cloud Functions** (after upgrading)

**Don't worry! Most apps stay within the free tier and never get charged.**

---

**Last Updated**: January 3, 2026  
**Version**: 1.0.0

