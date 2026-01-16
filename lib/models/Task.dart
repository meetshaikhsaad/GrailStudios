import '../../helpers/ExportImports.dart';

class Task {
  final int id;
  final String title;
  final String description;
  final String status;
  final String priority;
  final DateTime dueDate;
  final DateTime createdAt;

  final String reqContentType;
  final int reqQuantity;
  final int reqDurationMin;
  final List<String>? reqOutfitTags;
  final bool reqFaceVisible;
  final bool reqWatermark;

  final String context;

  final TaskAssignee  assigner;
  final TaskAssignee  assignee;

  final int chatCount;
  final int attachmentsCount;
  final bool isCreatedByMe;
  final List<Attachment> attachments;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    required this.dueDate,
    required this.createdAt,
    required this.reqContentType,
    required this.reqQuantity,
    required this.reqDurationMin,
    this.reqOutfitTags,
    required this.reqFaceVisible,
    required this.reqWatermark,
    required this.context,
    required this.assigner,
    required this.assignee,
    required this.chatCount,
    required this.attachmentsCount,
    required this.isCreatedByMe,
    required this.attachments,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      status: json['status'],
      priority: json['priority'],
      dueDate: DateTime.parse(json['due_date']),
      createdAt: DateTime.parse(json['created_at']),
      reqContentType: json['req_content_type'],
      reqQuantity: json['req_quantity'],
      reqDurationMin: json['req_duration_min'],
      reqOutfitTags: json['req_outfit_tags'] == null
          ? null
          : List<String>.from(json['req_outfit_tags']),
      reqFaceVisible: json['req_face_visible'],
      reqWatermark: json['req_watermark'],
      context: json['context'],
      assigner: TaskAssignee.fromJson(json['assigner']),
      assignee: TaskAssignee.fromJson(json['assignee']),
      chatCount: json['chat_count'],
      attachmentsCount: json['attachments_count'],
      isCreatedByMe: json['is_created_by_me'],
      attachments: (json['attachments'] as List)
          .map((e) => Attachment.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status,
      'priority': priority,
      'due_date': dueDate.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'req_content_type': reqContentType,
      'req_quantity': reqQuantity,
      'req_duration_min': reqDurationMin,
      'req_outfit_tags': reqOutfitTags,
      'req_face_visible': reqFaceVisible,
      'req_watermark': reqWatermark,
      'context': context,
      'assigner': assigner.toJson(),
      'assignee': assignee.toJson(),
      'chat_count': chatCount,
      'attachments_count': attachmentsCount,
      'is_created_by_me': isCreatedByMe,
      'attachments': attachments.map((e) => e.toJson()).toList(),
    };
  }
}

class TaskListResponse {
  final int total;
  final int skip;
  final int limit;
  final List<Task> tasks;

  TaskListResponse({
    required this.total,
    required this.skip,
    required this.limit,
    required this.tasks,
  });

  factory TaskListResponse.fromJson(Map<String, dynamic> json) {
    return TaskListResponse(
      total: json['total'],
      skip: json['skip'],
      limit: json['limit'],
      tasks: (json['tasks'] as List)
          .map((e) => Task.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'skip': skip,
      'limit': limit,
      'tasks': tasks.map((e) => e.toJson()).toList(),
    };
  }
}

class Attachment {
  final int id;
  final int uploaderId;
  final String fileUrl;
  final String thumbnailUrl;
  final String status;
  final DateTime createdAt;

  Attachment({
    required this.id,
    required this.uploaderId,
    required this.fileUrl,
    required this.thumbnailUrl,
    required this.status,
    required this.createdAt,
  });

  factory Attachment.fromJson(Map<String, dynamic> json) {
    return Attachment(
      id: json['id'],
      uploaderId: json['uploader_id'],
      fileUrl: json['file_url'],
      thumbnailUrl: json['thumbnail_url'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uploader_id': uploaderId,
      'file_url': fileUrl,
      'thumbnail_url': thumbnailUrl,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
