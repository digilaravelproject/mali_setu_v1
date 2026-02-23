import 'package:get/get.dart';
import '../data/data_source/donation_data_source.dart';
import '../domain/repository/donation_repository.dart';
import '../presentation/controller/donation_controller.dart';

class DonationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DonationDataSource>(() => DonationDataSourceImpl(apiClient: Get.find()));
    Get.lazyPut<DonationRepository>(() => DonationRepositoryImpl(dataSource: Get.find()));
    Get.lazyPut(() => DonationController());
  }
}
