# Chat Notifications & Message Count Feature

## Features Added

### 1. Read Status Tracking
- ✅ Messages now have `read` and `readAt` fields
- ✅ Messages are automatically marked as read when chat is opened
- ✅ Read receipts shown with checkmarks (✓ = sent, ✓✓ = read)

### 2. Unread Message Count Badge
- ✅ Real-time unread count displayed on Chat button
- ✅ Red badge with count appears when there are unread messages
- ✅ Badge shows "99+" for counts over 99
- ✅ Automatically updates in real-time

### 3. Message Read Indicators
- ✅ Single checkmark (✓) = Message sent
- ✅ Double checkmark (✓✓) = Message read
- ✅ Blue double checkmark when read

## Files Modified

### 1. `lib/models/chat_message.dart`
- Added `read` field (boolean)
- Added `readAt` field (DateTime)
- Updated JSON serialization

### 2. `lib/services/firestore_chat_service.dart`
- Messages now created with `read: false`
- Added `watchUnreadCount()` stream for real-time count
- Updated `_chatMessageFromMap()` to include read status
- Enhanced `markAsRead()` to mark messages when chat opens

### 3. `lib/screens/chat_screen.dart`
- Auto-mark messages as read when chat opens
- Auto-mark new messages as read when they arrive
- Show read receipts (checkmarks) on sent messages
- Blue checkmark when message is read

### 4. `lib/screens/requests_screen.dart`
- Added unread count badge to Chat button
- Real-time badge updates using StreamBuilder
- Badge only shows when count > 0

## How It Works

### Message Flow

**1. Sending a Message:**
```
User sends message → Firestore creates with read: false
```

**2. Opening Chat:**
```
User opens chat → markAsRead() called → All unread messages marked as read
```

**3. Real-time Updates:**
```
StreamBuilder watches unreadCount → Badge updates automatically
```

### Firestore Structure

**Message Document:**
```json
{
  "id": "msg_123...",
  "senderId": "user_123",
  "senderName": "John",
  "senderRole": "needy",
  "message": "Hello!",
  "createdAt": "2026-01-02T...",
  "read": false,
  "readAt": null
}
```

**After Read:**
```json
{
  "read": true,
  "readAt": "2026-01-02T..."
}
```

## UI Components

### Chat Button with Badge
```dart
Stack(
  children: [
    ElevatedButton.icon(
      icon: Icon(Icons.chat),
      label: Text('Chat'),
    ),
    if (unreadCount > 0)
      Positioned(
        right: 8,
        top: 4,
        child: Badge with count
      ),
  ],
)
```

### Read Receipts
```dart
Row(
  children: [
    Text(time),
    Icon(
      message.read ? Icons.done_all : Icons.done,
      color: message.read ? Colors.blue : Colors.grey,
    ),
  ],
)
```

## Testing

### Test Scenarios

**1. Send Message:**
- ✅ Message appears with single checkmark
- ✅ Badge appears on other user's Chat button

**2. Open Chat:**
- ✅ Messages marked as read
- ✅ Checkmarks turn blue (double check)
- ✅ Badge disappears

**3. New Message Arrives:**
- ✅ Badge count increases
- ✅ If chat is open, message auto-marked as read

**4. Multiple Unread:**
- ✅ Badge shows correct count
- ✅ Shows "99+" for counts > 99

## Future Enhancements

Possible additions:
- Push notifications for new messages
- Sound/vibration on message received
- Typing indicators
- Message delivery status
- Last seen timestamp
- Message reactions

## Database Indexes Required

For optimal performance, create these Firestore indexes:

**Collection: `petrolRequests/{requestId}/messages`**
- `senderId` (Ascending) + `read` (Ascending)
- `createdAt` (Ascending)

## Performance Notes

- Uses StreamBuilder for real-time updates
- Efficient queries with `where` clauses
- Batch updates for marking messages as read
- Minimal data transfer (only unread count)

## Troubleshooting

**Badge not updating:**
- Check Firestore connection
- Verify StreamBuilder is active
- Check userId is correct

**Messages not marking as read:**
- Verify `markAsRead()` is called
- Check Firestore permissions
- Verify userId matches

**Read receipts not showing:**
- Check message model has `read` field
- Verify Firestore document structure
- Check UI rendering logic

