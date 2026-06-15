import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PlatformSettingsService {
  PlatformSettingsService._();

  static const _catalogUrlKey = 'platform_catalog_url';
  static const _syncUrlKey = 'platform_sync_url';
  static const _syncEnabledKey = 'platform_sync_enabled';
  static const _syncApiKeyStorage = 'platform_sync_api_key';

  static const _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static Future<String?> get catalogUrl async {
    final prefs = await SharedPreferences.getInstance();
    final v = prefs.getString(_catalogUrlKey);
    return v != null && v.trim().isNotEmpty ? v.trim() : null;
  }

  static Future<void> setCatalogUrl(String? url) async {
    final prefs = await SharedPreferences.getInstance();
    if (url == null || url.trim().isEmpty) {
      await prefs.remove(_catalogUrlKey);
    } else {
      await prefs.setString(_catalogUrlKey, url.trim());
    }
  }

  static Future<String?> get syncUrl async {
    final prefs = await SharedPreferences.getInstance();
    final v = prefs.getString(_syncUrlKey);
    return v != null && v.trim().isNotEmpty ? v.trim() : null;
  }

  static Future<void> setSyncUrl(String? url) async {
    final prefs = await SharedPreferences.getInstance();
    if (url == null || url.trim().isEmpty) {
      await prefs.remove(_syncUrlKey);
    } else {
      await prefs.setString(_syncUrlKey, url.trim());
    }
  }

  static Future<bool> get syncEnabled async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_syncEnabledKey) ?? false;
  }

  static Future<void> setSyncEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_syncEnabledKey, enabled);
  }

  static Future<String?> get syncApiKey async =>
      _secureStorage.read(key: _syncApiKeyStorage);

  static Future<void> setSyncApiKey(String? key) async {
    if (key == null || key.isEmpty) {
      await _secureStorage.delete(key: _syncApiKeyStorage);
    } else {
      await _secureStorage.write(key: _syncApiKeyStorage, value: key);
    }
  }
}
