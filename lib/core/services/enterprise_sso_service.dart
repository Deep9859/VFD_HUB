import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/enterprise/app_permission.dart';
import '../../data/models/enterprise_profile.dart';
import 'platform_settings_service.dart';

/// SSO token exchange against enterprise backend (OIDC id_token → role).
class EnterpriseSsoService {
  EnterpriseSsoService._();

  /// Local demo invite codes when no server is configured.
  static const Map<String, EnterpriseRole> demoInviteCodes = {
    'VFDHUB-ADMIN': EnterpriseRole.admin,
    'VFDHUB-ENGINEER': EnterpriseRole.commissioningEngineer,
    'VFDHUB-VIEWER': EnterpriseRole.viewer,
  };

  static Future<({bool ok, EnterpriseProfile? profile, String message})>
      joinWithInviteCode({
    required String code,
    required String orgName,
    String? teamId,
  }) async {
    final normalized = code.trim().toUpperCase();
    final role = demoInviteCodes[normalized];

    if (role != null) {
      return (
        ok: true,
        profile: EnterpriseProfile(
          orgId: 'org_${normalized.hashCode.abs()}',
          orgName: orgName.isEmpty ? 'VFD Hub Enterprise' : orgName,
          role: role,
          teamId: teamId ?? 'team_default',
          enabled: true,
        ),
        message: 'Joined as ${EnterprisePermissions.label(role)}',
      );
    }

    final baseUrl = await PlatformSettingsService.syncUrl;
    if (baseUrl == null) {
      return (
        ok: false,
        profile: null,
        message: 'Invalid invite code. Configure server URL for SSO.',
      );
    }

    try {
      final uri = Uri.parse('${_trim(baseUrl)}/api/v1/auth/invite');
      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'code': normalized, 'orgName': orgName}),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        return (
          ok: false,
          profile: null,
          message: 'Invite rejected: HTTP ${response.statusCode}',
        );
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      return (
        ok: true,
        profile: EnterpriseProfile.fromJson(body),
        message: 'Organization joined via server',
      );
    } catch (e) {
      return (ok: false, profile: null, message: 'Invite failed: $e');
    }
  }

  static Future<({bool ok, EnterpriseProfile? profile, String message})>
      exchangeIdToken(String idToken) async {
    final baseUrl = await PlatformSettingsService.syncUrl;
    if (baseUrl == null) {
      return (
        ok: false,
        profile: null,
        message: 'Set sync server URL for SSO',
      );
    }

    try {
      final uri = Uri.parse('${_trim(baseUrl)}/api/v1/auth/sso');
      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'idToken': idToken}),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        return (
          ok: false,
          profile: null,
          message: 'SSO failed: HTTP ${response.statusCode}',
        );
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final profile = EnterpriseProfile.fromJson(body);
      return (
        ok: true,
        profile: profile.copyWithSso(idToken.substring(0, 12)),
        message: 'Signed in via SSO',
      );
    } catch (e) {
      return (ok: false, profile: null, message: 'SSO error: $e');
    }
  }

  static String _trim(String base) =>
      base.endsWith('/') ? base.substring(0, base.length - 1) : base;
}

extension on EnterpriseProfile {
  EnterpriseProfile copyWithSso(String subject) => EnterpriseProfile(
        orgId: orgId,
        orgName: orgName,
        role: role,
        teamId: teamId,
        ssoSubject: subject,
        enabled: enabled,
      );
}
