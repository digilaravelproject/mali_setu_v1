import '../../domain/repository/login_repository.dart';
import '../../data/data_source/login_data_source.dart';
import '../../data/model/req_login_model.dart';
import '../../data/model/res_login_model.dart';

class LoginRepositoryImpl implements LoginRepository {
  final LoginDataSource dataSource;

  LoginRepositoryImpl({required this.dataSource});

  @override
  Future<ResLoginModel> login(ReqLoginModel reqModel) async {
    return await dataSource.login(reqModel);
  }

  @override
  Future<ResLoginModel> googleLogin(Map<String, String> data) async {
    return await dataSource.googleLogin(data);
  }

  @override
  Future<ResLoginModel> logout() async {
    return await dataSource.logout();
  }
}
