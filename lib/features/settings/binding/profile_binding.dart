
import 'package:edu_cluezer/features/settings/controller/settings_controller.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/bindings_interface.dart';

import '../controller/profileController.dart';
import '../data/data_source/logout_data_source.dart';
import '../data/repository/logout_repository_impl.dart';
import '../domain/repository/logout_repository.dart';
import '../domain/usecase/logout_usecase.dart';



class SettingsBinding extends Bindings {
  @override
  void dependencies() {
    // Get.lazyPut(() => MatrimonyController());
    // Get.lazyPut(() => FilterController(), fenix: true);
    // Get.lazyPut(() => RegMatrimonyController());
    Get.lazyPut(() => UpProfileController() );

    Get.lazyPut<LogoutDataSource>(
          () => LogoutDataSourceImpl(apiClient: Get.find()),
    );

    Get.lazyPut<LogoutRepository>(
          () => LogoutRepositoryImpl(dataSource: Get.find()),
    );

    Get.lazyPut<LogoutUseCase>(
          () => LogoutUseCase(repository: Get.find()),
    );

    Get.lazyPut(() => SettingsController( logoutUseCase: Get.find()));


  }
}