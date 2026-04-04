import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationHelper {
  /// Fetches the current location and returns a formatted address string (City, District).
  /// Handles permission requests and service availability checks.
  static Future<String> getCurrentLocation() async {
    try {
      debugPrint("📍 Starting location detection...");

      // 1. Request Permission using permission_handler (More reliable for prompting)
      var status = await Permission.location.request();
      debugPrint("📍 Location permission status: $status");

      if (status.isDenied) {
        return "Permission Denied";
      }

      if (status.isPermanentlyDenied) {
        return "Permission Denied (Settings)";
      }

      // 2. Check if location services are enabled.
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      debugPrint("📍 Location services enabled: $serviceEnabled");
      
      if (!serviceEnabled) {
        debugPrint("📍 GPS is OFF, prompting user...");
        await Geolocator.openLocationSettings();
        return "GPS is Off";
      }

      // 3. Get current position with timeout using geolocator.
      debugPrint("📍 Fetching coordinates...");
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
        timeLimit: const Duration(seconds: 10),
      );
      debugPrint("📍 Coordinates found: ${position.latitude}, ${position.longitude}");

      // 4. Reverse geocode to get human-readable address.
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemarks.isNotEmpty) {
          Placemark place = placemarks[0];
          
          // Construct city/area string
          String city = place.locality ?? place.subAdministrativeArea ?? place.administrativeArea ?? "";
          String subLocality = place.subLocality ?? "";
          
          if (city.isNotEmpty && subLocality.isNotEmpty) {
            return "$subLocality, $city";
          } else {
            return city.isNotEmpty ? city : "Location Detected";
          }
        }
      } catch (e) {
        debugPrint("📍 Reverse geocoding error: $e");
        return "Location Detected";
      }

      return "Location Detected";
    } catch (e) {
      debugPrint("📍 Location service error: $e");
      String errorMsg = e.toString();
      if (errorMsg.contains("timeout")) {
        return "Location Timeout";
      }
      // Return the specific error to help debug
      if (errorMsg.contains("MissingPluginException")) {
        return "Please Restart App (New Plugin)";
      }
      return "Location Error: ${errorMsg.length > 20 ? errorMsg.substring(0, 20) : errorMsg}";
    }
  }
}
