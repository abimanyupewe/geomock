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

  final mockService = MockLocationService();
  final prefs = await SharedPreferences.getInstance();

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  service.on('updateLocation').listen((event) async {
    if (event != null) {
      final double lat = event['lat'];
      final double lng = event['lng'];
      await prefs.setDouble('mock_lat', lat);
      await prefs.setDouble('mock_lng', lng);
    }
  });

  // Location update loop
  Timer.periodic(const Duration(seconds: 1), (timer) async {
    if (service is AndroidServiceInstance) {
      if (!(await service.isForegroundService())) {
        timer.cancel();
        return;
      }
    }

    await prefs.reload();
    final double? lat = prefs.getDouble('mock_lat');
    final double? lng = prefs.getDouble('mock_lng');

    if (lat != null && lng != null) {
      // Send mock location to Android system
      await mockService.startMock(lat, lng);
      
      // Update notification to show active coordinates
      if (service is AndroidServiceInstance) {
        service.setForegroundNotificationInfo(
          title: "GeoMock Pro Active",
          content: "Mocking at ${lat.toStringAsFixed(5)}, ${lng.toStringAsFixed(5)}",
        );
      }
    }
  });
}

