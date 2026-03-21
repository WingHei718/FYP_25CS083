import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:virtual_try_on_app/services/arcore_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const MethodChannel channel = MethodChannel('com.example/arcore');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        switch (methodCall.method) {
          case 'startARSession':
            return 'Session Started';
          case 'closeARSession':
            return 'Session Closed';
          case 'loadModel':
             if (methodCall.arguments['modelPath'] == 'error') {
               throw PlatformException(code: 'ERROR', message: 'Failed');
             }
            return null;
          case 'setFinger':
          case 'enableHandTracking':
          case 'disableHandTracking':
          case 'enableTestingMode':
          case 'disableTestingMode':
            return null;
          default:
            throw PlatformException(code: 'NotImplemented', message: 'Not Implemented');
        }
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  test('startARSession', () async {
    final service = ARCoreService();
    final result = await service.startARSession();
    expect(result, 'Session Started');
  });

  test('closeARSession', () async {
    final service = ARCoreService();
    final result = await service.closeARSession();
    expect(result, 'Session Closed');
  });

  test('loadModel', () async {
    final service = ARCoreService();
    await service.loadModel('path/to/model');
  });

  test('onPlaneDetected', () async {
    final service = ARCoreService();
    bool detected = false;
    final subscription = service.onPlaneDetected.listen((_) {detected = true;});
    
    await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.handlePlatformMessage(
      'com.example/arcore',
      const StandardMethodCodec().encodeMethodCall(const MethodCall('planeDetected')),
      (ByteData? data) {},
    );
    await Future.delayed(Duration.zero);
    expect(detected, true);
    await subscription.cancel();
  });

  // Error
  test('startARSession (Error)', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        throw Exception('Error');
      },
    );
    final service = ARCoreService();
    final result = await service.startARSession();
    expect(result, null);
  });
  
  test('closeARSession (Error)', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        throw Exception('Error');
      },
    );
    final service = ARCoreService();
    final result = await service.closeARSession();
    expect(result, null);
  });

  test('loadModel (Error)', () async {
     final service = ARCoreService();
     await service.loadModel('error');
  });

  test('setFinger', () async {
    final service = ARCoreService();
    await service.setFinger('index');
  });

  test('enableHandTracking', () async {
    final service = ARCoreService();
    await service.enableHandTracking();
  });

  test('disableHandTracking', () async {
    final service = ARCoreService();
    await service.disableHandTracking();
  });

  test('enableTestingMode', () async {
    final service = ARCoreService();
    await service.enableTestingMode();
  });

  test('disableTestingMode', () async {
    final service = ARCoreService();
    await service.disableTestingMode();
  });

  test('Other Errors', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        throw Exception('Error');
      },
    );
    final service = ARCoreService();
    await service.setFinger('index');
    await service.enableHandTracking();
    await service.disableHandTracking();
    await service.enableTestingMode();
    await service.disableTestingMode();
  });
}
