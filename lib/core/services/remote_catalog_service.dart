import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/datasources/vfd_model_data.dart';
import 'audit_log_service.dart';
import '../../data/models/audit_event.dart';
import 'platform_settings_service.dart';

class RemoteCatalogService {
  RemoteCatalogService._();

  static const _cacheKey = 'remote_catalog_cache_v1';
  static const _cacheMetaKey = 'remote_catalog_meta_v1';

  static Map<String, List<VfdModelData>> _memoryCache = {};

  static Map<String, List<VfdModelData>> get cachedVendors =>
      Map.unmodifiable(_memoryCache);

  static Future<void> loadCacheFromDisk() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cacheKey);
    if (raw == null) return;
    try {
      _memoryCache = _parseVendorsMap(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      _memoryCache = {};
    }
  }

  static Future<({bool ok, String message})> refreshFromServer() async {
    final url = await PlatformSettingsService.catalogUrl;
    if (url == null) {
      return (ok: false, message: 'No catalog URL configured in Settings');
    }

    try {
      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 20));

      if (response.statusCode != 200) {
        return (
          ok: false,
          message: 'Server returned HTTP ${response.statusCode}',
        );
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final vendorsRaw = body['vendors'] as Map<String, dynamic>?;
      if (vendorsRaw == null) {
        return (ok: false, message: 'Invalid catalog JSON: missing vendors');
      }

      _memoryCache = _parseVendorsMap(vendorsRaw);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cacheKey, jsonEncode(vendorsRaw));
      await prefs.setString(
        _cacheMetaKey,
        jsonEncode({
          'updatedAt': DateTime.now().toIso8601String(),
          'source': url,
          'vendorCount': _memoryCache.length,
        }),
      );

      await AuditLogService.log(
        category: AuditCategory.catalog,
        action: 'Catalog updated',
        detail: '${_memoryCache.length} vendors from $url',
      );

      return (
        ok: true,
        message: 'Catalog updated (${_memoryCache.length} vendors)',
      );
    } on SocketException {
      return (ok: false, message: 'Network unreachable');
    } catch (e) {
      return (ok: false, message: 'Catalog fetch failed: $e');
    }
  }

  static Future<String?> lastUpdatedLabel() async {
    final prefs = await SharedPreferences.getInstance();
    final meta = prefs.getString(_cacheMetaKey);
    if (meta == null) return null;
    try {
      final map = jsonDecode(meta) as Map<String, dynamic>;
      return map['updatedAt'] as String?;
    } catch (_) {
      return null;
    }
  }

  static Map<String, List<VfdModelData>> _parseVendorsMap(
    Map<String, dynamic> vendorsRaw,
  ) {
    final result = <String, List<VfdModelData>>{};
    for (final entry in vendorsRaw.entries) {
      final list = entry.value as List<dynamic>;
      result[entry.key] = list.map((raw) {
        final m = raw as Map<String, dynamic>;
        return VfdModelData(
          name: m['name'] as String,
          minKw: (m['minKw'] as num).toDouble(),
          maxKw: (m['maxKw'] as num).toDouble(),
          powerRatings: (m['powerRatings'] as String?) ?? '',
          app: (m['app'] as String?) ?? 'General Purpose',
          status: (m['status'] as String?) ?? 'Current',
          commCard: (m['commCard'] as String?) ?? '',
          defaultProto: (m['defaultProto'] as String?) ?? 'Modbus RTU',
        );
      }).toList();
    }
    return result;
  }
}
