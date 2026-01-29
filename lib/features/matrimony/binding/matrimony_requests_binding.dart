import 'package:edu_cluezer/features/matrimony/presentation/controller/matrimony_requests_controller.dart';
import 'package:get/get.dart';

class MatrimonyRequestsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MatrimonyRequestsController>(() => MatrimonyRequestsController());
  }
}
