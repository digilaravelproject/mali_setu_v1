import 'package:edu_cluezer/features/_init/data/data_source/init_data_source.dart';
import 'package:edu_cluezer/features/_init/presentation/controller/init_controller.dart';
import 'package:get/get.dart';

import '../presentation/controller/intro_controller.dart';

class InitBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => InitController());

    Get.lazyPut<InitDataSource>(() => InitDataSourceImpl());
    Get.lazyPut(() => IntroController(dataSource: Get.find<InitDataSource>()));
  }
}
