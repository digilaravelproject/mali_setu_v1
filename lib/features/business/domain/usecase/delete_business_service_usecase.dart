import 'package:edu_cluezer/features/business/domain/repository/all_business_repository.dart';
import 'package:edu_cluezer/features/business/data/model/res_all_business_model.dart';

class DeleteBusinessServiceUseCase {
  final BusinessRepository repository;

  DeleteBusinessServiceUseCase({required this.repository});

  Future<BusinessResponse> call(int id) {
    return repository.deleteService(id);
  }
}
