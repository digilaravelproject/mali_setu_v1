import '../../../../../../core/network/api_client.dart';
import '../../../../../../core/constent/api_constants.dart';
import '../model/req_change_password_model.dart';
import '../model/res_change_password_model.dart';

abstract class ChangePasswordDataSource {
  Future<ResChangePasswordModel> changePassword(ReqChangePasswordModel reqModel);
}

class ChangePasswordDataSourceImpl implements ChangePasswordDataSource {
  final ApiClient apiClient;

  ChangePasswordDataSourceImpl({required this.apiClient});

  @override
  Future<ResChangePasswordModel> changePassword(ReqChangePasswordModel reqModel) async {
    try {
      final response = await apiClient.post(
        ApiConstants.authChangePassword,
        data: reqModel.toJson(),
      );
      
      return ResChangePasswordModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
