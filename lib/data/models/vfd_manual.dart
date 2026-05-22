class VfdManual {
  final int id;
  final int modelId;
  final String title;
  final String manualType;
  final String filePath;
  final String language;
  final int version;

  VfdManual({
    required this.id,
    required this.modelId,
    required this.title,
    required this.manualType,
    required this.filePath,
    required this.language,
    required this.version,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'modelId': modelId,
      'title': title,
      'manualType': manualType,
      'filePath': filePath,
      'language': language,
      'version': version,
    };
  }

  factory VfdManual.fromMap(Map<String, dynamic> map) {
    return VfdManual(
      id: map['id'] as int,
      modelId: map['modelId'] as int,
      title: map['title'] as String,
      manualType: map['manualType'] as String,
      filePath: (map['filePath'] as String?) ?? '',
      language: (map['language'] as String?) ?? '',
      version: (map['version'] as int?) ?? 1,
    );
  }

  VfdManual copyWith({
    int? id,
    int? modelId,
    String? title,
    String? manualType,
    String? filePath,
    String? language,
    int? version,
  }) {
    return VfdManual(
      id: id ?? this.id,
      modelId: modelId ?? this.modelId,
      title: title ?? this.title,
      manualType: manualType ?? this.manualType,
      filePath: filePath ?? this.filePath,
      language: language ?? this.language,
      version: version ?? this.version,
    );
  }
}

class VFDManual {
  final String id;
  final String vendorId;
  final String modelName;
  final String title;
  final String type;
  final String? url;
  final String? filePath;
  final bool isLocal;

  VFDManual({
    required this.id,
    required this.vendorId,
    required this.modelName,
    required this.title,
    required this.type,
    this.url,
    this.filePath,
    this.isLocal = false,
  });
}
