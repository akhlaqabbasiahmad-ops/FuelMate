import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class ApiService {
  static final String baseUrl = ApiConfig.apiBaseUrl;
  
  /// Test connection to the backend
  static Future<bool> testConnection() async {
    try {
      final url = Uri.parse('$baseUrl/health');
      print('🔗 Testing connection to: $url');
      
      final response = await http.get(url).timeout(
        const Duration(seconds: 5),
      );
      
      print('🔗 Health check response: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['status'] == 'ok';
      }
      return false;
    } catch (error) {
      print('🔗 Connection test failed: $error');
      return false;
    }
  }
  
  /// Generic GET request
  static Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, String>? queryParams,
  }) async {
    try {
      var uri = Uri.parse('$baseUrl$endpoint');
      if (queryParams != null && queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParams);
      }
      
      print('📡 GET: $uri');
      
      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      );
      
      print('📡 Response: ${response.statusCode}');
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (error) {
      print('❌ GET Error: $error');
      rethrow;
    }
  }
  
  /// Generic POST request
  static Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      
      print('📡 POST: $uri');
      print('📡 Body: ${jsonEncode(body)}');
      
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      
      print('📡 Response: ${response.statusCode}');
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (error) {
      print('❌ POST Error: $error');
      rethrow;
    }
  }
}

