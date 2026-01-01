import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _userIdKey = 'fuelmate_user_id';
  static const String _userNameKey = 'fuelmate_user_name';
  static const String _userRoleKey = 'fuelmate_user_role';
  
  /// Get the persistent user ID assigned by the backend during signup
  /// IMPORTANT: This ID comes from the backend system, not generated locally
  /// If no ID exists, user must register/login first
  static Future<String?> getUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_userIdKey);
    } catch (error) {
      print('Error getting user ID: $error');
      return null;
    }
  }
  
  /// Save user ID
  static Future<void> saveUserId(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userIdKey, userId);
    } catch (error) {
      print('Error saving user ID: $error');
    }
  }
  
  /// Get user name
  static Future<String?> getUserName() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_userNameKey);
    } catch (error) {
      print('Error getting user name: $error');
      return null;
    }
  }
  
  /// Save user name
  static Future<void> saveUserName(String name) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userNameKey, name);
    } catch (error) {
      print('Error saving user name: $error');
    }
  }
  
  /// Get user role
  static Future<String?> getUserRole() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_userRoleKey);
    } catch (error) {
      print('Error getting user role: $error');
      return null;
    }
  }
  
  /// Save user role
  static Future<void> saveUserRole(String role) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userRoleKey, role);
    } catch (error) {
      print('Error saving user role: $error');
    }
  }
  
  /// Clear all user data (for logout or role change)
  static Future<void> clearUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userIdKey);
      await prefs.remove(_userNameKey);
      await prefs.remove(_userRoleKey);
    } catch (error) {
      print('Error clearing user data: $error');
    }
  }
  
  /// Check if user is registered
  static Future<bool> isUserRegistered() async {
    final userId = await getUserId();
    final userName = await getUserName();
    final userRole = await getUserRole();
    return userId != null && userName != null && userRole != null;
  }
}

