import 'package:get/get.dart';

import '../data/data_source/register_data_source.dart';
import '../data/repository/register_repository_impl.dart';
import '../domain/repository/register_repository.dart';
import '../domain/usecase/register_usecase.dart';
import '../presentation/controller/register_controller.dart';

class RegisterBinding extends Bindings {
  @override
  void dependencies() {
    // Data Source
    Get.lazyPut<RegisterDataSource>(
      () => RegisterDataSourceImpl(apiClient: Get.find()),
    );

    // Repository
    Get.lazyPut<RegisterRepository>(
      () => RegisterRepositoryImpl(dataSource: Get.find()),
    );

    // Use Case
    Get.lazyPut<RegisterUseCase>(
      () => RegisterUseCase(repository: Get.find()),
    );

    // Controller
    Get.lazyPut(() => RegisterController(registerUseCase: Get.find()));
  }
}
