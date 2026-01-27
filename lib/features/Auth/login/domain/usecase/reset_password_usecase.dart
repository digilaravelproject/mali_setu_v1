import 'package:edu_cluezer/features/Auth/login/data/model/req_reset_password_model.dart';
import 'package:edu_cluezer/features/Auth/login/data/model/res_reset_password_model.dart';
import 'package:edu_cluezer/features/Auth/login/domain/repository/reset_password_repository.dart';

class ResetPasswordUseCase {
  final ResetPasswordRepository repository;

  ResetPasswordUseCase({required this.repository});

  Future<ResResetPasswordModel> call(ReqResetPasswordModel reqModel) async {
    return await repository.sendOtp(reqModel);
  }
}