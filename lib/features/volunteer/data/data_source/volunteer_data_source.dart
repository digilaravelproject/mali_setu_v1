import 'package:edu_cluezer/core/network/api_client.dart';
import 'package:edu_cluezer/core/constent/api_constants.dart';
import '../model/res_all_volunteer_model.dart';
import '../model/volunteer_profile_model.dart';

abstract class VolunteerDataSource {
  Future<VolunteerProfileResponse> getVolunteerProfile();
  Future<VolunteerProfileResponse> createVolunteerProfile(Map<String, dynamic> data);
  Future<VolunteerProfileResponse> updateVolunteerProfile(Map<String, dynamic> data);
  Future<ResVolunteerModel> fetchAllVolunteers();
  Future<ResSingleVolunteerModel> getVolunteerOpportunity(int id);
  Future<VolunteerSearchResponse> searchVolunteers(String query, {int size = 20});
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

  @override
  Future<ResVolunteerModel> fetchAllVolunteers() async {
    final response = await apiClient.get(ApiConstants.allVolunteer);
    return ResVolunteerModel.fromJson(response.data);
  }
  @override
  Future<ResSingleVolunteerModel> getVolunteerOpportunity(int id) async {
    final response = await apiClient.get("${ApiConstants.volunteerOpportunity}/$id");
    return ResSingleVolunteerModel.fromJson(response.data);
  }

  @override
  Future<VolunteerSearchResponse> searchVolunteers(String query, {int size = 20}) async {
    final response = await apiClient.get(
      ApiConstants.searchVolunteers,
      queryParameters: {
        'query': query,
        'size': size,
      },
    );
    return VolunteerSearchResponse.fromJson(response.data);
  }
}





