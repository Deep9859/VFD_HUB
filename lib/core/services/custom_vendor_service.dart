import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/custom_vendor_entry.dart';
import 'audit_log_service.dart';
import '../../data/models/audit_event.dart';

class CustomVendorService {
  CustomVendorService._();

  static const _storageKey = 'custom_vendors_v1';
  static List<CustomVendorEntry> _cache = [];

  static List<CustomVendorEntry> get cached => List.unmodifiable(_cache);

  static Future<void> loadCache() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_storageKey) ?? [];
    _cache = [];
    for (final entry in raw) {
      try {
        _cache.add(CustomVendorEntry.fromJson(
          jsonDecode(entry) as Map<String, dynamic>,
        ));
      } catch (_) {
        continue;
      }
    }
  }

  static Future<List<CustomVendorEntry>> getAll() async {
    if (_cache.isEmpty) await loadCache();
    return List.unmodifiable(_cache);
  }

  static Future<List<String>> vendorNames() async {
    final all = await getAll();
    return all.map((v) => v.name).toList();
  }

  static Future<CustomVendorEntry?> getVendor(String name) async {
    final all = await getAll();
    return all
        .where((v) => v.name.toLowerCase() == name.toLowerCase())
        .firstOrNull;
  }

  static Future<void> addVendor(CustomVendorEntry vendor) async {
    final all = await getAll();
    if (all.any((v) => v.name.toLowerCase() == vendor.name.toLowerCase())) {
      throw StateError('Vendor "${vendor.name}" already exists');
    }
    _cache = [vendor, ...all];
    await _persist();
    await AuditLogService.log(
      category: AuditCategory.system,
      action: 'Custom vendor added',
      detail: vendor.name,
    );
  }

  static Future<void> addModel(String vendorName, CustomModelEntry model) async {
    final all = await getAll();
    final idx = all.indexWhere(
      (v) => v.name.toLowerCase() == vendorName.toLowerCase(),
    );
    if (idx < 0) throw StateError('Vendor not found');
    final vendor = all[idx];
    final models = [...vendor.models, model];
    _cache = List.from(all);
    _cache[idx] = CustomVendorEntry(
      name: vendor.name,
      description: vendor.description,
      models: models,
    );
    await _persist();
  }

  static Future<void> deleteVendor(String name) async {
    _cache = (await getAll())
        .where((v) => v.name.toLowerCase() != name.toLowerCase())
        .toList();
    await _persist();
  }

  static Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _storageKey,
      _cache.map((v) => jsonEncode(v.toJson())).toList(),
    );
  }
}
