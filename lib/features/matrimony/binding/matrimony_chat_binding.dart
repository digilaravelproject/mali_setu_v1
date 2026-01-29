import 'package:get/get.dart';
import '../presentation/controller/matrimony_chat_controller.dart';

class MatrimonyChatBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MatrimonyChatController>(() => MatrimonyChatController());
  }
}
