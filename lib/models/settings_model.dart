import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsModel extends ChangeNotifier {
  static const String _handTrackingKey = 'hand_tracking_enabled';
  static const String _testingModeKey = 'testing_mode_enabled';
  static const String _targetFingerKey = 'target_finger';

  bool _handTrackingEnabled = true;
  bool _testingModeEnabled = true;
  String _targetFinger = 'ring';

  static final SettingsModel _instance = SettingsModel._internal();
  factory SettingsModel() => _instance;
  SettingsModel._internal();

  bool get handTrackingEnabled => _handTrackingEnabled;
  bool get testingModeEnabled => _testingModeEnabled;
  String get targetFinger => _targetFinger;

  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      _handTrackingEnabled = prefs.getBool(_handTrackingKey) ?? true;
      _testingModeEnabled = prefs.getBool(_testingModeKey) ?? true;
      _targetFinger = prefs.getString(_targetFingerKey) ?? 'ring';
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing settings: $e');
    }
  }

  Future<void> setHandTrackingEnabled(bool enabled) async {
    if (_handTrackingEnabled != enabled) {
      _handTrackingEnabled = enabled;
      await _saveToPrefs(_handTrackingKey, enabled);
      notifyListeners();
    }
  }

  Future<void> setTestingModeEnabled(bool enabled) async {
    if (_testingModeEnabled != enabled) {
      _testingModeEnabled = enabled;
      await _saveToPrefs(_testingModeKey, enabled);
      notifyListeners();
    }
  }

  Future<void> setTargetFinger(String finger) async {
    if (_targetFinger != finger) {
      _targetFinger = finger;
      await _saveToPrefs(_targetFingerKey, finger);
      notifyListeners();
    }
  }

  Future<void> _saveToPrefs(String key, dynamic value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      if (value is bool) {
        await prefs.setBool(key, value);
      } else if (value is String) {
        await prefs.setString(key, value);
      }
    } catch (e) {
      debugPrint('Error saving setting $key: $e');
    }
  }
}
