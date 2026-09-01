import 'package:edu_cluezer/features/business/data/model/res_all_business_model.dart';
import 'package:edu_cluezer/features/business/domain/repository/all_business_repository.dart';

class GetBusinessCategoriesPaginatedUseCase {
  final BusinessRepository repository;

  GetBusinessCategoriesPaginatedUseCase({required this.repository});
  
  Future<CategoryResponse> call({int page = 1}) {
    return repository.getBusinessCategoriesPaginated(page: page);
  }
}
