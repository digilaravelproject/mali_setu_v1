import 'package:get/get.dart';
import '../presentation/controller/matrimony_details_controller.dart';

class MatrimonyDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => MatrimonyDetailsController());
  }
}
