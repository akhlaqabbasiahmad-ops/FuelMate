import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/quote.dart';

class QuoteService {
  static final String baseUrl = ApiConfig.apiBaseUrl;

  // Create a quote (Provider)
  static Future<Quote> createQuote({
    required String requestId,
    required String providerId,
    required double price,
    String currency = 'PKR',
    int? estimatedDeliveryTime,
    String? message,
  }) async {
    final url = Uri.parse('$baseUrl/api/requests/quotes/create');
    
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'requestId': requestId,
        'providerId': providerId,
        'price': price,
        'currency': currency,
        'estimatedDeliveryTime': estimatedDeliveryTime,
        'message': message,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('📥 Create quote response: $data');
      print('📥 Response keys: ${data.keys.toList()}');
      return Quote.fromJson(data);
    } else {
      print('❌ Create quote failed: ${response.statusCode} - ${response.body}');
      throw Exception('Failed to create quote: ${response.body}');
    }
  }

  // Get quotes for a request
  static Future<List<Quote>> getQuotesForRequest(String requestId) async {
    final url = Uri.parse('$baseUrl/api/requests/quotes/request/$requestId');
    
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final quotes = data['quotes'] as List;
      return quotes.map((q) => Quote.fromJson(q)).toList();
    } else {
      throw Exception('Failed to get quotes: ${response.body}');
    }
  }

  // Get quotes for a needy user
  static Future<List<Quote>> getQuotesForNeedy(String needyId) async {
    final url = Uri.parse('$baseUrl/api/requests/quotes/needy/$needyId');
    
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final quotes = data['quotes'] as List;
      return quotes.map((q) => Quote.fromJson(q)).toList();
    } else {
      throw Exception('Failed to get quotes: ${response.body}');
    }
  }

  // Get quotes for a provider
  static Future<List<Quote>> getQuotesForProvider(String providerId) async {
    final url = Uri.parse('$baseUrl/api/requests/quotes/provider/$providerId');
    
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final quotes = data['quotes'] as List;
      return quotes.map((q) => Quote.fromJson(q)).toList();
    } else {
      throw Exception('Failed to get quotes: ${response.body}');
    }
  }

  // Accept a quote (Needy)
  static Future<Map<String, dynamic>> acceptQuote(String quoteId, String needyId) async {
    final url = Uri.parse('$baseUrl/api/requests/quotes/$quoteId/accept');
    
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'needyId': needyId}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to accept quote: ${response.body}');
    }
  }

  // Reject a quote (Needy)
  static Future<Quote> rejectQuote(String quoteId, String needyId) async {
    final url = Uri.parse('$baseUrl/api/requests/quotes/$quoteId/reject');
    
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'needyId': needyId}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Quote.fromJson(data);
    } else {
      throw Exception('Failed to reject quote: ${response.body}');
    }
  }
}

