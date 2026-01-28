import '../../data/model/res_all_business_model.dart';
import '../repository/all_business_repository.dart';

class DeleteJobUseCase {
  final BusinessRepository repository;

  DeleteJobUseCase({required this.repository});

  Future<BusinessResponse> call(int id) async {
    return await repository.deleteJob(id);
  }
}
