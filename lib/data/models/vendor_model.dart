class Vendor {
  final int id;
  final String name;
  final String logo;
  final String description;

  Vendor({
    required this.id,
    required this.name,
    required this.logo,
    required this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'logo': logo,
      'description': description,
    };
  }

  factory Vendor.fromMap(Map<String, dynamic> map) {
    return Vendor(
      id: map['id'] as int,
      name: map['name'] as String,
      logo: (map['logo'] as String?) ?? '',
      description: (map['description'] as String?) ?? '',
    );
  }

  Vendor copyWith({
    int? id,
    String? name,
    String? logo,
    String? description,
  }) {
    return Vendor(
      id: id ?? this.id,
      name: name ?? this.name,
      logo: logo ?? this.logo,
      description: description ?? this.description,
    );
  }
}
