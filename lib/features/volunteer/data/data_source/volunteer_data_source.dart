import 'package:edu_cluezer/core/network/api_client.dart';
import 'package:edu_cluezer/core/constent/api_constants.dart';
import '../model/volunteer_profile_model.dart';

abstract class VolunteerDataSource {
  Future<VolunteerProfileResponse> getVolunteerProfile();
  Future<VolunteerProfileResponse> createVolunteerProfile(Map<String, dynamic> data);
  Future<VolunteerProfileResponse> updateVolunteerProfile(Map<String, dynamic> data);
}

class VolunteerDataSourceImpl implements VolunteerDataSource {
  final ApiClient apiClient;

  VolunteerDataSourceImpl({required this.apiClient});

  @override
  Future<VolunteerProfileResponse> getVolunteerProfile() async {
    final response = await apiClient.get(ApiConstants.volunteerProfile);
    return VolunteerProfileResponse.fromJson(response.data);
  }

  @override
  Future<VolunteerProfileResponse> createVolunteerProfile(Map<String, dynamic> data) async {
    final response = await apiClient.post(ApiConstants.volunteerProfile, data: data);
    return VolunteerProfileResponse.fromJson(response.data);
  }

  @override
  Future<VolunteerProfileResponse> updateVolunteerProfile(Map<String, dynamic> data) async {
    final response = await apiClient.put(ApiConstants.volunteerProfile, data: data);
    return VolunteerProfileResponse.fromJson(response.data);
  }
}
