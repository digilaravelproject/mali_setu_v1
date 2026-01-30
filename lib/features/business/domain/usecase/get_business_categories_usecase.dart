
import 'package:edu_cluezer/features/business/data/model/res_all_business_model.dart';
import 'package:edu_cluezer/features/business/domain/repository/all_business_repository.dart';

class GetBusinessCategoriesUseCase {
  final BusinessRepository repository;

  GetBusinessCategoriesUseCase({required this.repository});
  
  Future<List<Category>> call() {
    return repository.getBusinessCategories();
  }
}
