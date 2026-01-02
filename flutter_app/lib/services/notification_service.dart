import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  /// Initialize notification service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize local notifications
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (details) {
          debugPrint('Notification tapped: ${details.payload}');
        },
      );

      // Request permissions
      await _requestPermissions();

      _isInitialized = true;
      debugPrint('✅ Notification service initialized');
    } catch (e) {
      debugPrint('❌ Error initializing notifications: $e');
    }
  }

  /// Request notification permissions
  Future<void> _requestPermissions() async {
    try {
      final androidPlugin = _notificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      
      if (androidPlugin != null) {
        await androidPlugin.requestNotificationsPermission();
      }

      final iosPlugin = _notificationsPlugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
      
      if (iosPlugin != null) {
        await iosPlugin.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
      }
    } catch (e) {
      debugPrint('❌ Error requesting permissions: $e');
    }
  }

  /// Play notification sound
  Future<void> _playSound() async {
    try {
      // Use system notification sound
      await SystemSound.play(SystemSoundType.alert);
      
      // Optionally vibrate (Android)
      HapticFeedback.vibrate();
    } catch (e) {
      debugPrint('❌ Error playing sound: $e');
    }
  }

  /// Show notification for new request (Provider)
  Future<void> showNewRequestNotification({
    required String requestId,
    required String needyName,
    required String message,
    String? distance,
  }) async {
    await _playSound();

    const androidDetails = AndroidNotificationDetails(
      'new_requests',
      'New Requests',
      channelDescription: 'Notifications for new petrol requests',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final distanceText = distance != null ? ' ($distance km away)' : '';

    await _notificationsPlugin.show(
      requestId.hashCode,
      '🚨 New Petrol Request',
      '$needyName needs petrol$distanceText\n$message',
      details,
      payload: 'request:$requestId',
    );

    debugPrint('✅ Showed new request notification');
  }

  /// Show notification for new quote (Needy)
  Future<void> showNewQuoteNotification({
    required String quoteId,
    required String providerName,
    required double price,
    required String currency,
  }) async {
    await _playSound();

    const androidDetails = AndroidNotificationDetails(
      'new_quotes',
      'New Quotes',
      channelDescription: 'Notifications for new price quotes',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.show(
      quoteId.hashCode,
      '💰 New Quote Received',
      '$providerName sent a quote: $currency ${price.toStringAsFixed(0)}',
      details,
      payload: 'quote:$quoteId',
    );

    debugPrint('✅ Showed new quote notification');
  }

  /// Show notification for new message
  Future<void> showNewMessageNotification({
    required String requestId,
    required String senderName,
    required String message,
  }) async {
    await _playSound();

    const androidDetails = AndroidNotificationDetails(
      'new_messages',
      'New Messages',
      channelDescription: 'Notifications for new chat messages',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.show(
      requestId.hashCode,
      '💬 $senderName',
      message,
      details,
      payload: 'chat:$requestId',
    );

    debugPrint('✅ Showed new message notification');
  }

  /// Show notification for quote accepted
  Future<void> showQuoteAcceptedNotification({
    required String requestId,
    required String needyName,
  }) async {
    await _playSound();

    const androidDetails = AndroidNotificationDetails(
      'quote_accepted',
      'Quote Accepted',
      channelDescription: 'Notifications when your quote is accepted',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.show(
      requestId.hashCode,
      '✅ Quote Accepted!',
      '$needyName accepted your quote. Start chatting now!',
      details,
      payload: 'request:$requestId',
    );

    debugPrint('✅ Showed quote accepted notification');
  }

  /// Show notification for request completed
  Future<void> showRequestCompletedNotification({
    required String requestId,
    required String userName,
  }) async {
    await _playSound();

    const androidDetails = AndroidNotificationDetails(
      'request_completed',
      'Request Completed',
      channelDescription: 'Notifications when request is completed',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.show(
      requestId.hashCode,
      '🎉 Request Completed',
      '$userName marked the request as complete!',
      details,
      payload: 'request:$requestId',
    );

    debugPrint('✅ Showed request completed notification');
  }

  /// Cancel all notifications
  Future<void> cancelAll() async {
    await _notificationsPlugin.cancelAll();
  }

  /// Cancel specific notification
  Future<void> cancel(int id) async {
    await _notificationsPlugin.cancel(id);
  }

  /// Dispose resources
  void dispose() {
    _audioPlayer.dispose();
  }
}

