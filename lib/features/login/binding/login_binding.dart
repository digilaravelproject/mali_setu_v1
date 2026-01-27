import 'package:edu_cluezer/features/login/data/data_source/login_data_source.dart';
import 'package:edu_cluezer/features/login/presentation/controller/login_controller.dart';
import 'package:get/get.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LoginDataSource>(() => LoginDataSourceImpl());
    Get.lazyPut(() => LoginController(dataSource: Get.find<LoginDataSource>()));
  }
}
