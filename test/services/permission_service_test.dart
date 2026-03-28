import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:virtual_try_on_app/services/permission_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const MethodChannel channel = MethodChannel('flutter.baseflow.com/permissions/methods');
  
  int permissionStatus = 1;

  setUp(() {
    permissionStatus = 1;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        switch (methodCall.method) {
          case 'checkPermissionStatus':
             if (permissionStatus == 0) return 0;
            return 1;
          case 'requestPermissions':
            // {Request Camera Permission: Granted}
            return {0: 1};
          case 'openAppSettings':
            return true;
          default:
            return null;
        }
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  test('checkCameraPermission (True)', () async {
    final result = await PermissionService.checkCameraPermission();
    expect(result, true);
  });

  test('checkCameraPermission (False)', () async {
    permissionStatus = 0;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
         if (methodCall.method == 'checkPermissionStatus') return permissionStatus;
         if (methodCall.method == 'requestPermissions') {
             permissionStatus = 1;
             return {0: 1};
         }
         return null;
      },
    );

    final result = await PermissionService.checkCameraPermission();
    expect(result, false);
  });

  test('openSettings', () async {
    final result = await PermissionService.openSettings();
    expect(result, true);
  });
}
