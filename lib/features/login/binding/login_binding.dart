import 'package:edu_cluezer/features/login/data/data_source/login_data_source.dart';
import 'package:edu_cluezer/features/login/presentation/controller/login_controller.dart';
import 'package:get/get.dart';

import '../../business/presentation/controller/reg_business_controller.dart';
import '../presentation/controller/reset_password_controller.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LoginDataSource>(() => LoginDataSourceImpl());
    Get.lazyPut(() => LoginController(dataSource: Get.find<LoginDataSource>()));
    Get.lazyPut(() => ResetPasswordController());

  }
}
