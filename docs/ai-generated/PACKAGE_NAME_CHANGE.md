# 📦 Package Name Change - com.example.fuelmate_flutter → com.fuelmate.app

## ⚠️ IMPORTANT: Firebase Configuration Required

You've changed the package name from `com.example.fuelmate_flutter` to `com.fuelmate.app`.

**You MUST update Firebase configuration before building!**

---

## 🔥 Firebase Setup Steps

### Step 1: Add New Android App in Firebase Console

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: **fuelmate-73aaf**
3. Click the **⚙️ Settings** icon → **Project settings**
4. Scroll down to **Your apps** section
5. Click **Add app** → Select **Android** icon
6. Enter:
   - **Android package name:** `com.fuelmate.app`
   - **App nickname (optional):** FuelMate Production
   - **Debug signing certificate SHA-1 (optional):** Leave blank for now
7. Click **Register app**

### Step 2: Download New google-services.json

1. After registering, download the new `google-services.json` file
2. **Replace** the existing file at:
   ```
   flutter_app/android/app/google-services.json
   ```

### Step 3: Verify Package Name

The new `google-services.json` should have:
```json
"package_name": "com.fuelmate.app"
```

---

## ✅ What Was Changed

### Files Updated:
1. ✅ `flutter_app/android/app/build.gradle.kts`
   - `namespace = "com.fuelmate.app"`
   - `applicationId = "com.fuelmate.app"`

### Files That Need Your Action:
1. ⚠️ `flutter_app/android/app/google-services.json` - **Download new one from Firebase**

---

## 🚀 After Firebase Update

Once you've downloaded the new `google-services.json`:

1. **Replace the file:**
   ```
   flutter_app/android/app/google-services.json
   ```

2. **Rebuild the AAB:**
   ```powershell
   cd "D:\my work place\PetrolMate\flutter_app"
   flutter clean
   flutter build appbundle --release
   ```

3. **Upload to Play Store:**
   - The new AAB will have package name: `com.fuelmate.app`
   - This is allowed by Google Play ✅

---

## 📋 Package Name Options

If you prefer a different package name, you can use:

- ✅ `com.fuelmate.app` (Current - recommended)
- ✅ `com.asentyx.fuelmate` (If you want company name)
- ✅ `com.fuelmate.mobile`
- ✅ `app.fuelmate`

**Just update `build.gradle.kts` and Firebase accordingly!**

---

## ⚠️ Important Notes

1. **Package name cannot be changed after first upload to Play Store**
2. **Firebase must match the package name exactly**
3. **Old Firebase app** (`com.example.fuelmate_flutter`) can be kept for reference or deleted
4. **All users will need to reinstall** if you've already published with the old package name

---

## 🔍 Verification

After updating Firebase, verify:

1. ✅ `google-services.json` has `"package_name": "com.fuelmate.app"`
2. ✅ `build.gradle.kts` has `applicationId = "com.fuelmate.app"`
3. ✅ Build completes without Firebase errors
4. ✅ AAB file is created successfully

---

**Next Step:** Go to Firebase Console and add the new Android app with package name `com.fuelmate.app`!

