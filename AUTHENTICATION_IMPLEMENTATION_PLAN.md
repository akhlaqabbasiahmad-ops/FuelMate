# 🔐 User Authentication Implementation Plan

## Overview
Add password-based authentication so users must register with a password and login if they already exist.

---

## 🎯 Requirements

### Current Flow:
1. User selects role (provider/needy)
2. User enters name
3. App checks if name is available
4. User is registered automatically

### New Flow:
1. User selects role (provider/needy)
2. User enters name
3. **If name exists** → Go to login screen (enter password)
4. **If name is new** → Register screen (enter password, confirm password)
5. User is authenticated and logged in

---

## 📋 Implementation Steps

### Backend Changes (4 files)

#### 1. Update Database Schema
**File:** `backend-dotnet/CreateDatabase.sql`

Add password field to Users table:
```sql
ALTER TABLE Users
ADD PasswordHash NVARCHAR(255) NOT NULL DEFAULT '';
```

Or create migration SQL:
```sql
-- Add password column
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'Users') AND name = 'PasswordHash')
BEGIN
    ALTER TABLE Users ADD PasswordHash NVARCHAR(255) NULL;
END
GO

-- Set default for existing users (they'll need to set password on next login)
UPDATE Users SET PasswordHash = '' WHERE PasswordHash IS NULL;
GO

-- Make it required
ALTER TABLE Users ALTER COLUMN PasswordHash NVARCHAR(255) NOT NULL;
GO
```

#### 2. Update User Model
**File:** `backend-dotnet/Models/User.cs`

Add password field:
```csharp
public string PasswordHash { get; set; } = string.Empty;
```

#### 3. Add Password Hashing Service
**New File:** `backend-dotnet/Services/PasswordService.cs`

```csharp
using System.Security.Cryptography;
using System.Text;

namespace FuelMateBackend.Services;

public class PasswordService
{
    public string HashPassword(string password)
    {
        using var sha256 = SHA256.Create();
        var bytes = sha256.ComputeHash(Encoding.UTF8.GetBytes(password));
        return Convert.ToBase64String(bytes);
    }

    public bool VerifyPassword(string password, string hash)
    {
        var passwordHash = HashPassword(password);
        return passwordHash == hash;
    }
}
```

#### 4. Update UsersController
**File:** `backend-dotnet/Controllers/UsersController.cs`

Add login endpoint:
```csharp
[HttpPost("login")]
public async Task<IActionResult> Login([FromBody] LoginDto dto)
{
    // 1. Find user by name
    // 2. Verify password
    // 3. Return user info with token/session
}
```

Update register endpoint:
```csharp
[HttpPost("register")]
public async Task<IActionResult> Register([FromBody] RegisterDto dto)
{
    // 1. Check if name exists
    // 2. Hash password
    // 3. Create user
    // 4. Return user info
}
```

### Frontend Changes (5 files)

#### 5. Create Login Screen
**New File:** `flutter_app/lib/screens/login_screen.dart`

- Email/Username field
- Password field
- Login button
- "Forgot password?" link (optional)
- Error messages

#### 6. Update Name Input Screen
**File:** `flutter_app/lib/screens/name_input_screen.dart`

- Add password field
- Add confirm password field
- Show/hide password toggle
- Password validation
- Show different UI if user exists (redirect to login)

#### 7. Add Authentication Service
**New File:** `flutter_app/lib/services/auth_service.dart`

Methods:
- `login(name, password)`
- `register(name, password, role)`
- `logout()`
- `isAuthenticated()`

#### 8. Update User Provider
**File:** `flutter_app/lib/providers/user_provider.dart`

Add:
- `isAuthenticated` state
- `login()` method
- `logout()` method
- Password handling

#### 9. Update Storage Service
**File:** `flutter_app/lib/services/storage_service.dart`

Add:
- Store authentication token
- Clear token on logout

---

## 🔐 Security Features

### Password Requirements:
- Minimum 6 characters
- Must contain at least one letter
- Must contain at least one number

### Password Hashing:
- Use SHA256 for hashing
- Store only hash in database
- Never store plain text passwords

### Session Management:
- Store userId in local storage after login
- Clear on logout
- Auto-logout on app restart (optional)

---

## 📱 UI Flow

### Registration Flow:
```
1. Role Selection → 2. Name Input → 3. Check Name
   ↓
   Name Available?
   ↓
   YES: Show password fields
        - Password
        - Confirm Password
        - [Register] button
   ↓
   NO: Redirect to Login Screen
```

### Login Flow:
```
1. Role Selection → 2. Name Input → 3. Check Name
   ↓
   Name Exists?
   ↓
   YES: Redirect to Login Screen
        - Name (pre-filled)
        - Password
        - [Login] button
   ↓
   NO: Show registration form
```

---

## 🎨 UI Components Needed

### Login Screen:
- Header: "Welcome Back!"
- Name field (pre-filled)
- Password field with show/hide toggle
- Login button
- "Forgot password?" link
- Error message display

### Registration (Updated Name Input):
- Header: "Create Account"
- Name field
- Password field with show/hide toggle
- Confirm password field
- Password strength indicator
- Register button
- Password requirements text

---

## 🚀 Implementation Priority

### Phase 1: Backend (High Priority)
1. ✅ Update database schema
2. ✅ Add PasswordService
3. ✅ Update User model
4. ✅ Create login endpoint
5. ✅ Update register endpoint

### Phase 2: Flutter (High Priority)
1. ✅ Create AuthService
2. ✅ Create LoginScreen
3. ✅ Update NameInputScreen
4. ✅ Update UserProvider
5. ✅ Update navigation flow

### Phase 3: Polish (Medium Priority)
1. ⏳ Password strength indicator
2. ⏳ "Forgot password" feature
3. ⏳ Session timeout
4. ⏳ Biometric authentication (optional)

---

## 📝 DTOs Needed

### LoginDto:
```csharp
public class LoginDto
{
    public string Name { get; set; }
    public string Password { get; set; }
    public string Role { get; set; }
}
```

### RegisterDto (Update existing):
```csharp
public class RegisterDto
{
    public string Name { get; set; }
    public string Password { get; set; }
    public string Role { get; set; }
}
```

---

## ⚠️ Migration for Existing Users

Existing users in database don't have passwords. Options:

### Option 1: Force Password Reset
- Detect empty password hash
- Redirect to "Set Password" screen
- User must set password to continue

### Option 2: Default Password
- Set temporary default password for existing users
- Prompt to change password on first login
- Show warning message

### Option 3: Grandfather Clause
- Existing users continue without password
- Only new users require password
- Add "Set Password" in settings for security

**Recommended: Option 1** (Force Password Reset)

---

## 🧪 Testing Checklist

- [ ] New user registration with password works
- [ ] Existing user login works
- [ ] Wrong password shows error
- [ ] Password validation works
- [ ] Password confirmation works
- [ ] Show/hide password toggle works
- [ ] Session persists after app restart
- [ ] Logout clears session
- [ ] Empty password field shows error
- [ ] Weak password is rejected

---

Ready to implement! Should I start with the backend or frontend first?

