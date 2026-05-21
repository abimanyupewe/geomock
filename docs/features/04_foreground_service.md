# Feature 04: Foreground Service Persistence

## Overview
Android's battery optimization often kills background processes. To ensure location spoofing continues while the app is minimized, we must run a **Foreground Service**.

## Implementation
- **Library**: `flutter_background_service`.
- **Purpose**: Keep the Dart VM and the Kotlin `MethodChannel` connection alive.

## Mechanism
1. **Initiation**: When "Start Mocking" is pressed, the foreground service is started.
2. **Persistent Notification**:
    - Displays "GeoMock Pro is active".
    - Icon: Small app icon in the status bar.
    - Action: A "Stop" button directly in the notification to kill the service and stop mocking immediately.
3. **Communication**: The Service communicates with the UI via `service.invoke('update', data)` or a stream.

## Lifecycle
- **App Open**: Service and UI are in sync.
- **App Minimized**: Service continues the `MethodChannel` injection logic.
- **Service Killed**: The test provider must be removed to restore real GPS functionality to the device.

## Configuration
The service will be configured in `main.dart` before `runApp()` to allow it to initialize correctly in a separate isolate if necessary.
