import '../../../../core/constent/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../model/res_category_business_model.dart';

abstract class CatBusinessDataSource {
  Future<ResBusinessCategoryModel> getBusinessByCategory(int categoryId);
}

class CatBusinessDataSourceImpl implements CatBusinessDataSource {
  final ApiClient apiClient;

  CatBusinessDataSourceImpl({required this.apiClient});

  @override
  Future<ResBusinessCategoryModel> getBusinessByCategory(int categoryId) async {
    final response = await apiClient.get(
      "${ApiConstants.getCategoryBusiness}/$categoryId"
    );

    return ResBusinessCategoryModel.fromJson(response.data);
  }
}
