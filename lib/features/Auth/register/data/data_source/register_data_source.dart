import 'dart:io';
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
      final data = reqModel.toJson();

      // Ensure term_condition is 1 for Laravel "accepted" validation
      if (data['term_condition'] == true) {
        data['term_condition'] = 1;
      }

      // Handle cast_certificate file upload as multipart/form-data
      if (reqModel.castCertificate != null && reqModel.castCertificate!.isNotEmpty) {
        final filePath = reqModel.castCertificate!;
        final file = File(filePath);
        if (await file.exists()) {
          data['cast_certificate'] = await MultipartFile.fromFile(
            filePath,
            filename: filePath.split('/').last,
          );
        } else {
          data.remove('cast_certificate');
        }
      } else {
        data.remove('cast_certificate');
      }

      print("DEBUG_REGISTER: Sending request body (as FormData): $data");

      final response = await apiClient.post(
        ApiConstants.authRegister,
        data: FormData.fromMap(data),
      );

      return ResRegisterModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
