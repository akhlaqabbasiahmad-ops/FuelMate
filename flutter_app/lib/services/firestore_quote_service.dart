import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/quote.dart';

class FirestoreQuoteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Create a new quote
  Future<Quote> createQuote({
    required String requestId,
    required String providerId,
    required double price,
    String currency = 'PKR',
    int? estimatedDeliveryTime,
    String? message,
  }) async {
    try {
      print('💰 Creating quote: requestId=$requestId, providerId=$providerId, price=$price');

      final quoteId = 'quote_${DateTime.now().millisecondsSinceEpoch}_${providerId.substring(0, 9)}';
      
      // Get provider name
      final providerDoc = await _firestore.collection('users').doc(providerId).get();
      final providerName = providerDoc.data()?['displayName'] ?? 'Unknown';

      final quoteData = {
        'id': quoteId,
        'requestId': requestId,
        'providerId': providerId,
        'providerName': providerName,
        'price': price,
        'currency': currency,
        'estimatedDeliveryTime': estimatedDeliveryTime,
        'message': message,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('quotes').doc(quoteId).set(quoteData);

      print('✅ Quote created successfully: $quoteId');

      return Quote(
        id: quoteId,
        requestId: requestId,
        providerId: providerId,
        providerName: providerName,
        price: price,
        currency: currency,
        estimatedDeliveryTime: estimatedDeliveryTime,
        message: message,
        status: 'pending',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    } catch (e) {
      print('❌ Error creating quote: $e');
      rethrow;
    }
  }

  /// Get quotes for a specific request
  Future<List<Quote>> getQuotesForRequest(String requestId) async {
    try {
      final querySnapshot = await _firestore
          .collection('quotes')
          .where('requestId', isEqualTo: requestId)
          .orderBy('createdAt', descending: true)
          .get();

      final quotes = querySnapshot.docs
          .map((doc) => _quoteFromMap(doc.data()))
          .toList();

      print('✅ Found ${quotes.length} quotes for request');
      return quotes;
    } catch (e) {
      print('❌ Error getting quotes for request: $e');
      return [];
    }
  }

  /// Get all quotes for a needy user (across all their requests)
  Future<List<Quote>> getQuotesForNeedy(String needyId) async {
    try {
      // First, get all request IDs for this needy user
      final requestsSnapshot = await _firestore
          .collection('petrolRequests')
          .where('userId', isEqualTo: needyId)
          .get();

      final requestIds = requestsSnapshot.docs
          .map((doc) => doc.data()['id'] as String)
          .toList();

      if (requestIds.isEmpty) {
        return [];
      }

      // Get quotes for these requests (in batches if needed)
      final quotes = <Quote>[];
      
      // Firestore has a limit of 10 items for 'whereIn', so we need to batch
      for (var i = 0; i < requestIds.length; i += 10) {
        final batch = requestIds.skip(i).take(10).toList();
        
        final quotesSnapshot = await _firestore
            .collection('quotes')
            .where('requestId', whereIn: batch)
            .orderBy('createdAt', descending: true)
            .get();

        quotes.addAll(
          quotesSnapshot.docs.map((doc) => _quoteFromMap(doc.data())),
        );
      }

      print('✅ Found ${quotes.length} quotes for needy');
      return quotes;
    } catch (e) {
      print('❌ Error getting quotes for needy: $e');
      return [];
    }
  }

  /// Accept a quote
  Future<void> acceptQuote(String quoteId, String needyId) async {
    try {
      final quoteDoc = await _firestore.collection('quotes').doc(quoteId).get();
      
      if (!quoteDoc.exists) {
        throw Exception('Quote not found');
      }

      final quoteData = quoteDoc.data()!;
      final requestId = quoteData['requestId'] as String;

      // Update quote status
      await _firestore.collection('quotes').doc(quoteId).update({
        'status': 'accepted',
        'acceptedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update request status
      await _firestore.collection('petrolRequests').doc(requestId).update({
        'status': 'accepted',
        'acceptedBy': quoteData['providerId'],
        'acceptedQuoteId': quoteId,
        'acceptedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Reject other quotes for this request
      final otherQuotes = await _firestore
          .collection('quotes')
          .where('requestId', isEqualTo: requestId)
          .where('status', isEqualTo: 'pending')
          .get();

      for (var doc in otherQuotes.docs) {
        if (doc.id != quoteId) {
          await doc.reference.update({
            'status': 'rejected',
            'rejectedAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      }

      print('✅ Quote accepted: $quoteId');
    } catch (e) {
      print('❌ Error accepting quote: $e');
      rethrow;
    }
  }

  /// Reject a quote
  Future<void> rejectQuote(String quoteId, String needyId) async {
    try {
      await _firestore.collection('quotes').doc(quoteId).update({
        'status': 'rejected',
        'rejectedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('✅ Quote rejected: $quoteId');
    } catch (e) {
      print('❌ Error rejecting quote: $e');
      rethrow;
    }
  }

  /// Listen to quotes for a request (real-time)
  Stream<List<Quote>> watchQuotesForRequest(String requestId) {
    return _firestore
        .collection('quotes')
        .where('requestId', isEqualTo: requestId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => _quoteFromMap(doc.data()))
            .toList());
  }

  /// Helper method to convert Firestore data to Quote
  Quote _quoteFromMap(Map<String, dynamic> data) {
    return Quote(
      id: data['id'] ?? '',
      requestId: data['requestId'] ?? '',
      providerId: data['providerId'] ?? '',
      providerName: data['providerName'],
      price: (data['price'] ?? 0.0).toDouble(),
      currency: data['currency'] ?? 'PKR',
      estimatedDeliveryTime: data['estimatedDeliveryTime'] as int?,
      message: data['message'] as String?,
      status: data['status'] ?? 'pending',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

