import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/models/saved_project.dart';
import 'saved_project_service.dart';
import 'widget_service.dart';

class BackupService {
  BackupService._();

  static const schemaVersion = 1;

  static Future<Map<String, dynamic>> createBackup() async {
    final projects = await SavedProjectService.getAll();
    final recent = await HomeScreenWidgetService.getRecentConfigs();
    return {
      'schemaVersion': schemaVersion,
      'exportedAt': DateTime.now().toIso8601String(),
      'app': 'VFD Hub',
      'savedProjects': projects.map((p) => p.toJson()).toList(),
      'recentConfigs': recent.map((r) => r.toJson()).toList(),
    };
  }

  static Future<bool> shareBackup() async {
    final backup = await createBackup();
    final json = const JsonEncoder.withIndent('  ').convert(backup);
    await Share.shareXFiles(
      [
        XFile.fromData(
          utf8.encode(json),
          name:
              'vfd_hub_backup_${DateTime.now().toIso8601String().substring(0, 10)}.json',
          mimeType: 'application/json',
        ),
      ],
      subject: 'VFD Hub full backup',
    );
    return true;
  }

  static Future<String?> restoreFromFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      if (result == null || result.files.single.bytes == null) return null;
      final text = utf8.decode(result.files.single.bytes!);
      final data = jsonDecode(text) as Map<String, dynamic>;
      return restoreFromMap(data);
    } catch (e) {
      return 'Invalid backup file: $e';
    }
  }

  static Future<String?> restoreFromMap(Map<String, dynamic> data) async {
    final version = data['schemaVersion'] as int?;
    if (version == null || version > schemaVersion) {
      return 'Unsupported backup version';
    }

    final projectList = data['savedProjects'] as List<dynamic>?;
    if (projectList != null) {
      final projects = projectList
          .map((e) => SavedProject.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
      await SavedProjectService.replaceAll(projects);
    }

    final recentList = data['recentConfigs'] as List<dynamic>?;
    if (recentList != null) {
      await HomeScreenWidgetService.restoreRecentConfigs(
        recentList
            .map((e) => VFDWidgetData.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
      );
    }

    return null;
  }
}
