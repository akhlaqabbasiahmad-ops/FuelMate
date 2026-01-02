import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import '../models/petrol_request.dart';

class FirestoreRequestService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Create a new petrol request
  Future<PetrolRequest> createRequest({
    required String userId,
    required String userName,
    required String userRole,
    required double latitude,
    required double longitude,
    required String message,
    required double quantityLiters,
    required String urgency,
  }) async {
    try {
      print('📝 Creating request for user: $userName');
      print('   🆔 userId: $userId');
      print('   👤 userName: $userName');
      print('   🎭 userRole: $userRole');

      final requestId = 'req_${DateTime.now().millisecondsSinceEpoch}_${userId.substring(0, 9)}';
      
      final requestData = {
        'id': requestId,
        'userId': userId,
        'userName': userName,
        'userRole': userRole,
        'latitude': latitude,
        'longitude': longitude,
        'location': GeoPoint(latitude, longitude),
        'message': message,
        'quantityLiters': quantityLiters,
        'urgency': urgency,
        'status': 'pending',
        'type': 'request', // Added: Identifies this as a request (not a provider/needy listing)
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('petrolRequests').doc(requestId).set(requestData);

      print('✅ Request created successfully: $requestId');
      print('   📋 Data saved to Firestore with userId=$userId');

      return PetrolRequest(
        id: requestId,
        needyId: userId,
        needyName: userName,
        name: userName,
        role: userRole,
        latitude: latitude,
        longitude: longitude,
        message: message,
        quantityLiters: quantityLiters,
        urgency: urgency,
        status: 'pending',
        type: 'request', // Added
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    } catch (e) {
      print('❌ Error creating request: $e');
      rethrow;
    }
  }

  /// Find nearest requests (for providers to see needers)
  Future<List<PetrolRequest>> findNearestRequests({
    required double latitude,
    required double longitude,
    required String userId,
    double radiusKm = 50,
  }) async {
    try {
      print('🔍 Finding requests near: ($latitude, $longitude)');

      final querySnapshot = await _firestore
          .collection('petrolRequests')
          .where('status', whereIn: ['pending', 'accepted'])
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();

      final requests = <PetrolRequest>[];

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final request = _petrolRequestFromMap(data);
        
        // Calculate distance
        final distance = Geolocator.distanceBetween(
          latitude,
          longitude,
          request.latitude,
          request.longitude,
        ) / 1000; // Convert to km

        // Only include requests within radius
        if (distance <= radiusKm && request.needyId != userId) {
          requests.add(request);
        }
      }

      print('✅ Found ${requests.length} requests');
      return requests;
    } catch (e) {
      if (e.toString().contains('failed-precondition') || e.toString().contains('index')) {
        print('❌ FIRESTORE INDEX REQUIRED! Please create indexes in Firebase Console.');
        print('See FIRESTORE_INDEX_FIX.md for instructions.');
      } else {
        print('❌ Error finding requests: $e');
      }
      return [];
    }
  }

  /// Find nearest providers (for needers to see their own requests with quotes)
  Future<List<PetrolRequest>> findUserRequests(String userId) async {
    try {
      print('🔍 Finding requests for user: $userId');

      final querySnapshot = await _firestore
          .collection('petrolRequests')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(20)
          .get();

      final requests = querySnapshot.docs
          .map((doc) => _petrolRequestFromMap(doc.data()))
          .toList();

      print('✅ Found ${requests.length} user requests');
      return requests;
    } catch (e) {
      if (e.toString().contains('failed-precondition') || e.toString().contains('index')) {
        print('❌ FIRESTORE INDEX REQUIRED! Please create indexes in Firebase Console.');
        print('See FIRESTORE_INDEX_FIX.md for instructions.');
      } else {
        print('❌ Error finding user requests: $e');
      }
      return [];
    }
  }

  /// Get request by ID
  Future<PetrolRequest?> getRequest(String requestId) async {
    try {
      final doc = await _firestore.collection('petrolRequests').doc(requestId).get();
      
      if (!doc.exists) {
        return null;
      }

      return _petrolRequestFromMap(doc.data()!);
    } catch (e) {
      print('❌ Error getting request: $e');
      return null;
    }
  }

  /// Accept a request (provider accepts a needy's request)
  Future<void> acceptRequest(String requestId, String providerId) async {
    try {
      await _firestore.collection('petrolRequests').doc(requestId).update({
        'status': 'accepted',
        'acceptedBy': providerId,
        'acceptedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('✅ Request accepted: $requestId');
    } catch (e) {
      print('❌ Error accepting request: $e');
      rethrow;
    }
  }

  /// Complete a request
  Future<void> completeRequest(String requestId) async {
    try {
      await _firestore.collection('petrolRequests').doc(requestId).update({
        'status': 'completed',
        'completedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('✅ Request completed: $requestId');
    } catch (e) {
      print('❌ Error completing request: $e');
      rethrow;
    }
  }

  /// Cancel a request
  Future<void> cancelRequest(String requestId) async {
    try {
      await _firestore.collection('petrolRequests').doc(requestId).update({
        'status': 'cancelled',
        'cancelledAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('✅ Request cancelled: $requestId');
    } catch (e) {
      print('❌ Error cancelling request: $e');
      rethrow;
    }
  }

  /// Get request history for a user
  Future<List<PetrolRequest>> getRequestHistory(String userId, String userRole) async {
    try {
      Query query = _firestore.collection('petrolRequests');

      if (userRole == 'needy') {
        query = query.where('userId', isEqualTo: userId);
      } else {
        query = query.where('acceptedBy', isEqualTo: userId);
      }

      final querySnapshot = await query
          .where('status', whereIn: ['completed', 'cancelled'])
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();

      final requests = querySnapshot.docs
          .map((doc) => _petrolRequestFromMap(doc.data() as Map<String, dynamic>))
          .toList();

      print('✅ Found ${requests.length} history items');
      return requests;
    } catch (e) {
      if (e.toString().contains('failed-precondition') || e.toString().contains('index')) {
        print('❌ FIRESTORE INDEX REQUIRED! Please create indexes in Firebase Console.');
        print('See FIRESTORE_INDEX_FIX.md for instructions.');
      } else {
        print('❌ Error getting history: $e');
      }
      return [];
    }
  }

  /// Get active requests for a user
  Future<List<PetrolRequest>> getActiveRequests(String userId, String userRole) async {
    try {
      Query query = _firestore.collection('petrolRequests');

      if (userRole == 'needy') {
        query = query.where('userId', isEqualTo: userId);
      } else {
        query = query.where('acceptedBy', isEqualTo: userId);
      }

      final querySnapshot = await query
          .where('status', whereIn: ['pending', 'accepted'])
          .orderBy('createdAt', descending: true)
          .limit(20)
          .get();

      final requests = querySnapshot.docs
          .map((doc) => _petrolRequestFromMap(doc.data() as Map<String, dynamic>))
          .toList();

      print('✅ Found ${requests.length} active requests');
      return requests;
    } catch (e) {
      print('❌ Error getting active requests: $e');
      return [];
    }
  }

  /// Listen to request updates (real-time)
  Stream<PetrolRequest> watchRequest(String requestId) {
    return _firestore
        .collection('petrolRequests')
        .doc(requestId)
        .snapshots()
        .map((doc) => _petrolRequestFromMap(doc.data()!));
  }

  /// Listen to all requests (real-time)
  Stream<List<PetrolRequest>> watchRequests({
    required double latitude,
    required double longitude,
    required String userId,
    double radiusKm = 50,
  }) {
    return _firestore
        .collection('petrolRequests')
        .where('status', whereIn: ['pending', 'accepted'])
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
      final requests = <PetrolRequest>[];
      
      for (var doc in snapshot.docs) {
        final request = _petrolRequestFromMap(doc.data());
        
        // Calculate distance
        final distance = Geolocator.distanceBetween(
          latitude,
          longitude,
          request.latitude,
          request.longitude,
        ) / 1000;

        if (distance <= radiusKm && request.needyId != userId) {
          requests.add(request);
        }
      }
      
      return requests;
    });
  }

  /// Listen to user's own requests (real-time)
  Stream<List<PetrolRequest>> watchUserRequests(String userId) {
    print('🔍 Setting up real-time listener for userId: $userId');
    return _firestore
        .collection('petrolRequests')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(20)
        .snapshots()
        .map((snapshot) {
      print('📡 Real-time update: ${snapshot.docs.length} documents from Firestore');
      for (var doc in snapshot.docs) {
        final data = doc.data();
        print('   📄 Request: ${data['id']}, userId=${data['userId']}, status=${data['status']}');
      }
      return snapshot.docs
          .map((doc) => _petrolRequestFromMap(doc.data()))
          .toList();
    });
  }

  /// Helper method to convert Firestore data to PetrolRequest
  PetrolRequest _petrolRequestFromMap(Map<String, dynamic> data) {
    return PetrolRequest(
      id: data['id'] ?? '',
      needyId: data['userId'] ?? '',
      needyName: data['userName'] ?? '',
      name: data['userName'] ?? '',
      role: data['userRole'] ?? '',
      latitude: (data['latitude'] ?? 0.0).toDouble(),
      longitude: (data['longitude'] ?? 0.0).toDouble(),
      message: data['message'] ?? '',
      quantityLiters: (data['quantityLiters'] as num?)?.toDouble(),
      urgency: data['urgency'] ?? 'normal',
      status: data['status'] ?? 'pending',
      type: data['type'] ?? 'request', // Added: Default to 'request' if not set
      acceptedBy: data['acceptedBy'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

