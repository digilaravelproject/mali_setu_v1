import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class PlaceSuggestion {
  final String placeId;
  final String fullText;
  final String mainText;
  final String secondaryText;

  PlaceSuggestion({
    required this.placeId,
    required this.fullText,
    required this.mainText,
    required this.secondaryText,
  });

  factory PlaceSuggestion.fromJson(Map<String, dynamic> json) {
    final prediction = json['placePrediction'] ?? {};
    final placeId = prediction['placeId']?.toString() ?? '';
    final fullText = prediction['text']?['text']?.toString() ?? '';
    final structured = prediction['structuredFormat'];
    final mainText = structured?['mainText']?['text']?.toString() ?? fullText;
    final secondaryText = structured?['secondaryText']?['text']?.toString() ?? '';

    return PlaceSuggestion(
      placeId: placeId,
      fullText: fullText,
      mainText: mainText,
      secondaryText: secondaryText,
    );
  }
}

class PlaceDetails {
  final String placeId;
  final double latitude;
  final double longitude;
  final String formattedAddress;
  final String displayName;
  final String postalCode;
  final String city;
  final String state;
  final String district;
  final String taluka;
  final String village;
  final String country;

  PlaceDetails({
    required this.placeId,
    required this.latitude,
    required this.longitude,
    required this.formattedAddress,
    required this.displayName,
    required this.postalCode,
    required this.city,
    required this.state,
    required this.district,
    required this.taluka,
    required this.village,
    required this.country,
  });

  factory PlaceDetails.fromJson(Map<String, dynamic> json) {
    final location = json['location'] as Map<String, dynamic>? ?? {};
    final double lat = (location['latitude'] as num?)?.toDouble() ?? 0.0;
    final double lng = (location['longitude'] as num?)?.toDouble() ?? 0.0;
    final String formattedAddress = json['formattedAddress']?.toString() ?? '';
    final String displayName = json['displayName']?['text']?.toString() ?? '';

    String postalCode = '';
    String locality = '';
    String adminAreaLevel1 = ''; // State
    String adminAreaLevel2 = ''; // District / Division
    String adminAreaLevel3 = ''; // City / Subdistrict
    String sublocalityLevel1 = ''; // Area / Taluka
    String sublocalityLevel2 = ''; // Village / Locality
    String country = 'India';

    final components = json['addressComponents'] as List<dynamic>? ?? [];
    for (final item in components) {
      if (item is! Map<String, dynamic>) continue;
      final types = (item['types'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList();
      final longText = item['longText']?.toString() ?? '';

      if (types.contains('postal_code')) {
        postalCode = longText;
      } else if (types.contains('locality')) {
        locality = longText;
      } else if (types.contains('administrative_area_level_1')) {
        adminAreaLevel1 = longText;
      } else if (types.contains('administrative_area_level_2')) {
        adminAreaLevel2 = longText;
      } else if (types.contains('administrative_area_level_3')) {
        adminAreaLevel3 = longText;
      } else if (types.contains('sublocality_level_1')) {
        sublocalityLevel1 = longText;
      } else if (types.contains('sublocality_level_2') || types.contains('neighborhood')) {
        sublocalityLevel2 = longText;
      } else if (types.contains('country')) {
        country = longText.isNotEmpty ? longText : 'India';
      }
    }

    // Fallback: extract 6-digit pin code from formatted address if not found in components
    if (postalCode.isEmpty) {
      final pinMatch = RegExp(r'\b[1-9][0-9]{5}\b').firstMatch(formattedAddress);
      if (pinMatch != null) {
        postalCode = pinMatch.group(0) ?? '';
      }
    }

    // District cleanup: remove " Division" suffix if present
    String cleanDistrict = adminAreaLevel2;
    if (cleanDistrict.endsWith(' Division')) {
      cleanDistrict = cleanDistrict.replaceAll(' Division', '').trim();
    }
    if (cleanDistrict.isEmpty && adminAreaLevel3.isNotEmpty) {
      cleanDistrict = adminAreaLevel3;
    }

    // City determination
    String city = locality;
    if (city.isEmpty) {
      city = adminAreaLevel3.isNotEmpty ? adminAreaLevel3 : cleanDistrict;
    }

    // Taluka determination
    String taluka = sublocalityLevel1;
    if (taluka.isEmpty && adminAreaLevel3.isNotEmpty && adminAreaLevel3 != city) {
      taluka = adminAreaLevel3;
    }

    // Village determination
    String village = sublocalityLevel2;
    if (village.isEmpty && sublocalityLevel1.isNotEmpty && sublocalityLevel1 != taluka) {
      village = sublocalityLevel1;
    }

    return PlaceDetails(
      placeId: json['id']?.toString() ?? '',
      latitude: lat,
      longitude: lng,
      formattedAddress: formattedAddress,
      displayName: displayName,
      postalCode: postalCode,
      city: city,
      state: adminAreaLevel1,
      district: cleanDistrict,
      taluka: taluka,
      village: village,
      country: country,
    );
  }
}

class GooglePlacesService {
  static const String apiKey = 'AIzaSyBpMpg4D_qO3FMx0S5JIu7OctoxOOYYOXs';
  static final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 8),
    receiveTimeout: const Duration(seconds: 8),
  ));

  /// Fetch autocomplete suggestions from Google Places API (New)
  static Future<List<PlaceSuggestion>> getAutocompleteSuggestions(String input) async {
    final query = input.trim();
    if (query.length < 2) return [];

    try {
      final response = await _dio.post(
        'https://places.googleapis.com/v1/places:autocomplete',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'X-Goog-Api-Key': apiKey,
          },
        ),
        data: {
          'input': query,
          'includedRegionCodes': ['in'],
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final suggestionsJson = response.data['suggestions'] as List<dynamic>? ?? [];
        return suggestionsJson
            .whereType<Map<String, dynamic>>()
            .map((e) => PlaceSuggestion.fromJson(e))
            .where((s) => s.placeId.isNotEmpty)
            .toList();
      }
    } catch (e) {
      debugPrint('[GooglePlacesService] Autocomplete error: $e');
    }
    return [];
  }

  /// Fetch full place details (lat, lng, address components) from Google Places API (New)
  static Future<PlaceDetails?> getPlaceDetails(String placeId) async {
    if (placeId.isEmpty) return null;

    try {
      final response = await _dio.get(
        'https://places.googleapis.com/v1/places/$placeId',
        options: Options(
          headers: {
            'X-Goog-Api-Key': apiKey,
            'X-Goog-FieldMask': 'id,displayName,formattedAddress,addressComponents,location',
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        return PlaceDetails.fromJson(response.data as Map<String, dynamic>);
      }
    } catch (e) {
      debugPrint('[GooglePlacesService] Place details error: $e');
    }
    return null;
  }
}
