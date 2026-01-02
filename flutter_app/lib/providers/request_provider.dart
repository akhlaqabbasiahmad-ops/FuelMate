import 'package:flutter/foundation.dart';
import 'dart:async';
import '../models/petrol_request.dart';
import '../models/quote.dart';
import '../models/chat_message.dart';
import '../services/firestore_request_service.dart';
import '../services/firestore_quote_service.dart';
import '../services/firestore_chat_service.dart';
import '../services/notification_service.dart';

class RequestProvider with ChangeNotifier {
  final FirestoreRequestService _requestService = FirestoreRequestService();
  final FirestoreQuoteService _quoteService = FirestoreQuoteService();
  final FirestoreChatService _chatService = FirestoreChatService();
  final NotificationService _notificationService = NotificationService();
  
  List<PetrolRequest> _requests = [];
  Map<String, List<Quote>> _quotes = {};
  bool _isLoading = false;
  String? _error;
  StreamSubscription? _requestsSubscription;
  Set<String> _notifiedRequests = {}; // Track notified requests
  Map<String, int> _previousQuoteCounts = {}; // Track quote counts
  Map<String, StreamSubscription> _messageSubscriptions = {}; // Track message listeners
  Map<String, int> _previousMessageCounts = {}; // Track message counts per request
  Map<String, StreamSubscription> _quoteSubscriptions = {}; // Track quote listeners
  Set<String> _notifiedQuotes = {}; // Track notified quotes to avoid duplicates

