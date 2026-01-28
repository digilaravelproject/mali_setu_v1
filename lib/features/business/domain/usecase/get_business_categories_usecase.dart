
import '../../data/model/res_all_business_model.dart';
import '../repository/all_business_repository.dart';

class GetBusinessCategoriesUseCase {
  final BusinessRepository repository;

  GetBusinessCategoriesUseCase({required this.repository});
  
  Future<List<Category>> call() {
    return repository.getBusinessCategories();
  }
}
