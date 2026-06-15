enum AuditCategory {
  configuration,
  parameter,
  project,
  sync,
  catalog,
  commissioning,
  system,
}

class AuditEvent {
  final String id;
  final AuditCategory category;
  final String action;
  final String detail;
  final DateTime timestamp;
  final String? userEmail;

  const AuditEvent({
    required this.id,
    required this.category,
    required this.action,
    required this.detail,
    required this.timestamp,
    this.userEmail,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'category': category.name,
        'action': action,
        'detail': detail,
        'timestamp': timestamp.toIso8601String(),
        'userEmail': userEmail,
      };

  factory AuditEvent.fromJson(Map<String, dynamic> json) => AuditEvent(
        id: json['id'] as String,
        category: AuditCategory.values.firstWhere(
          (c) => c.name == json['category'],
          orElse: () => AuditCategory.system,
        ),
        action: json['action'] as String,
        detail: json['detail'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
        userEmail: json['userEmail'] as String?,
      );
}
