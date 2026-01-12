class ActiveUser {
  final String message;
  final String accessToken;
  final String refreshToken;
  final ActiveUserProfile user;

  ActiveUser({
    required this.message,
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  factory ActiveUser.fromJson(Map<String, dynamic> json) {
    return ActiveUser(
      message: json['message'] as String? ?? '',
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      user: ActiveUserProfile.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}

class ActiveUserProfile {
  final int id;
  final String? username;
  final String email;
  final String fullName;
  final String role;
  final String? accountStatus;

  final RelatedUser? manager;
  final RelatedUser? assignedModelRel;
  final List<dynamic> modelsUnderManager;

  final String? phone;
  final String? mobileNumber;
  final String profilePictureUrl;
  final String? bio;
  final String? gender;
  final DateTime? dob;
  final String? city;
  final int? countryId;
  final String? address1;
  final String? address2;
  final String? zipcode;

  final String? xLink;
  final String? ofLink;
  final String? instaLink;

  final bool isOnboarded;
  final DateTime createdAt;
  final DateTime? lastLogin;

  ActiveUserProfile({
    required this.id,
    this.username,
    required this.email,
    required this.fullName,
    required this.role,
    this.accountStatus,
    this.manager,
    this.assignedModelRel,
    required this.modelsUnderManager,
    this.phone,
    this.mobileNumber,
    required this.profilePictureUrl,
    this.bio,
    this.gender,
    this.dob,
    this.city,
    this.countryId,
    this.address1,
    this.address2,
    this.zipcode,
    this.xLink,
    this.ofLink,
    this.instaLink,
    required this.isOnboarded,
    required this.createdAt,
    this.lastLogin,
  });

  factory ActiveUserProfile.fromJson(Map<String, dynamic> json) {
    return ActiveUserProfile(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      fullName: json['full_name'],
      role: json['role'],
      accountStatus: json['account_status'],

      manager: json['manager'] != null
          ? RelatedUser.fromJson(json['manager'])
          : null,

      assignedModelRel: json['assigned_model_rel'] != null
          ? RelatedUser.fromJson(json['assigned_model_rel'])
          : null,

      modelsUnderManager: json['models_under_manager'] ?? [],

      phone: json['phone'],
      mobileNumber: json['mobile_number'],
      profilePictureUrl: json['profile_picture_url'],
      bio: json['bio'],
      gender: json['gender'],
      dob: json['dob'] != null ? DateTime.parse(json['dob']) : null,
      city: json['city'],
      countryId: json['country_id'],
      address1: json['address_1'],
      address2: json['address_2'],
      zipcode: json['zipcode'],

      xLink: json['x_link'],
      ofLink: json['of_link'],
      instaLink: json['insta_link'],

      isOnboarded: json['is_onboarded'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      lastLogin: json['last_login'] != null
          ? DateTime.parse(json['last_login'])
          : null,
    );
  }
}

class RelatedUser {
  final int id;
  final String fullName;
  final String profilePictureUrl;
  final String role;

  RelatedUser({
    required this.id,
    required this.fullName,
    required this.profilePictureUrl,
    required this.role,
  });

  factory RelatedUser.fromJson(Map<String, dynamic> json) {
    return RelatedUser(
      id: json['id'],
      fullName: json['full_name'],
      profilePictureUrl: json['profile_picture_url'],
      role: json['role'],
    );
  }
}