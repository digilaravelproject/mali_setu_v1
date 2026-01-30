import 'package:edu_cluezer/features/business/domain/repository/all_business_repository.dart';
import 'package:edu_cluezer/features/business/data/model/res_all_business_model.dart';

class UpdateBusinessUseCase {
  final BusinessRepository repository;

  UpdateBusinessUseCase({required this.repository});

  Future<BusinessResponse> call(int id, Map<String, dynamic> data) {
    return repository.updateBusiness(id, data);
  }
}
