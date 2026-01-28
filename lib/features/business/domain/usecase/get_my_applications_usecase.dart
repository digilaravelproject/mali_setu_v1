import '../../data/model/res_all_business_model.dart';
import '../repository/all_business_repository.dart';

class GetMyApplicationsUseCase {
  final BusinessRepository repository;

  GetMyApplicationsUseCase({required this.repository});

  Future<MyApplicationsResponse> call() {
    return repository.getMyApplications();
  }
}
