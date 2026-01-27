import 'package:edu_cluezer/core/network/api_constants.dart';
import 'package:edu_cluezer/core/network/api_services.dart';
import 'package:edu_cluezer/features/login/data/model/req_login_model.dart';
import 'package:get/get.dart';

abstract class LoginDataSource {
  Future<String> makeOtpLoginRequest(ReqLoginModel request);

  Future<String> verifyUserOTP(ReqOTPModel request);
}

class LoginDataSourceImpl extends LoginDataSource {
  final apiService = Get.find<ApiServices>();

  @override
  Future<String> makeOtpLoginRequest(ReqLoginModel request) async {
    var endPoint = request.isLoginPass
        ? ApiConstants.pwdLogin
        : ApiConstants.sendOtp;

    final response = await apiService.callPost(endPoint, req: request.toMap());
    if (response.data == null) {
      throw Exception(response.message);
    }
    return response.message;
  }

  @override
  Future<String> verifyUserOTP(ReqOTPModel request) async {
    final response = await apiService.callPost(
      ApiConstants.verifyOtp,
      req: request.toMap(),
    );
    if (response.data == null) {
      throw Exception(response.message);
    }
    return response.message;
  }
}
