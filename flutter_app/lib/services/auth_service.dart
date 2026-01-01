import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/user.dart';

class AuthService {
  static final String baseUrl = ApiConfig.apiBaseUrl;

  /// Check if user exists and has password set
  static Future<Map<String, dynamic>> checkUserExists(
      String name, String role) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/users/check-exists'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name, 'role': role}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to check user: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error checking user exists: $e');
      rethrow;
    }
  }

  /// Register new user with password
  static Future<User> register(
      String name, String password, String role) async {
    try {
      print('📝 Registering user: $name ($role)');

      final response = await http.post(
        Uri.parse('$baseUrl/api/users/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'password': password,
          'role': role,
        }),
      );

      print('📡 Registration response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['user'] != null) {
          print('✅ User registered successfully');
          return User.fromJson(data['user']);
        } else {
          throw Exception(data['message'] ?? 'Registration failed');
        }
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Registration failed');
      }
    } catch (e) {
      print('❌ Registration error: $e');
      rethrow;
    }
  }

  /// Login user with password
  static Future<User> login(String name, String password, String role) async {
    try {
      print('🔐 Logging in user: $name ($role)');

      final response = await http.post(
        Uri.parse('$baseUrl/api/users/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'password': password,
          'role': role,
        }),
      );

      print('📡 Login response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['user'] != null) {
          print('✅ User logged in successfully');
          return User.fromJson(data['user']);
        } else {
          throw Exception(data['message'] ?? 'Login failed');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Invalid username or password');
      } else {
        final error = jsonDecode(response.body);
        if (error['message'] == 'PASSWORD_NOT_SET') {
          throw Exception('PASSWORD_NOT_SET');
        }
        throw Exception(error['message'] ?? 'Login failed');
      }
    } catch (e) {
      print('❌ Login error: $e');
      rethrow;
    }
  }

  /// Validate password strength
  static String? validatePassword(String password) {
    if (password.isEmpty) {
      return 'Password is required';
    }

    if (password.length < 6) {
      return 'Password must be at least 6 characters';
    }

    if (!password.contains(RegExp(r'[a-zA-Z]'))) {
      return 'Password must contain at least one letter';
    }

    if (!password.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }

    return null; // Password is valid
  }

  /// Check if passwords match
  static String? validatePasswordConfirmation(
      String password, String confirmPassword) {
    if (confirmPassword.isEmpty) {
      return 'Please confirm your password';
    }

    if (password != confirmPassword) {
      return 'Passwords do not match';
    }

    return null;
  }
}

