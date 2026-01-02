import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_message.dart';

class FirestoreChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Send a chat message
  Future<ChatMessage> sendMessage({
    required String requestId,
    required String senderId,
    required String senderName,
    required String senderRole,
    required String message,
  }) async {
    try {
      print('💬 Sending message in request: $requestId');

      final messageId = 'msg_${DateTime.now().millisecondsSinceEpoch}_${senderId.substring(0, 9)}';
      
      final messageData = {
        'id': messageId,
        'senderId': senderId,
        'senderName': senderName,
        'senderRole': senderRole,
        'message': message,
        'createdAt': FieldValue.serverTimestamp(),
        'read': false,
        'readAt': null,
      };

      // Store message in subcollection under the request
      await _firestore
          .collection('petrolRequests')
          .doc(requestId)
          .collection('messages')
          .doc(messageId)
          .set(messageData);

      // Update request's lastMessageAt timestamp and unread count
      await _firestore
          .collection('petrolRequests')
          .doc(requestId)
          .update({
        'lastMessageAt': FieldValue.serverTimestamp(),
        'lastMessage': message,
        'lastMessageFrom': senderName,
        'lastMessageSenderId': senderId,
      });

      print('✅ Message sent: $messageId');

      return ChatMessage(
        id: messageId,
        requestId: requestId,
        senderId: senderId,
        senderName: senderName,
        senderRole: senderRole,
        message: message,
        createdAt: DateTime.now(),
      );
    } catch (e) {
      print('❌ Error sending message: $e');
      rethrow;
    }
  }

  /// Get chat messages for a request
  Future<List<ChatMessage>> getMessages(String requestId) async {
    try {
      final querySnapshot = await _firestore
          .collection('petrolRequests')
          .doc(requestId)
          .collection('messages')
          .orderBy('createdAt', descending: false)
          .get();

      final messages = querySnapshot.docs
          .map((doc) => _chatMessageFromMap(doc.data(), requestId))
          .toList();

      print('✅ Found ${messages.length} messages');
      return messages;
    } catch (e) {
      print('❌ Error getting messages: $e');
      return [];
    }
  }

  /// Listen to chat messages (real-time)
  Stream<List<ChatMessage>> watchMessages(String requestId) {
    return _firestore
        .collection('petrolRequests')
        .doc(requestId)
        .collection('messages')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => _chatMessageFromMap(doc.data(), requestId))
            .toList());
  }

  /// Mark messages as read (optional feature)
  Future<void> markAsRead(String requestId, String userId) async {
    try {
      final messagesSnapshot = await _firestore
          .collection('petrolRequests')
          .doc(requestId)
          .collection('messages')
          .where('senderId', isNotEqualTo: userId)
          .where('read', isEqualTo: false)
          .get();

      for (var doc in messagesSnapshot.docs) {
        await doc.reference.update({
          'read': true,
          'readAt': FieldValue.serverTimestamp(),
        });
      }

      print('✅ Messages marked as read');
    } catch (e) {
      print('❌ Error marking messages as read: $e');
    }
  }

  /// Get unread message count (optional feature)
  Future<int> getUnreadCount(String requestId, String userId) async {
    try {
      final messagesSnapshot = await _firestore
          .collection('petrolRequests')
          .doc(requestId)
          .collection('messages')
          .where('senderId', isNotEqualTo: userId)
          .where('read', isEqualTo: false)
          .get();

      return messagesSnapshot.docs.length;
    } catch (e) {
      print('❌ Error getting unread count: $e');
      return 0;
    }
  }

  /// Get unread message count stream (real-time)
  Stream<int> watchUnreadCount(String requestId, String userId) {
    // Get all messages and filter in memory to avoid index requirement
    return _firestore
        .collection('petrolRequests')
        .doc(requestId)
        .collection('messages')
        .snapshots()
        .map((snapshot) {
      // Filter in memory - no compound index needed
      final unreadCount = snapshot.docs.where((doc) {
        final data = doc.data();
        final senderId = data['senderId'] as String?;
        final isRead = data['isRead'] as bool? ?? false;
        return senderId != userId && !isRead;
      }).length;
      
      print('📊 Unread count for $requestId: $unreadCount');
      return unreadCount;
    });
  }

  /// Helper method to convert Firestore data to ChatMessage
  ChatMessage _chatMessageFromMap(Map<String, dynamic> data, String requestId) {
    return ChatMessage(
      id: data['id'] ?? '',
      requestId: requestId,
      senderId: data['senderId'] ?? '',
      senderName: data['senderName'] ?? '',
      senderRole: data['senderRole'] ?? '',
      message: data['message'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      read: data['read'] as bool? ?? false,
      readAt: (data['readAt'] as Timestamp?)?.toDate(),
    );
  }
}

