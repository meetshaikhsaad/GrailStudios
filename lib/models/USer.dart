class User {
  final int id;
  final String? username;
  final String email;
  final String fullName;
  final String role;
  final String accountStatus;

  final UserRelation? manager;
  final UserRelation? assignedModel;
  final List<UserRelation> modelsUnderManager;

  final String? phone;
  final String? mobileNumber;
  final String? profilePictureUrl;

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

  User({
    required this.id,
    this.username,
    required this.email,
    required this.fullName,
    required this.role,
    required this.accountStatus,

    this.manager,
    this.assignedModel,
    required this.modelsUnderManager,

    this.phone,
    this.mobileNumber,
    this.profilePictureUrl,
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

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      username: json['username'] as String?,
      email: json['email'] as String,
      fullName: json['full_name'] as String,
      role: json['role'] as String,
      accountStatus: json['account_status'] as String,

      manager: json['manager'] != null
          ? UserRelation.fromJson(json['manager'])
          : null,

      assignedModel: json['assigned_model_rel'] != null
          ? UserRelation.fromJson(json['assigned_model_rel'])
          : null,

      modelsUnderManager: (json['models_under_manager'] as List<dynamic>? ?? [])
          .map((e) => UserRelation.fromJson(e))
          .toList(),

      phone: json['phone'] as String?,
      mobileNumber: json['mobile_number'] as String?,
      profilePictureUrl: json['profile_picture_url'] as String?,
      bio: json['bio'] as String?,
      gender: json['gender'] as String?,
      dob: json['dob'] != null && json['dob'].toString().isNotEmpty
          ? DateTime.tryParse(json['dob'])
          : null,
      city: json['city'] as String?,
      countryId: json['country_id'] as int?,
      address1: json['address_1'] as String?,
      address2: json['address_2'] as String?,
      zipcode: json['zipcode'] as String?,
      xLink: json['x_link'] as String?,
      ofLink: json['of_link'] as String?,
      instaLink: json['insta_link'] as String?,
      isOnboarded: json['is_onboarded'] as bool,
      createdAt: DateTime.parse(json['created_at']),
      lastLogin: json['last_login'] != null
          ? DateTime.tryParse(json['last_login'])
          : null,
    );
  }
}

class UserRelation {
  final int id;
  final String fullName;
  final String? profilePictureUrl;
  final String role;

  UserRelation({
    required this.id,
    required this.fullName,
    this.profilePictureUrl,
    required this.role,
  });

  factory UserRelation.fromJson(Map<String, dynamic> json) {
    return UserRelation(
      id: json['id'] as int,
      fullName: json['full_name'] as String,
      profilePictureUrl: json['profile_picture_url'] as String?,
      role: json['role'] as String,
    );
  }
}

class UserData {
  final int id;
  final String fullName;
  final String username;
  final String? profilePictureUrl;
  final String role;

  UserData({
    required this.id,
    required this.fullName,
    required this.username,
    this.profilePictureUrl,
    required this.role,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id'],
      fullName: json['full_name'],
      username: json['username'],
      profilePictureUrl: json['profile_picture_url'],
      role: json['role'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'username': username,
      'profile_picture_url': profilePictureUrl,
      'role': role,
    };
  }
}
