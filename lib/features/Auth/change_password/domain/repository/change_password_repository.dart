import '../../data/model/req_change_password_model.dart';
import '../../data/model/res_change_password_model.dart';

abstract class ChangePasswordRepository {
  Future<ResChangePasswordModel> changePassword(ReqChangePasswordModel reqModel);
}
