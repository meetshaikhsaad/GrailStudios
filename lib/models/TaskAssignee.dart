class TaskAssignee {
  final int id;
  final String fullName;
  final String username;
  final String? profilePictureUrl;
  final String role;

  TaskAssignee({
    required this.id,
    required this.fullName,
    required this.username,
    this.profilePictureUrl,
    required this.role,
  });

  factory TaskAssignee.fromJson(Map<String, dynamic> json) {
    return TaskAssignee(
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
