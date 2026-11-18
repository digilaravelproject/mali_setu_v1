import 'package:geolocator/geolocator.dart';

class LocationHelper {
  /// Returns fresh real-time {latitude, longitude} or null if permission denied / service unavailable.
  /// Always fetches current live position and does NOT use stale/stored location.
  static Future<Map<String, double>?> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print("DEBUG_LOCATION: Location service is disabled on device");
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print("DEBUG_LOCATION: Location permission denied by user");
          return null;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        print("DEBUG_LOCATION: Location permission denied forever");
        return null;
      }

      // 1. Try instant last known position first (fastest, takes <50ms)
      try {
        final lastKnown = await Geolocator.getLastKnownPosition();
        if (lastKnown != null) {
          print("DEBUG_LOCATION: Instant last known location acquired: ${lastKnown.latitude}, ${lastKnown.longitude}");
          return {
            'latitude': lastKnown.latitude,
            'longitude': lastKnown.longitude,
          };
        }
      } catch (_) {}

      // 2. Otherwise request live position with a short 3-second timeout so UI is never blocked
      Position? position;
      try {
        position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.medium,
            timeLimit: Duration(seconds: 3),
          ),
        );
      } catch (e) {
        print("DEBUG_LOCATION: Live location fetch timed out or failed ($e), proceeding without coordinates.");
      }

      if (position != null) {
        print("DEBUG_LOCATION: Live Location acquired: ${position.latitude}, ${position.longitude}");
        return {
          'latitude': position.latitude,
          'longitude': position.longitude,
        };
      }

      return null;
    } catch (e) {
      print("DEBUG_LOCATION: Error in getCurrentLocation: $e");
      return null;
    }
  }
}

