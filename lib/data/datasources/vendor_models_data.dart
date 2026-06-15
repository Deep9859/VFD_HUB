import 'vendor_models_from_excel.dart';

export 'vendor_models_from_excel.dart' show VfdModelInfo;

/// Model catalog for DB seeding — from VFD Master Excel (9 vendors).
class VendorModelsData {
  VendorModelsData._();

  static Map<String, List<VfdModelInfo>> get models =>
      VendorModelsFromExcel.models;

  static const List<String> defaultManualTypes = [
    'User Manual',
    'Quick Start Guide',
    'Parameter Guide',
    'Installation Guide',
    'Troubleshooting Guide',
  ];
}
