# Feature 03: Interactive Map Interface (OSM)

## Overview
The map interface allows users to visualize their current location and pick a target coordinate for spoofing. We use `flutter_map` (OpenStreetMap) to avoid Google Maps API fees.

## Key Components
- **Library**: `flutter_map`, `latlong2`.
- **Tile Provider**: `https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png`.

## Functional Requirements
1. **Interactive Pin**: Users can tap anywhere on the map to drop a marker.
2. **Auto-Center**: A button to center the map on the device's real location (using `geolocator`).
3. **Coordinate Display**: A floating panel or bottom sheet showing the Lat/Lng of the selected point.
4. **Visual Feedback**: The marker changes color or icon when mocking is active (e.g., Red = Idle, Green = Mocking).

## Riverpod Integration
- UI listens to `selectedLocationProvider`.
- On Map Tap: `ref.read(selectedLocationProvider.notifier).state = tappedPoint;`.

## UI Flow
1. User pans/zooms map.
2. User taps location -> `Marker` appears.
3. User presses "Start Mocking" on the persistent bottom control panel.
4. UI reflects "Active" state.
