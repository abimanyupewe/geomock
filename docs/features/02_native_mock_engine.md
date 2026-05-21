# Feature 02: Native Mock Engine (Android)

## Overview
Since Flutter cannot directly access Android's `LocationManager.addTestProvider` API, we use a `MethodChannel` to communicate with the native Kotlin layer.

## MethodChannel Definition
- **Channel Name**: `com.example.geomock/mock_location`
- **Methods**:
    - `startMock(Map<String, double> params)`: Expects `lat` and `lng`.
    - `stopMock()`: Stops the injection and removes the test provider.
    - `isMockEnabled()`: Checks if the app is set as the Mock Location app in Developer Settings.

## Android Implementation (Kotlin)
The `MainActivity.kt` or a dedicated `MockLocationPlugin.kt` will handle:
1. **Permission Check**: Ensure `ACCESS_FINE_LOCATION` is granted.
2. **Provider Setup**: 
    - `locationManager.addTestProvider(providerName, ...)`
    - `locationManager.setTestProviderEnabled(providerName, true)`
3. **Injection Loop**:
    - Periodically (or once) creating a `Location` object with the target coordinates.
    - Calling `locationManager.setTestProviderLocation(providerName, mockLocation)`.

## Permissions (AndroidManifest.xml)
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_MOCK_LOCATION" tools:ignore="MockLocation" />
```

## Challenges & Solutions
- **Rubberbanding**: If the real GPS competes with the mock, we must ensure the `LocationManager` is strictly controlled by our provider.
- **Developer Options**: The app must guide the user to enable "Select mock location app" if not already set.
