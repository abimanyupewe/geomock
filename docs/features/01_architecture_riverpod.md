# Feature 01: Architecture & State Management (Riverpod)

## Overview
GeoMock Pro follows a **Feature-First Architecture** to keep the codebase modular yet simple for MVP. We use **Riverpod** for state management and Dependency Injection (DI).

## Folder Structure
```text
lib/
├── core/               # Shared utilities, constants, and global providers
│   ├── constants/
│   └── network/
├── features/           # Feature modules
│   ├── map/            # Map visualization and picking
│   │   ├── provider/   # Riverpod providers
│   │   └── ui/         # Flutter widgets/screens
│   └── mock_location/  # Core spoofing logic
│       ├── provider/
│       └── service/    # Native interface (MethodChannel)
└── main.dart
```

## State Management Pattern
- **Providers**: Used for read-only data and service injection (e.g., `mockLocationServiceProvider`).
- **StateNotifier / Notifier**: Used for mutable state (e.g., `mockStatusProvider`, `selectedLocationProvider`).
- **ConsumerWidget**: UI components will use `ref.watch()` to react to changes.

## Global States (MVP)
1. **`selectedLocationProvider`**: Holds the current `LatLng` selected on the map.
2. **`isMockingActiveProvider`**: Boolean flag indicating if the spoofer is running.
3. **`mockLocationServiceProvider`**: Provides access to the `MethodChannel` wrapper.

## Why Riverpod?
- **No BuildContext dependency**: Easy to access state from background services or deep in the widget tree.
- **Testability**: Simple to override providers for unit testing.
- **Safety**: Compile-time safety for dependencies.
