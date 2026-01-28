import '../../data/model/res_all_business_model.dart';
import '../repository/all_business_repository.dart';

class ToggleJobStatusUseCase {
  final BusinessRepository repository;

  ToggleJobStatusUseCase(this.repository);

  Future<BusinessResponse> call(int id) async {
    return await repository.toggleJobStatus(id);
  }
}
