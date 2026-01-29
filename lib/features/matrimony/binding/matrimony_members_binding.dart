import 'package:edu_cluezer/features/matrimony/presentation/controller/matrimony_members_controller.dart';
import 'package:get/get.dart';

class MatrimonyMembersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MatrimonyMembersController>(() => MatrimonyMembersController());
  }
}
