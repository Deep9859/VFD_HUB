class VfdDrawing {
  final int id;
  final int modelId;
  final String name;
  final String filePath;
  final String fileType;
  final DateTime uploadedAt;

  VfdDrawing({
    required this.id,
    required this.modelId,
    required this.name,
    required this.filePath,
    required this.fileType,
    required this.uploadedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'modelId': modelId,
      'name': name,
      'filePath': filePath,
      'fileType': fileType,
      'uploadedAt': uploadedAt.toIso8601String(),
    };
  }

  factory VfdDrawing.fromMap(Map<String, dynamic> map) {
    return VfdDrawing(
      id: map['id'] as int,
      modelId: map['modelId'] as int,
      name: map['name'] as String,
      filePath: (map['filePath'] as String?) ?? '',
      fileType: (map['fileType'] as String?) ?? '',
      uploadedAt: DateTime.parse(map['uploadedAt'] as String),
    );
  }

  VfdDrawing copyWith({
    int? id,
    int? modelId,
    String? name,
    String? filePath,
    String? fileType,
    DateTime? uploadedAt,
  }) {
    return VfdDrawing(
      id: id ?? this.id,
      modelId: modelId ?? this.modelId,
      name: name ?? this.name,
      filePath: filePath ?? this.filePath,
      fileType: fileType ?? this.fileType,
      uploadedAt: uploadedAt ?? this.uploadedAt,
    );
  }
}
