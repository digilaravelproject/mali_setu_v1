import 'package:edu_cluezer/features/business/data/model/res_all_business_model.dart';
import 'package:edu_cluezer/features/business/domain/repository/all_business_repository.dart';

class GetJobDetailsUseCase {
  final BusinessRepository repository;

  GetJobDetailsUseCase({required this.repository});

  Future<JobDetailData?> call(int jobId) async {
    final response = await repository.getJobDetails(jobId);
    return response.data;
  }
}
