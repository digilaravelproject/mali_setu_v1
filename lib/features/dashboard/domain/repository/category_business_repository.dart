import '../../data/model/res_category_business_model.dart';

abstract class CatBusinessRepository {
  Future<ResBusinessCategoryModel> getBusinessByCategory(int categoryId);
}