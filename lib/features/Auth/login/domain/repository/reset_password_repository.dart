import 'package:edu_cluezer/features/Auth/login/data/model/req_reset_password_model.dart';
import 'package:edu_cluezer/features/Auth/login/data/model/res_reset_password_model.dart';

import '../../../../../../core/network/api_response.dart';
import '../../data/model/req_login_model.dart';
import '../../data/model/res_login_model.dart';

abstract class ResetPasswordRepository {
  Future<ResResetPasswordModel> sendOtp(ReqResetPasswordModel reqModel);
}
