# 🚀 Google Play Store Deployment Guide

## ✅ Complete Checklist for Play Store Submission

### **1. Permissions & Manifest** ✅ DONE
- ✅ All required permissions added
- ✅ Location permissions (FINE, COARSE, BACKGROUND)
- ✅ Internet & Network state
- ✅ Foreground service for location
- ✅ Query intents for URL launcher
- ✅ Network security config
- ✅ Back gesture handler enabled

### **2. Build Configuration** ✅ DONE
- ✅ Updated application ID: `com.fuelmate.app`
- ✅ Target SDK 34 (Android 14)
- ✅ Min SDK 21 (Android 5.0)
- ✅ ProGuard rules configured
- ✅ Code minification enabled
- ✅ Resource shrinking enabled
- ✅ AAB bundle configuration

### **3. What's Ready**
- ✅ Android Manifest with all permissions
- ✅ Network security configuration
- ✅ ProGuard rules for release build
- ✅ Build script (BUILD_AAB.ps1)
- ✅ Firebase integration
- ✅ Location services
- ✅ Maps integration

---

## ⚠️ **IMPORTANT: Before Building AAB**

### **A. Configure Release Signing (REQUIRED!)**

Currently using DEBUG keystore which is **NOT** suitable for Play Store!

#### **Create Release Keystore:**

```powershell
# Run this in your terminal
keytool -genkey -v -keystore fuelmate-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias fuelmate
```

**Enter details when prompted:**
- Password: (Choose a strong password and SAVE IT!)
- First and last name: Your name
- Organization: FuelMate
- City, State, Country: Your location
- Confirm: yes

**SAVE THIS FILE SAFELY! You'll need it for ALL future updates!**

#### **Configure Signing in Android:**

1. Create `android/key.properties`:
```properties
storePassword=YOUR_KEYSTORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=fuelmate
storeFile=D:/path/to/fuelmate-release-key.jks
```

2. Update `android/app/build.gradle.kts` to use the keystore

---

### **B. Update App Information**

#### **1. Update Version (pubspec.yaml):**
```yaml
version: 1.0.0+1
```

#### **2. Update App Name (if needed):**
`android/app/src/main/AndroidManifest.xml`:
```xml
android:label="FuelMate - Petrol Delivery"
```

#### **3. Add App Icon:**
- Place icon files in: `android/app/src/main/res/mipmap-*/`
- Or use: https://romannurik.github.io/AndroidAssetStudio/

---

## 🔨 **Building the AAB**

### **Option 1: Use PowerShell Script (Easiest)**

```powershell
.\BUILD_AAB.ps1
```

This script will:
1. Clean previous builds
2. Get dependencies
3. Build release AAB
4. Show build statistics
5. Display next steps

### **Option 2: Manual Build**

```powershell
cd "D:\my work place\PetrolMate\flutter_app"

# Clean
flutter clean

# Get dependencies
flutter pub get

# Build AAB
flutter build appbundle --release
```

### **Output Location:**
```
D:\my work place\PetrolMate\flutter_app\build\app\outputs\bundle\release\app-release.aab
```

---

## 📋 **Play Console Setup**

### **1. Create App in Play Console**
1. Go to: https://play.google.com/console
2. Click "Create app"
3. Fill in details:
   - **App name**: FuelMate
   - **Default language**: English (United States)
   - **App or game**: App
   - **Free or paid**: Free

### **2. Fill Required Information**

#### **A. App Details:**
- **App name**: FuelMate - Emergency Petrol Delivery
- **Short description** (80 chars):
  ```
  Connect with nearby petrol providers for quick emergency fuel delivery
  ```
- **Full description** (4000 chars):
  ```
  FuelMate connects people in need of emergency petrol with nearby providers for fast, reliable fuel delivery.

  KEY FEATURES:
  • Real-time location-based matching
  • Instant quote comparison
  • Direct chat with providers
  • Live delivery tracking
  • Transparent pricing
  • Quick request creation
  • History of all deliveries
  
  FOR NEEDY USERS:
  - Create petrol request in seconds
  - Receive multiple quotes instantly
  - Compare prices and distances
  - Track provider location
  - Safe and reliable delivery
  
  FOR PROVIDERS:
  - Find nearby requests
  - Send competitive quotes
  - Build your customer base
  - Track earnings and history
  - Flexible working hours

  Perfect for:
  • Emergency situations
  • Remote locations
  • Late night needs
  • Stranded vehicles
  • Quick refueling

  Download FuelMate today and never worry about running out of fuel again!
  ```

#### **B. App Category:**
- **Category**: Travel & Local
- **Tags**: delivery, petrol, fuel, emergency, on-demand

#### **C. Contact Details:**
- **Email**: your-email@example.com
- **Website** (optional): https://yourwebsite.com
- **Phone** (optional): Your phone number

#### **D. Privacy Policy:**
- **URL**: Must have privacy policy URL
- See template below

### **3. Graphics Assets Required**

