# GeoMock Pro - Agent Instructions

## [Architecture] Feature-First + Manual Riverpod
- **Structure**: Logic is partitioned by feature in `lib/features/{feature_name}/`.
- **State Management**: Uses **manual Riverpod providers** (not `riverpod_generator`). Do NOT run `build_runner`.
- **Service Layer**: Background logic resides in `lib/features/mock_location/service/background_service.dart`.

## [Native] Android Mocking Engine
- **MethodChannel**: `com.example.geomock/mock_location`.
- **Implementation**: Managed in `MainActivity.kt` using Android's `LocationManager.addTestProvider`.
- **Constraint**: **Android only**. iOS is NOT supported due to reliance on Android's `testProvider` API.
- **Requirement**: The app must be selected as the "Mock Location App" in Android Developer Options.

## [Tech Stack] Core Libraries
- **Maps**: `flutter_map` (OSM) with `latlong2`.
- **Background**: `flutter_background_service` (mandatory to prevent "rubberbanding").
- **Location**: `geolocator` for reading real position; `permission_handler` for GPS permissions.

## [Verification] Essential Commands
- `flutter pub get`: Fetch dependencies.
- `flutter analyze`: Primary lint/type check (adhere to `analysis_options.yaml`).
- `flutter run`: Deploy to Android (emulator/device).
- `flutter test`: Run widget/unit tests (verify `test/` directory).

## [Investigation] Entrypoints
- **App Entry**: `lib/main.dart` initializes background services and Riverpod.
- **Mock Logic**: `lib/features/mock_location/provider/mock_location_provider.dart` bridges UI to Native.
- **Background Entry**: `initializeService()` in `background_service.dart`.
