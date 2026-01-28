import '../repository/login_repository.dart';
import '../../data/model/res_login_model.dart';

class LogoutUseCase {
  final LoginRepository repository;

  LogoutUseCase({required this.repository});

  Future<ResLoginModel> call() async {
    return await repository.logout();
  }
}
