import 'package:edu_cluezer/features/business/data/model/res_all_business_model.dart';
import 'package:edu_cluezer/features/business/domain/repository/all_business_repository.dart';

class GetBusinessProductsUseCase {
  final BusinessRepository repository;

  GetBusinessProductsUseCase({required this.repository});

  Future<List<Product>> call(int businessId) async {
    final response = await repository.getBusinessProducts(businessId);
    return response.data?.products ?? [];
  }
}
