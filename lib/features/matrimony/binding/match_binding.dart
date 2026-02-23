import 'package:edu_cluezer/features/filter/presentation/controller/filter_controller.dart';
import 'package:edu_cluezer/features/matrimony/presentation/controller/reg_matrimony_controller.dart';
import 'package:get/get.dart';

import '../data/data_source/matrimony_data_source.dart';
import '../data/repository/matrimony_repository_impl.dart';
import '../domain/repository/matrimony_repository.dart';
import '../presentation/controller/matrimony_controller.dart';

import 'package:edu_cluezer/features/razorpay/payment_repository.dart';

class MatrimonyBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => MatrimonyController());
    Get.lazyPut(() => FilterController(), fenix: true);
    Get.lazyPut(() => PaymentRepository());

    // Data Layer
    Get.lazyPut<MatrimonyDataSource>(
      () => MatrimonyDataSourceImpl(apiClient: Get.find()),
      fenix: true,
    );

    Get.lazyPut<MatrimonyRepository>(
      () =>
          MatrimonyRepositoryImpl(dataSource: Get.find<MatrimonyDataSource>()),
      fenix: true,
    );

    Get.lazyPut(() => RegMatrimonyController());
  }
}
