import '../../domain/repository/register_repository.dart';
import '../../data/data_source/register_data_source.dart';
import '../../data/model/req_register_model.dart';
import '../../data/model/res_register_model.dart';

class RegisterRepositoryImpl implements RegisterRepository {
  final RegisterDataSource dataSource;

  RegisterRepositoryImpl({required this.dataSource});

  @override
  Future<ResRegisterModel> register(ReqRegisterModel reqModel) async {
    return await dataSource.register(reqModel);
  }
}
