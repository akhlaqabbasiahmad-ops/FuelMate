import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../providers/request_provider.dart';
import '../services/request_service.dart';
import '../services/quote_service.dart';
import '../widgets/create_request_dialog.dart';
import '../models/quote.dart';

class RequestsScreen extends StatefulWidget {
  const RequestsScreen({super.key});

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> {
  @override
  void initState() {
    super.initState();
    _fetchRequests();
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

      await QuoteService.createQuote(
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
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B35),
            ),
            child: const Text('Send Quote'),
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
        await QuoteService.createQuote(
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
        await QuoteService.acceptQuote(quote.id, userId);
        
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
        await RequestService.completeRequest(requestId, userId, userRole);
        
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
              Text(
                '⛽ Quantity: ${request.quantityLiters} liters',
                style: const TextStyle(fontSize: 14, color: Color(0xFF666666)),
              ),
            if (request.distance != null)
              Text(
                '📍 Distance: ${request.distance!.toStringAsFixed(2)} km away',
                style: const TextStyle(fontSize: 14, color: Color(0xFF666666)),
              ),
            Text(
              '📊 Status: ${request.status} | Type: ${request.type ?? 'undefined'}',
              style: const TextStyle(fontSize: 14, color: Color(0xFF666666)),
            ),

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
                        Text(
                          'PKR ${quote.price.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFF6B35),
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
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _acceptQuote(quote),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        child: const Text('Accept Quote'),
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
                        side: const BorderSide(color: Color(0xFFFF6B35)),
                      ),
                      child: const Text('Custom Quote'),
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
                    child: ElevatedButton.icon(
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
              icon: const Icon(Icons.add),
              label: const Text('Create Request'),
            )
          : null,
    );
  }
}
