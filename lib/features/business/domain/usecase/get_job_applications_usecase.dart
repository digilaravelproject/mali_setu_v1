import 'package:edu_cluezer/features/business/data/model/res_all_business_model.dart';
import 'package:edu_cluezer/features/business/domain/repository/all_business_repository.dart';

class GetJobApplicationsUseCase {
  final BusinessRepository repository;

  GetJobApplicationsUseCase({required this.repository});

  Future<JobApplicationsResponse> call(int jobId) {
    return repository.getJobApplications(jobId);
  }
}
