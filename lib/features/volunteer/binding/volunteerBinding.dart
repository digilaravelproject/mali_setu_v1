import 'package:edu_cluezer/features/volunteer/controller/volunteerController.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/bindings_interface.dart';
import 'package:get/get_instance/src/extension_instance.dart';

import '../../dashboard/presentation/controller/dashboard_controller.dart';
import '../controller/volunteerUpdateProfileController.dart';

class VolunteerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => VolunteerProfileController());
    Get.lazyPut(() => VoluntProfileUpdateController());
  }
}