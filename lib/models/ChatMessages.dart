class ChatMessage {
  final int id;
  final String message;
  final DateTime createdAt;
  final bool isFromCurrentUser;
  final String senderName;
  final String? senderProfileUrl;

  ChatMessage({
    required this.id,
    required this.message,
    required this.createdAt,
    required this.isFromCurrentUser,
    required this.senderName,
    this.senderProfileUrl,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json, int currentUserId) {
    final author = json['author'] as Map<String, dynamic>? ?? {};
    return ChatMessage(
      id: json['id'] as int,
      message: json['message'] as String,
      createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
      isFromCurrentUser: (json['author']['id'] as int?) == currentUserId,
      senderName: author['full_name'] as String? ?? 'Unknown',
      senderProfileUrl: author['profile_picture_url'] as String?,
    );
  }
}