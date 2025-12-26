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
      accessToken: json['access_token'] as String? ?? '',
      refreshToken: json['refresh_token'] as String? ?? '',
      user: ActiveUserClass.fromJson(json['user'] as Map<String, dynamic>? ?? {}),
    );
  }
}

class ActiveUserClass {
  int id;
  String email;
  String username;
  String fullName;
  String role;
  bool isOnboarded;
  dynamic timezone;
  dynamic phone;
  dynamic gender;
  DateTime createdAt;

  ActiveUserClass({
    required this.id,
    required this.email,
    required this.username,
    required this.fullName,
    required this.role,
    required this.isOnboarded,
    required this.timezone,
    required this.phone,
    required this.gender,
    required this.createdAt,
  });

  factory ActiveUserClass.fromJson(Map<String, dynamic> json) {
    return ActiveUserClass(
      id: json['id'] as int? ?? 0,
      email: json['email'] as String? ?? '',
      username: json['username'] as String? ?? '',
      fullName: json['full_name'] as String? ?? '',
      role: json['role'] as String? ?? '',
      isOnboarded: json['is_onboarded'] as bool? ?? false,
      timezone: json['timezone'],
      phone: json['phone'],
      gender: json['gender'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }
}