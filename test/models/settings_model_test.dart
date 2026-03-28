import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';
import 'package:virtual_try_on_app/models/settings_model.dart';

// Simulate as SharedPreferences package in Flutter
class MockSharedPreferencesStorePlatform extends SharedPreferencesStorePlatform {
  @override
  bool get isMock => true;
  
  bool throwOnInitialize = false;

  @override
  Future<bool> setValue(String valueType, String key, Object value, [Map<String, Object>? options]) async {
      throw Exception('Saving error');
  }

  @override
  Future<bool> clear() async => true;

  @override
  Future<Map<String, Object>> getAll() async {
    if (throwOnInitialize) throw Exception('Initializing error');
    return {};
  }

  @override
  Future<bool> remove(String key) async => true;
}

// Test Settings
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('SettingsModel (Init)', () async {
    final settingsModel = SettingsModel();
    await settingsModel.initialize();
    expect(settingsModel.handTrackingEnabled, true);
    expect(settingsModel.testingModeEnabled, true);
    expect(settingsModel.targetFinger, 'ring');
  });

  test('SettingsModel (Hand Tracking)', () async {
    final settingsModel = SettingsModel();
    await settingsModel.initialize();
    
    await settingsModel.setHandTrackingEnabled(false);
    expect(settingsModel.handTrackingEnabled, false);
  });

  test('SettingsModel (Testing Mode)', () async {
    final settingsModel = SettingsModel();
    await settingsModel.initialize();
    
    await settingsModel.setTestingModeEnabled(false);
    expect(settingsModel.testingModeEnabled, false);
  });

  test('SettingsModel (Target Finger)', () async {
    final settingsModel = SettingsModel();
    await settingsModel.initialize();
    
    await settingsModel.setTargetFinger('index');
    expect(settingsModel.targetFinger, 'index');
  });

  test('SettingsModel (Saving Error)', () async {
    SharedPreferences.setMockInitialValues({});
    SharedPreferencesStorePlatform.instance = MockSharedPreferencesStorePlatform();
    final settingsModel = SettingsModel();
    await settingsModel.initialize();
    await settingsModel.setHandTrackingEnabled(false);
  });

  test('SettingsModel (Init Error)', () async {
    SharedPreferences.setMockInitialValues({});
    final mockPlatform = MockSharedPreferencesStorePlatform();
    mockPlatform.throwOnInitialize = true;
    SharedPreferencesStorePlatform.instance = mockPlatform;
    final model = SettingsModel();
    await model.initialize();
  });
}

