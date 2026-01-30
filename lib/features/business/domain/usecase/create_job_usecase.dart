import 'package:edu_cluezer/features/business/data/model/res_all_business_model.dart';
import 'package:edu_cluezer/features/business/domain/repository/all_business_repository.dart';

class CreateJobUseCase {
  final BusinessRepository repository;

  CreateJobUseCase({required this.repository});

  Future<BusinessResponse> call(Map<String, dynamic> data) async {
    return await repository.createJob(data);
  }
}
