import 'package:get/get.dart';

import '../presentation/controller/date_profile_controller.dart';

class DateBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => DateProfileController());
  }
}
