class VfdModel {
  final int id;
  final int vendorId;
  final String name;
  final String series;
  final String description;
  final double powerRating;
  final String voltage;

  VfdModel({
    required this.id,
    required this.vendorId,
    required this.name,
    required this.series,
    required this.description,
    required this.powerRating,
    required this.voltage,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vendorId': vendorId,
      'name': name,
      'series': series,
      'description': description,
      'powerRating': powerRating,
      'voltage': voltage,
    };
  }

  factory VfdModel.fromMap(Map<String, dynamic> map) {
    return VfdModel(
      id: map['id'] as int,
      vendorId: map['vendorId'] as int,
      name: map['name'] as String,
      series: (map['series'] as String?) ?? '',
      description: (map['description'] as String?) ?? '',
      powerRating: (map['powerRating'] as num?)?.toDouble() ?? 0.0,
      voltage: (map['voltage'] as String?) ?? '',
    );
  }

  VfdModel copyWith({
    int? id,
    int? vendorId,
    String? name,
    String? series,
    String? description,
    double? powerRating,
    String? voltage,
  }) {
    return VfdModel(
      id: id ?? this.id,
      vendorId: vendorId ?? this.vendorId,
      name: name ?? this.name,
      series: series ?? this.series,
      description: description ?? this.description,
      powerRating: powerRating ?? this.powerRating,
      voltage: voltage ?? this.voltage,
    );
  }
}

class VFDModel {
  final String id;
  final String vendorId;
  final String modelSeries;
  final double minPowerKw;
  final double maxPowerKw;
  final List<double> powerRatings;
  final String applicationFocus;
  final String status;
  final bool supportsCommCard;
  final String? defaultProtocol;
  final String? supportedCommCards;

  VFDModel({
    required this.id,
    required this.vendorId,
    required this.modelSeries,
    required this.minPowerKw,
    required this.maxPowerKw,
    required this.powerRatings,
    required this.applicationFocus,
    required this.status,
    required this.supportsCommCard,
    this.defaultProtocol,
    this.supportedCommCards,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vendorId': vendorId,
      'modelSeries': modelSeries,
      'minPowerKw': minPowerKw,
      'maxPowerKw': maxPowerKw,
      'powerRatings': powerRatings.join(','),
      'applicationFocus': applicationFocus,
      'status': status,
      'supportsCommCard': supportsCommCard ? 1 : 0,
      'defaultProtocol': defaultProtocol,
      'supportedCommCards': supportedCommCards,
    };
  }

  factory VFDModel.fromMap(Map<String, dynamic> map) {
    final powerStr = map['powerRatings'] as String? ?? '';
    return VFDModel(
      id: map['id'] as String,
      vendorId: map['vendorId'] as String,
      modelSeries: map['modelSeries'] as String,
      minPowerKw: (map['minPowerKw'] as num?)?.toDouble() ?? 0.0,
      maxPowerKw: (map['maxPowerKw'] as num?)?.toDouble() ?? 0.0,
      powerRatings: powerStr.isEmpty
          ? []
          : powerStr
              .split(',')
              .map((e) => double.tryParse(e.trim()) ?? 0.0)
              .toList(),
      applicationFocus: map['applicationFocus'] as String? ?? '',
      status: map['status'] as String? ?? 'current',
      supportsCommCard: (map['supportsCommCard'] as int?) == 1,
      defaultProtocol: map['defaultProtocol'] as String?,
      supportedCommCards: map['supportedCommCards'] as String?,
    );
  }
}
