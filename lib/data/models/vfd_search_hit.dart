import '../datasources/vfd_static_data.dart';

/// Result from smart search including vendor context for home-screen loading.
class VfdSearchHit {
  final String vendor;
  final VfdModelData model;

  const VfdSearchHit({required this.vendor, required this.model});
}
