import 'package:get/get.dart';

import '../presentation/controller/init_controller.dart';


class InitBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => InitController());


  }
}
