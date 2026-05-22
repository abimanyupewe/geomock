import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../service/mock_location_service.dart';

final mockLocationServiceProvider = Provider((ref) => MockLocationService());

final selectedLocationProvider = StateProvider<LatLng?>((ref) => null);

final isMockingActiveProvider = StateNotifierProvider<MockStatusNotifier, bool>((ref) {
  final service = ref.watch(mockLocationServiceProvider);
  return MockStatusNotifier(service, ref);
});

class MockStatusNotifier extends StateNotifier<bool> {
  final MockLocationService _service;
  final Ref _ref;

  MockStatusNotifier(this._service, this._ref) : super(false);

  Future<void> startMocking() async {
    final location = _ref.read(selectedLocationProvider);
    if (location == null) return;

    // Save to prefs first to ensure background service gets it
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('mock_lat', location.latitude);
    await prefs.setDouble('mock_lng', location.longitude);
    
    // Explicitly notify the background service if it's already running
    FlutterBackgroundService().invoke('updateLocation', {
      'lat': location.latitude,
      'lng': location.longitude,
    });

    final success = await _service.startMock(location.latitude, location.longitude);
    if (success) {
      state = true;
      // Start background service if not already running
      final isRunning = await FlutterBackgroundService().isRunning();
      if (!isRunning) {
        await FlutterBackgroundService().startService();
      }
    }
  }

  Future<void> stopMocking() async {
    final success = await _service.stopMock();
    if (success) {
      state = false;
      // Stop background service
      FlutterBackgroundService().invoke('stopService');
      
      // Clear prefs
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('mock_lat');
      await prefs.remove('mock_lng');
    }
  }

  Future<bool> checkPermission() async {
    return await _service.isMockEnabled();
  }
}


