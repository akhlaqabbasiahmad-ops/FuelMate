# App Icon Assets

## Required Files

Place your app icon files here:

### 1. **app_icon.png** (REQUIRED)
- Size: 1024x1024 pixels
- Format: PNG
- Background: Solid color (no transparency for iOS)
- This is your main app icon

### 2. **app_icon_foreground.png** (OPTIONAL)
- Size: 432x432 pixels (108dp)
- Format: PNG
- For Android adaptive icons
- If not provided, the script will copy app_icon.png

---

## How to Generate Your Icon

### Quick Method (5 minutes):

1. **Generate with AI**:
   - Go to https://www.bing.com/create
   - Use this prompt:
   ```
   Modern minimalist app icon for petrol delivery service.
   Blue fuel drop combined with orange location pin.
   Flat design, professional, clean, 1024x1024px, iOS style.
   ```
   - Download the generated image

2. **Save it here**:
   - Save as: `app_icon.png`
   - Place in this directory

3. **Run the generator**:
   ```powershell
   # From project root
   .\scripts\GENERATE_APP_ICONS.ps1
   ```

That's it! The script will automatically generate all required sizes for iOS and Android.

---

## Alternative Tools

- **Canva**: https://www.canva.com/create/app-icons/
- **Adobe Express**: https://www.adobe.com/express/create/app-icon
- **Leonardo.ai**: https://leonardo.ai
- **Ideogram.ai**: https://ideogram.ai

---

## Color Palette

Use these colors for consistency with the app:

```
Primary Blue:     #2196F3
Secondary Orange: #FF9800
Accent Yellow:    #FFC107
Background:       #FFFFFF
```

---

## Design Guidelines

✅ **Do**:
- Keep design simple and bold
- Use high contrast colors
- Make it recognizable at small sizes (29x29px)
- Use solid background for iOS

❌ **Don't**:
- Use text or small details
- Use transparency (iOS requirement)
- Use too many colors
- Copy existing app icons

---

## Testing

After generating icons, test on:
- iOS Simulator: `flutter run -d "iPhone 15 Pro"`
- Android Emulator: `flutter run -d emulator-5554`

Check the icon on:
- Home screen
- App switcher
- Settings menu
- Notification bar

---

## Need Help?

See full documentation:
- Quick Start: `docs/ai-generated/ICON_QUICK_START.md`
- Detailed Guide: `docs/ai-generated/APP_ICON_DESIGN_GUIDE.md`

---

**Current Status**: ⚠️ No icon files yet. Please generate your icon using the steps above.

