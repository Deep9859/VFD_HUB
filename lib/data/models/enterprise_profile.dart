import '../../core/enterprise/app_permission.dart';

class EnterpriseProfile {
  final String orgId;
  final String orgName;
  final EnterpriseRole role;
  final String? teamId;
  final String? ssoSubject;
  final bool enabled;

  const EnterpriseProfile({
    required this.orgId,
    required this.orgName,
    required this.role,
    this.teamId,
    this.ssoSubject,
    this.enabled = true,
  });

  bool can(AppPermission permission) =>
      !enabled || EnterprisePermissions.can(role, permission);

  Map<String, dynamic> toJson() => {
        'orgId': orgId,
        'orgName': orgName,
        'role': role.name,
        'teamId': teamId,
        'ssoSubject': ssoSubject,
        'enabled': enabled,
      };

  factory EnterpriseProfile.fromJson(Map<String, dynamic> json) =>
      EnterpriseProfile(
        orgId: json['orgId'] as String,
        orgName: json['orgName'] as String,
        role: EnterpriseRole.values.firstWhere(
          (r) => r.name == json['role'],
          orElse: () => EnterpriseRole.viewer,
        ),
        teamId: json['teamId'] as String?,
        ssoSubject: json['ssoSubject'] as String?,
        enabled: json['enabled'] as bool? ?? true,
      );
}
