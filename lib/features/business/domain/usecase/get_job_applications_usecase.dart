import '../../data/model/res_all_business_model.dart';
import '../repository/all_business_repository.dart';

class GetJobApplicationsUseCase {
  final BusinessRepository repository;

  GetJobApplicationsUseCase({required this.repository});

  Future<JobApplicationsResponse> call(int jobId) {
    return repository.getJobApplications(jobId);
  }
}
