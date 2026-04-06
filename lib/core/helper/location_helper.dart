import 'package:geolocator/geolocator.dart';

class LocationHelper {
  /// Returns {latitude, longitude} or null if permission denied / unavailable
  static Future<Map<String, double>?> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return null;
      }
      if (permission == LocationPermission.deniedForever) return null;

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      return {
        'latitude': position.latitude,
        'longitude': position.longitude,
      };
    } catch (_) {
      return null;
    }
  }
}
