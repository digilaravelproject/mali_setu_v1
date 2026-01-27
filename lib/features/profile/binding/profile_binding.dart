import 'package:edu_cluezer/features/profile/presentation/controller/edit_profile_controller.dart';
import 'package:edu_cluezer/features/profile/presentation/controller/profile_controller.dart';
import 'package:edu_cluezer/features/settings/controller/changePasswordController.dart';
import 'package:get/get.dart';

import '../../settings/controller/profileController.dart';
import '../../Auth/change_password/data/data_source/change_password_data_source.dart';
import '../../Auth/change_password/data/repository/change_password_repository_impl.dart';
import '../../Auth/change_password/domain/repository/change_password_repository.dart';
import '../../Auth/change_password/domain/usecase/change_password_usecase.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => EditProfileController());
    Get.lazyPut(() => ProfileController());
    Get.lazyPut(() => UpProfileController());

    // Change Password Dependencies
    Get.lazyPut<ChangePasswordDataSource>(
      () => ChangePasswordDataSourceImpl(apiClient: Get.find()),
    );
    Get.lazyPut<ChangePasswordRepository>(
      () => ChangePasswordRepositoryImpl(dataSource: Get.find()),
    );
    Get.lazyPut<ChangePasswordUseCase>(
      () => ChangePasswordUseCase(repository: Get.find()),
    );
    Get.lazyPut(() => ChangePasswordController(changePasswordUseCase: Get.find()));
  }
}
