import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'notification_service.dart';

/// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('🔔 Background message received: ${message.messageId}');
  debugPrint('   Title: ${message.notification?.title}');
  debugPrint('   Body: ${message.notification?.body}');
  debugPrint('   Data: ${message.data}');
}

class FCMService {
  static final FCMService _instance = FCMService._internal();
  factory FCMService() => _instance;
  FCMService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final NotificationService _notificationService = NotificationService();
  
  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  /// Initialize FCM
  Future<void> initialize() async {
    try {
      // Request permission
      final settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      debugPrint('📱 FCM Permission: ${settings.authorizationStatus}');

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        debugPrint('✅ User granted FCM permission');
        
        // Get FCM token
        _fcmToken = await _messaging.getToken();
        debugPrint('🔑 FCM Token: $_fcmToken');

        // Setup message handlers
        _setupMessageHandlers();

        // Subscribe to topics
        await _subscribeToTopics();
      } else {
        debugPrint('⚠️ User declined FCM permission');
      }
    } catch (e) {
      debugPrint('❌ Error initializing FCM: $e');
    }
  }

  /// Setup message handlers
  void _setupMessageHandlers() {
    // Foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('🔔 Foreground message received: ${message.messageId}');
      _handleMessage(message, isBackground: false);
    });

    // Background messages (app in background but not terminated)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('🔔 Background message opened: ${message.messageId}');
      _handleMessageTap(message);
    });

    // Check if app was opened from terminated state
    _messaging.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        debugPrint('🔔 App opened from terminated state: ${message.messageId}');
        _handleMessageTap(message);
      }
    });
  }

  /// Handle incoming message
  void _handleMessage(RemoteMessage message, {required bool isBackground}) {
    final notification = message.notification;
    final data = message.data;

    if (notification != null) {
      // Show local notification
      final type = data['type'] as String?;
      
      switch (type) {
        case 'new_quote':
          _notificationService.showNewQuoteNotification(
            quoteId: data['quoteId'] ?? '',
            providerName: data['providerName'] ?? 'Provider',
            price: double.tryParse(data['price'] ?? '0') ?? 0.0,
            currency: data['currency'] ?? 'PKR',
          );
          break;
          
        case 'new_message':
          _notificationService.showNewMessageNotification(
            requestId: data['requestId'] ?? '',
            senderName: data['senderName'] ?? 'Someone',
            message: data['message'] ?? '',
          );
          break;
          
        case 'new_request':
          _notificationService.showNewRequestNotification(
            requestId: data['requestId'] ?? '',
            needyName: data['needyName'] ?? 'Someone',
            message: data['message'] ?? '',
            distance: data['distance'],
          );
          break;
          
        default:
          debugPrint('⚠️ Unknown notification type: $type');
      }
    }
  }

  /// Handle notification tap
  void _handleMessageTap(RemoteMessage message) {
    final data = message.data;
    final type = data['type'] as String?;
    final requestId = data['requestId'] as String?;

    debugPrint('👆 User tapped notification: type=$type, requestId=$requestId');
    
    // TODO: Navigate to appropriate screen
    // This would require a navigation service or global navigator key
  }

  /// Subscribe to topics
  Future<void> _subscribeToTopics() async {
    try {
      // Subscribe to general notifications
      await _messaging.subscribeToTopic('all_users');
      debugPrint('✅ Subscribed to topic: all_users');
    } catch (e) {
      debugPrint('❌ Error subscribing to topics: $e');
    }
  }

  /// Subscribe to user-specific topic
  Future<void> subscribeToUserTopic(String userId) async {
    try {
      await _messaging.subscribeToTopic('user_$userId');
      debugPrint('✅ Subscribed to topic: user_$userId');
    } catch (e) {
      debugPrint('❌ Error subscribing to user topic: $e');
    }
  }

  /// Subscribe to role-specific topic
  Future<void> subscribeToRoleTopic(String role) async {
    try {
      await _messaging.subscribeToTopic('role_$role');
      debugPrint('✅ Subscribed to topic: role_$role');
      
      // If provider, also subscribe to 'providers' topic for new request notifications
      if (role.toLowerCase() == 'provider') {
        await _messaging.subscribeToTopic('providers');
        debugPrint('✅ Subscribed to topic: providers');
      }
    } catch (e) {
      debugPrint('❌ Error subscribing to role topic: $e');
    }
  }

  /// Unsubscribe from user topic
  Future<void> unsubscribeFromUserTopic(String userId) async {
    try {
      await _messaging.unsubscribeFromTopic('user_$userId');
      debugPrint('✅ Unsubscribed from topic: user_$userId');
    } catch (e) {
      debugPrint('❌ Error unsubscribing from user topic: $e');
    }
  }

  /// Save FCM token to Firestore
  Future<void> saveFCMTokenToFirestore(String userId) async {
    if (_fcmToken == null) {
      debugPrint('⚠️ No FCM token to save');
      return;
    }
    
    try {
      // Save the token to Firestore for server-side push notifications
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .set({
            'fcmToken': _fcmToken,
            'lastTokenUpdate': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
      
      debugPrint('✅ FCM token saved for user: $userId');
      debugPrint('   Token: $_fcmToken');
    } catch (e) {
      debugPrint('❌ Error saving FCM token: $e');
    }
  }
}

