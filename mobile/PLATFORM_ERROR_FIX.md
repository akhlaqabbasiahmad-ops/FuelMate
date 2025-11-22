# PlatformConstants Error Fix

## Error: "PlatefarmConstant could not be found"

This error is typically caused by:
1. Metro bundler cache issues
2. React Native/Expo compatibility issues
3. Corrupted node_modules

## Quick Fix

### Step 1: Clear Metro Cache
```powershell
cd mobile
npx expo start --clear
```

### Step 2: If Still Not Working - Full Clean
```powershell
cd mobile

# Stop Metro bundler first (Ctrl+C)

# Remove node_modules and lock file
Remove-Item -Recurse -Force node_modules
Remove-Item package-lock.json

# Clear npm cache
npm cache clean --force

# Reinstall dependencies
npm install --legacy-peer-deps

# Start with cleared cache
npx expo start --clear
```

### Step 3: Alternative - Use Expo Install
```powershell
cd mobile
npx expo install --fix
npx expo start --clear
```

## What Was Changed

1. **ChatScreen.tsx**: Updated `KeyboardAvoidingView` behavior to avoid Platform.OS issues
   - Changed from `'height'` to `undefined` for Android
   - This prevents PlatformConstants access issues

## If Error Persists

1. **Check React Native Version Compatibility**:
   - Expo SDK 54 should work with React Native 0.76.5
   - If issues persist, try downgrading React Native:
     ```powershell
     npx expo install react-native@0.76.3
     ```

2. **Check for Native Module Issues**:
   - Ensure all native modules are properly linked
   - Run: `npx expo prebuild --clean`

3. **Reset Everything**:
   ```powershell
   cd mobile
   Remove-Item -Recurse -Force node_modules
   Remove-Item package-lock.json
   Remove-Item .expo
   npm cache clean --force
   npm install --legacy-peer-deps
   npx expo start --clear
   ```

## Prevention

- Always use `npx expo start --clear` when encountering module errors
- Use `npx expo install` for Expo packages instead of `npm install`
- Keep dependencies updated with `npx expo install --fix`

