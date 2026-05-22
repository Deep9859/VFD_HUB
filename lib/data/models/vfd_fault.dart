class VfdFault {
  final int id;
  final String vendorId;
  final String errorCode;
  final String description;
  final String solution;
  final String severity; // e.g., 'Low', 'Medium', 'High', 'Critical'

  const VfdFault({
    required this.id,
    required this.vendorId,
    required this.errorCode,
    required this.description,
    required this.solution,
    required this.severity,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vendorId': vendorId,
      'errorCode': errorCode,
      'description': description,
      'solution': solution,
      'severity': severity,
    };
  }

  factory VfdFault.fromMap(Map<String, dynamic> map) {
    return VfdFault(
      id: map['id'] as int,
      vendorId: map['vendorId'] as String,
      errorCode: map['errorCode'] as String,
      description: map['description'] as String,
      solution: map['solution'] as String,
      severity: map['severity'] as String,
    );
  }

  VfdFault copyWith({
    int? id,
    String? vendorId,
    String? errorCode,
    String? description,
    String? solution,
    String? severity,
  }) {
    return VfdFault(
      id: id ?? this.id,
      vendorId: vendorId ?? this.vendorId,
      errorCode: errorCode ?? this.errorCode,
      description: description ?? this.description,
      solution: solution ?? this.solution,
      severity: severity ?? this.severity,
    );
  }

  @override
  String toString() {
    return 'VfdFault(id: $id, vendorId: $vendorId, errorCode: $errorCode, description: $description, solution: $solution, severity: $severity)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is VfdFault &&
        other.id == id &&
        other.vendorId == vendorId &&
        other.errorCode == errorCode &&
        other.description == description &&
        other.solution == solution &&
        other.severity == severity;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        vendorId.hashCode ^
        errorCode.hashCode ^
        description.hashCode ^
        solution.hashCode ^
        severity.hashCode;
  }
}
