import '../../domain/repository/logout_repository.dart';
import '../../data/data_source/logout_data_source.dart';
import '../../data/model/req_login_model.dart';
import '../../data/model/res_login_model.dart';

// class LoginRepositoryImpl implements LoginRepository {
//   final LoginDataSource dataSource;
//
//   LoginRepositoryImpl({required this.dataSource});
//
//   @override
//   Future<ResLoginModel> login(ReqLoginModel reqModel) async {
//     return await dataSource.login(reqModel);
//   }
// }


class LogoutRepositoryImpl implements LogoutRepository {
  final LogoutDataSource dataSource;

  LogoutRepositoryImpl({required this.dataSource});

  @override
  Future<bool> logout() async {
    return await dataSource.logout();
  }
}
