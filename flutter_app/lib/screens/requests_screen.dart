import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/user_provider.dart';
import '../providers/request_provider.dart';
import '../services/firestore_request_service.dart';
import '../services/firestore_quote_service.dart';
import '../services/firestore_chat_service.dart';
import '../widgets/create_request_dialog.dart';
import '../models/quote.dart';

class RequestsScreen extends StatefulWidget {
  const RequestsScreen({super.key});

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> {
  final FirestoreRequestService _requestService = FirestoreRequestService();
  final FirestoreQuoteService _quoteService = FirestoreQuoteService();
  final FirestoreChatService _chatService = FirestoreChatService();

  @override
  void initState() {
    super.initState();
    _setupRealtimeUpdates();
  }

  void _setupRealtimeUpdates() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.userId;
    final userRole = userProvider.userRole;

    if (userId == null || userRole == null) {
      print('⚠️ User not logged in, cannot setup real-time updates');
      return;
    }

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    final requestProvider = Provider.of<RequestProvider>(context, listen: false);
    
    // Setup real-time listeners
    requestProvider.watchRequests(
      latitude: position.latitude,
      longitude: position.longitude,
      userId: userId,
      userRole: userRole,
    );
  }

  Future<void> _handleLogout() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      // Clear request provider data (requests and quotes)
      final requestProvider = Provider.of<RequestProvider>(context, listen: false);
      requestProvider.clear();

      // Clear user data
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.clearUserData();

