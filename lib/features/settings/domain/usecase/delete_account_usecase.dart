import '../repository/logout_repository.dart';

class DeleteAccountUseCase {
  final LogoutRepository repository;

  DeleteAccountUseCase({required this.repository});

  Future<bool> call() async {
    return await repository.deleteAccount();
  }
}
