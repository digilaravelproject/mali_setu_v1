import 'package:edu_cluezer/features/business/presentation/controller/create_job_controller.dart';
import 'package:edu_cluezer/features/business/presentation/controller/reg_business_controller.dart';
import 'package:edu_cluezer/features/business/presentation/page/create_job_post_page.dart';
import 'package:edu_cluezer/features/filter/presentation/controller/filter_controller.dart';
import 'package:edu_cluezer/features/matrimony/presentation/controller/reg_matrimony_controller.dart';
import 'package:get/get.dart';

import '../data/data_source/all_business_data_source.dart';
import '../data/repository/all_business_repository_impl.dart';
import '../domain/repository/all_business_repository.dart';
import '../domain/usecase/all_business_usecase.dart';
import '../presentation/controller/business_controller.dart';



class BusinessBinding extends Bindings {
  @override
  void dependencies() {
    // Get.lazyPut(() => MatrimonyController());
    // Get.lazyPut(() => FilterController(), fenix: true);
    Get.lazyPut(() => CreateJobController());
    Get.lazyPut(() => RegBusinessController());

    Get.lazyPut<BusinessDataSource>(() => BusinessDataSourceImpl(apiClient: Get.find()));
    Get.lazyPut<BusinessRepository>(() => BusinessRepositoryImpl(dataSource: Get.find()));
    Get.lazyPut(() => GetAllBusinessesUseCase(repository: Get.find()));
    Get.lazyPut(() => BusinessController(getAllBusinessesUseCase: Get.find()));
  }
}