  List<PetrolRequest> get requests => _requests;
  Map<String, List<Quote>> get quotes => _quotes;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Fetch requests with real-time updates
  Future<void> fetchRequests({
    required double latitude,
    required double longitude,
    required String userId,
    required String userRole,
  }) async {
    // Defer state updates to avoid "setState during build" error
    Future.microtask(() {
      _isLoading = true;
      _error = null;
      notifyListeners();
    });

    try {
      if (userRole == 'provider') {
        await _fetchForProvider(latitude, longitude, userId);
      } else {
        await _fetchForNeedy(latitude, longitude, userId);
      }
    } catch (error) {
      _error = error.toString();
      print('❌ Error fetching requests: $error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Provider fetches nearby needy requests
  Future<void> _fetchForProvider(
      double latitude, double longitude, String userId) async {
    print('🔍 Provider fetching nearby requests...');

    try {
      // Get requests
      final requestsList = await _requestService.findNearestRequests(
        latitude: latitude,
        longitude: longitude,
        userId: userId,
        radiusKm: 50,
      );

      _requests = requestsList;

      // Fetch quotes for each request
      for (var request in requestsList) {
        final requestQuotes =
            await _quoteService.getQuotesForRequest(request.id);
        _quotes[request.id] = requestQuotes;
      }

      print('✅ Provider: Found ${requestsList.length} requests');
      notifyListeners();
    } catch (e) {
      print('❌ Error fetching for provider: $e');
      rethrow;
    }
  }

  /// Needy fetches their own requests with quotes
  Future<void> _fetchForNeedy(
      double latitude, double longitude, String userId) async {
    print('🔍 Needy fetching own requests...');

    try {
      // Get user's own requests
      final requestsList = await _requestService.findUserRequests(userId);
      _requests = requestsList;

      // Fetch quotes for each request
      for (var request in requestsList) {
        final requestQuotes =
            await _quoteService.getQuotesForRequest(request.id);
        _quotes[request.id] = requestQuotes;
      }

      print('✅ Needy: Found ${requestsList.length} requests');
      notifyListeners();
    } catch (e) {
      print('❌ Error fetching for needy: $e');
      rethrow;
    }
  }

  /// Enable real-time updates for requests
  void watchRequests({
    required double latitude,
    required double longitude,
    required String userId,
    required String userRole,
  }) {
    _requestsSubscription?.cancel();

    if (userRole == 'provider') {
      // Watch nearby requests for providers
      _requestsSubscription = _requestService
          .watchRequests(
        latitude: latitude,
        longitude: longitude,
        userId: userId,
        radiusKm: 50,
      )
          .listen((requestsList) async {
        // Check for new requests and notify
        for (var request in requestsList) {
          if (!_notifiedRequests.contains(request.id)) {
            _notifiedRequests.add(request.id);
            
            // Show notification for new request
            await _notificationService.showNewRequestNotification(
              requestId: request.id,
              needyName: request.needyName ?? request.name ?? 'Someone',
              message: request.message,
              distance: request.distance?.toStringAsFixed(1),
            );
          }
        }
        
        _requests = requestsList;

        // Fetch quotes for new/updated requests
        for (var request in requestsList) {
          if (!_quotes.containsKey(request.id)) {
            final requestQuotes =
                await _quoteService.getQuotesForRequest(request.id);
            _quotes[request.id] = requestQuotes;
          }
        }

        notifyListeners();
      });
    } else {
      // Watch user's own requests for needers (REAL-TIME)
      _requestsSubscription = _requestService
          .watchUserRequests(userId)
          .listen((requestsList) async {
        _requests = requestsList;

        // Setup real-time quote listeners for each request
        for (var request in requestsList) {
          // Setup quote listener if not already setup
          if (!_quoteSubscriptions.containsKey(request.id)) {
            _setupQuoteListener(request.id);
          }
          
          // Setup message listener for accepted requests
          if (request.status == 'accepted' && !_messageSubscriptions.containsKey(request.id)) {
            _setupMessageListener(request.id, userId);
          }
        }

        print('✅ Needy: Real-time update - ${requestsList.length} requests');
        notifyListeners();
      });
    }
  }

  /// Get quotes for a specific request
  List<Quote> getQuotesForRequest(String requestId) {
    return _quotes[requestId] ?? [];
  }

  /// Refresh quotes for a request
  Future<void> refreshQuotes(String requestId) async {
    try {
      final requestQuotes = await _quoteService.getQuotesForRequest(requestId);
      _quotes[requestId] = requestQuotes;
      notifyListeners();
    } catch (e) {
      print('❌ Error refreshing quotes: $e');
    }
  }

  /// Setup real-time quote listener for instant notifications
  void _setupQuoteListener(String requestId) {
    print('🔔 Setting up real-time quote listener for request: $requestId');
    
    final subscription = _quoteService.watchQuotesForRequest(requestId).listen((quotes) async {
      // Update quotes map
      _quotes[requestId] = quotes;
      
      // Check for new quotes and notify
      for (var quote in quotes) {
        if (!_notifiedQuotes.contains(quote.id)) {
          _notifiedQuotes.add(quote.id);
          
          // Only notify if this is not the initial load
          if (_previousQuoteCounts.containsKey(requestId)) {
            print('🔔 NEW QUOTE RECEIVED! From ${quote.providerName}: ${quote.currency} ${quote.price}');
            
            // Show notification immediately
            await _notificationService.showNewQuoteNotification(
              quoteId: quote.id,
              providerName: quote.providerName ?? 'Provider',
              price: quote.price,
              currency: quote.currency,
            );
          }
        }
      }
      
      _previousQuoteCounts[requestId] = quotes.length;
      notifyListeners();
    });
    
    _quoteSubscriptions[requestId] = subscription;
  }

  /// Setup message listener for a request to notify on new messages
  void _setupMessageListener(String requestId, String userId) {
    print('🔔 Setting up REAL-TIME message listener for request: $requestId');
    
    final subscription = _chatService.watchMessages(requestId).listen((messages) async {
      final previousCount = _previousMessageCounts[requestId] ?? 0;
      
      print('📨 Message update: ${messages.length} messages (previous: $previousCount)');
      
      if (messages.length > previousCount && previousCount > 0) {
        // New message arrived
        final newMessage = messages.last;
        
        print('📨 New message detected: from ${newMessage.senderId}, current user: $userId');
        
        if (newMessage.senderId != userId) {
          // Message from other user - show notification IMMEDIATELY
          print('🔔 INSTANT NOTIFICATION: ${newMessage.senderName}: ${newMessage.message}');
          await _notificationService.showNewMessageNotification(
            requestId: requestId,
            senderName: newMessage.senderName,
            message: newMessage.message,
          );
        } else {
          print('📨 Skipping notification - message is from current user');
        }
      } else if (previousCount == 0) {
        print('📨 Initial message load - no notification');
      }
      
      _previousMessageCounts[requestId] = messages.length;
    });
    
    _messageSubscriptions[requestId] = subscription;
  }

  /// Clear all data
  void clear() {
    _requests = [];
    _quotes = {};
    _error = null;
    _requestsSubscription?.cancel();
    
    // Cancel all quote subscriptions
    for (var subscription in _quoteSubscriptions.values) {
      subscription.cancel();
    }
    _quoteSubscriptions.clear();
    _notifiedQuotes.clear();
    
    // Cancel all message subscriptions
    for (var subscription in _messageSubscriptions.values) {
      subscription.cancel();
    }
    _messageSubscriptions.clear();
    _previousMessageCounts.clear();
    
    notifyListeners();
  }

  @override
  void dispose() {
    _requestsSubscription?.cancel();
    
    // Cancel all quote subscriptions
    for (var subscription in _quoteSubscriptions.values) {
      subscription.cancel();
    }
    
    // Cancel all message subscriptions
    for (var subscription in _messageSubscriptions.values) {
      subscription.cancel();
    }
    
    super.dispose();
  }
}
