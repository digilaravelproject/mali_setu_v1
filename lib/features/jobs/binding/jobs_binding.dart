import 'package:get/get.dart';
import '../presentation/controller/jobs_controller.dart';

class JobsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => JobsController(), fenix: true);
  }
}

