import 'package:flutter_test/flutter_test.dart';
import 'package:vfd_param_app/core/enterprise/app_permission.dart';

void main() {
  group('EnterprisePermissions', () {
    test('null role grants all (personal mode)', () {
      expect(EnterprisePermissions.can(null, AppPermission.adminPanel), isTrue);
    });

    test('viewer denied write permissions', () {
      expect(
        EnterprisePermissions.can(
          EnterpriseRole.viewer,
          AppPermission.editParameters,
        ),
        isFalse,
      );
    });

    test('engineer can commission but not admin', () {
      expect(
        EnterprisePermissions.can(
          EnterpriseRole.commissioningEngineer,
          AppPermission.runCommissioning,
        ),
        isTrue,
      );
      expect(
        EnterprisePermissions.can(
          EnterpriseRole.commissioningEngineer,
          AppPermission.adminPanel,
        ),
        isFalse,
      );
    });

    test('admin has full access', () {
      for (final p in AppPermission.values) {
        expect(EnterprisePermissions.can(EnterpriseRole.admin, p), isTrue);
      }
    });
  });
}
