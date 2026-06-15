import '../../core/config/supported_vendors.dart';
import '../../core/services/custom_vendor_service.dart';
import 'vfd_master_from_excel.dart';
import 'vfd_model_data.dart';
import '../../core/services/remote_catalog_service.dart';

export 'vfd_model_data.dart';

/// Static VFD catalog — Excel-backed where available; DB for remaining vendors.
class VfdStaticData {
  VfdStaticData._();

  static Map<String, List<VfdModelData>> get vendors {
    final base = VfdMasterFromExcel.vendors;
    final remote = RemoteCatalogService.cachedVendors;
    if (remote.isEmpty) return base;

    final merged = Map<String, List<VfdModelData>>.from(base);
    for (final entry in remote.entries) {
      merged[entry.key] = entry.value;
    }
    return merged;
  }

  static List<String> get vendorNames {
    return SupportedVendors.namesInOrder
        .where((name) => vendors.containsKey(name))
        .toList(growable: false);
  }

  static List<VfdModelData> getModelsByVendor(String vendorName) {
    final base = vendors[vendorName] ?? [];
    final custom = CustomVendorService.cached
        .where((v) => v.name.toLowerCase() == vendorName.toLowerCase())
        .firstOrNull;
    if (custom == null) return base;
    final customModels = custom.models
        .map(
          (m) => VfdModelData(
            name: m.name,
            minKw: m.minKw,
            maxKw: m.maxKw,
            powerRatings: m.powerRatings,
            app: 'Custom',
            status: 'Current',
            commCard: '',
            defaultProto: m.defaultProto,
          ),
        )
        .toList();
    return [...base, ...customModels];
  }

  static List<String> getModelNames(String vendorName) {
    return vendors[vendorName]?.map((m) => m.name).toList() ?? [];
  }

  static List<double> getPowerRatings(String vendorName, String modelName) {
    final model =
        vendors[vendorName]?.where((m) => m.name == modelName).firstOrNull;
    if (model == null || model.powerRatings.isEmpty) return [];
    return model.powerRatings
        .split(',')
        .map((s) => double.tryParse(s.trim()))
        .where((d) => d != null)
        .cast<double>()
        .toList()
      ..sort();
  }

  /// Primary protocol string(s) from Excel "Default Communication Protocol".
  static List<String> getProtocols(String vendorName, String modelName) {
    final model =
        vendors[vendorName]?.where((m) => m.name == modelName).firstOrNull;
    if (model == null) return ['Direct I/O'];

    final proto = model.defaultProto.trim();
    if (proto.isEmpty || proto.toLowerCase().contains('none')) {
      return ['Direct I/O'];
    }
    return [proto];
  }

  /// Optional comm cards from Excel "Supports Communication Card" column.
  static List<String> getCommunicationCards(
      String vendorName, String modelName) {
    final model =
        vendors[vendorName]?.where((m) => m.name == modelName).firstOrNull;
    if (model == null) return [];

    final raw = model.commCard.trim();
    if (raw.isEmpty || raw.toLowerCase().contains('none')) {
      return [];
    }

    return raw
        .split(RegExp(r'[;,]'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toSet()
        .toList();
  }
}
