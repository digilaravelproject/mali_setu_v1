import '../../../../../../core/network/api_response.dart';
import '../../data/model/req_register_model.dart';
import '../../data/model/res_register_model.dart';

abstract class RegisterRepository {
  Future<ResRegisterModel> register(ReqRegisterModel reqModel);
}
