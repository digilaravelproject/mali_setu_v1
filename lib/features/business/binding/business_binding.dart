import 'package:edu_cluezer/features/business/presentation/controller/create_job_controller.dart';
import 'package:edu_cluezer/features/business/presentation/controller/reg_business_controller.dart';
import 'package:edu_cluezer/features/business/presentation/page/create_job_post_page.dart';
import 'package:edu_cluezer/features/filter/presentation/controller/filter_controller.dart';
import 'package:edu_cluezer/features/matrimony/presentation/controller/reg_matrimony_controller.dart';
import 'package:get/get.dart';

import 'package:edu_cluezer/features/business/presentation/controller/business_controller.dart';
import 'package:edu_cluezer/features/business/data/data_source/all_business_data_source.dart';
import 'package:edu_cluezer/features/business/data/repository/all_business_repository_impl.dart';
import 'package:edu_cluezer/features/business/domain/repository/all_business_repository.dart';
import 'package:edu_cluezer/features/business/domain/usecase/all_business_usecase.dart';
import 'package:edu_cluezer/features/business/domain/usecase/get_business_categories_usecase.dart';
import 'package:edu_cluezer/features/business/domain/usecase/get_business_details_usecase.dart';
import 'package:edu_cluezer/features/business/domain/usecase/get_business_products_usecase.dart';
import 'package:edu_cluezer/features/business/domain/usecase/get_business_services_usecase.dart';
import 'package:edu_cluezer/features/business/domain/usecase/get_my_businesses_usecase.dart';
import 'package:edu_cluezer/features/business/domain/usecase/add_business_product_usecase.dart';
import 'package:edu_cluezer/features/business/domain/usecase/add_business_service_usecase.dart';
import 'package:edu_cluezer/features/business/domain/usecase/update_business_usecase.dart';
import 'package:edu_cluezer/features/business/domain/usecase/delete_business_usecase.dart';
import 'package:edu_cluezer/features/business/domain/usecase/create_job_usecase.dart';
import 'package:edu_cluezer/features/business/domain/usecase/get_my_jobs_usecase.dart';
import 'package:edu_cluezer/features/business/domain/usecase/get_job_details_usecase.dart';
import 'package:edu_cluezer/features/business/domain/usecase/update_job_usecase.dart';
import 'package:edu_cluezer/features/business/domain/usecase/delete_job_usecase.dart';
import 'package:edu_cluezer/features/business/domain/usecase/toggle_job_status_usecase.dart';
import 'package:edu_cluezer/features/business/domain/usecase/get_job_analytics_usecase.dart';
import 'package:edu_cluezer/features/business/domain/usecase/apply_job_usecase.dart';
import 'package:edu_cluezer/features/business/domain/usecase/get_my_applications_usecase.dart';
import 'package:edu_cluezer/features/business/domain/usecase/get_job_applications_usecase.dart';
import 'package:edu_cluezer/features/business/domain/usecase/update_application_status_usecase.dart';
import 'package:edu_cluezer/features/business/domain/usecase/search_business_usecase.dart';



