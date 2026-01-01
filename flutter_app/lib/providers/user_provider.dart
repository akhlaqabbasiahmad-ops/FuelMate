import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../services/storage_service.dart';

class UserProvider with ChangeNotifier {
  String? _userRole;
  String? _userId;
  String? _userName;
  Position? _location;
  bool _locationPermissionGranted = false;
  bool _isCheckingRegistration = true;

  String? get userRole => _userRole;
  String? get userId => _userId;
  String? get userName => _userName;
  Position? get location => _location;
  bool get locationPermissionGranted => _locationPermissionGranted;
  bool get isCheckingRegistration => _isCheckingRegistration;

  /// Initialize the app - check registration and request location
  Future<void> initializeApp() async {
    await requestLocationPermission();
    await checkUserRegistration();
    _isCheckingRegistration = false;
    notifyListeners();
  }

  /// Request location permission
  Future<void> requestLocationPermission() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      
      if (permission == LocationPermission.deniedForever) {
        print('⚠️ Location permissions are permanently denied');
        _locationPermissionGranted = false;
        notifyListeners();
        return;
      }
      
      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        _locationPermissionGranted = true;
        
        // Get current location
        final position = await Geolocator.getCurrentPosition();
        _location = position;
        notifyListeners();
      }
    } catch (error) {
      print('Error requesting location permission: $error');
    }
  }

  /// Check if user is registered
  Future<void> checkUserRegistration() async {
    try {
      final isRegistered = await StorageService.isUserRegistered();
      
      if (isRegistered) {
        _userId = await StorageService.getUserId();
        _userName = await StorageService.getUserName();
        _userRole = await StorageService.getUserRole();
        print('✅ User is registered: $_userName ($_userRole)');
      } else {
        print('⚠️ User not registered');
      }
      
      notifyListeners();
    } catch (error) {
      print('Error checking user registration: $error');
    }
  }

  /// Set user role and save to storage
  Future<void> setUserRole(String role) async {
    _userRole = role;
    await StorageService.saveUserRole(role);
    notifyListeners();
  }

  /// Set user ID and save to storage
  Future<void> setUserId(String id) async {
    _userId = id;
    await StorageService.saveUserId(id);
    notifyListeners();
  }

  /// Set user name and save to storage
  Future<void> setUserName(String name) async {
    _userName = name;
    await StorageService.saveUserName(name);
    notifyListeners();
  }

  /// Set all user data at once (for login/register)
  Future<void> setUser(String id, String name, String role) async {
    _userId = id;
    _userName = name;
    _userRole = role;
    await StorageService.saveUserId(id);
    await StorageService.saveUserName(name);
    await StorageService.saveUserRole(role);
    notifyListeners();
  }

  /// Check if user is logged in
  bool get isLoggedIn => _userId != null && _userName != null && _userRole != null;

  /// Clear user data (logout)
  Future<void> clearUserData() async {
    _userRole = null;
    _userId = null;
    _userName = null;
    await StorageService.clearUserData();
    notifyListeners();
  }

  /// Update location
  void updateLocation(Position position) {
    _location = position;
    notifyListeners();
  }
}

