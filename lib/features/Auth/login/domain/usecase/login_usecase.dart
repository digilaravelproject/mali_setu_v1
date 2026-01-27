import '../../data/model/req_login_model.dart';
import '../../data/model/res_login_model.dart';
import '../repository/login_repository.dart';

class LoginUseCase {
  final LoginRepository repository;

  LoginUseCase({required this.repository});

  Future<ResLoginModel> call(ReqLoginModel reqModel) async {
    return await repository.login(reqModel);
  }
}
