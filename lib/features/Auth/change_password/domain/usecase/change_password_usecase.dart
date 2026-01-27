import '../../data/model/req_change_password_model.dart';
import '../../data/model/res_change_password_model.dart';
import '../repository/change_password_repository.dart';

class ChangePasswordUseCase {
  final ChangePasswordRepository repository;

  ChangePasswordUseCase({required this.repository});
  
  Future<ResChangePasswordModel> call(ReqChangePasswordModel reqModel) async {
    return await repository.changePassword(reqModel);
  }
}
