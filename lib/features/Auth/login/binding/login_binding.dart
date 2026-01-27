import 'package:get/get.dart';

import '../data/data_source/login_data_source.dart';
import '../data/repository/login_repository_impl.dart';
import '../domain/repository/login_repository.dart';
import '../domain/usecase/login_usecase.dart';
import '../presentation/controller/login_controller.dart';
import '../presentation/controller/reset_password_controller.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    // Data Source
    Get.lazyPut<LoginDataSource>(
      () => LoginDataSourceImpl(apiClient: Get.find()),
    );

    // Repository
    Get.lazyPut<LoginRepository>(
      () => LoginRepositoryImpl(dataSource: Get.find()),
    );

    // Use Case
    Get.lazyPut<LoginUseCase>(
      () => LoginUseCase(repository: Get.find()),
    );

    // Controller
    Get.lazyPut(() => LoginController(loginUseCase: Get.find()));
    
    // Reset Password Controller (leaving as is for now)
    Get.lazyPut(() => ResetPasswordController());
  }
}
