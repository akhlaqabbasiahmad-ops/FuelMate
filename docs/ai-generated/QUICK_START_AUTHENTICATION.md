# 🚀 Quick Start - Authentication System

## Step-by-Step Guide to Enable Authentication

### ✅ Prerequisites
- Backend is set up (LocalDB configured)
- Flutter app is configured
- Both are currently working without auth

---

## 🔧 Step 1: Run Database Migration

Open PowerShell in the `backend-dotnet` directory:

```powershell
cd backend-dotnet
.\MIGRATE_ADD_PASSWORD.ps1
```

**Expected Output:**
```
========================================
  FuelMate - Database Migration
  Adding Password Authentication
========================================

📊 Checking SQL Server LocalDB...
✅ sqlcmd found

🔄 Running database migration...

📝 Adding PasswordHash column to Users table...
✅ PasswordHash column added successfully!
✅ Updated existing users with empty password hash.
✅ PasswordHash is now required!

========================================
  ✅ Migration completed successfully!
========================================
```

---

## 🔧 Step 2: Restart Backend

```powershell
# In the backend-dotnet directory
.\START_BACKEND.ps1
```

Or manually:

```powershell
dotnet watch run
```

**Expected Output:**
```
info: Microsoft.Hosting.Lifetime[14]
      Now listening on: http://0.0.0.0:3000
```

---

## 🔧 Step 3: Run Flutter App

Open a new PowerShell window:

```powershell
cd flutter_app
flutter run
```

**Expected Output:**
```
Launching lib\main.dart on V2310 in debug mode...
Running Gradle task 'assembleDebug'...
✓ Built build\app\outputs\flutter-apk\app-debug.apk
```

---

## 🎯 Step 4: Test the Authentication

### Test New User Registration:

1. **Open the app** - It will show role selection
2. **Select "I need petrol" or "I can supply"**
3. **Enter a new name** - e.g., "TestUser"
4. **Wait 1 second** - App checks if name exists
5. **See "Username available!" message**
6. **Enter password** - e.g., "test123"
7. **Confirm password** - e.g., "test123"
8. **Click "Create Account"**
9. **✅ You're in!** - Redirected to Requests Screen

### Test Existing User Login:

1. **Open the app** (close and reopen, or logout)
2. **Select same role as before**
3. **Enter existing name** - e.g., "TestUser"
4. **Automatically redirected to Login Screen** 🎉
5. **Enter password** - e.g., "test123"
6. **Click "Login"**
7. **✅ You're in!** - Redirected to Requests Screen

---

## 🔍 Verify Everything Works

### ✅ Backend Verification

1. **Open Swagger UI:** http://localhost:3000/swagger
2. **Look for these endpoints:**
   - `POST /api/users/login` ✅
   - `POST /api/users/register` (now accepts password) ✅
   - `POST /api/users/check-exists` ✅

### ✅ Flutter Verification

1. **Registration screen shows password fields** ✅
2. **Login screen appears for existing users** ✅
3. **Password validation works** ✅
4. **Show/hide password toggle works** ✅
5. **Error messages appear for invalid input** ✅

---

## 🎨 What Changed?

### Backend:
- ✅ Added `PasswordHash` column to Users table
- ✅ Created `PasswordService` for hashing/verification
- ✅ Added `login` endpoint
- ✅ Updated `register` endpoint to accept passwords
- ✅ Added `check-exists` endpoint

### Flutter:
- ✅ Created `AuthService` for authentication
- ✅ Created beautiful `LoginScreen`
- ✅ Updated `NameInputScreen` with password fields
- ✅ Enhanced `UserProvider` with authentication state
- ✅ Added automatic routing (existing → login, new → register)

---

## 🐛 Troubleshooting

### Problem: "Migration failed"
**Solution:**
```powershell
# Make sure LocalDB is running
sqllocaldb info MSSQLLocalDB

# If not running, start it
sqllocaldb start MSSQLLocalDB

# Re-run migration
.\MIGRATE_ADD_PASSWORD.ps1
```

### Problem: "Backend won't start"
**Solution:**
```powershell
# Check for port conflicts
netstat -ano | findstr :3000

# Kill process if needed (replace PID)
taskkill /PID <PID> /F

# Restart backend
dotnet watch run
```

### Problem: "Flutter build errors"
**Solution:**
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter run
```

### Problem: "Can't login with existing user"
**Reason:** Existing users don't have passwords yet.

**Solution:**
1. **Option A:** Create new user with password
2. **Option B:** Reset database:
   ```powershell
   cd backend-dotnet
   .\SETUP_LOCALDB.ps1  # Recreates database
   .\MIGRATE_ADD_PASSWORD.ps1
   ```

---

## 📊 Test Scenarios

### ✅ Happy Path - New User
```
1. Select role → 2. Enter new name → 3. See "available" 
→ 4. Enter password → 5. Confirm → 6. Register → 7. Success!
```

### ✅ Happy Path - Existing User
```
1. Select role → 2. Enter existing name → 3. Auto-redirect to login
→ 4. Enter password → 5. Login → 6. Success!
```

### ❌ Error Path - Invalid Password
```
1. Try password "123" → Error: "Must be at least 6 characters"
2. Try password "123456" → Error: "Must contain at least one letter"
3. Try password "abcdef" → Error: "Must contain at least one number"
4. Try password "test123" → ✅ Success!
```

### ❌ Error Path - Wrong Login Password
```
1. Enter existing username
2. Enter wrong password
3. Click login
4. See error: "Invalid password. Please try again."
5. Password field clears
6. Try again with correct password → ✅ Success!
```

---

## 🎯 Quick Commands Reference

```powershell
# Migrate database
cd backend-dotnet
.\MIGRATE_ADD_PASSWORD.ps1

# Start backend
.\START_BACKEND.ps1

# Run Flutter app
cd ..\flutter_app
flutter run

# View Swagger docs
start http://localhost:3000/swagger

# Reset everything (if needed)
cd ..\backend-dotnet
.\SETUP_LOCALDB.ps1
.\MIGRATE_ADD_PASSWORD.ps1
.\START_BACKEND.ps1
```

---

## 🎊 You're Done!

If you've completed all steps above, you now have:

- ✅ Password-protected user accounts
- ✅ Beautiful login/register UI
- ✅ Secure password hashing
- ✅ Session management
- ✅ Automatic user routing

**Enjoy your secure FuelMate app!** 🚀

---

## 📞 Need Help?

Check these files for more details:
- `AUTHENTICATION_COMPLETE.md` - Full documentation
- `BACKEND_AUTH_COMPLETE.md` - Backend API reference
- `AUTHENTICATION_IMPLEMENTATION_PLAN.md` - Architecture details

**Happy coding!** 💻

