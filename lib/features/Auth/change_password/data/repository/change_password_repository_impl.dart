import '../../domain/repository/change_password_repository.dart';
import '../../data/data_source/change_password_data_source.dart';
import '../../data/model/req_change_password_model.dart';
import '../../data/model/res_change_password_model.dart';

class ChangePasswordRepositoryImpl implements ChangePasswordRepository {
  final ChangePasswordDataSource dataSource;

  ChangePasswordRepositoryImpl({required this.dataSource});

  @override
  Future<ResChangePasswordModel> changePassword(ReqChangePasswordModel reqModel) async {
    return await dataSource.changePassword(reqModel);
  }
}
