class User {
  final String id;
  final String name;
  final String role; // 'needy' or 'provider'
  final DateTime? createdAt;
  final DateTime? lastLoginAt;

  User({
    required this.id,
    required this.name,
    required this.role,
    this.createdAt,
    this.lastLoginAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      role: json['role'] as String,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      lastLoginAt: json['lastLoginAt'] != null
          ? DateTime.parse(json['lastLoginAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'role': role,
      'createdAt': createdAt?.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
    };
  }
}

class CheckNameResponse {
  final String requestedName;
  final bool isAvailable;
  final String suggestedName;
  final String message;

  CheckNameResponse({
    required this.requestedName,
    required this.isAvailable,
    required this.suggestedName,
    required this.message,
  });

  factory CheckNameResponse.fromJson(Map<String, dynamic> json) {
    return CheckNameResponse(
      requestedName: json['requestedName'] as String,
      isAvailable: json['isAvailable'] as bool,
      suggestedName: json['suggestedName'] as String,
      message: json['message'] as String,
    );
  }
}

class RegisterResponse {
  final bool success;
  final User user;
  final bool isNewUser;
  final String message;

  RegisterResponse({
    required this.success,
    required this.user,
    required this.isNewUser,
    required this.message,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      success: json['success'] as bool,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      isNewUser: json['isNewUser'] as bool,
      message: json['message'] as String,
    );
  }
}

