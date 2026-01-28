import '../../../../../../core/network/api_response.dart';
import '../../data/model/req_login_model.dart';
import '../../data/model/res_login_model.dart';

abstract class LoginRepository {
  Future<ResLoginModel> login(ReqLoginModel reqModel);
  Future<ResLoginModel> googleLogin(Map<String, String> data);
  Future<ResLoginModel> logout();
}
