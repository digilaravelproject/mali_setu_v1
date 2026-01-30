import 'package:edu_cluezer/features/business/data/model/res_all_business_model.dart';
import 'package:edu_cluezer/features/business/domain/repository/all_business_repository.dart';

class UpdateApplicationStatusUseCase {
  final BusinessRepository repository;

  UpdateApplicationStatusUseCase({required this.repository});

  Future<BusinessResponse> call(int applicationId, String status, {String? notes}) {
    return repository.updateApplicationStatus(applicationId, status, notes: notes);
  }
}
