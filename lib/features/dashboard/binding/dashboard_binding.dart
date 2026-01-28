import 'package:edu_cluezer/features/settings/controller/settings_controller.dart';
import 'package:edu_cluezer/features/volunteer/controller/volunteerController.dart';
import 'package:get/get.dart';

import '../presentation/controller/dashboard_controller.dart';
import '../presentation/controller/home_controller.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => DashboardController());
    Get.lazyPut(() => HomeController());
    Get.lazyPut(() => SettingsController(logoutUseCase: Get.find()));
  }
}
