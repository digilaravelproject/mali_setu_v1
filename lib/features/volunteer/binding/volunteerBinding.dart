import 'package:edu_cluezer/features/volunteer/controller/volunteerController.dart';
import 'package:get/get.dart';

import '../../../core/network/api_client.dart';
import '../controller/opportunity_details_controller.dart';
import '../controller/volunteerUpdateProfileController.dart';
import '../data/data_source/volunteer_data_source.dart';
import '../data/repository/volunteer_repository_impl.dart';
import '../domain/repository/volunteer_repository.dart';
import '../domain/usecase/all_volunteer_use_case.dart';
import '../domain/usecase/single_volunteer_use_case.dart';

class VolunteerBinding extends Bindings {
  @override
  void dependencies() {
    // Data Source
    Get.lazyPut<VolunteerDataSource>(() => VolunteerDataSourceImpl(apiClient: Get.find<ApiClient>()));

    // Repository
    Get.lazyPut<VolunteerRepository>(() => VolunteerRepositoryImpl(dataSource: Get.find<VolunteerDataSource>()));

    // Use Case
    Get.lazyPut(() => VolunteerUseCase(repository: Get.find<VolunteerRepository>()));
    Get.lazyPut(() => SingleVolunteerUseCase(repository: Get.find<VolunteerRepository>()));

    // Controller
    Get.lazyPut(() => VolunteerProfileController(repository: Get.find<VolunteerRepository>()));
    Get.lazyPut(() => VoluntProfileUpdateController(repository: Get.find<VolunteerRepository>()));
    Get.lazyPut(() => OpportunityDetailsController(useCase: Get.find<SingleVolunteerUseCase>()));
  }
}