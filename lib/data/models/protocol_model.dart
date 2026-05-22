class Protocol {
  final int id;
  final int vendorId;
  final int? modelId; // Model-specific protocol support
  final String name;
  final String type;
  final String description;
  final String? commCard;

  Protocol({
    required this.id,
    required this.vendorId,
    this.modelId,
    required this.name,
    required this.type,
    required this.description,
    this.commCard,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vendorId': vendorId,
      'modelId': modelId,
      'name': name,
      'type': type,
      'description': description,
      'commCard': commCard,
    };
  }

  factory Protocol.fromMap(Map<String, dynamic> map) {
    return Protocol(
      id: map['id'] as int,
      vendorId: map['vendorId'] as int,
      modelId: map['modelId'] as int?,
      name: map['name'] as String,
      type: (map['type'] as String?) ?? '',
      description: (map['description'] as String?) ?? '',
      commCard: (map['commCard'] as String?) ?? '',
    );
  }

  Protocol copyWith({
    int? id,
    int? vendorId,
    int? modelId,
    String? name,
    String? type,
    String? description,
    String? commCard,
  }) {
    return Protocol(
      id: id ?? this.id,
      vendorId: vendorId ?? this.vendorId,
      modelId: modelId ?? this.modelId,
      name: name ?? this.name,
      type: type ?? this.type,
      description: description ?? this.description,
      commCard: commCard ?? this.commCard,
    );
  }
}
