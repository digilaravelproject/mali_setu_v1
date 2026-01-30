import 'package:edu_cluezer/features/business/data/model/res_all_business_model.dart';
import 'package:edu_cluezer/features/business/domain/repository/all_business_repository.dart';

class GetMyApplicationsUseCase {
  final BusinessRepository repository;

  GetMyApplicationsUseCase({required this.repository});

  Future<MyApplicationsResponse> call() {
    return repository.getMyApplications();
  }
}
