class User {
  final int adminId;
  final String? phone;
  final String? email;
  final String? name;

  User({
    required this.adminId,
    this.phone,
    this.email,
    this.name,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'adminId': adminId,
      'phone': phone,
      'email': email,
      'name': name,
    };
  }

  // Create from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      adminId: json['adminId'] as int,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      name: json['name'] as String?,
    );
  }
  
  // Create from login response (adminId only)
  factory User.fromLoginResponse(int adminId) {
    return User(adminId: adminId);
  }
  
  User copyWith({
    int? adminId,
    String? phone,
    String? email,
    String? name,
  }) {
    return User(
      adminId: adminId ?? this.adminId,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      name: name ?? this.name,
    );
  }
}
