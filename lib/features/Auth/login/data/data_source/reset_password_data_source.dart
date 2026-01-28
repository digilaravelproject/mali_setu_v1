import 'package:edu_cluezer/features/Auth/login/data/model/req_reset_password_model.dart';
import 'package:edu_cluezer/features/Auth/login/data/model/res_reset_password_model.dart';

import '../../../../../../core/network/api_client.dart';
import '../../../../../../core/constent/api_constants.dart';
import '../model/req_login_model.dart';
import '../model/res_login_model.dart';

abstract class ResetPasswordDataSource {
  Future<ResResetPasswordModel> sendOtp(ReqResetPasswordModel reqModel);
  Future<bool> resetPassword(RequestResetPasswordModel reqModel);

}

class ResetPasswordDataSourceImpl implements ResetPasswordDataSource {
  final ApiClient apiClient;

  ResetPasswordDataSourceImpl({required this.apiClient});

  @override
  Future<ResResetPasswordModel> sendOtp(ReqResetPasswordModel reqModel) async {
    try {
      final response = await apiClient.post(
        ApiConstants.forgotPassword,
        data: reqModel.toJson(),
      );

      return ResResetPasswordModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<bool> resetPassword(RequestResetPasswordModel reqModel) async {
    final response = await apiClient.post(
      ApiConstants.resetPassword,  // ya ApiConstants.authResetPassword
      data: reqModel.toJson(),
      handleError: true,
      showToaster: true,
    );

    return response.statusCode == 200;
  }
}













