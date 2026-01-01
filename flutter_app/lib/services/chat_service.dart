import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/chat_message.dart';

class ChatService {
  static final String baseUrl = ApiConfig.apiBaseUrl;

  // Send a message
  static Future<ChatMessage> sendMessage({
    required String requestId,
    required String senderId,
    required String message,
  }) async {
    final url = Uri.parse('$baseUrl/api/chat/send');
    
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'requestId': requestId,
        'senderId': senderId,
        'message': message,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return ChatMessage.fromJson(data);
    } else {
      throw Exception('Failed to send message: ${response.body}');
    }
  }

  // Get messages for a request
  static Future<List<ChatMessage>> getMessages(String requestId, String userId) async {
    final url = Uri.parse('$baseUrl/api/chat/messages/$requestId?userId=$userId');
    
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final messages = data['messages'] as List;
      return messages.map((m) => ChatMessage.fromJson(m)).toList();
    } else {
      throw Exception('Failed to get messages: ${response.body}');
    }
  }

  // Get unread counts for a user
  static Future<Map<String, int>> getUnreadCounts(String userId) async {
    final url = Uri.parse('$baseUrl/api/chat/unread-counts/$userId');
    
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final unreadCounts = data['unreadCounts'] as Map<String, dynamic>;
      return unreadCounts.map((key, value) => MapEntry(key, value as int));
    } else {
      return {};
    }
  }

  // Mark messages as read
  static Future<void> markAsRead(String requestId, String userId) async {
    final url = Uri.parse('$baseUrl/api/chat/mark-read/$requestId');
    
    await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': userId}),
    );
  }

  // Get chat participants
  static Future<Map<String, dynamic>> getParticipants(String requestId) async {
    final url = Uri.parse('$baseUrl/api/chat/participants/$requestId');
    
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get participants: ${response.body}');
    }
  }
}
