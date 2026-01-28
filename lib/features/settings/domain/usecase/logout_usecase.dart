import '../../data/model/req_login_model.dart';
import '../../data/model/res_login_model.dart';
import '../repository/logout_repository.dart';

class LogoutUseCase {
  final LogoutRepository repository;

  LogoutUseCase({required this.repository});

  Future<bool> call() async {
    return await repository.logout();
  }
}

