import 'package:flutter/foundation.dart';
import '../models/petrol_request.dart';
import '../models/quote.dart';
import '../services/request_service.dart';
import '../services/quote_service.dart';

class RequestProvider with ChangeNotifier {
  List<PetrolRequest> _requests = [];
  Map<String, List<Quote>> _quotes = {};
  bool _isLoading = false;
  String? _error;

  List<PetrolRequest> get requests => _requests;
  Map<String, List<Quote>> get quotes => _quotes;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Fetch nearby requests/providers based on user role
  /// This implements the EXACT React Native logic
  Future<void> fetchRequests({
    required double latitude,
    required double longitude,
    required String userId,
    required String userRole,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (userRole == 'provider') {
        // PROVIDER LOGIC (React Native lines 181-260)
        await _fetchForProvider(latitude, longitude, userId);
      } else {
        // NEEDY LOGIC (React Native lines 269-392)
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

  /// Provider fetches: Requests + Needers
  Future<void> _fetchForProvider(double latitude, double longitude, String userId) async {
    print('🔍 Provider fetching requests and needers...');
    
    // Fetch BOTH requests AND needers in parallel
    final requestsResponse = await RequestService.findNearestRequests(
      latitude: latitude,
      longitude: longitude,
      userId: userId,
      maxDistance: 50,
      userRole: 'provider',
    );
    
    final needersResponse = await RequestService.findNearestNeeders(
      latitude: latitude,
      longitude: longitude,
      providerId: userId,
      maxDistance: 50,
    );
    
    final requestsList = requestsResponse['requests'] as List<PetrolRequest>;
    final needersList = needersResponse['needers'] as List;
    
    print('✅ Received requests: ${requestsList.length}');
    print('✅ Received needers: ${needersList.length}');
    
    // Combine requests and needers
    final allItems = <PetrolRequest>[];
    
    // Add requests first - with type 'request'
    for (var req in requestsList) {
      print('📋 Adding request: ${req.id}, status: ${req.status}, role: ${req.role}');
      allItems.add(PetrolRequest(
        id: req.id,
        needyId: req.needyId,
        name: req.name ?? req.needyName,
        role: req.role,
        latitude: req.latitude,
        longitude: req.longitude,
        message: req.message,
        quantityLiters: req.quantityLiters,
        urgency: req.urgency,
        status: req.status,
        acceptedBy: req.acceptedBy,
        createdAt: req.createdAt,
        updatedAt: req.updatedAt,
        distance: req.distance,
        type: 'request', // Explicitly set type
      ));
    }
    
    // Add needers who don't have requests (type 'needy')
    for (var needy in needersList) {
      final hasRequest = requestsList.any((req) => req.needyId == needy['userId']);
      if (!hasRequest) {
        allItems.add(PetrolRequest(
          id: 'needy_${needy['userId']}',
          needyId: needy['userId'] as String,
          name: needy['name'] as String,
          latitude: (needy['latitude'] as num).toDouble(),
          longitude: (needy['longitude'] as num).toDouble(),
          message: '${needy['name']} is looking for petrol',
          urgency: 'normal',
          status: 'available',
          distance: needy['distance'] != null ? (needy['distance'] as num).toDouble() : null,
          type: 'needy', // Type: needy user without request
        ));
      }
    }
    
    _requests = allItems;
    
    // Load quotes for requests only
    final quotesMap = <String, List<Quote>>{};
    for (var req in requestsList) {
      try {
        final requestQuotes = await QuoteService.getQuotesForRequest(req.id);
        quotesMap[req.id] = requestQuotes;
        print('💰 Loaded ${requestQuotes.length} quotes for request ${req.id}');
      } catch (err) {
        print('Error loading quotes for request ${req.id}: $err');
      }
    }
    _quotes = quotesMap;
    
    print('✅ Provider view: ${allItems.length} items total');
  }

  /// Needy fetches: Providers + Own Requests
  Future<void> _fetchForNeedy(double latitude, double longitude, String userId) async {
    print('🔍 Needy fetching providers and own requests...');
    
    // Fetch BOTH providers AND requests in parallel
    final providersResponse = await RequestService.findNearestProviders(
      latitude: latitude,
      longitude: longitude,
      needyId: userId,
      maxDistance: 50,
    );
    
    final requestsResponse = await RequestService.findNearestRequests(
      latitude: latitude,
      longitude: longitude,
      userId: userId,
      maxDistance: 50,
      userRole: 'needy',
    );
    
    final providersList = providersResponse['providers'] as List;
    final requestsList = requestsResponse['requests'] as List<PetrolRequest>;
    
    print('✅ Received providers: ${providersList.length}');
    print('✅ Received requests: ${requestsList.length}');
    
    // Combine providers and requests
    final allItems = <PetrolRequest>[];
    
    // Add providers first (type 'provider')
    for (var provider in providersList) {
      allItems.add(PetrolRequest(
        id: provider['userId'] as String,
        needyId: provider['userId'] as String,
        name: provider['name'] as String? ?? 'Provider',
        latitude: (provider['latitude'] as num).toDouble(),
        longitude: (provider['longitude'] as num).toDouble(),
        message: '${provider['name'] ?? 'Provider'} is available nearby',
        urgency: 'normal',
        status: provider['isAvailable'] == true ? 'available' : 'busy',
        distance: provider['distance'] != null ? (provider['distance'] as num).toDouble() : null,
        type: 'provider', // Type: provider user
      ));
    }
    
    // Add needy's own requests (IMPORTANT!)
    for (var req in requestsList) {
      if (req.needyId == userId && req.role == 'needy') {
        print('📋 Adding needy\'s own request: ${req.id}');
        allItems.add(PetrolRequest(
          id: req.id,
          needyId: req.needyId,
          name: req.name ?? req.needyName,
          role: req.role,
          latitude: req.latitude,
          longitude: req.longitude,
          message: req.message,
          quantityLiters: req.quantityLiters,
          urgency: req.urgency,
          status: req.status,
          acceptedBy: req.acceptedBy,
          createdAt: req.createdAt,
          updatedAt: req.updatedAt,
          distance: req.distance,
          type: 'request', // Type: request
        ));
      }
    }
    
    _requests = allItems;
    
    // Load quotes for needy's own requests
    final quotesMap = <String, List<Quote>>{};
    
    // First, load all quotes for this needy user
    try {
      final allNeedyQuotes = await QuoteService.getQuotesForNeedy(userId);
      print('💰 Total quotes for needy $userId: ${allNeedyQuotes.length}');
      
      // Group quotes by request ID
      for (var quote in allNeedyQuotes) {
        if (!quotesMap.containsKey(quote.requestId)) {
          quotesMap[quote.requestId] = [];
        }
        quotesMap[quote.requestId]!.add(quote);
      }
    } catch (err) {
      print('Error loading quotes for needy: $err');
    }
    
    // Also load quotes for each request individually
    for (var req in requestsList) {
      if (req.needyId == userId && req.role == 'needy') {
        try {
          final requestQuotes = await QuoteService.getQuotesForRequest(req.id);
          print('📋 Loaded ${requestQuotes.length} quotes for request ${req.id}');
          
          // Merge with existing quotes
          if (!quotesMap.containsKey(req.id)) {
            quotesMap[req.id] = [];
          }
          for (var quote in requestQuotes) {
            if (!quotesMap[req.id]!.any((q) => q.id == quote.id)) {
              quotesMap[req.id]!.add(quote);
            }
          }
        } catch (err) {
          print('Error loading quotes for request ${req.id}: $err');
        }
      }
    }
    
    _quotes = quotesMap;
    
    print('✅ Needy view: ${allItems.length} items total');
    print('✅ Quotes map size: ${quotesMap.length} requests have quotes');
  }

  /// Refresh requests
  Future<void> refreshRequests({
    required double latitude,
    required double longitude,
    required String userId,
    required String userRole,
  }) async {
    await fetchRequests(
      latitude: latitude,
      longitude: longitude,
      userId: userId,
      userRole: userRole,
    );
  }

  /// Clear all data
  void clear() {
    _requests = [];
    _quotes = {};
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}
