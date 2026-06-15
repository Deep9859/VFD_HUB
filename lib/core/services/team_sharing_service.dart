import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/team_member.dart';
import 'audit_log_service.dart';
import '../../data/models/audit_event.dart';
import 'platform_settings_service.dart';

class TeamSharingService {
  TeamSharingService._();

  static const _membersKey = 'team_members_v1';
  static const _projectsKey = 'team_projects_v1';
  static final _random = Random();

  static String _newId() =>
      'team_${DateTime.now().millisecondsSinceEpoch}_${_random.nextInt(99999)}';

  static Future<List<TeamMember>> getMembers() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_membersKey) ?? [];
    return raw
        .map((e) => TeamMember.fromJson(jsonDecode(e) as Map<String, dynamic>))
        .toList();
  }

  static Future<void> addMember(TeamMember member) async {
    final members = await getMembers();
    members.removeWhere(
      (m) => m.email.toLowerCase() == member.email.toLowerCase(),
    );
    members.insert(0, member);
    await _saveMembers(members);
  }

  static Future<void> removeMember(String email) async {
    final members = await getMembers()
      ..removeWhere((m) => m.email.toLowerCase() == email.toLowerCase());
    await _saveMembers(members);
  }

  static Future<void> _saveMembers(List<TeamMember> members) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _membersKey,
      members.map((m) => jsonEncode(m.toJson())).toList(),
    );
  }

  static Future<List<SharedTeamProject>> getSharedProjects() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_projectsKey) ?? [];
    return raw
        .map((e) =>
            SharedTeamProject.fromJson(jsonDecode(e) as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.sharedAt.compareTo(a.sharedAt));
  }

  static Future<SharedTeamProject> shareProjectLocally({
    required String teamId,
    required String sharedBy,
    required String projectName,
    required Map<String, dynamic> configuration,
  }) async {
    final project = SharedTeamProject(
      id: _newId(),
      teamId: teamId,
      sharedBy: sharedBy,
      projectName: projectName,
      configuration: configuration,
      sharedAt: DateTime.now(),
    );
    final projects = await getSharedProjects();
    projects.insert(0, project);
    await _saveProjects(projects);

    await AuditLogService.log(
      category: AuditCategory.project,
      action: 'Shared to team',
      detail: projectName,
    );

    return project;
  }

  static Future<({bool ok, String message})> pushToServer(
    SharedTeamProject project,
  ) async {
    final baseUrl = await PlatformSettingsService.syncUrl;
    if (baseUrl == null) {
      return (ok: false, message: 'Configure sync server URL in Settings');
    }
    final apiKey = await PlatformSettingsService.syncApiKey;
    try {
      final uri = Uri.parse(
        '${_trim(baseUrl)}/api/v1/team/${project.teamId}/projects',
      );
      final response = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              if (apiKey != null && apiKey.isNotEmpty)
                'Authorization': 'Bearer $apiKey',
            },
            body: jsonEncode(project.toJson()),
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return (ok: true, message: 'Project pushed to team workspace');
      }
      return (ok: false, message: 'Push failed: HTTP ${response.statusCode}');
    } catch (e) {
      return (ok: false, message: 'Push failed: $e');
    }
  }

  static Future<({bool ok, String message, int count})> pullFromServer(
    String teamId,
  ) async {
    final baseUrl = await PlatformSettingsService.syncUrl;
    if (baseUrl == null) {
      return (ok: false, message: 'Configure sync server URL', count: 0);
    }
    final apiKey = await PlatformSettingsService.syncApiKey;
    try {
      final uri = Uri.parse(
        '${_trim(baseUrl)}/api/v1/team/$teamId/projects',
      );
      final response = await http
          .get(
            uri,
            headers: {
              if (apiKey != null && apiKey.isNotEmpty)
                'Authorization': 'Bearer $apiKey',
            },
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode != 200) {
        return (
          ok: false,
          message: 'Pull failed: HTTP ${response.statusCode}',
          count: 0,
        );
      }

      final list = jsonDecode(response.body) as List<dynamic>;
      final remote = list
          .map((e) =>
              SharedTeamProject.fromJson(e as Map<String, dynamic>))
          .toList();

      final local = await getSharedProjects();
      final merged = <String, SharedTeamProject>{
        for (final p in local) p.id: p,
        for (final p in remote) p.id: p,
      };
      await _saveProjects(merged.values.toList());

      return (
        ok: true,
        message: 'Pulled ${remote.length} team projects',
        count: remote.length,
      );
    } catch (e) {
      return (ok: false, message: 'Pull failed: $e', count: 0);
    }
  }

  static Future<void> _saveProjects(List<SharedTeamProject> projects) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _projectsKey,
      projects.map((p) => jsonEncode(p.toJson())).toList(),
    );
  }

  static String _trim(String base) =>
      base.endsWith('/') ? base.substring(0, base.length - 1) : base;
}
