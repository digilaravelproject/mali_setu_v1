import '../repository/all_business_repository.dart';
import '../../data/model/res_all_business_model.dart';

class UpdateBusinessUseCase {
  final BusinessRepository repository;

  UpdateBusinessUseCase({required this.repository});

  Future<BusinessResponse> call(int id, Map<String, dynamic> data) {
    return repository.updateBusiness(id, data);
  }
}
