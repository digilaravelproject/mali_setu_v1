import '../../data/model/res_all_business_model.dart';
import '../repository/all_business_repository.dart';

class UpdateJobUseCase {
  final BusinessRepository repository;

  UpdateJobUseCase({required this.repository});

  Future<BusinessResponse> call(int id, Map<String, dynamic> data) async {
    return await repository.updateJob(id, data);
  }
}
