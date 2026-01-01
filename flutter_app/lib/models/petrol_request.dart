class PetrolRequest {
  final String id;
  final String needyId;
  final String? needyName;
  final String? name;
  final String? role; // 'needy' or 'provider'
  final double latitude;
  final double longitude;
  final String message;
  final double? quantityLiters;
  final String urgency; // 'normal' or 'urgent'
  final String status; // 'pending', 'accepted', 'in_progress', 'completed', 'cancelled'
  final String? acceptedBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final double? distance;
  final String? type; // 'request', 'needy', 'provider'

  PetrolRequest({
    required this.id,
    required this.needyId,
    this.needyName,
    this.name,
    this.role,
    required this.latitude,
    required this.longitude,
    required this.message,
    this.quantityLiters,
    required this.urgency,
    required this.status,
    this.acceptedBy,
    this.createdAt,
    this.updatedAt,
    this.distance,
    this.type,
  });

  factory PetrolRequest.fromJson(Map<String, dynamic> json) {
    return PetrolRequest(
      id: json['id'] as String,
      needyId: json['needyId'] as String,
      needyName: json['needyName'] as String?,
      name: json['name'] as String?,
      role: json['role'] as String?,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      message: json['message'] as String,
      quantityLiters: json['quantityLiters'] != null
          ? (json['quantityLiters'] as num).toDouble()
          : null,
      urgency: json['urgency'] as String? ?? 'normal',
      status: json['status'] as String,
      acceptedBy: json['acceptedBy'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      distance: json['distance'] != null
          ? (json['distance'] as num).toDouble()
          : null,
      type: json['type'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'needyId': needyId,
      'needyName': needyName,
      'name': name,
      'role': role,
      'latitude': latitude,
      'longitude': longitude,
      'message': message,
      'quantityLiters': quantityLiters,
      'urgency': urgency,
      'status': status,
      'acceptedBy': acceptedBy,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'distance': distance,
      'type': type,
    };
  }
}

class CreateRequestData {
  final double latitude;
  final double longitude;
  final String message;
  final double? quantityLiters;
  final String? urgency;
  final String? userId;
  final String? userRole;

  CreateRequestData({
    required this.latitude,
    required this.longitude,
    required this.message,
    this.quantityLiters,
    this.urgency,
    this.userId,
    this.userRole,
  });

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'message': message,
      'quantityLiters': quantityLiters,
      'urgency': urgency ?? 'normal',
      'userId': userId,
      'userRole': userRole ?? 'needy',
    };
  }
}

