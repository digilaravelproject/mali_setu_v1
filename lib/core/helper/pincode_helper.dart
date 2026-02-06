import 'package:dio/dio.dart';

/// Helper class for fetching address details from pincode
class PincodeHelper {
  static final Dio _dio = Dio();

  /// Fetch address details from pincode
  static Future<PincodeResponse?> fetchAddressFromPincode(String pincode) async {
    try {
      // Validate pincode format (6 digits)
      if (pincode.length != 6 || int.tryParse(pincode) == null) {
        return null;
      }

      final response = await _dio.get(
        'https://api.postalpincode.in/pincode/$pincode',
        options: Options(
          receiveTimeout: const Duration(seconds: 10),
          sendTimeout: const Duration(seconds: 10),
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data;
        
        if (data.isNotEmpty) {
          final firstResult = data[0];
          
          // Check if status is success
          if (firstResult['Status'] == 'Success' && 
              firstResult['PostOffice'] != null && 
              (firstResult['PostOffice'] as List).isNotEmpty) {
            
            // Get first post office from the list
            final postOffice = (firstResult['PostOffice'] as List)[0];
            
            return PincodeResponse(
              state: postOffice['State'] ?? '',
              district: postOffice['District'] ?? '',
              name: postOffice['Name'] ?? '', // Post office name as city
              country: postOffice['Country'] ?? 'India',
              block: postOffice['Block'] ?? '',
              region: postOffice['Region'] ?? '',
              division: postOffice['Division'] ?? '',
              circle: postOffice['Circle'] ?? '',
              postOfficeName: postOffice['Name'] ?? '',
              pincode: postOffice['Pincode'] ?? pincode,
            );
          }
        }
      }
      
      return null;
    } catch (e) {
      print('Error fetching pincode details: $e');
      return null;
    }
  }
}

/// Model for pincode API response
class PincodeResponse {
  final String state;
  final String district;
  final String name; // Post office name as city
  final String country;
  final String block;
  final String region;
  final String division;
  final String circle;
  final String postOfficeName;
  final String pincode;

  PincodeResponse({
    required this.state,
    required this.district,
    required this.name,
    required this.country,
    required this.block,
    required this.region,
    required this.division,
    required this.circle,
    required this.postOfficeName,
    required this.pincode,
  });

  @override
  String toString() {
    return 'PincodeResponse(state: $state, district: $district, city: $name, country: $country)';
  }
}
