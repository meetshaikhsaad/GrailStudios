class User {
  final int id;
  final String? username;
  final String email;
  final String fullName;
  final String role;
  final String accountStatus;

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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'full_name': fullName,
      'role': role,
      'account_status': accountStatus,
      'phone': phone,
      'mobile_number': mobileNumber,
      'profile_picture_url': profilePictureUrl,
      'bio': bio,
      'gender': gender,
      'dob': dob?.toIso8601String(),
      'city': city,
      'country_id': countryId,
      'address_1': address1,
      'address_2': address2,
      'zipcode': zipcode,
      'x_link': xLink,
      'of_link': ofLink,
      'insta_link': instaLink,
      'is_onboarded': isOnboarded,
      'created_at': createdAt.toIso8601String(),
      'last_login': lastLogin?.toIso8601String(),
    };
  }
}
