class CustomModelEntry {
  final String name;
  final double minKw;
  final double maxKw;
  final String powerRatings;
  final String defaultProto;

  const CustomModelEntry({
    required this.name,
    required this.minKw,
    required this.maxKw,
    this.powerRatings = '',
    this.defaultProto = 'Modbus RTU',
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'minKw': minKw,
        'maxKw': maxKw,
        'powerRatings': powerRatings,
        'defaultProto': defaultProto,
      };

  factory CustomModelEntry.fromJson(Map<String, dynamic> json) =>
      CustomModelEntry(
        name: json['name'] as String,
        minKw: (json['minKw'] as num).toDouble(),
        maxKw: (json['maxKw'] as num).toDouble(),
        powerRatings: json['powerRatings'] as String? ?? '',
        defaultProto: json['defaultProto'] as String? ?? 'Modbus RTU',
      );
}

class CustomVendorEntry {
  final String name;
  final String description;
  final List<CustomModelEntry> models;

  const CustomVendorEntry({
    required this.name,
    required this.description,
    this.models = const [],
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'models': models.map((m) => m.toJson()).toList(),
      };

  factory CustomVendorEntry.fromJson(Map<String, dynamic> json) =>
      CustomVendorEntry(
        name: json['name'] as String,
        description: json['description'] as String? ?? '',
        models: (json['models'] as List<dynamic>?)
                ?.map((e) =>
                    CustomModelEntry.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
      );
}
