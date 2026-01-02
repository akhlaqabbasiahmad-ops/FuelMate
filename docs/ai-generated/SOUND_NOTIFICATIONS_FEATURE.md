# Sound & Bell Notifications Feature

## Overview

Added sound notifications (bell/ring) for:
1. **New Request Arrival** (Provider) - Bell rings when new petrol request arrives
2. **New Quote Received** (Needy) - Bell rings when provider sends quote
3. **New Message** - Bell rings when chat message arrives

## Features Implemented

### 1. Notification Service
- ✅ Sound/bell plays on notifications
- ✅ Device vibration on notifications
- ✅ Visual notifications with message
- ✅ Automatic permission requests

### 2. Notification Types

**For Providers:**
- 🚨 New Request: "🚨 New Petrol Request - [Name] needs petrol"
- ✅ Quote Accepted: "✅ Quote Accepted! - [Name] accepted your quote"
- 💬 New Message: "💬 [Name] - [Message]"

**For Needers:**
- 💰 New Quote: "💰 New Quote Received - [Provider] sent quote: PKR [price]"
- 💬 New Message: "💬 [Name] - [Message]"
- 🎉 Request Completed: "🎉 Request Completed"

### 3. Sound & Vibration
- System notification sound plays
- Device vibrates
- Works even when app is in background

## Files Created/Modified

### New Files

**1. `lib/services/notification_service.dart`**
- Complete notification service
- Sound/vibration handling
- Multiple notification types
- Permission management

### Modified Files

**1. `pubspec.yaml`**
- Added `audioplayers: ^5.2.1`
- Added `flutter_local_notifications: ^16.3.2`

**2. `lib/main.dart`**
- Initialize NotificationService on app start
- Import notification service

**3. `lib/providers/request_provider.dart`**
- Notify on new requests (Provider)
- Notify on new quotes (Needy)
- Track notified items to avoid duplicates

**4. `lib/screens/chat_screen.dart`**
- Notify on new messages
- Only notify for messages from others
- Track message count

**5. `android/app/src/main/AndroidManifest.xml`**
- Added notification permissions
- Added vibration permission
- Firebase messaging metadata

## How It Works

### Notification Flow

**1. New Request (Provider):**
```
New request arrives → RequestProvider detects → NotificationService plays bell → Shows notification
```

**2. New Quote (Needy):**
```
Quote arrives → RequestProvider detects → NotificationService plays bell → Shows notification
```

**3. New Message:**
```
Message arrives → ChatScreen detects → NotificationService plays bell → Shows notification
```

### Permission Handling

**Android:**
- Automatically requests notification permission
- Requests vibration permission
- Works on Android 13+ (API 33+)

**iOS:**
- Requests alert, badge, and sound permissions
- User can allow/deny

## Usage

### Initialize (Already Done)
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  // Initialize notifications
  await NotificationService().initialize();
  
  runApp(const FuelMateApp());
}
```

### Show Notification Manually
```dart
final notificationService = NotificationService();

// New request
await notificationService.showNewRequestNotification(
  requestId: 'req_123',
  needyName: 'John',
  message: 'Need 10L petrol urgently',
  distance: '2.5',
);

// New quote
await notificationService.showNewQuoteNotification(
  quoteId: 'quote_123',
  providerName: 'Ali',
  price: 390.0,
  currency: 'PKR',
);

// New message
await notificationService.showNewMessageNotification(
  requestId: 'req_123',
  senderName: 'John',
  message: 'On my way!',
);
```

## Testing

### Test Scenarios

**1. New Request (Provider):**
- ✅ Open app as Provider
- ✅ Have Needy create request nearby
- ✅ Bell should ring
- ✅ Notification should appear

**2. New Quote (Needy):**
- ✅ Open app as Needy
- ✅ Create a request
- ✅ Have Provider send quote
- ✅ Bell should ring
- ✅ Notification should appear

**3. New Message:**
- ✅ Open chat
- ✅ Other user sends message
- ✅ Bell should ring
- ✅ Notification should appear

**4. Background:**
- ✅ Put app in background
- ✅ Trigger any notification
- ✅ Bell should ring
- ✅ Notification should appear in system tray

## Configuration

### Notification Channels

**Android:**
- `new_requests` - New Requests channel
- `new_quotes` - New Quotes channel
- `new_messages` - New Messages channel
- `quote_accepted` - Quote Accepted channel
- `request_completed` - Request Completed channel

All channels use:
- High importance
- High priority
- Sound enabled
- Vibration enabled

### Customization

**Change Sound:**
```dart
// In notification_service.dart
await SystemSound.play(SystemSoundType.alert); // Change this
```

**Change Vibration:**
```dart
HapticFeedback.vibrate(); // Or HapticFeedback.heavyImpact()
```

**Disable Sound:**
```dart
// Comment out in _playSound()
// await SystemSound.play(SystemSoundType.alert);
```

## Permissions Required

### Android (AndroidManifest.xml)
```xml
<uses-permission android:name="android.permission.VIBRATE"/>
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
```

### iOS (Info.plist)
Automatically handled by flutter_local_notifications

## Dependencies

```yaml
dependencies:
  audioplayers: ^5.2.1
  flutter_local_notifications: ^16.3.2
```

## Troubleshooting

**No sound playing:**
- Check device is not on silent mode
- Check notification permissions granted
- Check system notification settings

**No vibration:**
- Check device vibration is enabled
- Check app has vibration permission
- Some devices don't support vibration

**Notifications not showing:**
- Check notification permissions
- Check app is not in battery saver mode
- Check notification channels are enabled

**Duplicate notifications:**
- Provider tracks notified requests
- Needy tracks quote counts
- Message count tracked per chat

## Future Enhancements

Possible additions:
- Custom notification sounds
- Different sounds for different notification types
- Notification grouping
- Rich notifications with actions
- Firebase Cloud Messaging for remote notifications
- Notification history
- Do Not Disturb mode
- Quiet hours

## Performance Notes

- Notifications are lightweight
- Sound plays instantly
- No impact on app performance
- Efficient duplicate detection
- Minimal battery usage

## Build Instructions

After adding this feature, run:

```powershell
cd flutter_app
flutter pub get
flutter clean
flutter build appbundle --release --split-debug-info=build/app/debug-info
```

Then upload the new AAB to Play Store.

