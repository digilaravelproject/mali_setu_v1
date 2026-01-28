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
import '../domain/usecase/get_business_categories_usecase.dart';
import '../domain/usecase/get_business_details_usecase.dart';
import '../domain/usecase/get_business_products_usecase.dart';
import '../domain/usecase/get_business_services_usecase.dart';
import '../domain/usecase/get_my_businesses_usecase.dart';
import '../domain/usecase/add_business_product_usecase.dart';
import '../domain/usecase/add_business_service_usecase.dart';
import '../domain/usecase/update_business_usecase.dart';
import '../domain/usecase/delete_business_usecase.dart';
import '../domain/usecase/create_job_usecase.dart';
import '../domain/usecase/get_my_jobs_usecase.dart';
import '../domain/usecase/get_job_details_usecase.dart';
import '../domain/usecase/update_job_usecase.dart';
import '../domain/usecase/delete_job_usecase.dart';
import '../domain/usecase/toggle_job_status_usecase.dart';
import '../domain/usecase/get_job_analytics_usecase.dart';
import '../domain/usecase/apply_job_usecase.dart';
import '../domain/usecase/get_my_applications_usecase.dart';
import '../presentation/controller/business_controller.dart';



class BusinessBinding extends Bindings {
  @override
  void dependencies() {
    // Get.lazyPut(() => MatrimonyController());
    // Get.lazyPut(() => FilterController(), fenix: true);
    // UseCases
    Get.lazyPut(() => GetBusinessCategoriesUseCase(repository: Get.find()));

    Get.lazyPut(() => RegBusinessController(
      getBusinessCategoriesUseCase: Get.find(),
    ));

    Get.lazyPut<BusinessDataSource>(() => BusinessDataSourceImpl(apiClient: Get.find()));
    Get.lazyPut<BusinessRepository>(() => BusinessRepositoryImpl(dataSource: Get.find()));
    Get.lazyPut(() => GetAllBusinessesUseCase(repository: Get.find()));
    Get.lazyPut(() => GetMyBusinessesUseCase(repository: Get.find()));
    Get.lazyPut(() => GetBusinessDetailsUseCase(repository: Get.find()));
    Get.lazyPut(() => GetBusinessProductsUseCase(repository: Get.find()));
    Get.lazyPut(() => GetBusinessServicesUseCase(repository: Get.find()));
    Get.lazyPut(() => AddBusinessProductUseCase(repository: Get.find()));
    Get.lazyPut(() => AddBusinessServiceUseCase(repository: Get.find()));
    Get.lazyPut(() => UpdateBusinessUseCase(repository: Get.find()));
    Get.lazyPut(() => DeleteBusinessUseCase(repository: Get.find()));
    Get.lazyPut(() => CreateJobUseCase(repository: Get.find()));
    Get.lazyPut(() => UpdateJobUseCase(repository: Get.find()));
    Get.lazyPut(() => DeleteJobUseCase(repository: Get.find()));
    Get.lazyPut(() => GetMyJobsUseCase(repository: Get.find()));
    Get.lazyPut(() => GetJobDetailsUseCase(repository: Get.find()));
    Get.lazyPut(() => ToggleJobStatusUseCase(Get.find()));
    Get.lazyPut(() => GetJobAnalyticsUseCase(Get.find()));
    Get.lazyPut(() => ApplyJobUseCase(repository: Get.find()));
    Get.lazyPut(() => GetMyApplicationsUseCase(repository: Get.find()));
    
    // Controllers at the end
    Get.lazyPut(() => CreateJobController(
      createJobUseCase: Get.find(),
      updateJobUseCase: Get.find(),
    ), fenix: true);

    Get.lazyPut(() => BusinessController(
          getAllBusinessesUseCase: Get.find(),
          getMyBusinessesUseCase: Get.find(),
          getBusinessDetailsUseCase: Get.find(),
          getBusinessProductsUseCase: Get.find(),
          getBusinessServicesUseCase: Get.find(),
          addBusinessProductUseCase: Get.find(),
          addBusinessServiceUseCase: Get.find(),
          updateBusinessUseCase: Get.find(),
          deleteBusinessUseCase: Get.find(),
          getMyJobsUseCase: Get.find(),
          getJobDetailsUseCase: Get.find(),
          updateJobUseCase: Get.find(),
          deleteJobUseCase: Get.find(),
          toggleJobStatusUseCase: Get.find(),
          getJobAnalyticsUseCase: Get.find(),
          applyJobUseCase: Get.find(),
          getMyApplicationsUseCase: Get.find(),
        ), fenix: true);
  }
}
