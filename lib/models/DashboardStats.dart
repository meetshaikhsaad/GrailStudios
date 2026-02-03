import '../helpers/ExportImports.dart';

class DashboardStats {
  final Metrics metrics;
  final Completion completion;
  final ListsData lists;
  final TimeData time;

  DashboardStats({
    required this.metrics,
    required this.completion,
    required this.lists,
    required this.time,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      metrics: Metrics.fromJson(json['metrics']),
      completion: Completion.fromJson(json['completion']),
      lists: ListsData.fromJson(json['lists']),
      time: TimeData.fromJson(json['time']),
    );
  }
}

class Metrics {
  final int overdue;
  final int missing;
  final int unsigned;
  final int blocked;

  Metrics({
    required this.overdue,
    required this.missing,
    required this.unsigned,
    required this.blocked,
  });

  factory Metrics.fromJson(Map<String, dynamic> json) {
    return Metrics(
      overdue: json['overdue'] ?? 0,
      missing: json['missing'] ?? 0,
      unsigned: json['unsigned'] ?? 0,
      blocked: json['blocked'] ?? 0,
    );
  }
}

class Completion {
  final int overallRate;

  Completion({required this.overallRate});

  factory Completion.fromJson(Map<String, dynamic> json) {
    return Completion(overallRate: json['overall_rate'] ?? 0);
  }
}

class ListsData {
  final List<MissingContentItem> missingContent;
  final List<DocumentItem> documents;

  ListsData({
    required this.missingContent,
    required this.documents,
  });

  factory ListsData.fromJson(Map<String, dynamic> json) {
    return ListsData(
      missingContent: (json['missing_content'] as List<dynamic>? ?? [])
          .map((e) => MissingContentItem.fromJson(e))
          .toList(),
      documents: (json['documents'] as List<dynamic>? ?? [])
          .map((e) => DocumentItem.fromJson(e))
          .toList(),
    );
  }
}

class MissingContentItem {
  final String name;
  final int count;

  MissingContentItem({required this.name, required this.count});

  factory MissingContentItem.fromJson(Map<String, dynamic> json) {
    return MissingContentItem(
      name: json['name'] ?? 'Unknown',
      count: json['count'] ?? 0,
    );
  }
}

class DocumentItem {
  final String userName;
  final String docName;
  final String status;
  final String badgeClass;

  DocumentItem({
    required this.userName,
    required this.docName,
    required this.status,
    required this.badgeClass,
  });

  factory DocumentItem.fromJson(Map<String, dynamic> json) {
    return DocumentItem(
      userName: json['user_name'] ?? 'Unknown',
      docName: json['doc_name'] ?? 'Unknown',
      status: json['status'] ?? 'Unknown',
      badgeClass: json['badge_class'] ?? '',
    );
  }

  Color get statusColor {
    switch (badgeClass) {
      case 'badge-expired':
        return Colors.red;
      case 'status-badge':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}

class TimeData {
  final double avgDays;

  TimeData({required this.avgDays});

  factory TimeData.fromJson(Map<String, dynamic> json) {
    return TimeData(avgDays: (json['avg_days'] as num?)?.toDouble() ?? 0.0);
  }
}