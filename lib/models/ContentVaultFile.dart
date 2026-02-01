class ContentVaultFile {
  final int id;
  final String fileUrl;
  final String? thumbnailUrl;
  final double fileSizeMb;
  final String mimeType;
  final String mediaType;
  final String contentType;
  final String tags;
  final DateTime createdAt;
  final VaultTask? task;

  ContentVaultFile({
    required this.id,
    required this.fileUrl,
    this.thumbnailUrl,
    required this.fileSizeMb,
    required this.mimeType,
    required this.mediaType,
    required this.contentType,
    required this.tags,
    required this.createdAt,
    this.task,
  });

  factory ContentVaultFile.fromJson(Map<String, dynamic> json) {
    return ContentVaultFile(
      id: json['id'],
      fileUrl: json['file_url'],
      thumbnailUrl: json['thumbnail_url'],
      fileSizeMb: (json['file_size_mb'] as num).toDouble(),
      mimeType: json['mime_type'],
      mediaType: json['media_type'],
      contentType: json['content_type'],
      tags: json['tags'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
      task: json['task'] != null ? VaultTask.fromJson(json['task']) : null,
    );
  }
}

class VaultTask {
  final int id;
  final String title;

  VaultTask({
    required this.id,
    required this.title,
  });

  factory VaultTask.fromJson(Map<String, dynamic> json) {
    return VaultTask(
      id: json['id'],
      title: json['title'],
    );
  }
}
