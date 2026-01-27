import 'package:edu_cluezer/features/profile/presentation/controller/edit_profile_controller.dart';
import 'package:edu_cluezer/features/profile/presentation/controller/profile_controller.dart';
import 'package:edu_cluezer/features/settings/controller/changePasswordController.dart';
import 'package:get/get.dart';

import '../../settings/controller/profileController.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => EditProfileController());
    Get.lazyPut(() => ProfileController());
    Get.lazyPut(() => UpProfileController() );
    Get.lazyPut(() => ChangePasswordController() );
  }
}
