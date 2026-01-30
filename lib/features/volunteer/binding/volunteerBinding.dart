import 'package:edu_cluezer/features/volunteer/controller/volunteerController.dart';
import 'package:get/get.dart';

import '../../../core/network/api_client.dart';
import '../controller/volunteerUpdateProfileController.dart';
import '../data/data_source/volunteer_data_source.dart';
import '../data/repository/volunteer_repository_impl.dart';
import '../domain/repository/volunteer_repository.dart';

class VolunteerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VolunteerDataSource>(() => VolunteerDataSourceImpl(apiClient: Get.find<ApiClient>()));
    Get.lazyPut<VolunteerRepository>(() => VolunteerRepositoryImpl(dataSource: Get.find<VolunteerDataSource>()));

    Get.lazyPut(() => VolunteerProfileController(repository: Get.find<VolunteerRepository>()));
    Get.lazyPut(() => VoluntProfileUpdateController(repository: Get.find<VolunteerRepository>()));
  }
}