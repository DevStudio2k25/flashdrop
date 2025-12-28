import 'package:flutter_test/flutter_test.dart';
import 'package:flashdrop/core/services/permission_service.dart';

void main() {
  group('PermissionService', () {
    late PermissionService permissionService;

    setUp(() {
      permissionService = PermissionService();
    });

    test('requestAllPermissions returns map of permissions', () async {
      final permissions = await permissionService.requestAllPermissions();

      expect(permissions, isA<Map<String, bool>>());
      expect(permissions.containsKey('storage'), true);
      expect(permissions.containsKey('camera'), true);
      expect(permissions.containsKey('notification'), true);
    });

    test('checkAllPermissions returns map of permission statuses', () async {
      final permissions = await permissionService.checkAllPermissions();

      expect(permissions, isA<Map<String, bool>>());
      expect(permissions.containsKey('storage'), true);
      expect(permissions.containsKey('camera'), true);
      expect(permissions.containsKey('notification'), true);
    });
  });
}
