import 'package:edu_cluezer/features/razorpay/payment_repository.dart';
import 'package:edu_cluezer/features/settings/controller/settings_controller.dart';
import 'package:edu_cluezer/features/razorpay/razorpay_controller.dart';
import 'package:edu_cluezer/features/volunteer/controller/volunteerController.dart';
import 'package:get/get.dart';

import 'package:edu_cluezer/features/business/data/data_source/all_business_data_source.dart';
import 'package:edu_cluezer/features/business/data/repository/all_business_repository_impl.dart';
import 'package:edu_cluezer/features/business/domain/repository/all_business_repository.dart';
import 'package:edu_cluezer/features/business/domain/usecase/get_business_categories_usecase.dart';
import '../../notification/data/data_source/notification_data_source.dart';
import '../../notification/data/repository/notification_repository_impl.dart';
import '../../notification/domain/repository/notification_repository.dart';
import '../../notification/presentation/controller/notification_controller.dart';

import '../../volunteer/controller/all_volunteer_controller.dart';
import '../../volunteer/data/data_source/volunteer_data_source.dart';
import '../../volunteer/data/repository/volunteer_repository_impl.dart';
import '../../volunteer/domain/repository/volunteer_repository.dart';
import '../../volunteer/domain/usecase/all_volunteer_use_case.dart';
import '../data/data_source/category_business_data_source.dart';
import '../data/repository/category_business_repository_impl.dart';
import '../domain/repository/category_business_repository.dart';
import '../domain/usecase/category_business_usecase.dart';
import '../presentation/controller/cat_business_controller.dart';
import '../presentation/controller/dashboard_controller.dart';
import '../presentation/controller/home_controller.dart';
import '../data/data_source/dashboard_data_source.dart';
import '../data/repository/dashboard_repository_impl.dart';
import '../domain/repository/dashboard_repository.dart';
import '../domain/usecase/get_banners_usecase.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    // Inject Business Dependencies for Home Screen Categories
    Get.lazyPut<BusinessDataSource>(() => BusinessDataSourceImpl(apiClient: Get.find()));
    Get.lazyPut<BusinessRepository>(() => BusinessRepositoryImpl(dataSource: Get.find()));
    Get.lazyPut(() => GetBusinessCategoriesUseCase(repository: Get.find()));

    // Inject Notification Dependencies (for Badge Count on Home)
    Get.lazyPut<NotificationDataSource>(() => NotificationDataSourceImpl(apiClient: Get.find()));
    Get.lazyPut<NotificationRepository>(() => NotificationRepositoryImpl(dataSource: Get.find()));
    Get.lazyPut(() => NotificationController(repository: Get.find()));

    Get.lazyPut<DashboardDataSource>(() => DashboardDataSourceImpl(apiClient: Get.find()));
    Get.lazyPut<DashboardRepository>(() => DashboardRepositoryImpl(dataSource: Get.find()));
    Get.lazyPut(() => GetBannersUseCase(repository: Get.find()));

    Get.lazyPut(() => DashboardController());
    Get.lazyPut(() => HomeController(
      getBusinessCategoriesUseCase: Get.find(),
      getBannersUseCase: Get.find(),
    ));
    Get.lazyPut(() => SettingsController(logoutUseCase: Get.find()));

    Get.lazyPut<CatBusinessDataSource>(() => CatBusinessDataSourceImpl(apiClient: Get.find()),);
    // Repository
    Get.lazyPut<CatBusinessRepository>(() => CatBusinessRepositoryImpl(dataSource: Get.find()),);
    // UseCase
    Get.lazyPut<GetBusinessByCategoryUseCase>(() => GetBusinessByCategoryUseCase(repository: Get.find()),);
    // Controller
    Get.lazyPut(() => CatBusinessController(useCase: Get.find()));


    // Data Source
    Get.lazyPut<VolunteerDataSource>(() => VolunteerDataSourceImpl(apiClient: Get.find()));

    // Repository
    Get.lazyPut<VolunteerRepository>(() => VolunteerRepositoryImpl(dataSource: Get.find()));

    // Use Case
    Get.lazyPut(() => VolunteerUseCase(repository: Get.find()));

    // Controller
    Get.lazyPut(() => AllVolunteerController(useCase: Get.find()));

    Get.lazyPut(() => PaymentRepository());
    Get.put(RazorpayController(), permanent: true);
  }
}


