import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class MockLocationService {
  static const _channel = MethodChannel('com.example.geomock/mock_location');

  Future<bool> isMockEnabled() async {
    try {
      final bool? result = await _channel.invokeMethod('isMockEnabled');
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint("Failed to check mock status: '${e.message}'.");
      return false;
    }
  }

  Future<bool> startMock(double lat, double lng) async {
    try {
      final bool? result = await _channel.invokeMethod('startMock', {
        'lat': lat,
        'lng': lng,
      });
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint("Failed to start mock: '${e.message}'.");
      return false;
    }
  }

  Future<bool> stopMock() async {
    try {
      final bool? result = await _channel.invokeMethod('stopMock');
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint("Failed to stop mock: '${e.message}'.");
      return false;
    }
  }
}
