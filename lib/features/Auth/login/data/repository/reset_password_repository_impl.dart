import 'package:edu_cluezer/features/Auth/login/data/data_source/reset_password_data_source.dart';
import 'package:edu_cluezer/features/Auth/login/data/model/req_reset_password_model.dart';
import 'package:edu_cluezer/features/Auth/login/data/model/res_reset_password_model.dart';
import 'package:edu_cluezer/features/Auth/login/domain/repository/reset_password_repository.dart';

import '../../domain/repository/login_repository.dart';
import '../../data/data_source/login_data_source.dart';
import '../../data/model/req_login_model.dart';
import '../../data/model/res_login_model.dart';

class ResetPasswordRepositoryImpl implements ResetPasswordRepository {
  final ResetPasswordDataSource dataSource;

  ResetPasswordRepositoryImpl({required this.dataSource});

  @override
  Future<ResResetPasswordModel> sendOtp(ReqResetPasswordModel reqModel) async {
    return await dataSource.sendOtp(reqModel);
  }

  @override
  Future<bool> resetPassword(RequestResetPasswordModel reqModel) async {
    return await dataSource.resetPassword(reqModel);
  }



}



