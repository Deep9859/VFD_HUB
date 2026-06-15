import '../../data/datasources/vendor_models_from_excel.dart';
import '../../data/datasources/vfd_static_data.dart';
import '../../data/models/vendor_model.dart';
import '../../core/services/custom_vendor_service.dart';

/// All VFD vendors seeded in the local database (Excel catalog covers a subset).
class SupportedVendors {
  SupportedVendors._();

  static const List<String> namesInOrder = [
    'ABB',
    'Allen Bradley',
    'Danfoss',
    'Delta',
    'Fuji',
    'Hitachi',
    'INVT',
    'Inovance',
    'KEB',
    'L&T',
    'Lenze',
    'LS',
    'Mitsubishi',
    'Nidec',
    'Omron',
    'Parker',
    'Schneider',
    'Siemens',
    'Toshiba',
    'WEG',
    'Yaskawa',
  ];

  static bool includes(String name) {
    final lower = name.trim().toLowerCase();
    if (namesInOrder.any((n) => n.toLowerCase() == lower)) return true;
    return CustomVendorService.cached
        .any((v) => v.name.toLowerCase() == lower);
  }

  static List<String> get allVendorNames {
    final custom = CustomVendorService.cached.map((v) => v.name);
    return {...namesInOrder, ...custom}.toList();
  }

  static int sortIndex(String name) {
    final idx = namesInOrder.indexWhere(
      (n) => n.toLowerCase() == name.trim().toLowerCase(),
    );
    return idx < 0 ? namesInOrder.length : idx;
  }

  static List<Vendor> filterVendors(List<Vendor> vendors) {
    final filtered = vendors.where((v) => includes(v.name)).toList();
    filtered.sort((a, b) => sortIndex(a.name).compareTo(sortIndex(b.name)));
    return filtered;
  }

  /// Model names for a vendor (DB + Excel catalog merged).
  static List<String> filterModelNames(String vendorName, List<String> fromDb) {
    final catalog = catalogModelNames(vendorName);
    if (catalog.isEmpty) {
      final sorted = List<String>.from(fromDb)..sort();
      return sorted;
    }

    final allowed = catalog.toSet();
    final fromDbFiltered =
        fromDb.where((name) => allowed.contains(name)).toList();
    if (fromDbFiltered.isNotEmpty) {
      fromDbFiltered.sort();
      return fromDbFiltered;
    }
    return List<String>.from(catalog)..sort();
  }

  static List<String> catalogModelNames(String vendorName) {
    final custom = CustomVendorService.cached
        .where((v) => v.name.toLowerCase() == vendorName.toLowerCase())
        .firstOrNull;
    if (custom != null && custom.models.isNotEmpty) {
      return custom.models.map((m) => m.name).toList();
    }

    final fromCatalog = VendorModelsFromExcel.models[vendorName]
        ?.map((m) => m.name)
        .toList();
    if (fromCatalog != null && fromCatalog.isNotEmpty) {
      return fromCatalog;
    }
    return VfdStaticData.getModelNames(vendorName);
  }

  /// Full power rating list for a model (DB + static catalog merged).
  static List<double> resolvePowerRatings(
    String vendorName,
    String modelName,
    List<double> fromDb,
  ) {
    final customVendor = CustomVendorService.cached
        .where((v) => v.name.toLowerCase() == vendorName.toLowerCase())
        .firstOrNull;
    final customModel = customVendor?.models
        .where((m) => m.name == modelName)
        .firstOrNull;
    if (customModel != null && customModel.powerRatings.isNotEmpty) {
      final parsed = customModel.powerRatings
          .split(',')
          .map((s) => double.tryParse(s.trim()))
          .whereType<double>()
          .toList();
      final merged = <double>{...fromDb, ...parsed}.toList()..sort();
      return merged;
    }

    final staticList = VfdStaticData.getPowerRatings(vendorName, modelName);
    final merged = <double>{...fromDb, ...staticList}.toList()..sort();
    return merged;
  }

  static ({double minKw, double maxKw})? modelPowerRange(
    String vendorName,
    String modelName,
    List<double> ratings,
  ) {
    final info = VendorModelsFromExcel.models[vendorName]
        ?.where((m) => m.name == modelName)
        .firstOrNull;
    if (info != null) {
      return (minKw: info.minKw, maxKw: info.maxKw);
    }
    if (ratings.isEmpty) return null;
    return (minKw: ratings.first, maxKw: ratings.last);
  }
}