      // Navigate to role selection screen
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/role-selection',
          (route) => false,
        );
      }
    }
  }

  Future<void> _fetchRequests() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final requestProvider = Provider.of<RequestProvider>(context, listen: false);

    final location = userProvider.location;
    final userId = userProvider.userId;
    final userName = userProvider.userName;
    final userRole = userProvider.userRole;

    if (location == null || userId == null || userName == null || userRole == null) {
      return;
    }

    // Fetch requests (location is updated automatically by backend)
    await requestProvider.fetchRequests(
      latitude: location.latitude,
      longitude: location.longitude,
      userId: userId,
      userRole: userRole,
    );
  }

  Future<void> _sendQuickQuote(String requestId, double quantityLiters) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.userId;

    if (userId == null) return;

    try {
      final pricePerLiter = 390.0;
      final deliveryFee = 50.0;
      final totalPrice = (pricePerLiter * quantityLiters) + deliveryFee;

      await _quoteService.createQuote(
        requestId: requestId,
        providerId: userId,
        price: totalPrice,
        currency: 'PKR',
        estimatedDeliveryTime: 30,
        message: 'Quick Quote: PKR ${pricePerLiter.toStringAsFixed(0)}/L + PKR ${deliveryFee.toStringAsFixed(0)} delivery',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Quote sent successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        _fetchRequests();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error sending quote: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _sendCustomQuote(String requestId) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.userId;

    if (userId == null) return;

    final priceController = TextEditingController();
    final deliveryTimeController = TextEditingController(text: '30');
    final messageController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send Custom Quote'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: priceController,
                decoration: const InputDecoration(
                  labelText: 'Total Price (PKR)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: deliveryTimeController,
                decoration: const InputDecoration(
                  labelText: 'Delivery Time (minutes)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: messageController,
                decoration: const InputDecoration(
                  labelText: 'Message (optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey[700],
            ),
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B35),
              foregroundColor: Colors.white,
            ),
            child: const Text(
              'Send Quote',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (result == true) {
      final price = double.tryParse(priceController.text);
      final deliveryTime = int.tryParse(deliveryTimeController.text);

      if (price == null || price <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a valid price')),
        );
        return;
      }

      try {
        await _quoteService.createQuote(
          requestId: requestId,
          providerId: userId,
          price: price,
          currency: 'PKR',
          estimatedDeliveryTime: deliveryTime ?? 30,
          message: messageController.text.isEmpty ? null : messageController.text,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Custom quote sent!'),
              backgroundColor: Colors.green,
            ),
          );
          _fetchRequests();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Error: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _acceptQuote(Quote quote) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.userId;

    if (userId == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Accept Quote'),
        content: Text('Accept quote for PKR ${quote.price.toStringAsFixed(0)}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text('Accept'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _quoteService.acceptQuote(quote.id, userId);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Quote accepted! Provider will be notified.'),
              backgroundColor: Colors.green,
            ),
          );
          _fetchRequests();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Error: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _completeRequest(String requestId) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.userId;
    final userRole = userProvider.userRole;

    if (userId == null || userRole == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Complete Request'),
        content: const Text('Mark this request as delivered/completed?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text('Complete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _requestService.completeRequest(requestId);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Request marked as completed!'),
              backgroundColor: Colors.green,
            ),
          );
          _fetchRequests();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Error: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Widget _buildRequestCard(dynamic request, String userRole, String userId) {
    final requestProvider = Provider.of<RequestProvider>(context, listen: false);
    final quotes = requestProvider.quotes[request.id] ?? [];
    final pendingQuotes = quotes.where((q) => q.status == 'pending').toList();
    
    // Check if this is needy's own request
    final isMyRequest = userRole == 'needy' && request.needyId == userId && request.type == 'request';
    
    // Check if provider accepted this request
    final providerAcceptedThis = userRole == 'provider' && 
                                  request.acceptedBy != null && 
                                  request.acceptedBy == userId;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isMyRequest ? 'My Request' : (request.name ?? 'User'),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFF6B35),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        request.message,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF333333),
                        ),
                      ),
                    ],
                  ),
                ),
                if (request.urgency == 'urgent')
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF4444),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'URGENT',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            
            // Details
            const SizedBox(height: 10),
            if (request.quantityLiters != null)
              Row(
                children: [
                  const Icon(Icons.local_gas_station, size: 16, color: Color(0xFF666666)),
                  const SizedBox(width: 4),
                  Text(
                    'Quantity: ${request.quantityLiters} liters',
                    style: const TextStyle(fontSize: 14, color: Color(0xFF666666)),
                  ),
                ],
              ),
            const SizedBox(height: 5),
            
            // Distance with Map button
            // Show for: 1) Provider viewing needy requests, 2) Needy viewing accepted requests (to see provider location)
            if (!isMyRequest || (isMyRequest && request.status == 'accepted' && request.acceptedBy != null))
              _buildDistanceAndMapRow(request),
            
            const SizedBox(height: 5),
            Text(
              '📊 Status: ${request.status}',
              style: const TextStyle(fontSize: 14, color: Color(0xFF666666)),
            ),

            // Provider information for accepted requests (shown to needy)
            if (isMyRequest && request.status == 'accepted' && request.acceptedBy != null) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.local_shipping, color: Colors.green, size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          'Provider Assigned',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Provider ID: ${request.acceptedBy}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF666666),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Your request has been accepted and the provider is on the way!',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Quotes section for needy's own requests
            if (isMyRequest && pendingQuotes.isNotEmpty) ...[
              const Divider(height: 20),
              Text(
                '💰 Received Quotes (${pendingQuotes.length})',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 10),
              ...pendingQuotes.map((quote) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F0F0),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'PKR ${quote.price.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFFF6B35),
                                ),
                              ),
                              if (quote.providerName != null) ...[
                                const SizedBox(height: 2),
                                Text(
                                  'Provider: ${quote.providerName}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF999999),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        Text(
                          '${quote.estimatedDeliveryTime} min',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF666666),
                          ),
                        ),
                      ],
                    ),
                    if (quote.message != null) ...[
                      const SizedBox(height: 5),
                      Text(
                        quote.message!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF666666),
                        ),
                      ),
                    ],
                    // Distance and map button for provider
                    const SizedBox(height: 8),
                    FutureBuilder<Map<String, double>?>(
                      future: _getProviderLocation(quote.providerId),
                      builder: (context, snapshot) {
                        if (snapshot.hasData && snapshot.data != null) {
                          final providerLat = snapshot.data!['latitude']!;
                          final providerLng = snapshot.data!['longitude']!;
                          
                          return _buildQuoteDistanceRow(
                            providerLat,
                            providerLng,
                            quote.providerName ?? 'Provider',
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _acceptQuote(quote),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text(
                          'Accept Quote',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              )),
            ],

            // Waiting message if no quotes yet
            if (isMyRequest && quotes.isEmpty && request.status == 'pending') ...[
              const SizedBox(height: 10),
              const Text(
                'Waiting for quotes from providers...',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF999999),
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ],

            // Action buttons for providers on pending requests
            if (userRole == 'provider' && request.status == 'pending' && request.type == 'request') ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _sendQuickQuote(
                        request.id,
                        (request.quantityLiters ?? 10).toDouble(),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      child: const Column(
                        children: [
                          Text('Quick Quote'),
                          Text('390/L + 50', style: TextStyle(fontSize: 10)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _sendCustomQuote(request.id),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFFF6B35), width: 2),
                        foregroundColor: const Color(0xFFFF6B35),
                      ),
                      child: const Text(
                        'Custom Quote',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],

            // Chat and Complete buttons for accepted requests
            if (request.status == 'accepted' && (isMyRequest || providerAcceptedThis)) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: StreamBuilder<int>(
                      stream: _chatService.watchUnreadCount(request.id, userId),
                      builder: (context, snapshot) {
                        final unreadCount = snapshot.data ?? 0;
                        return Stack(
                          children: [
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  '/chat',
                                  arguments: request.id,
                                );
                              },
                              icon: const Icon(Icons.chat),
                              label: const Text('Chat'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                              ),
                            ),
                            if (unreadCount > 0)
                              Positioned(
                                right: 8,
                                top: 4,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 20,
                                    minHeight: 20,
                                  ),
                                  child: Text(
                                    unreadCount > 99 ? '99+' : '$unreadCount',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _completeRequest(request.id),
                      icon: const Icon(Icons.check_circle),
                      label: const Text('Complete'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                    ),
                  ),
                ],
              ),
            ],

            // Info message for needy type
            if (request.type == 'needy') ...[
              const SizedBox(height: 10),
              Text(
                '${request.name} is available. They haven\'t created a request yet.',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF666666),
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final requestProvider = Provider.of<RequestProvider>(context);
    final userRole = userProvider.userRole ?? 'needy';
    final userId = userProvider.userId ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(
          userRole == 'provider' ? 'Nearby Needers & Requests' : 'Nearby Providers',
        ),
        backgroundColor: const Color(0xFFFF6B35),
        actions: [
          IconButton(
            icon: const Icon(Icons.map_outlined),
            onPressed: _showMapView,
            tooltip: 'Map View',
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.pushNamed(context, '/history');
            },
            tooltip: 'History',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: requestProvider.isLoading && requestProvider.requests.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xFFFF6B35)),
                  SizedBox(height: 10),
                  Text('Loading nearby requests...'),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _fetchRequests,
              child: requestProvider.requests.isEmpty
                  ? ListView(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(40),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.search_off,
                                size: 60,
                                color: Color(0xFF999999),
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                'No nearby requests found',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF999999),
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                userRole == 'provider'
                                    ? 'Pull to refresh or wait for new requests'
                                    : userRole == 'needy'
                                        ? 'Create your first request using the + button below'
                                        : 'Pull to refresh',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF999999),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(15),
                      itemCount: requestProvider.requests.length,
                      itemBuilder: (context, index) {
                        final request = requestProvider.requests[index];
                        return _buildRequestCard(request, userRole, userId);
                      },
                    ),
            ),
      floatingActionButton: userRole == 'needy'
          ? FloatingActionButton.extended(
              onPressed: () {
                final location = userProvider.location;
                if (location != null) {
                  showDialog(
                    context: context,
                    builder: (context) => CreateRequestDialog(
                      latitude: location.latitude,
                      longitude: location.longitude,
                      onRequestCreated: _fetchRequests,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Location not available. Please enable location services.'),
                    ),
                  );
                }
              },
              backgroundColor: const Color(0xFFFF6B35),
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Create Request',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            )
          : null,
    );
  }

  // Calculate distance and show map button
  Widget _buildDistanceAndMapRow(dynamic request) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final currentLocation = userProvider.location;
    final userRole = userProvider.userRole;
    
    if (currentLocation == null) {
      return const Row(
        children: [
          Icon(Icons.location_off, size: 16, color: Colors.grey),
          SizedBox(width: 4),
          Text(
            'Location unavailable',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      );
    }

    // Calculate distance using Geolocator
    final distanceInMeters = Geolocator.distanceBetween(
      currentLocation.latitude,
      currentLocation.longitude,
      request.latitude,
      request.longitude,
    );
    final distanceInKm = distanceInMeters / 1000;

    // Determine what we're showing distance to
    final isAcceptedByProvider = request.status == 'accepted' && request.acceptedBy != null;
    final locationLabel = (userRole == 'needy' && isAcceptedByProvider) 
        ? "Provider's location" 
        : request.name ?? 'Location';

    return Row(
      children: [
        const Icon(Icons.location_on, size: 16, color: Color(0xFFFF6B35)),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            '${distanceInKm.toStringAsFixed(2)} km away${(userRole == 'needy' && isAcceptedByProvider) ? ' (Provider)' : ''}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF333333),
            ),
          ),
        ),
        const SizedBox(width: 10),
        // Map button
        InkWell(
          onTap: () => _openInMaps(
            request.latitude,
            request.longitude,
            locationLabel,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFFF6B35).withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: const Color(0xFFFF6B35), width: 1),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.map, size: 14, color: Color(0xFFFF6B35)),
                SizedBox(width: 4),
                Text(
                  'Open Map',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFFF6B35),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Open location in Google Maps
  Future<void> _openInMaps(double latitude, double longitude, String label) async {
    // Try Google Maps first
    final googleMapsUrl = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude'
    );
    
    // For Android, try the native Google Maps app
    final googleMapsAppUrl = Uri.parse(
      'geo:$latitude,$longitude?q=$latitude,$longitude($label)'
    );

    try {
      // Try to open in Google Maps app first (better experience)
      if (await canLaunchUrl(googleMapsAppUrl)) {
        await launchUrl(googleMapsAppUrl, mode: LaunchMode.externalApplication);
      } else if (await canLaunchUrl(googleMapsUrl)) {
        // Fallback to browser
        await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not open maps';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Could not open maps: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Show all nearby requests/providers on a map view dialog
  void _showMapView() {
    final requestProvider = Provider.of<RequestProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final requests = requestProvider.requests;
    final currentLocation = userProvider.location;

    if (currentLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location not available')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nearby Locations'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              // Current user location
              ListTile(
                leading: const Icon(Icons.my_location, color: Colors.blue),
                title: const Text('Your Location'),
                subtitle: Text(
                  '${currentLocation.latitude.toStringAsFixed(6)}, ${currentLocation.longitude.toStringAsFixed(6)}',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.map, color: Color(0xFFFF6B35)),
                  onPressed: () => _openInMaps(
                    currentLocation.latitude,
                    currentLocation.longitude,
                    'My Location',
                  ),
                ),
              ),
              const Divider(),
              // All nearby requests/providers
              ...requests.map((request) {
                final distance = Geolocator.distanceBetween(
                  currentLocation.latitude,
                  currentLocation.longitude,
                  request.latitude,
                  request.longitude,
                ) / 1000;

                return ListTile(
                  leading: Icon(
                    request.role == 'needy' ? Icons.person : Icons.local_shipping,
                    color: const Color(0xFFFF6B35),
                  ),
                  title: Text(request.name ?? 'Unknown'),
                  subtitle: Text(
                    '${request.message} • ${distance.toStringAsFixed(2)} km away',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.map, color: Color(0xFFFF6B35)),
                    onPressed: () => _openInMaps(
                      request.latitude,
                      request.longitude,
                      request.name ?? 'Location',
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // Get provider location from Firestore
  Future<Map<String, double>?> _getProviderLocation(String providerId) async {
    try {
      // For now, we'll get it from the users collection
      // In a real app, providers would update their location regularly
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(providerId)
          .get();
      
      if (userDoc.exists) {
        final data = userDoc.data();
        if (data != null && data['latitude'] != null && data['longitude'] != null) {
          return {
            'latitude': (data['latitude'] as num).toDouble(),
            'longitude': (data['longitude'] as num).toDouble(),
          };
        }
      }
      
      // If no location in users, try to get from recent requests
      final requestsSnapshot = await FirebaseFirestore.instance
          .collection('petrolRequests')
          .where('userId', isEqualTo: providerId)
          .orderBy('updatedAt', descending: true)
          .limit(1)
          .get();
      
      if (requestsSnapshot.docs.isNotEmpty) {
        final data = requestsSnapshot.docs.first.data();
        return {
          'latitude': (data['latitude'] as num).toDouble(),
          'longitude': (data['longitude'] as num).toDouble(),
        };
      }
      
      return null;
    } catch (e) {
      print('❌ Error getting provider location: $e');
      return null;
    }
  }

  // Build distance row for quotes (showing distance to provider)
  Widget _buildQuoteDistanceRow(double providerLat, double providerLng, String providerName) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final currentLocation = userProvider.location;
    
    if (currentLocation == null) {
      return const SizedBox.shrink();
    }

    // Calculate distance
    final distanceInMeters = Geolocator.distanceBetween(
      currentLocation.latitude,
      currentLocation.longitude,
      providerLat,
      providerLng,
    );
    final distanceInKm = distanceInMeters / 1000;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on, size: 14, color: Colors.blue),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              '${distanceInKm.toStringAsFixed(2)} km away',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.blue,
              ),
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: () => _openInMaps(providerLat, providerLng, providerName),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.map, size: 12, color: Colors.white),
                  SizedBox(width: 3),
                  Text(
                    'Map',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
