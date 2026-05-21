# GeoMock Pro - Repository Instructions

## [Architecture] Architecture (MVP Standalone)
- **State Management**: Riverpod.
- **Pattern**: Feature-First (lib/features/{feature_name}/).
- **Goal**: Lean and functional location spoofer for Android.

## [Tech Stack] Tech Stack
- **Framework**: Flutter.
- **Map**: `flutter_map` (OSM).
- **Native**: Kotlin + MethodChannel for `LocationManager`.
- **Persistence**: `flutter_background_service`.

## [Constraints] Critical Constraints
- **Android Only**: Mocking logic relies on Android `testProvider`. iOS is not in scope for MVP.
- **Developer Settings**: App requires "Mock Location App" permission in Android Developer Options.
- **Service Stability**: The Foreground Service is mandatory to prevent GPS "rubberbanding" or process death.

## [Commands] Key Commands
- `flutter pub get`: Install dependencies.
- `flutter run`: Run on Android device/emulator.
- `flutter analyze`: Check for linting issues.

## [Docs] Documentation Reference
- See `docs/features/` for detailed technical specs before implementing changes.
- Refer to `docs/PRD Template_ GeoMock Pro.md` for the original product vision.
