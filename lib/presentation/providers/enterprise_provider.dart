import 'package:flutter/material.dart';

import '../../core/enterprise/app_permission.dart';
import '../../data/models/enterprise_profile.dart';
import '../../core/services/audit_log_service.dart';
import '../../data/models/audit_event.dart';
import '../../core/services/custom_vendor_service.dart';
import '../../core/services/enterprise_profile_service.dart';
import '../../core/services/enterprise_sso_service.dart';

class EnterpriseProvider extends ChangeNotifier {
  EnterpriseProfile? _profile;
  bool _loading = true;

  EnterpriseProfile? get profile => _profile;
  bool get isEnterpriseMode => _profile?.enabled == true;
  bool get isLoading => _loading;

  EnterpriseRole? get role => _profile?.role;

  bool can(AppPermission permission) {
    if (_profile == null || !_profile!.enabled) return true;
    return _profile!.can(permission);
  }

  Future<void> load() async {
    _loading = true;
    notifyListeners();
    _profile = await EnterpriseProfileService.load();
    await CustomVendorService.loadCache();
    _loading = false;
    notifyListeners();
  }

  Future<({bool ok, String message})> joinWithInviteCode({
    required String code,
    required String orgName,
    String? teamId,
  }) async {
    final result = await EnterpriseSsoService.joinWithInviteCode(
      code: code,
      orgName: orgName,
      teamId: teamId,
    );
    if (!result.ok || result.profile == null) {
      return (ok: false, message: result.message);
    }
    _profile = result.profile;
    await EnterpriseProfileService.save(_profile!);
    await AuditLogService.log(
      category: AuditCategory.system,
      action: 'Joined organization',
      detail: '${_profile!.orgName} (${_profile!.role.name})',
    );
    notifyListeners();
    return (ok: true, message: result.message);
  }

  Future<({bool ok, String message})> joinWithSsoToken(String idToken) async {
    final result = await EnterpriseSsoService.exchangeIdToken(idToken);
    if (!result.ok || result.profile == null) {
      return (ok: false, message: result.message);
    }
    _profile = result.profile;
    await EnterpriseProfileService.save(_profile!);
    await AuditLogService.log(
      category: AuditCategory.system,
      action: 'SSO sign-in',
      detail: _profile!.orgName,
    );
    notifyListeners();
    return (ok: true, message: result.message);
  }

  Future<void> leaveOrganization() async {
    await EnterpriseProfileService.clear();
    _profile = null;
    await AuditLogService.log(
      category: AuditCategory.system,
      action: 'Left organization',
      detail: 'Enterprise mode disabled',
    );
    notifyListeners();
  }

  void showDenied(BuildContext context, AppPermission permission) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Permission denied: ${permission.name} requires '
          '${role != null ? EnterprisePermissions.label(role!) : "higher"} role',
        ),
        backgroundColor: Colors.orange,
      ),
    );
  }

  bool guard(BuildContext context, AppPermission permission) {
    if (can(permission)) return true;
    showDenied(context, permission);
    return false;
  }
}
