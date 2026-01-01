# 🚀 Run Backend & Flutter App - Complete Setup Guide

This guide shows you how to run the .NET 8 backend and Flutter app together on your network.

---

## 📡 Network Configuration

**Your Computer's IP Address:** `192.168.1.8`  
**Backend Port:** `3000`  
**Backend URL:** `http://192.168.1.8:3000`

---

## ⚡ Quick Start (One Command)

```powershell
.\RUN_BOTH.ps1
```

This script will:
1. ✅ Detect your network IP automatically
2. ✅ Update Flutter app configuration
3. ✅ Check prerequisites (.NET, Flutter, SQL Server)
4. ✅ Open firewall port
5. ✅ Start backend in new window
6. ✅ Start Flutter app in new window
7. ✅ Display all connection info

---

## 🔧 Manual Setup (Step by Step)

### **Step 1: Start the .NET Backend**

```powershell
cd "D:\my work place\PetrolMate\backend-dotnet"

# Option A: Use the startup script
.\START_BACKEND.ps1

# Option B: Run directly
dotnet run
```

The backend will start on:
- **Local:** http://localhost:3000
- **Network:** http://192.168.1.8:3000
- **API Docs:** http://192.168.1.8:3000/api/docs

### **Step 2: Configure Flutter App**

The Flutter app is already configured for your network IP!

**File:** `flutter_app/lib/config/api_config.dart`

```dart
class ApiConfig {
  static const String apiHostIp = '192.168.1.8'; // ✅ Already set!
  static const int apiPort = 3000;
  static const bool usePhysicalDevice = true;
  
  static String getApiBaseUrl() {
    if (usePhysicalDevice) {
      return 'http://$apiHostIp:$apiPort'; // http://192.168.1.8:3000
    }
    return 'http://10.0.2.2:$apiPort'; // For Android emulator
  }
}
```

**For Physical Device:** Set `usePhysicalDevice = true` (already set)  
**For Android Emulator:** Set `usePhysicalDevice = false`

### **Step 3: Run Flutter App**

```powershell
cd "D:\my work place\PetrolMate\flutter_app"

# For physical device (connected via USB)
flutter run

# For Android emulator
flutter run

# For Chrome (web)
flutter run -d chrome

# For specific device
flutter devices  # List available devices
flutter run -d <device-id>
```

---

## 🔥 Firewall Configuration

**Open port 3000 for network access:**

```powershell
New-NetFirewallRule -DisplayName "FuelMate API" -Direction Inbound -LocalPort 3000 -Protocol TCP -Action Allow
```

Or use the `RUN_BOTH.ps1` script which does this automatically.

---

## 📱 Device-Specific Configuration

### **Physical Device (Phone/Tablet)**

1. **Connect to same WiFi** as your computer
2. **Flutter config:** Set `usePhysicalDevice = true`
3. **API URL:** `http://192.168.1.8:3000`
4. **Connect device via USB** for Flutter deployment
5. **Enable USB debugging** on device

### **Android Emulator**

1. **Flutter config:** Set `usePhysicalDevice = false`
2. **API URL:** `http://10.0.2.2:3000` (emulator uses special IP)
3. **Note:** Emulator redirects `10.0.2.2` to `localhost` on host

### **Chrome (Web)**

1. **API URL:** `http://localhost:3000`
2. **No device needed**
3. **Run with:** `flutter run -d chrome`

---

## 🧪 Test the Connection

### **1. Test Backend Health**

**From Browser:**
```
http://localhost:3000/health
http://192.168.1.8:3000/health
```

**From PowerShell:**
```powershell
Invoke-WebRequest http://localhost:3000/health
```

**Expected Response:**
```json
{
  "status": "ok",
  "message": "FuelMate API is running",
  "timestamp": "2026-01-01T00:00:00Z"
}
```

### **2. Test API Documentation**

Open in browser:
```
http://192.168.1.8:3000/api/docs
```

### **3. Test User Registration**

```powershell
Invoke-RestMethod -Method POST -Uri "http://192.168.1.8:3000/api/users/register" `
  -ContentType "application/json" `
  -Body '{"name":"testuser","role":"needy"}'
```

---

## 🌐 Network URLs Summary

| Service | URL | Description |
|---------|-----|-------------|
| **Backend (Local)** | http://localhost:3000 | Access from same computer |
| **Backend (Network)** | http://192.168.1.8:3000 | Access from any device on network |
| **API Documentation** | http://192.168.1.8:3000/api/docs | Swagger UI |
| **Health Check** | http://192.168.1.8:3000/health | Test if backend is running |
| **For Android Emulator** | http://10.0.2.2:3000 | Special emulator IP |

---

## 🐛 Troubleshooting

### **Problem: Backend not accessible from phone**

**Solution 1: Check Firewall**
```powershell
# Check if rule exists
Get-NetFirewallRule -DisplayName "FuelMate API"

# Create rule if missing
New-NetFirewallRule -DisplayName "FuelMate API" -Direction Inbound -LocalPort 3000 -Protocol TCP -Action Allow
```

**Solution 2: Verify Same Network**
```powershell
# Get your computer's IP
ipconfig | findstr IPv4

# On phone: Make sure WiFi is connected to same network
```

**Solution 3: Test from Computer First**
```powershell
# Test locally
Invoke-WebRequest http://localhost:3000/health

# Test via network IP
Invoke-WebRequest http://192.168.1.8:3000/health
```

