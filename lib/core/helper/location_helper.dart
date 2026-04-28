import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationHelper {
  static const String _latKey = 'last_latitude';
  static const String _lngKey = 'last_longitude';

  /// Returns {latitude, longitude} or null if permission denied / unavailable
  static Future<Map<String, double>?> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return await _getLastStoredLocation();

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return await _getLastStoredLocation();
      }
      if (permission == LocationPermission.deniedForever) return await _getLastStoredLocation();

      // Try to get last known position first for instant result
      Position? position = await Geolocator.getLastKnownPosition();
      
      // If last known is null, fetch fresh one with a short timeout
      if (position == null) {
        try {
          position = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.low,
              timeLimit: Duration(seconds: 5),
            ),
          );
        } catch (e) {
          print("DEBUG_LOCATION: Fresh location fetch failed: $e");
        }
      }

      if (position != null) {
        final location = {
          'latitude': position.latitude,
          'longitude': position.longitude,
        };
        // Save to persistent storage for future use if GPS fails
        await _saveLocation(position.latitude, position.longitude);
        return location;
      }

      // Fallback to stored location if everything else fails
      return await _getLastStoredLocation();
    } catch (e) {
      print("DEBUG_LOCATION: Error in getCurrentLocation: $e");
      return await _getLastStoredLocation();
    }
  }

  static Future<void> _saveLocation(double lat, double lng) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_latKey, lat);
      await prefs.setDouble(_lngKey, lng);
    } catch (_) {}
  }

  static Future<Map<String, double>?> _getLastStoredLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lat = prefs.getDouble(_latKey);
      final lng = prefs.getDouble(_lngKey);
      if (lat != null && lng != null) {
        print("DEBUG_LOCATION: Using last stored location: $lat, $lng");
        return {'latitude': lat, 'longitude': lng};
      }
    } catch (_) {}
    return null;
  }
}
