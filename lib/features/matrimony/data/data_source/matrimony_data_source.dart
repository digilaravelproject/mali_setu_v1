import 'package:edu_cluezer/core/constent/api_constants.dart';
import 'package:edu_cluezer/core/network/api_client.dart';
import '../model/matrimony_response.dart';

abstract class MatrimonyDataSource {
  Future<MatrimonyResponse> createProfile(Map<String, dynamic> data);
  Future<dynamic> getProfiles(); // dynamic for now until I see response
}

class MatrimonyDataSourceImpl implements MatrimonyDataSource {
  final ApiClient apiClient;

  MatrimonyDataSourceImpl({required this.apiClient});

  @override
  Future<MatrimonyResponse> createProfile(Map<String, dynamic> data) async {
    final response = await apiClient.post(ApiConstants.matrimonyProfile, data: data);
    return MatrimonyResponse.fromJson(response.data);
  }

  @override
  Future<dynamic> getProfiles() async {
    final response = await apiClient.get(ApiConstants.matrimonyProfile);
    return response.data;
  }
}
