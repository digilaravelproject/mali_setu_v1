import '../../../../../../core/network/api_response.dart';
import '../../data/model/req_login_model.dart';
import '../../data/model/res_login_model.dart';

abstract class LogoutRepository {
  Future<bool> logout();
}