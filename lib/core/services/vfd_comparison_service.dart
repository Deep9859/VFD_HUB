import '../../data/database/database_helper.dart';
import '../../data/datasources/vfd_model_data.dart';
import '../../data/models/protocol_model.dart';
import '../../data/models/vfd_parameter.dart';

class ModelComparisonData {
  final String vendorName;
  final VfdModelData catalogModel;
  final List<VfdParameter> parameters;
  final List<Protocol> protocols;
  final String? sampleVoltage;
  final double? samplePowerKw;

  const ModelComparisonData({
    required this.vendorName,
    required this.catalogModel,
    required this.parameters,
    required this.protocols,
    this.sampleVoltage,
    this.samplePowerKw,
  });
}

class VfdComparisonService {
  VfdComparisonService._();

  static final _db = DatabaseHelper.instance;

  static Future<ModelComparisonData> loadDetail(
    String vendorName,
    VfdModelData catalogModel,
  ) async {
    final empty = ModelComparisonData(
      vendorName: vendorName,
      catalogModel: catalogModel,
      parameters: const [],
      protocols: const [],
    );

    try {
      final vendors = await _db.getAllVendors();
      final vendor = vendors
          .where((v) => v.name.toLowerCase() == vendorName.toLowerCase())
          .firstOrNull;
      if (vendor == null) return empty;

      final powers =
          await _db.getPowerRatingsByVendorAndName(vendor.id, catalogModel.name);
      if (powers.isEmpty) return empty;

      final power = powers.first;
      final voltages =
          await _db.getVoltagesByFilter(vendor.id, catalogModel.name, power);
      final voltage = voltages.isNotEmpty ? voltages.first : '415V';

      final model = await _db.getModelByFilter(
        vendor.id,
        catalogModel.name,
        power,
        voltage,
      );
      if (model == null) {
        return ModelComparisonData(
          vendorName: vendorName,
          catalogModel: catalogModel,
          parameters: const [],
          protocols: const [],
          samplePowerKw: power,
          sampleVoltage: voltage,
        );
      }

      final parameters = await _db.getParametersByModel(model.id);
      final protocols = await _db.getProtocolsByModel(model.id);

      return ModelComparisonData(
        vendorName: vendorName,
        catalogModel: catalogModel,
        parameters: parameters,
        protocols: protocols,
        samplePowerKw: power,
        sampleVoltage: voltage,
      );
    } catch (_) {
      return empty;
    }
  }
}
