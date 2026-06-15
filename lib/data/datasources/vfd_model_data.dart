/// VFD model row from master Excel (one row per model series).
class VfdModelData {
  final String name;
  final double minKw;
  final double maxKw;
  final String powerRatings;
  final String app;
  final String status;
  final String commCard;
  final String defaultProto;

  const VfdModelData({
    required this.name,
    required this.minKw,
    required this.maxKw,
    required this.powerRatings,
    required this.app,
    required this.status,
    required this.commCard,
    required this.defaultProto,
  });
}
