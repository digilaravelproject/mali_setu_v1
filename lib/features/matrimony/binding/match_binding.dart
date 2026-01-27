import 'package:edu_cluezer/features/filter/presentation/controller/filter_controller.dart';
import 'package:edu_cluezer/features/matrimony/presentation/controller/reg_matrimony_controller.dart';
import 'package:get/get.dart';

import '../presentation/controller/matrimony_controller.dart';

class MatrimonyBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => MatrimonyController());
    Get.lazyPut(() => FilterController(), fenix: true);
    Get.lazyPut(() => RegMatrimonyController());
  }
}
