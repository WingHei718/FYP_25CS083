import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'dart:async';

class ARCoreService {
  static final ARCoreService _instance = ARCoreService._internal();
  static const MethodChannel _ARCorechannel = MethodChannel('com.example/arcore');

  factory ARCoreService() => _instance;

  final StreamController<void> _planeDetectedController = StreamController<void>.broadcast();
  Stream<void> get onPlaneDetected => _planeDetectedController.stream;

  ARCoreService._internal() {
    _ARCorechannel.setMethodCallHandler((call) async {
      if (call.method == 'planeDetected') {
        _planeDetectedController.add(null);
      }
    });
  }

  Future<String?> startARSession() async {
    try {
      final String? result = await _ARCorechannel.invokeMethod('startARSession');
      return result;
    } catch (e) {
      print('Error starting AR session: $e');
      return null;
    }
  }

  Future<String?> closeARSession() async {
    try {
      final String? result = await _ARCorechannel.invokeMethod('closeARSession');
      return result;
    } catch (e) {
      print('Error closing AR session: $e');
      return null;
    }
  }

  Future<void> loadModel(String modelPath) async {
    try {
      await _ARCorechannel.invokeMethod('loadModel', {
        'modelPath': modelPath,
      });
    } catch (e) {
      print('Error loading model: $e');
    }
  }

  Future<void> setFinger(String finger) async {
    try {
      await _ARCorechannel.invokeMethod('setFinger', {
        'finger': finger,
      });
    } catch (e) {
      print('Error setting finger: $e');
    }
  }

  Future<void> enableHandTracking() async {
    try {
      await _ARCorechannel.invokeMethod('enableHandTracking');
    } catch (e) {
      print('Error enabling hand tracking: $e');
    }
  }

  Future<void> disableHandTracking() async {
    try {
      await _ARCorechannel.invokeMethod('disableHandTracking');
      await _ARCorechannel.invokeMethod('clearPoints');
    } catch (e) {
      print('Error disabling hand tracking: $e');
    }
  }

  Future<void> enableTestingMode() async {
    try {
      await _ARCorechannel.invokeMethod('enableTestingMode');
    } catch (e) {
      print('Error enabling testing mode: $e');
    }
  }

  Future<void> disableTestingMode() async {
    try {
      await _ARCorechannel.invokeMethod('disableTestingMode');
    } catch (e) {
      print('Error disabling testing mode: $e');
    }
  }

  @visibleForTesting
  void simulatePlaneDetected() {
    _planeDetectedController.add(null);
  }
}