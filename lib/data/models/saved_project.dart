class SavedProject {
  final String id;
  final String name;
  final Map<String, dynamic> configuration;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SavedProject({
    required this.id,
    required this.name,
    required this.configuration,
    required this.createdAt,
    required this.updatedAt,
  });

  String get vendorName => configuration['vendor'] as String? ?? '';
  String get modelName => configuration['model'] as String? ?? '';
  double? get powerRating => (configuration['powerRating'] as num?)?.toDouble();

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'configuration': configuration,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory SavedProject.fromJson(Map<String, dynamic> json) => SavedProject(
        id: json['id'] as String,
        name: json['name'] as String,
        configuration: Map<String, dynamic>.from(json['configuration'] as Map),
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );

  SavedProject copyWith({
    String? name,
    Map<String, dynamic>? configuration,
    DateTime? updatedAt,
  }) =>
      SavedProject(
        id: id,
        name: name ?? this.name,
        configuration: configuration ?? this.configuration,
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}
