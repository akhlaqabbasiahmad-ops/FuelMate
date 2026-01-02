# 🔥 How to Update Package Name in Firebase Console

## ⚠️ Important: You Cannot Change Package Name of Existing App

Firebase doesn't allow changing the package name of an existing Android app. You need to **add a new Android app** with the new package name.

---

## 📋 Step-by-Step Guide

### Step 1: Go to Firebase Console

1. Open [Firebase Console](https://console.firebase.google.com/)
2. Select your project: **fuelmate-73aaf**

### Step 2: Navigate to Project Settings

1. Click the **⚙️ Settings** icon (gear icon) in the top left
2. Select **Project settings** from the dropdown

### Step 3: Add New Android App

1. Scroll down to the **Your apps** section
2. You'll see your existing app: `com.example.fuelmate_flutter`
3. Click the **Add app** button (or **+ Add app** if no apps shown)
4. Select the **Android** icon (Android robot)

### Step 4: Register the New App

Fill in the form:

- **Android package name:** `com.fuelmate.app`
  - ⚠️ Must match exactly: `com.fuelmate.app`
  
- **App nickname (optional):** `FuelMate Production` or `FuelMate - com.fuelmate.app`
  - This is just for your reference in Firebase Console

- **Debug signing certificate SHA-1 (optional):** 
  - Leave blank for now (you can add it later if needed)
  - This is only needed for Google Sign-In and other services that require it

5. Click **Register app**

### Step 5: Download google-services.json

1. After registering, you'll see a page with download options
2. Click **Download google-services.json**
3. Save the file

### Step 6: Replace the File in Your Project

1. **Copy** the downloaded `google-services.json`
2. **Replace** the existing file at:
   ```
   D:\my work place\PetrolMate\flutter_app\android\app\google-services.json
   ```

### Step 7: Verify the Package Name

Open the new `google-services.json` and verify it has:
```json
"package_name": "com.fuelmate.app"
```

---

## ✅ What You'll Have After This

You'll have **TWO Android apps** in Firebase:

1. **Old app:** `com.example.fuelmate_flutter` (can be kept or deleted)
2. **New app:** `com.fuelmate.app` (use this one)

Both will work with the same Firebase project and share:
- ✅ Firestore database
- ✅ Authentication users
- ✅ Storage bucket
- ✅ Project settings

---

## 🗑️ Optional: Delete Old App (If You Want)

If you want to clean up and remove the old app:

1. In Firebase Console → Project settings → Your apps
2. Find `com.example.fuelmate_flutter`
3. Click the **⋮** (three dots) menu next to it
4. Select **Delete app**
5. Confirm deletion

**⚠️ Warning:** Only delete if you're sure you don't need it anymore!

---

## 🔍 Quick Visual Guide

```
Firebase Console
├── ⚙️ Settings
│   └── Project settings
│       └── Your apps
│           ├── [Existing] com.example.fuelmate_flutter
│           └── [+ Add app] ← Click here
│               └── Select Android
│                   └── Package name: com.fuelmate.app
│                       └── Register app
│                           └── Download google-services.json
```

---

## 📱 After Setup

Once you've added the new app and replaced `google-services.json`:

1. **Rebuild your AAB:**
   ```powershell
   cd "D:\my work place\PetrolMate\flutter_app"
   flutter clean
   flutter build appbundle --release
   ```

2. **Verify it works:**
   - Build should complete successfully
   - No Firebase package name errors
   - App will use `com.fuelmate.app` package name

---

## 🆘 Troubleshooting

### "Package name already exists"
- This means you already added it! Just download the `google-services.json` again

### "Invalid package name"
- Make sure it's exactly: `com.fuelmate.app`
- No spaces, no special characters

### Build still fails with package name error
- Make sure you replaced `flutter_app/android/app/google-services.json`
- Check the file has `"package_name": "com.fuelmate.app"`
- Run `flutter clean` before rebuilding

---

## 📝 Summary

**What to do:**
1. ✅ Add new Android app in Firebase Console
2. ✅ Package name: `com.fuelmate.app`
3. ✅ Download new `google-services.json`
4. ✅ Replace file in project
5. ✅ Rebuild AAB

**Result:**
- ✅ New package name works with Firebase
- ✅ Ready for Google Play Store
- ✅ All Firebase services will work

---

**Need help?** The Firebase Console interface is straightforward - just follow the steps above! 🚀

