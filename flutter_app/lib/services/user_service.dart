import '../config/api_endpoints.dart';
import '../models/user.dart';
import 'api_service.dart';

class UserService {
  /// Check if a name is available and get suggestions
  static Future<CheckNameResponse> checkName(String name) async {
    try {
      final response = await ApiService.post(
        ApiEndpoints.checkName,
        {'name': name.trim()},
      );
      return CheckNameResponse.fromJson(response);
    } catch (error) {
      print('❌ Error checking name: $error');
      rethrow;
    }
  }
  
  /// Register a new user or login existing user
  static Future<RegisterResponse> registerUser(String name, String role) async {
    try {
      final response = await ApiService.post(
        ApiEndpoints.register,
        {
          'name': name.trim(),
          'role': role,
        },
      );
      return RegisterResponse.fromJson(response);
    } catch (error) {
      print('❌ Error registering user: $error');
      rethrow;
    }
  }
  
  /// Get user by ID
  static Future<User> getUserById(String userId) async {
    try {
      final response = await ApiService.get(
        ApiEndpoints.getUserById(userId),
      );
      return User.fromJson(response['user'] as Map<String, dynamic>);
    } catch (error) {
      print('❌ Error getting user by ID: $error');
      rethrow;
    }
  }
}

