import 'package:edu_cluezer/features/matrimony/data/data_source/matrimony_data_source.dart';
import 'package:edu_cluezer/features/matrimony/data/repository/matrimony_repository_impl.dart';
import 'package:edu_cluezer/features/matrimony/domain/repository/matrimony_repository.dart';
import 'package:edu_cluezer/features/matrimony/presentation/controller/blocked_users_controller.dart';
import 'package:get/get.dart';

class BlockedUsersBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<MatrimonyDataSource>()) {
      Get.lazyPut<MatrimonyDataSource>(
        () => MatrimonyDataSourceImpl(apiClient: Get.find()),
        fenix: true,
      );
    }
    if (!Get.isRegistered<MatrimonyRepository>()) {
      Get.lazyPut<MatrimonyRepository>(
        () => MatrimonyRepositoryImpl(dataSource: Get.find<MatrimonyDataSource>()),
        fenix: true,
      );
    }
    Get.lazyPut<BlockedUsersController>(() => BlockedUsersController());
  }
}
