import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  factory VFDWidgetData.fromJson(Map<String, dynamic> json) => VFDWidgetData(
        vendorName: json['vendorName'] as String,
        modelName: json['modelName'] as String,
        powerRating: json['powerRating'] as String,
        lastAccessed: DateTime.parse(json['lastAccessed'] as String),
        configName: json['configName'] as String?,
      );
}

class HomeScreenWidgetService {
  static const _channel = MethodChannel('com.vfdapp.vfd_param_app/widget');
  static const _recentKey = 'widget_recent_configs';
  static const _maxRecent = 5;

  static Future<void> saveWidgetData(VFDWidgetData data) async {
    try {
      await _channel.invokeMethod('updateWidget', data.toJson());
    } catch (_) {
      // Platform channel not available on all platforms.
    }
    await _persistRecent(data);
    LoggingService.info(
      'Widget data saved: ${data.vendorName} - ${data.modelName}',
      tag: 'WIDGET',
    );
  }

  static Future<List<VFDWidgetData>> getRecentConfigs() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_recentKey) ?? [];
    final items = <VFDWidgetData>[];
    for (final entry in raw) {
      try {
        items.add(VFDWidgetData.fromJson(
          jsonDecode(entry) as Map<String, dynamic>,
        ));
      } catch (_) {
        continue;
      }
    }
    return items;
  }

  static Future<void> _persistRecent(VFDWidgetData data) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = await getRecentConfigs();

    final updated = [
      data,
      ...existing.where(
        (e) =>
            e.vendorName != data.vendorName || e.modelName != data.modelName,
      ),
    ].take(_maxRecent).toList();

    await prefs.setStringList(
      _recentKey,
      updated.map((e) => jsonEncode(e.toJson())).toList(),
    );
  }
}
