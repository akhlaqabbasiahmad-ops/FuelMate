import '../config/api_endpoints.dart';
import '../models/petrol_request.dart';
import '../models/quote.dart';
import 'api_service.dart';

class RequestService {
  /// Create a new petrol request
  static Future<PetrolRequest> createRequest(CreateRequestData data) async {
    if (data.userId == null) {
      throw Exception('User ID is required to create request');
    }
    
    try {
      print('📝 Creating request with user data: ${data.userId}');
      final response = await ApiService.post(
        ApiEndpoints.createRequest,
        data.toJson(),
      );
      return PetrolRequest.fromJson(response);
    } catch (error) {
      print('❌ Error creating request: $error');
      rethrow;
    }
  }
  
  /// Find nearest requests
  static Future<Map<String, dynamic>> findNearestRequests({
    required double latitude,
    required double longitude,
    required String userId,
    double maxDistance = 50,
    String? userRole,
  }) async {
    try {
      print('🔍 Finding nearest requests for: $userId');
      
      final params = {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'maxDistance': maxDistance.toString(),
        'limit': '20',
        'providerId': userId,
      };
      
      if (userId.startsWith('needy_')) {
        params['needyId'] = userId;
      }
      
      if (userRole != null) {
        params['userRole'] = userRole;
      }
      
      final response = await ApiService.get(
        ApiEndpoints.nearestRequests,
        queryParams: params,
      );
      
      final requests = (response['requests'] as List)
          .map((e) => PetrolRequest.fromJson(e as Map<String, dynamic>))
          .toList();
      
      return {
        'requests': requests,
        'count': response['count'],
      };
    } catch (error) {
      print('❌ Error finding nearest requests: $error');
      rethrow;
    }
  }
  
  /// Find nearest providers
  static Future<Map<String, dynamic>> findNearestProviders({
    required double latitude,
    required double longitude,
    required String needyId,
    double maxDistance = 50,
  }) async {
    try {
      print('🔍 Finding nearest providers for: $needyId');
      
      final response = await ApiService.get(
        ApiEndpoints.providersNearest,
        queryParams: {
          'latitude': latitude.toString(),
          'longitude': longitude.toString(),
          'maxDistance': maxDistance.toString(),
          'limit': '20',
          'needyId': needyId,
        },
      );
      
      return {
        'providers': response['providers'],
        'count': response['count'],
      };
    } catch (error) {
      print('❌ Error finding nearest providers: $error');
      rethrow;
    }
  }
  
  /// Find nearest needers
  static Future<Map<String, dynamic>> findNearestNeeders({
    required double latitude,
    required double longitude,
    required String providerId,
    double maxDistance = 50,
  }) async {
    try {
      print('🔍 Finding nearest needers for: $providerId');
      
      final response = await ApiService.get(
        ApiEndpoints.needersNearest,
        queryParams: {
          'latitude': latitude.toString(),
          'longitude': longitude.toString(),
          'maxDistance': maxDistance.toString(),
          'limit': '20',
          'providerId': providerId,
        },
      );
      
      return {
        'needers': response['needers'],
        'count': response['count'],
      };
    } catch (error) {
      print('❌ Error finding nearest needers: $error');
      rethrow;
    }
  }
  
  /// Accept a request
  static Future<Map<String, dynamic>> acceptRequest(
    String requestId,
    String providerId,
  ) async {
    try {
      print('✅ Accepting request: $requestId');
      final response = await ApiService.post(
        ApiEndpoints.acceptRequest(requestId),
        {'providerId': providerId},
      );
      return response;
    } catch (error) {
      print('❌ Error accepting request: $error');
      rethrow;
    }
  }
  
  /// Update user location
  static Future<Map<String, dynamic>> updateLocation({
    required String userId,
    required String name,
    required String role,
    required double latitude,
    required double longitude,
  }) async {
    try {
      print('📍 Updating location: $userId at $latitude, $longitude');
      final response = await ApiService.post(
        ApiEndpoints.updateLocation,
        {
          'userId': userId,
          'name': name,
          'role': role,
          'latitude': latitude,
          'longitude': longitude,
          'isAvailable': true,
        },
      );
      return response;
    } catch (error) {
      print('❌ Error updating location: $error');
      rethrow;
    }
  }
  
  /// Complete a request
  static Future<Map<String, dynamic>> completeRequest(
    String requestId,
    String userId,
    String userRole,
  ) async {
    try {
      final response = await ApiService.post(
        ApiEndpoints.completeRequest(requestId),
        {'userId': userId, 'userRole': userRole},
      );
      return response;
    } catch (error) {
      print('❌ Error completing request: $error');
      rethrow;
    }
  }
  
  /// Get request history
  static Future<List<PetrolRequest>> getRequestHistory(
    String userId,
    String userRole,
  ) async {
    try {
      print('📜 Getting request history for: $userId');
      final response = await ApiService.get(
        ApiEndpoints.requestHistory,
        queryParams: {
          'userId': userId,
          'userRole': userRole,
        },
      );
      
      final history = (response['history'] as List)
          .map((e) => PetrolRequest.fromJson(e as Map<String, dynamic>))
          .toList();
      return history;
    } catch (error) {
      print('❌ Error getting request history: $error');
      rethrow;
    }
  }
}