### **Problem: Flutter app can't connect**

**Check 1: Verify Backend is Running**
```powershell
# Should show process
Get-Process | Where-Object {$_.ProcessName -like "*FuelMateBackend*"}
```

**Check 2: Verify Flutter Configuration**
```dart
// flutter_app/lib/config/api_config.dart
static const String apiHostIp = '192.168.1.8'; // ✅ Match your IP
static const bool usePhysicalDevice = true;     // ✅ For physical device
```

**Check 3: Test Connection from Phone Browser**
- Open browser on phone
- Go to: `http://192.168.1.8:3000/health`
- Should see JSON response

### **Problem: IP Address Changed**

Your IP address changes when you switch networks. To update:

**Option 1: Use RUN_BOTH.ps1**
```powershell
.\RUN_BOTH.ps1  # Automatically detects and updates IP
```

**Option 2: Manual Update**
```powershell
# Get new IP
ipconfig | findstr IPv4

# Update flutter_app/lib/config/api_config.dart
# Change: static const String apiHostIp = 'NEW_IP_HERE';
```

### **Problem: Port 3000 already in use**

```powershell
# Find what's using port 3000
netstat -ano | findstr :3000

# Kill the process (replace PID with actual process ID)
Stop-Process -Id <PID> -Force

# Or change port in backend-dotnet/appsettings.json
# Then update Flutter app config
```

### **Problem: SQL Server Connection Failed**

```powershell
cd backend-dotnet
.\SETUP_SQLSERVER.ps1  # Run database setup
.\TEST_CONNECTION.ps1   # Test connection
```

---

## 📂 Configuration Files Reference

### **Backend Configuration**

**File:** `backend-dotnet/appsettings.json`
```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=localhost;Database=FuelMate;User Id=sa;Password=YourPassword123!;TrustServerCertificate=True;"
  },
  "Port": "3000"
}
```

### **Flutter Configuration**

**File:** `flutter_app/lib/config/api_config.dart`
```dart
class ApiConfig {
  static const String apiHostIp = '192.168.1.8';
  static const int apiPort = 3000;
  static const bool usePhysicalDevice = true;
  
  static String getApiBaseUrl() {
    if (usePhysicalDevice) {
      return 'http://$apiHostIp:$apiPort';
    }
    return 'http://10.0.2.2:$apiPort'; // Emulator
  }
}
```

---

## 🎯 Common Scenarios

### **Scenario 1: Testing on Physical Device**

```powershell
# 1. Start backend
cd backend-dotnet
dotnet run

# 2. Connect phone to WiFi (same network as PC)
# 3. Connect phone via USB
# 4. Enable USB debugging on phone

# 5. Run Flutter app
cd ..\flutter_app
flutter run  # Automatically detects USB device
```

### **Scenario 2: Testing on Android Emulator**

```powershell
# 1. Update Flutter config
# Set usePhysicalDevice = false in api_config.dart

# 2. Start backend
cd backend-dotnet
dotnet run

# 3. Start emulator
# Open Android Studio → AVD Manager → Start Emulator

# 4. Run Flutter app
cd ..\flutter_app
flutter run  # Automatically detects emulator
```

### **Scenario 3: Testing on Chrome**

```powershell
# 1. Start backend
cd backend-dotnet
dotnet run

# 2. Run Flutter app in Chrome
cd ..\flutter_app
flutter run -d chrome
```

---

## ✅ Verification Checklist

After starting both services:

- [ ] Backend running: Visit http://localhost:3000/health
- [ ] Network access: Visit http://192.168.1.8:3000/health
- [ ] API docs working: http://192.168.1.8:3000/api/docs
- [ ] Flutter app configured with correct IP
- [ ] Phone connected to same WiFi network
- [ ] Firewall port 3000 is open
- [ ] Flutter app runs and connects to backend
- [ ] Can register user in app
- [ ] Can create request in app

---

## 🚀 Quick Commands Reference

```powershell
# Start both services (easiest)
.\RUN_BOTH.ps1

# Or manually:

# Start backend only
cd backend-dotnet
.\START_BACKEND.ps1

# Start Flutter only
cd flutter_app
flutter run

# Get your IP address
ipconfig | findstr IPv4

# Test backend health
Invoke-WebRequest http://localhost:3000/health

# Open firewall
New-NetFirewallRule -DisplayName "FuelMate API" -Direction Inbound -LocalPort 3000 -Protocol TCP -Action Allow

# List Flutter devices
flutter devices

# Run on specific device
flutter run -d <device-id>

# Run on Chrome
flutter run -d chrome
```

---

## 📞 Need Help?

1. **Check backend is running:** http://localhost:3000/health
2. **Check firewall:** `Get-NetFirewallRule -DisplayName "FuelMate API"`
3. **Check IP address:** `ipconfig | findstr IPv4`
4. **Test from phone browser:** http://192.168.1.8:3000/health
5. **Check Flutter config:** `flutter_app/lib/config/api_config.dart`

---

**Your Current Configuration:**
- **Computer IP:** 192.168.1.8
- **Backend Port:** 3000
- **Backend URL:** http://192.168.1.8:3000
- **Flutter Config:** ✅ Already configured for your network

**Ready to run!** Just execute: `.\RUN_BOTH.ps1` 🚀

