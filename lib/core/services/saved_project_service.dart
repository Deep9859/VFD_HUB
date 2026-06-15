import 'dart:convert';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/saved_project.dart';
import '../../core/services/audit_log_service.dart';
import '../../data/models/audit_event.dart';

class SavedProjectService {
  SavedProjectService._();

  static const _storageKey = 'saved_vfd_projects_v1';
  static final _random = Random();

  static String _newId() =>
      'proj_${DateTime.now().millisecondsSinceEpoch}_${_random.nextInt(999999)}';

  static Future<List<SavedProject>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_storageKey) ?? [];
    final projects = <SavedProject>[];
    for (final entry in raw) {
      try {
        projects.add(SavedProject.fromJson(
          jsonDecode(entry) as Map<String, dynamic>,
        ));
      } catch (_) {
        continue;
      }
    }
    projects.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return projects;
  }

  static Future<SavedProject> save({
    required String name,
    required Map<String, dynamic> configuration,
    String? existingId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final projects = await getAll();
    final now = DateTime.now();

    if (existingId != null) {
      final idx = projects.indexWhere((p) => p.id == existingId);
      if (idx >= 0) {
        projects[idx] = projects[idx].copyWith(
          name: name,
          configuration: configuration,
          updatedAt: now,
        );
        await _persist(prefs, projects);
        return projects[idx];
      }
    }

    final project = SavedProject(
      id: _newId(),
      name: name,
      configuration: configuration,
      createdAt: now,
      updatedAt: now,
    );
    projects.insert(0, project);
    await _persist(prefs, projects);
    await AuditLogService.log(
      category: AuditCategory.project,
      action: 'Project saved',
      detail: name,
    );
    return project;
  }

  static Future<void> delete(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final projects = await getAll()..removeWhere((p) => p.id == id);
    await _persist(prefs, projects);
  }

  static Future<void> replaceAll(List<SavedProject> projects) async {
    final prefs = await SharedPreferences.getInstance();
    await _persist(prefs, projects);
  }

  static Future<void> _persist(
    SharedPreferences prefs,
    List<SavedProject> projects,
  ) async {
    await prefs.setStringList(
      _storageKey,
      projects.map((p) => jsonEncode(p.toJson())).toList(),
    );
  }
}
