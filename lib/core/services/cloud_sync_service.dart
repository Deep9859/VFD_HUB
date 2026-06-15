import 'dart:convert';

import 'package:http/http.dart' as http;

import 'audit_log_service.dart';
import '../../data/models/audit_event.dart';
import 'backup_service.dart';
import 'platform_settings_service.dart';

class CloudSyncService {
  CloudSyncService._();

  static Future<({bool ok, String message})> uploadBackup() async {
    if (!await PlatformSettingsService.syncEnabled) {
      return (ok: false, message: 'Cloud sync is disabled in Settings');
    }

    final baseUrl = await PlatformSettingsService.syncUrl;
    final apiKey = await PlatformSettingsService.syncApiKey;
    if (baseUrl == null) {
      return (ok: false, message: 'No sync server URL configured');
    }

    try {
      final backup = await BackupService.createBackup();
      final uri = Uri.parse(_join(baseUrl, '/api/v1/backup'));
      final response = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              if (apiKey != null && apiKey.isNotEmpty)
                'Authorization': 'Bearer $apiKey',
            },
            body: jsonEncode({
              'schemaVersion': BackupService.schemaVersion,
              'payload': backup,
              'deviceTime': DateTime.now().toIso8601String(),
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        await AuditLogService.log(
          category: AuditCategory.sync,
          action: 'Cloud upload',
          detail: 'Backup uploaded to $baseUrl',
        );
        return (ok: true, message: 'Backup uploaded successfully');
      }
      return (
        ok: false,
        message: 'Upload failed: HTTP ${response.statusCode}',
      );
    } catch (e) {
      return (ok: false, message: 'Upload failed: $e');
    }
  }

  static Future<({bool ok, String message})> downloadBackup() async {
    if (!await PlatformSettingsService.syncEnabled) {
      return (ok: false, message: 'Cloud sync is disabled in Settings');
    }

    final baseUrl = await PlatformSettingsService.syncUrl;
    final apiKey = await PlatformSettingsService.syncApiKey;
    if (baseUrl == null) {
      return (ok: false, message: 'No sync server URL configured');
    }

    try {
      final uri = Uri.parse(_join(baseUrl, '/api/v1/backup'));
      final response = await http
          .get(
            uri,
            headers: {
              if (apiKey != null && apiKey.isNotEmpty)
                'Authorization': 'Bearer $apiKey',
            },
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        return (
          ok: false,
          message: 'Download failed: HTTP ${response.statusCode}',
        );
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final payload = body['payload'] as Map<String, dynamic>? ?? body;
      final error = await BackupService.restoreFromMap(payload);
      if (error != null) return (ok: false, message: error);

      await AuditLogService.log(
        category: AuditCategory.sync,
        action: 'Cloud download',
        detail: 'Backup restored from $baseUrl',
      );
      return (ok: true, message: 'Backup restored from cloud');
    } catch (e) {
      return (ok: false, message: 'Download failed: $e');
    }
  }

  static Future<({bool ok, String message})> testConnection() async {
    final baseUrl = await PlatformSettingsService.syncUrl;
    if (baseUrl == null) {
      return (ok: false, message: 'No sync server URL configured');
    }
    try {
      final uri = Uri.parse(_join(baseUrl, '/api/v1/health'));
      final apiKey = await PlatformSettingsService.syncApiKey;
      final response = await http
          .get(
            uri,
            headers: {
              if (apiKey != null && apiKey.isNotEmpty)
                'Authorization': 'Bearer $apiKey',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return (ok: true, message: 'Server reachable');
      }
      return (
        ok: false,
        message: 'Health check HTTP ${response.statusCode}',
      );
    } catch (e) {
      return (ok: false, message: 'Connection failed: $e');
    }
  }

  static String _join(String base, String path) {
    if (base.endsWith('/')) base = base.substring(0, base.length - 1);
    return '$base$path';
  }
}
