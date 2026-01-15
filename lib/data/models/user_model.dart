class UserModel {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final bool isVerified;
  final bool isBanned;
  final String? avatar;
  final String createdAt;
  final String updatedAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.isVerified,
    required this.isBanned,
    this.avatar,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      role: json['user_type'] as String,  // Backend returns 'user_type'
      // MySQL returns 0/1 for boolean, convert to bool
      isVerified: json['is_verified'] == 1 || json['is_verified'] == true,
      isBanned: json['is_banned'] == 1 || json['is_banned'] == true,
      avatar: json['avatar'] as String?,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'is_verified': isVerified,
      'is_banned': isBanned,
      'avatar': avatar,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  bool get isBuyer => role == 'buyer';
  bool get isSeller => role == 'seller';
  bool get isAdmin => role == 'admin';

  UserModel copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    String? role,
    bool? isVerified,
    bool? isBanned,
    String? avatar,
    String? createdAt,
    String? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      isVerified: isVerified ?? this.isVerified,
      isBanned: isBanned ?? this.isBanned,
      avatar: avatar ?? this.avatar,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
