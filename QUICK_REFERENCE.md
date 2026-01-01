# ⚡ Quick Reference - Backend & Flutter

## 🚀 ONE COMMAND TO RUN EVERYTHING

```powershell
.\RUN_BOTH.ps1
```

This starts:
- ✅ .NET Backend on http://192.168.1.8:3000
- ✅ Flutter App (your choice of device)
- ✅ Automatic firewall configuration
- ✅ Automatic IP detection

---

## 📡 Your Configuration

```
Computer IP:    192.168.1.8
Backend Port:   3000
Backend URL:    http://192.168.1.8:3000
API Docs:       http://192.168.1.8:3000/api/docs
```

---

## 🎯 Manual Start

### Backend
```powershell
cd backend-dotnet
dotnet run
```

### Flutter (Physical Device)
```powershell
cd flutter_app
flutter run
```

### Flutter (Chrome)
```powershell
cd flutter_app
flutter run -d chrome
```

---

## 📱 Device Configuration

### Physical Device
```dart
// flutter_app/lib/config/api_config.dart
usePhysicalDevice = true;   // ✅ Already set
apiHostIp = '192.168.1.8';  // ✅ Already set
```

### Android Emulator
```dart
usePhysicalDevice = false;  // Change to false
// API will use 10.0.2.2:3000
```

---

## 🧪 Test

```powershell
# Test backend
Invoke-WebRequest http://localhost:3000/health

# Test network access
Invoke-WebRequest http://192.168.1.8:3000/health
```

---

## 🔥 Open Firewall

```powershell
New-NetFirewallRule -DisplayName "FuelMate API" -Direction Inbound -LocalPort 3000 -Protocol TCP -Action Allow
```

---

## 📚 Full Documentation

- **NETWORK_SETUP_GUIDE.md** - Complete setup guide
- **backend-dotnet/README.md** - Backend documentation
- **flutter_app/README.md** - Flutter app documentation

---

**Ready!** Run: `.\RUN_BOTH.ps1` 🎉

