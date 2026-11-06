import 'package:get/get.dart';
import '../../../../core/network/api_client.dart';
import '../../data/data_source/referral_data_source.dart';
import '../../data/repository/referral_repository_impl.dart';
import '../../domain/repository/referral_repository.dart';
import '../controller/referral_controller.dart';

class ReferralBinding extends Bindings {
  /// Safely ensures all dependencies for Referral (ApiClient, DataSource, Repository, Controller)
  /// are initialized and registered, and returns the [ReferralController] instance.
  static ReferralController init() {
    final apiClient = Get.isRegistered<ApiClient>() ? Get.find<ApiClient>() : ApiClient();
    if (!Get.isRegistered<ApiClient>()) {
      Get.put<ApiClient>(apiClient, permanent: true);
    }

    final dataSource = Get.isRegistered<ReferralDataSource>()
        ? Get.find<ReferralDataSource>()
        : Get.put<ReferralDataSource>(
            ReferralDataSourceImpl(apiClient: apiClient),
            permanent: true,
          );

    final repository = Get.isRegistered<ReferralRepository>()
        ? Get.find<ReferralRepository>()
        : Get.put<ReferralRepository>(
            ReferralRepositoryImpl(dataSource: dataSource),
            permanent: true,
          );

    if (Get.isRegistered<ReferralController>()) {
      try {
        return Get.find<ReferralController>();
      } catch (_) {
        // If Get.find fails for any reason, re-put below
      }
    }

    return Get.put<ReferralController>(
      ReferralController(repository: repository),
      permanent: true,
    );
  }

  @override
  void dependencies() {
    init();
  }
}
