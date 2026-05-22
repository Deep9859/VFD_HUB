class VfdParameter {
  final int id;
  final int modelId;
  final String paramCode;
  final String paramName;
  final String description;
  final String defaultValue;
  final String minValue;
  final String maxValue;
  final String groupName;
  final String? userValue;

  VfdParameter({
    required this.id,
    required this.modelId,
    required this.paramCode,
    required this.paramName,
    required this.description,
    required this.defaultValue,
    required this.minValue,
    required this.maxValue,
    required this.groupName,
    this.userValue,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'modelId': modelId,
      'paramCode': paramCode,
      'paramName': paramName,
      'description': description,
      'defaultValue': defaultValue,
      'minValue': minValue,
      'maxValue': maxValue,
      'groupName': groupName,
      'userValue': userValue,
    };
  }

  factory VfdParameter.fromMap(Map<String, dynamic> map) {
    return VfdParameter(
      id: map['id'] as int,
      modelId: map['modelId'] as int,
      paramCode: map['paramCode'] as String,
      paramName: map['paramName'] as String,
      description: (map['description'] as String?) ?? '',
      defaultValue: (map['defaultValue'] as String?) ?? '',
      minValue: (map['minValue'] as String?) ?? '',
      maxValue: (map['maxValue'] as String?) ?? '',
      groupName: (map['groupName'] as String?) ?? '',
      userValue: map['userValue'] as String?,
    );
  }

  VfdParameter copyWith({
    int? id,
    int? modelId,
    String? paramCode,
    String? paramName,
    String? description,
    String? defaultValue,
    String? minValue,
    String? maxValue,
    String? groupName,
    String? userValue,
  }) {
    return VfdParameter(
      id: id ?? this.id,
      modelId: modelId ?? this.modelId,
      paramCode: paramCode ?? this.paramCode,
      paramName: paramName ?? this.paramName,
      description: description ?? this.description,
      defaultValue: defaultValue ?? this.defaultValue,
      minValue: minValue ?? this.minValue,
      maxValue: maxValue ?? this.maxValue,
      groupName: groupName ?? this.groupName,
      userValue: userValue ?? this.userValue,
    );
  }
}
