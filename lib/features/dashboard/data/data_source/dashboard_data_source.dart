import '../../../../core/network/api_client.dart';
import '../../../../core/constent/api_constants.dart';
import '../model/banner_model.dart';

abstract class DashboardDataSource {
  Future<BannerResponse> getBanners();
}

class DashboardDataSourceImpl implements DashboardDataSource {
  final ApiClient apiClient;

  DashboardDataSourceImpl({required this.apiClient});

  @override
  Future<BannerResponse> getBanners() async {
    final response = await apiClient.get(ApiConstants.getBanner);
    return BannerResponse.fromJson(response.data);
  }
}



