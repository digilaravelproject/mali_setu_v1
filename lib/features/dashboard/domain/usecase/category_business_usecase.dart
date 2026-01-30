import '../../data/model/res_category_business_model.dart';
import '../repository/category_business_repository.dart';

class GetBusinessByCategoryUseCase {
  final CatBusinessRepository repository;

  GetBusinessByCategoryUseCase({required this.repository});

  Future<ResBusinessCategoryModel> call(int categoryId) {
    return repository.getBusinessByCategory(categoryId);
  }
}
