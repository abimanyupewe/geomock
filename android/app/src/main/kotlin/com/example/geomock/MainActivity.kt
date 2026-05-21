package com.example.geomock

import android.content.Context
import android.location.Location
import android.location.LocationManager
import android.os.Build
import android.os.SystemClock
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.geomock/mock_location"
    private var locationManager: LocationManager? = null
    private val PROVIDER_NAME = LocationManager.GPS_PROVIDER

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        locationManager = getSystemService(Context.LOCATION_SERVICE) as LocationManager

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "isMockEnabled" -> {
                    result.success(isMockLocationEnabled())
                }
                "startMock" -> {
                    val lat = call.argument<Double>("lat")
                    val lng = call.argument<Double>("lng")
                    if (lat != null && lng != null) {
                        val success = startMockLocation(lat, lng)
                        if (success) result.success(true) else result.error("ERROR", "Could not start mock", null)
                    } else {
                        result.error("INVALID_ARGS", "Latitude or longitude is null", null)
                    }
                }
                "stopMock" -> {
                    stopMockLocation()
                    result.success(true)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun isMockLocationEnabled(): Boolean {
        return try {
            Settings.Secure.getString(contentResolver, Settings.Secure.ALLOW_MOCK_LOCATION) != "0"
        } catch (e: Exception) {
            false
        }
    }

    private fun startMockLocation(lat: Double, lng: Double): Boolean {
        return try {
            // Check if provider already exists, if not add it
            try {
                locationManager?.addTestProvider(
                    PROVIDER_NAME,
                    false, false, false, false, true, true, true,
                    1, 1
                )
            } catch (e: Exception) {
                // Already added or failed
            }
            
            locationManager?.setTestProviderEnabled(PROVIDER_NAME, true)

            val mockLocation = Location(PROVIDER_NAME)
            mockLocation.latitude = lat
            mockLocation.longitude = lng
            mockLocation.altitude = 0.0
            mockLocation.time = System.currentTimeMillis()
            mockLocation.accuracy = 1.0f
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR1) {
                mockLocation.elapsedRealtimeNanos = SystemClock.elapsedRealtimeNanos()
            }

            locationManager?.setTestProviderLocation(PROVIDER_NAME, mockLocation)
            true
        } catch (e: SecurityException) {
            false
        } catch (e: Exception) {
            false
        }
    }

    private fun stopMockLocation() {
        try {
            locationManager?.removeTestProvider(PROVIDER_NAME)
        } catch (e: Exception) {
            // Provider might not exist
        }
    }
}

