import '../../../../../../core/network/api_client.dart';
import '../../../../../../core/constent/api_constants.dart';
import '../model/res_all_business_model.dart';




abstract class BusinessDataSource {
  Future<BusinessResponse> getAllBusinesses();
}

class BusinessDataSourceImpl implements BusinessDataSource {
  final ApiClient apiClient;

  BusinessDataSourceImpl({required this.apiClient});

  @override
  Future<BusinessResponse> getAllBusinesses() async {
    final response = await apiClient.get(ApiConstants.allBusiness);
    return BusinessResponse.fromJson(response.data);
  }
}

