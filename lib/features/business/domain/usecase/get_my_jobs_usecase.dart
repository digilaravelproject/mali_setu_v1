import 'package:edu_cluezer/features/business/data/model/res_all_business_model.dart';
import 'package:edu_cluezer/features/business/domain/repository/all_business_repository.dart';

class GetMyJobsUseCase {
  final BusinessRepository repository;

  GetMyJobsUseCase({required this.repository});

  Future<List<Job>> call(int businessId) async {
    final response = await repository.getMyJobs(businessId);
    return response.data?.jobs ?? [];
  }
}