| Asset | Size | Required |
|-------|------|----------|
| App icon | 512x512 | ✅ Yes |
| Feature graphic | 1024x500 | ✅ Yes |
| Phone screenshots | 1080x1920 or higher | ✅ Yes (2-8) |
| 7-inch tablet | 1536x2048 | ❌ Optional |
| 10-inch tablet | 2048x1536 | ❌ Optional |

### **4. Content Rating**
1. Fill out questionnaire
2. Answer questions about your app's content
3. Get rating (likely: Everyone or Teen)

### **5. Privacy & Security**
- ✅ Data safety form (what data you collect)
- ✅ Privacy policy URL
- ✅ Permissions declaration
- ✅ Target audience (18+)

---

## 🔐 **Data Safety (Play Console)**

Declare what data your app collects:

### **Location Data:**
- ✅ Collected for: Core functionality
- ✅ Shared: No
- ✅ Optional: No (required for app to work)

### **Personal Information:**
- ✅ Username
- ✅ Not shared with third parties
- ✅ User can request deletion

### **App Activity:**
- ✅ In-app messages (chat)
- ✅ For user communication only

---

## 📄 **Privacy Policy Template**

You MUST have a privacy policy. Here's a template:

```
FuelMate Privacy Policy

Last updated: [DATE]

1. Information We Collect
- Location data (to match users with nearby providers)
- Username (for identification)
- Request history (for your records)
- Chat messages (for communication)

2. How We Use Information
- To connect needy users with providers
- To facilitate petrol delivery services
- To improve app functionality
- To provide customer support

3. Data Sharing
- We do NOT sell your personal information
- Location is shared only with matched providers
- Chat messages are only visible to participants

4. Data Storage
- Data stored securely using Firebase
- Encrypted in transit and at rest
- Retained as long as your account is active

5. Your Rights
- Access your data
- Delete your account
- Opt out of location services (app won't work)

6. Contact
Email: your-email@example.com

7. Changes
We may update this policy. Check regularly for updates.
```

---

## 🚀 **Upload to Play Store**

### **Step-by-Step:**

1. **Go to Production Track**
   - Play Console → Your App → Release → Production

2. **Create New Release**
   - Click "Create new release"

3. **Upload AAB**
   - Drag and drop `app-release.aab`
   - Wait for processing (2-5 minutes)

4. **Release Notes**
   ```
   Initial release of FuelMate!

   Features:
   • Emergency petrol delivery requests
   • Real-time provider matching
   • Instant quote comparison
   • Live chat functionality
   • Location tracking
   • Request history
   
   We're excited to help you never run out of fuel!
   ```

5. **Review and Rollout**
   - Review all information
   - Click "Review release"
   - Fix any warnings/errors
   - Click "Start rollout to Production"

### **Review Process:**
- Usually takes 1-3 days
- You'll get email updates
- May ask for additional information

---

## ⚠️ **Common Issues & Solutions**

### **Issue 1: "App not using Play App Signing"**
**Solution:** Enable Play App Signing when creating first release

### **Issue 2: "Missing privacy policy"**
**Solution:** Add privacy policy URL in App Content

### **Issue 3: "Target API level too low"**
**Solution:** Already set to 34 ✅

### **Issue 4: "Permissions not declared"**
**Solution:** Already declared in manifest ✅

### **Issue 5: "Missing screenshots"**
**Solution:** Take 2-8 screenshots of app screens

---

## 📸 **Screenshots to Take**

1. **Login/Registration Screen**
2. **Role Selection (Needy/Provider)**
3. **Main Screen (with requests)**
4. **Create Request Dialog**
5. **Quotes Display**
6. **Map View**
7. **Chat Screen**
8. **History Screen**

**Tips:**
- Use real data
- Show app in use
- Clear, readable text
- Good lighting/contrast

---

## ✅ **Final Checklist Before Upload**

- [ ] Release keystore created and saved
- [ ] Version number updated
- [ ] AAB built successfully
- [ ] Privacy policy created and hosted
- [ ] App screenshots taken (2-8)
- [ ] Feature graphic created (1024x500)
- [ ] App icon ready (512x512)
- [ ] App description written
- [ ] Contact email added
- [ ] Content rating completed
- [ ] Data safety form filled
- [ ] All permissions declared

---

## 🎯 **Quick Start Commands**

```powershell
# Build AAB for Play Store
.\BUILD_AAB.ps1

# Or manually:
cd "D:\my work place\PetrolMate\flutter_app"
flutter build appbundle --release

# Check AAB location:
explorer "D:\my work place\PetrolMate\flutter_app\build\app\outputs\bundle\release\"
```

---

## 📞 **Support**

If you encounter issues:
1. Check Flutter/Android Studio logs
2. Review Play Console error messages
3. Check Firebase configuration
4. Ensure all dependencies are updated

---

## 🎉 **After Approval**

Once approved:
1. ✅ App goes live on Play Store
2. ✅ Users can download
3. ✅ Track downloads in Play Console
4. ✅ Monitor crash reports
5. ✅ Collect user reviews
6. ✅ Plan updates

---

**Good luck with your Play Store submission!** 🚀

