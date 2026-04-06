import '../../../../core/constent/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../model/res_category_business_model.dart';

abstract class CatBusinessDataSource {
  Future<ResBusinessCategoryModel> getBusinessByCategory(int categoryId, {double? lat, double? long});
}

class CatBusinessDataSourceImpl implements CatBusinessDataSource {
  final ApiClient apiClient;

  CatBusinessDataSourceImpl({required this.apiClient});

  @override
  Future<ResBusinessCategoryModel> getBusinessByCategory(int categoryId, {double? lat, double? long}) async {
    final Map<String, dynamic> queryParams = {};
    if (lat != null) queryParams['latitude'] = lat;
    if (long != null) queryParams['longitude'] = long;

    final response = await apiClient.get(
      "${ApiConstants.getCategoryBusiness}/$categoryId",
      queryParameters: queryParams,
    );

    return ResBusinessCategoryModel.fromJson(response.data);
  }
}
