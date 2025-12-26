class User {
  final int id;
  final String? username;
  final String email;
  final String fullName;
  final String role;
  final String accountStatus;
  final String? phone;
  final String? profilePictureUrl;
  final DateTime createdAt;
  final DateTime? lastLogin;

  User({
    required this.id,
    this.username,
    required this.email,
    required this.fullName,
    required this.role,
    required this.accountStatus,
    this.phone,
    this.profilePictureUrl,
    required this.createdAt,
    this.lastLogin,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      username: json['username'] as String?,
      email: json['email'] as String,
      fullName: json['full_name'] as String,
      role: json['role'] as String,
      accountStatus: json['account_status'] as String,
      phone: json['phone'] as String?,
      profilePictureUrl: json['profile_picture_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      lastLogin: json['last_login'] != null
          ? DateTime.parse(json['last_login'] as String)
          : null,
    );
  }
}