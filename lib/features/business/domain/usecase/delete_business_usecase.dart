import 'package:edu_cluezer/features/business/domain/repository/all_business_repository.dart';

class DeleteBusinessUseCase {
  final BusinessRepository repository;

  DeleteBusinessUseCase({required this.repository});

  Future<void> call(int id) {
    return repository.deleteBusiness(id);
  }
}
