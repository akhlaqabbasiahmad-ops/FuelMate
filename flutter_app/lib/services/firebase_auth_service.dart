import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart' as app_models;

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get current user
  User? get currentUser => _auth.currentUser;

  /// Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  /// Check if user is logged in
  bool get isLoggedIn => _auth.currentUser != null;

  /// Listen to authentication state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Register new user with username and password
  Future<app_models.User> register({
    required String username,
    required String password,
    required String role,
  }) async {
    try {
      print('📝 Registering user: $username ($role)');

      // Validate password
      final passwordError = validatePassword(password);
      if (passwordError != null) {
        throw Exception(passwordError);
      }

      // Check if username already exists
      final existingUser = await getUserByUsername(username);
      if (existingUser != null) {
        throw Exception('Username "$username" is already taken');
      }

      // Generate a consistent user ID based on username and role
      // This ensures the same ID every time they log in
      final userId = _generateConsistentUserId(username, role);

      // Sign in anonymously to get Firebase auth
      await _auth.signInAnonymously();

      // Create user document in Firestore
      final userData = {
        'id': userId,
        'username': username.trim().toLowerCase(),
        'displayName': username.trim(),
        'role': role,
        'password': password, // Store password (in real app, use hashing!)
        'createdAt': FieldValue.serverTimestamp(),
        'lastLoginAt': FieldValue.serverTimestamp(),
        'isAvailable': true,
      };

      await _firestore.collection('users').doc(userId).set(userData);

      print('✅ User registered successfully: $username ($userId)');

      // Return user model
      return app_models.User(
        id: userId,
        name: username.trim(),
        role: role,
      );
    } catch (e) {
      print('❌ Registration error: $e');
      rethrow;
    }
  }

  /// Login user with username and password
  Future<app_models.User> login({
    required String username,
    required String password,
    required String role,
  }) async {
    try {
      print('🔐 Logging in user: $username ($role)');

      // Generate the consistent user ID
      final userId = _generateConsistentUserId(username, role);

      // Find user in Firestore
      final userDoc = await _firestore.collection('users').doc(userId).get();

      if (!userDoc.exists) {
        throw Exception('Invalid username or role');
      }

      final userData = userDoc.data()!;

      // Verify password
      if (userData['password'] != password) {
        throw Exception('Invalid password');
      }

      // Sign in anonymously to get Firebase auth
      await _auth.signInAnonymously();

      // Update last login time
      await _firestore.collection('users').doc(userId).update({
        'lastLoginAt': FieldValue.serverTimestamp(),
      });

      print('✅ User logged in successfully: $username ($userId)');

      return app_models.User(
        id: userId,
        name: userData['displayName'] as String,
        role: userData['role'] as String,
      );
    } catch (e) {
      print('❌ Login error: $e');
      rethrow;
    }
  }

  /// Generate a consistent user ID based on username and role
  /// This ensures the SAME user ID across ALL sessions
  String _generateConsistentUserId(String username, String role) {
    // Create a deterministic ID from username + role
    // Format: role_username (e.g., "needy_john" or "provider_mary")
    final normalized = username.trim().toLowerCase().replaceAll(' ', '_');
    return '${role}_$normalized';
  }

  /// Check if username exists
  Future<bool> isUsernameAvailable(String username) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('username', isEqualTo: username.trim().toLowerCase())
          .limit(1)
          .get();

      return querySnapshot.docs.isEmpty;
    } catch (e) {
      print('❌ Error checking username: $e');
      return false;
    }
  }

  /// Get user by username
  Future<Map<String, dynamic>?> getUserByUsername(String username) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('username', isEqualTo: username.trim().toLowerCase())
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return null;
      }

      return querySnapshot.docs.first.data();
    } catch (e) {
      print('❌ Error getting user by username: $e');
      return null;
    }
  }

  /// Check if user exists
  Future<Map<String, dynamic>> checkUserExists(
      String username, String role) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('username', isEqualTo: username.trim().toLowerCase())
          .where('role', isEqualTo: role)
          .limit(1)
          .get();

      final exists = querySnapshot.docs.isNotEmpty;

      return {
        'exists': exists,
        'hasPassword': exists, // Always true since we require password
        'needsPasswordSet': false,
        'message': exists
            ? 'User exists with password'
            : 'User does not exist',
      };
    } catch (e) {
      print('❌ Error checking user exists: $e');
      return {
        'exists': false,
        'hasPassword': false,
        'needsPasswordSet': false,
        'message': 'Error checking user',
      };
    }
  }

  /// Logout
  Future<void> logout() async {
    try {
      await _auth.signOut();
      print('✅ User logged out successfully');
    } catch (e) {
      print('❌ Logout error: $e');
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

  /// Validate password confirmation
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

