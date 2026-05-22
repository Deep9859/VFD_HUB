import 'package:flutter/services.dart';
import 'logging_service.dart';

class VFDWidgetData {
  final String vendorName;
  final String modelName;
  final String powerRating;
  final DateTime lastAccessed;
  final String? configName;

  VFDWidgetData({
    required this.vendorName,
    required this.modelName,
    required this.powerRating,
    required this.lastAccessed,
    this.configName,
  });

  Map<String, dynamic> toJson() => {
        'vendorName': vendorName,
        'modelName': modelName,
        'powerRating': powerRating,
        'lastAccessed': lastAccessed.toIso8601String(),
        'configName': configName,
      };
}

class HomeScreenWidgetService {
  static const _channel = MethodChannel('com.vfdapp.vfd_param_app/widget');

  static Future<void> saveWidgetData(VFDWidgetData data) async {
    try {
      await _channel.invokeMethod('updateWidget', data.toJson());
    } catch (_) {
      // Platform channel not available on all platforms.
    }
    LoggingService.info(
      'Widget data saved: ${data.vendorName} - ${data.modelName}',
      tag: 'WIDGET',
    );
  }
}
