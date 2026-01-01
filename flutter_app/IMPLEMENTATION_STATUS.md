# Flutter App - Complete Implementation Guide

## ✅ Completed

1. ✅ Quote model (`lib/models/quote.dart`)
2. ✅ ChatMessage model (`lib/models/chat_message.dart`)
3. ✅ QuoteService (`lib/services/quote_service.dart`)
4. ✅ ChatService (`lib/services/chat_service.dart`)
5. ✅ CreateRequestDialog (`lib/widgets/create_request_dialog.dart`)

## 🚀 Quick Implementation Steps

### Step 1: Update RequestService

Add missing methods to `lib/services/request_service.dart`:

```dart
// Add these methods to request_service.dart:

static Future<Map<String, dynamic>> completeRequest({
  required String requestId,
  required String userId,
  required String userRole,
}) async {
  final url = Uri.parse('$baseUrl/api/requests/$requestId/complete');
  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'userId': userId,
      'userRole': userRole,
    }),
  );
  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Failed to complete request');
  }
}

static Future<Map<String, dynamic>> acceptRequest({
  required String requestId,
  required String providerId,
}) async {
  final url = Uri.parse('$baseUrl/api/requests/$requestId/accept');
  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'providerId': providerId}),
  );
  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Failed to accept request');
  }
}
```

### Step 2: Update RequestsScreen

Replace `lib/screens/requests_screen.dart` with the comprehensive version that includes:

- Create Request button for needers
- Quote buttons for providers  
- Accept Quote functionality for needers
- Chat button with unread badges
- Complete Request button
- All missing UI elements

**Key Changes to Make:**

1. Import the new dialog:
```dart
import '../widgets/create_request_dialog.dart';
import '../services/quote_service.dart';
import '../services/chat_service.dart';
import '../models/quote.dart';
```

2. Add FAB for creating requests:
```dart
floatingActionButton: userRole == 'needy'
    ? FloatingActionButton.extended(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => CreateRequestDialog(
              latitude: location!.latitude,
              longitude: location.longitude,
              onRequestCreated: _fetchRequests,
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Create Request'),
        backgroundColor: const Color(0xFFFF6B35),
      )
    : null,
```

3. Add Quote display section in request cards
4. Add Chat button
5. Add Complete button
6. Add Quote action buttons for providers

### Step 3: Create ChatScreen

Create `lib/screens/chat_screen.dart`:

```dart
import 'package:flutter/material.dart';
import '../services/chat_service.dart';
import '../services/storage_service.dart';
import '../models/chat_message.dart';
import 'dart:async';

class ChatScreen extends StatefulWidget {
  final String requestId;
  
  const ChatScreen({super.key, required this.requestId});
  
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  List<ChatMessage> _messages = [];
  bool _isLoading = true;
  String? _currentUserId;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    // Poll every 2 seconds
    _pollTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      _loadMessages();
    });
  }

  @override
  void dispose() {
    _poll Timer?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    try {
      final userId = await StorageService.getUserId();
      if (userId == null) return;
      
      setState(() => _currentUserId = userId);
      
      final messages = await ChatService.getMessages(widget.requestId, userId);
      if (mounted) {
        setState(() {
          _messages = messages;
          _isLoading = false;
        });
        // Mark as read
        await ChatService.markAsRead(widget.requestId, userId);
      }
    } catch (e) {
      print('Error loading messages: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;
    
    final message = _messageController.text.trim();
    _messageController.clear();
    
    try {
      final userId = await StorageService.getUserId();
      if (userId == null) return;
      
      await ChatService.sendMessage(
        requestId: widget.requestId,
        senderId: userId,
        message: message,
      );
      
      await _loadMessages();
      _scrollToBottom();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send: $e')),
      );
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
        backgroundColor: const Color(0xFFFF6B35),
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      final isMe = msg.senderId == _currentUserId;
                      
                      return Align(
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isMe ? const Color(0xFFFF6B35) : Colors.grey[300],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.7,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                msg.senderName,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isMe ? Colors.white : Colors.black87,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                msg.message,
                                style: TextStyle(
                                  color: isMe ? Colors.white : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    maxLines: null,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _sendMessage,
                  icon: const Icon(Icons.send),
                  color: const Color(0xFFFF6B35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

### Step 4: Update App Routes

In `lib/main.dart`, add the chat route:

```dart
routes: {
  '/': (context) => const RoleSelectionScreen(),
  '/name-input': (context) => const NameInputScreen(),
  '/requests': (context) => const RequestsScreen(),
  '/history': (context) => const HistoryScreen(),
  '/chat': (context) {
    final requestId = ModalRoute.of(context)!.settings.arguments as String;
    return ChatScreen(requestId: requestId);
  },
},
```

### Step 5: Run the App

```powershell
# Terminal 1: Start backend with LocalDB
cd backend-dotnet
.\SETUP_LOCALDB.ps1  # First time only
.\START_BACKEND.ps1

# Terminal 2: Run Flutter
cd flutter_app
flutter pub get
flutter run
```

## 📝 Complete File Structure

```
flutter_app/lib/
├── models/
│   ├── quote.dart ✅
│   ├── chat_message.dart ✅
│   └── request.dart (existing)
├── services/
│   ├── quote_service.dart ✅
│   ├── chat_service.dart ✅
│   └── request_service.dart (update needed)
├── widgets/
│   └── create_request_dialog.dart ✅
├── screens/
│   ├── chat_screen.dart ⚠️ (create from above)
│   ├── requests_screen.dart ⚠️ (needs major update)
│   └── history_screen.dart (existing)
└── main.dart ⚠️ (add chat route)
```

## 🎯 Priority Implementation Order

1. ✅ Models & Services (DONE)
2. ✅ CreateRequestDialog (DONE)
3. ⚠️ ChatScreen (code provided above)
4. ⚠️ Update RequestsScreen with all features
5. ⚠️ Test complete flow

## 🚀 Testing Checklist

After implementation:
- [ ] Needy can create request
- [ ] Provider can send quote
- [ ] Needy can see and accept quote
- [ ] Both can chat after quote accepted
- [ ] Both can mark request as complete
- [ ] History shows completed requests

---

**The core services are done! Now you need to:**
1. Create ChatScreen (code above)
2. Update RequestsScreen to use the new dialogs and services
3. Test the flow

Would you like me to provide the complete updated RequestsScreen.dart file?