class BusinessBinding extends Bindings {
  @override
  void dependencies() {
    // Get.lazyPut(() => MatrimonyController());
    // Get.lazyPut(() => FilterController(), fenix: true);
    // UseCases
    Get.lazyPut<GetBusinessCategoriesUseCase>(() => GetBusinessCategoriesUseCase(repository: Get.find<BusinessRepository>()), fenix: true);

    Get.lazyPut<RegBusinessController>(() => RegBusinessController(
      getBusinessCategoriesUseCase: Get.find<GetBusinessCategoriesUseCase>(),
      getBusinessDetailsUseCase: Get.find<GetBusinessDetailsUseCase>(),
    ), fenix: true);

    Get.lazyPut<BusinessDataSource>(() => BusinessDataSourceImpl(apiClient: Get.find()), fenix: true);
    Get.lazyPut<BusinessRepository>(() => BusinessRepositoryImpl(dataSource: Get.find()), fenix: true);
    Get.lazyPut<GetAllBusinessesUseCase>(() => GetAllBusinessesUseCase(repository: Get.find<BusinessRepository>()), fenix: true);
    Get.lazyPut<GetMyBusinessesUseCase>(() => GetMyBusinessesUseCase(repository: Get.find<BusinessRepository>()), fenix: true);
    Get.lazyPut<GetBusinessDetailsUseCase>(() => GetBusinessDetailsUseCase(repository: Get.find<BusinessRepository>()), fenix: true);
    Get.lazyPut<GetBusinessProductsUseCase>(() => GetBusinessProductsUseCase(repository: Get.find<BusinessRepository>()), fenix: true);
    Get.lazyPut<GetBusinessServicesUseCase>(() => GetBusinessServicesUseCase(repository: Get.find<BusinessRepository>()), fenix: true);
    Get.lazyPut<AddBusinessProductUseCase>(() => AddBusinessProductUseCase(repository: Get.find<BusinessRepository>()), fenix: true);
    Get.lazyPut<AddBusinessServiceUseCase>(() => AddBusinessServiceUseCase(repository: Get.find<BusinessRepository>()), fenix: true);
    Get.lazyPut<UpdateBusinessUseCase>(() => UpdateBusinessUseCase(repository: Get.find<BusinessRepository>()), fenix: true);
    Get.lazyPut<DeleteBusinessUseCase>(() => DeleteBusinessUseCase(repository: Get.find<BusinessRepository>()), fenix: true);
    Get.lazyPut<CreateJobUseCase>(() => CreateJobUseCase(repository: Get.find<BusinessRepository>()), fenix: true);
    Get.lazyPut<UpdateJobUseCase>(() => UpdateJobUseCase(repository: Get.find<BusinessRepository>()), fenix: true);
    Get.lazyPut<DeleteJobUseCase>(() => DeleteJobUseCase(repository: Get.find<BusinessRepository>()), fenix: true);
    Get.lazyPut<GetMyJobsUseCase>(() => GetMyJobsUseCase(repository: Get.find<BusinessRepository>()), fenix: true);
    Get.lazyPut<GetJobDetailsUseCase>(() => GetJobDetailsUseCase(repository: Get.find<BusinessRepository>()), fenix: true);
    Get.lazyPut<ToggleJobStatusUseCase>(() => ToggleJobStatusUseCase(Get.find<BusinessRepository>()), fenix: true);
    Get.lazyPut<GetJobAnalyticsUseCase>(() => GetJobAnalyticsUseCase(Get.find<BusinessRepository>()), fenix: true);
    Get.lazyPut<ApplyJobUseCase>(() => ApplyJobUseCase(repository: Get.find<BusinessRepository>()), fenix: true);
    Get.lazyPut<GetMyApplicationsUseCase>(() => GetMyApplicationsUseCase(repository: Get.find<BusinessRepository>()), fenix: true);
    Get.lazyPut<GetJobApplicationsUseCase>(() => GetJobApplicationsUseCase(repository: Get.find<BusinessRepository>()), fenix: true);
    Get.lazyPut<UpdateApplicationStatusUseCase>(() => UpdateApplicationStatusUseCase(repository: Get.find<BusinessRepository>()), fenix: true);
    Get.lazyPut<SearchBusinessUseCase>(() => SearchBusinessUseCase(repository: Get.find<BusinessRepository>()), fenix: true);
    
    // Controllers at the end
    Get.lazyPut<CreateJobController>(() => CreateJobController(
      createJobUseCase: Get.find<CreateJobUseCase>(),
      updateJobUseCase: Get.find<UpdateJobUseCase>(),
    ), fenix: true);

    Get.lazyPut<BusinessController>(() => BusinessController(
          getAllBusinessesUseCase: Get.find<GetAllBusinessesUseCase>(),
          getMyBusinessesUseCase: Get.find<GetMyBusinessesUseCase>(),
          getBusinessDetailsUseCase: Get.find<GetBusinessDetailsUseCase>(),
          getBusinessProductsUseCase: Get.find<GetBusinessProductsUseCase>(),
          getBusinessServicesUseCase: Get.find<GetBusinessServicesUseCase>(),
          addBusinessProductUseCase: Get.find<AddBusinessProductUseCase>(),
          addBusinessServiceUseCase: Get.find<AddBusinessServiceUseCase>(),
          updateBusinessUseCase: Get.find<UpdateBusinessUseCase>(),
          deleteBusinessUseCase: Get.find<DeleteBusinessUseCase>(),
          getMyJobsUseCase: Get.find<GetMyJobsUseCase>(),
          getJobDetailsUseCase: Get.find<GetJobDetailsUseCase>(),
          updateJobUseCase: Get.find<UpdateJobUseCase>(),
          deleteJobUseCase: Get.find<DeleteJobUseCase>(),
          toggleJobStatusUseCase: Get.find<ToggleJobStatusUseCase>(),
          getJobAnalyticsUseCase: Get.find<GetJobAnalyticsUseCase>(),
          applyJobUseCase: Get.find<ApplyJobUseCase>(),
          getMyApplicationsUseCase: Get.find<GetMyApplicationsUseCase>(),
          getJobApplicationsUseCase: Get.find<GetJobApplicationsUseCase>(),
       //   getJobApplicationsUseCase: Get.find<GetJobApplicationsUseCase>(),
          updateApplicationStatusUseCase: Get.find<UpdateApplicationStatusUseCase>(),
          searchBusinessUseCase: Get.find<SearchBusinessUseCase>(),
        ), fenix: true);
  }
}
