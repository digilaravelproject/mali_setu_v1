import 'package:edu_cluezer/features/business/data/model/res_all_business_model.dart';
import 'package:edu_cluezer/features/business/domain/repository/all_business_repository.dart';

class GetJobAnalyticsUseCase {
  final BusinessRepository repository;

  GetJobAnalyticsUseCase(this.repository);

  Future<JobAnalyticsResponse> call() async {
    return await repository.getJobAnalytics();
  }
}
