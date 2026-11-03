import 'package:get/get.dart';
import '../presentation/controllers/webinars_controller.dart';

class WebinarsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WebinarsController>(() => WebinarsController());
  }
}

