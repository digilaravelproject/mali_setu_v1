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

      // Always fetch fresh real-time current position where the app is currently opened
      Position? position;
      try {
        position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 10),
          ),
        );
      } catch (e) {
        print("DEBUG_LOCATION: High accuracy position fetch failed ($e), trying balanced accuracy...");
        try {
          position = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.medium,
              timeLimit: Duration(seconds: 5),
            ),
          );
        } catch (e2) {
          print("DEBUG_LOCATION: Medium accuracy fallback also failed: $e2");
        }
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

