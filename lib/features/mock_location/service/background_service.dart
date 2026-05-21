import 'dart:async';
import 'dart:ui';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'mock_location_service.dart';

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: false,
      isForegroundMode: true,
      notificationChannelId: 'my_foreground',
      initialNotificationTitle: 'GeoMock Pro',
      initialNotificationContent: 'Mocking location is active',
      foregroundServiceNotificationId: 888,
      foregroundServiceTypes: [AndroidForegroundType.location],
    ),
    iosConfiguration: IosConfiguration(
      autoStart: false,
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
  );
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  return true;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  final mockService = MockLocationService();
  final prefs = await SharedPreferences.getInstance();
  
  Timer.periodic(const Duration(seconds: 2), (timer) async {
    // Reload prefs to get latest target
    await prefs.reload();
    final double? lat = prefs.getDouble('mock_lat');
    final double? lng = prefs.getDouble('mock_lng');

    if (lat != null && lng != null) {
      await mockService.startMock(lat, lng);
    }
  });
}

