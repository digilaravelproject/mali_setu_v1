import 'package:dio/dio.dart';
import '../../../../../../core/network/api_client.dart';
import '../../../../../../core/constent/api_constants.dart';
import '../model/req_register_model.dart';
import '../model/res_register_model.dart';

abstract class RegisterDataSource {
  Future<ResRegisterModel> register(ReqRegisterModel reqModel);
}

class RegisterDataSourceImpl implements RegisterDataSource {
  final ApiClient apiClient;

  RegisterDataSourceImpl({required this.apiClient});

  @override
  Future<ResRegisterModel> register(ReqRegisterModel reqModel) async {
    try {
      final response = await apiClient.post(
        ApiConstants.authRegister,
        data: reqModel.toJson(),
      );
      
      return ResRegisterModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
