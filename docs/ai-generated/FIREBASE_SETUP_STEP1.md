# 🔥 Firebase Setup Instructions - Step 1

## 📝 Create Firebase Project

Follow these steps to create your Firebase project:

---

## Step 1: Go to Firebase Console

1. Open your browser
2. Go to: **https://console.firebase.google.com/**
3. Sign in with your Google account

---

## Step 2: Create New Project

1. Click **"Add project"** or **"Create a project"**
2. **Project name:** Enter `PetrolMate` (or any name you prefer)
3. Click **Continue**

---

## Step 3: Google Analytics (Optional)

1. **Enable Google Analytics?** 
   - You can toggle this **OFF** for now (not required)
   - Or leave it **ON** if you want analytics
2. Click **Continue**

If you enabled Analytics:
- Select or create an Analytics account
- Click **Create project**

---

## Step 4: Wait for Project Creation

- Firebase will create your project (~30 seconds)
- Click **Continue** when ready

---

## Step 5: Add Android App

Now we need to add your Flutter Android app to Firebase:

1. In Firebase Console, you should see your project dashboard
2. Click the **Android icon** (robot icon) to add an Android app

### Android Package Name:
You need to provide the Android package name. Let me find it for you...

---

## 🔍 Finding Your Android Package Name

The package name is in your Flutter project. It should be:

**`com.example.fuelmate_flutter`**

(I can verify this if needed)

---

## Step 6: Register Android App

1. **Android package name:** `com.example.fuelmate_flutter`
2. **App nickname (optional):** `PetrolMate Flutter`
3. **Debug signing certificate (optional):** Leave empty for now
4. Click **Register app**

---

## Step 7: Download google-services.json

1. Firebase will show you a **Download google-services.json** button
2. Click **Download google-services.json**
3. **IMPORTANT:** Save this file, we'll need it in the next step

---

## Step 8: Enable Authentication

Before we continue with the Flutter setup, let's enable Firebase Authentication:

1. In the left sidebar, click **Build** → **Authentication**
2. Click **Get started**
3. Click on **Anonymous** provider
4. Toggle **Enable** to ON
5. Click **Save**

---

## Step 9: Enable Firestore Database

1. In the left sidebar, click **Build** → **Firestore Database**
2. Click **Create database**
3. **Location:** Choose your region (e.g., `us-central` or closest to you)
4. Click **Next**
5. **Security rules:** Select **Start in test mode** (we'll secure it later)
6. Click **Enable**

⚠️ **Note:** Test mode allows all reads/writes. We'll add security rules later.

---

## ✅ Firebase Project Setup Complete!

You should now have:
- ✅ Firebase project created
- ✅ Android app registered
- ✅ google-services.json downloaded
- ✅ Authentication enabled (Anonymous)
- ✅ Firestore Database enabled (test mode)

---

## 📍 What You Need from Firebase Console:

Before proceeding to the next step, please confirm you have:

1. **✅ google-services.json file** (downloaded)
2. **✅ Firebase project ID** (shown in Firebase Console)
3. **✅ Authentication enabled** (Anonymous provider)
4. **✅ Firestore Database created** (test mode)

---

## 🚀 Next Step:

Once you confirm the above, I'll help you:
1. Add the `google-services.json` file to your Flutter project
2. Configure Firebase in your Flutter app
3. Add Firebase packages

---

## 🆘 Need Help?

If you encounter any issues:
- Take a screenshot
- Share the error message
- I'll help you resolve it

---

**Please complete the Firebase Console setup and let me know when:**
1. ✅ You have the `google-services.json` file
2. ✅ Authentication is enabled
3. ✅ Firestore is created

Then we'll continue with the Flutter configuration! 🚀

