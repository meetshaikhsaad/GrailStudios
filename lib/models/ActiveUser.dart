class ActiveUser {
  String message;
  String accessToken;
  String refreshToken;
  ActiveUserClass user;

  ActiveUser({
    required this.message,
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  factory ActiveUser.fromJson(Map<String, dynamic> json) {
    return ActiveUser(
      message: json['message'] as String? ?? 'Login successful',
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      user: ActiveUserClass.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}

class ActiveUserClass {
  final int id;
  final String email;
  final String? username; // Can be null
  final String fullName;
  final String role;
  final bool isOnboarded;
  final String? timezone; // Can be null
  final String profilePictureUrl;
  final String? phone;
  final String? gender; // Can be null
  final DateTime createdAt;

  ActiveUserClass({
    required this.id,
    required this.email,
    this.username,
    required this.fullName,
    required this.role,
    required this.isOnboarded,
    this.timezone,
    required this.profilePictureUrl,
    this.phone,
    this.gender,
    required this.createdAt,
  });

  factory ActiveUserClass.fromJson(Map<String, dynamic> json) {
    return ActiveUserClass(
      id: json['id'] as int,
      email: json['email'] as String,
      username: json['username'] as String?, // nullable
      fullName: json['full_name'] as String,
      role: json['role'] as String,
      isOnboarded: json['is_onboarded'] as bool,
      timezone: json['timezone'] as String?,
      profilePictureUrl: json['profile_picture_url'] as String,
      phone: json['phone'] as String?,
      gender: json['gender'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}