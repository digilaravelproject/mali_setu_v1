import '../../../../../../core/network/api_client.dart';
import '../../../../../../core/constent/api_constants.dart';
import '../model/req_login_model.dart';
import '../model/res_login_model.dart';

abstract class LoginDataSource {
  Future<ResLoginModel> login(ReqLoginModel reqModel);
}

class LoginDataSourceImpl implements LoginDataSource {
  final ApiClient apiClient;

  LoginDataSourceImpl({required this.apiClient});

  @override
  Future<ResLoginModel> login(ReqLoginModel reqModel) async {
    try {
      final response = await apiClient.post(
        ApiConstants.authLogin,
        data: reqModel.toJson(),
      );
      
      return ResLoginModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
