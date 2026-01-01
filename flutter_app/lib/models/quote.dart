class Quote {
  final String id;
  final String requestId;
  final String providerId;
  final String? providerName;
  final double price;
  final String currency;
  final int? estimatedDeliveryTime;
  final String? message;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  Quote({
    required this.id,
    required this.requestId,
    required this.providerId,
    this.providerName,
    required this.price,
    required this.currency,
    this.estimatedDeliveryTime,
    this.message,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Quote.fromJson(Map<String, dynamic> json) {
    // Handle both camelCase and PascalCase from backend
    final id = json['id'] ?? json['Id'];
    final requestId = json['requestId'] ?? json['RequestId'];
    final providerId = json['providerId'] ?? json['ProviderId'];
    final providerName = json['providerName'] ?? json['ProviderName'];
    final price = json['price'] ?? json['Price'];
    final currency = json['currency'] ?? json['Currency'] ?? 'PKR';
    final estimatedDeliveryTime = json['estimatedDeliveryTime'] ?? json['EstimatedDeliveryTime'];
    final message = json['message'] ?? json['Message'];
    final status = json['status'] ?? json['Status'] ?? 'pending';
    final createdAt = json['createdAt'] ?? json['CreatedAt'];
    final updatedAt = json['updatedAt'] ?? json['UpdatedAt'];

    return Quote(
      id: id as String,
      requestId: requestId as String,
      providerId: providerId as String,
      providerName: providerName as String?,
      price: (price as num).toDouble(),
      currency: currency as String,
      estimatedDeliveryTime: estimatedDeliveryTime as int?,
      message: message as String?,
      status: status as String,
      createdAt: DateTime.parse(createdAt as String),
      updatedAt: DateTime.parse(updatedAt as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'requestId': requestId,
      'providerId': providerId,
      'providerName': providerName,
      'price': price,
      'currency': currency,
      'estimatedDeliveryTime': estimatedDeliveryTime,
      'message': message,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
