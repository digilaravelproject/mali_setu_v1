import '../../data/model/req_register_model.dart';
import '../../data/model/res_register_model.dart';
import '../repository/register_repository.dart';

class RegisterUseCase {
  final RegisterRepository repository;

  RegisterUseCase({required this.repository});

  Future<ResRegisterModel> call(ReqRegisterModel reqModel) async {
    return await repository.register(reqModel);
  }
}
