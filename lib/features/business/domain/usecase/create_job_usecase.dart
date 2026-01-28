import '../../data/model/res_all_business_model.dart';
import '../repository/all_business_repository.dart';

class CreateJobUseCase {
  final BusinessRepository repository;

  CreateJobUseCase({required this.repository});

  Future<BusinessResponse> call(Map<String, dynamic> data) async {
    return await repository.createJob(data);
  }
}
