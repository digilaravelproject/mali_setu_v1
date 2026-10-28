import 'package:edu_cluezer/features/business/domain/repository/all_business_repository.dart';
import 'package:edu_cluezer/features/business/data/model/res_all_business_model.dart';

class DeleteBusinessProductUseCase {
  final BusinessRepository repository;

  DeleteBusinessProductUseCase({required this.repository});

  Future<BusinessResponse> call(int id) {
    return repository.deleteProduct(id);
  }
}
