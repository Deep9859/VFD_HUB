enum EnterpriseRole {
  admin,
  commissioningEngineer,
  viewer,
}

enum AppPermission {
  editParameters,
  runCommissioning,
  exportConfiguration,
  importConfiguration,
  manageProjects,
  platformSettings,
  adminPanel,
  manageTeam,
  manageCustomVendors,
  clearAuditLog,
}

class EnterprisePermissions {
  EnterprisePermissions._();

  static bool can(EnterpriseRole? role, AppPermission permission) {
    if (role == null) return true;
    switch (role) {
      case EnterpriseRole.admin:
        return true;
      case EnterpriseRole.commissioningEngineer:
        return permission != AppPermission.adminPanel &&
            permission != AppPermission.manageTeam &&
            permission != AppPermission.manageCustomVendors &&
            permission != AppPermission.clearAuditLog;
      case EnterpriseRole.viewer:
        return false;
    }
  }

  static String label(EnterpriseRole role) {
    switch (role) {
      case EnterpriseRole.admin:
        return 'Administrator';
      case EnterpriseRole.commissioningEngineer:
        return 'Commissioning Engineer';
      case EnterpriseRole.viewer:
        return 'Viewer';
    }
  }
}
