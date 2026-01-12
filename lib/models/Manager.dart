class Manager {
  final int id;
  final String fullName;
  final String? profilePictureUrl;
  final String role;

  Manager({
    required this.id,
    required this.fullName,
    this.profilePictureUrl,
    required this.role,
  });

  factory Manager.fromJson(Map<String, dynamic> json) {
    return Manager(
      id: json['id'] as int,
      fullName: json['full_name'] as String,
      profilePictureUrl: json['profile_picture_url'] as String?,
      role: json['role'] as String,
    );
  }
}