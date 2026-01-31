import 'TaskAssignee.dart';

class Signature {
  final int id;
  final String title;
  final String? description;
  final String documentUrl;
  final String status;
  final DateTime deadline;
  final DateTime createdAt;
  final String? signedLegalName;
  final DateTime? signedAt;
  final String? signerIpAddress;
  final TaskAssignee requester;
  final TaskAssignee signer;

  Signature({
    required this.id,
    required this.title,
    this.description,
    required this.documentUrl,
    required this.status,
    required this.deadline,
    required this.createdAt,
    this.signedLegalName,
    this.signedAt,
    this.signerIpAddress,
    required this.requester,
    required this.signer,
  });

  factory Signature.fromJson(Map<String, dynamic> json) {
    return Signature(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      documentUrl: json['document_url'],
      status: json['status'],
      deadline: DateTime.parse(json['deadline']),
      createdAt: DateTime.parse(json['created_at']),
      signedLegalName: json['signed_legal_name'],
      signedAt:
      json['signed_at'] != null ? DateTime.parse(json['signed_at']) : null,
      signerIpAddress: json['signer_ip_address'],
      requester: TaskAssignee.fromJson(json['requester']),
      signer: TaskAssignee.fromJson(json['signer']),
    );
  }
}

class SignatureListResponse {
  final int total;
  final List<Signature> signatures;

  SignatureListResponse({required this.total, required this.signatures});

  factory SignatureListResponse.fromJson(Map<String, dynamic> json) {
    return SignatureListResponse(
      total: json['total'],
      signatures: (json['data'] as List)
          .map((e) => Signature.fromJson(e))
          .toList(),
    );
  }
}
