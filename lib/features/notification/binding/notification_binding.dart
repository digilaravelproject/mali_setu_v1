import 'package:get/get.dart';
import '../../../../core/network/api_client.dart';
import '../data/data_source/notification_data_source.dart';
import '../data/repository/notification_repository_impl.dart';
import '../domain/repository/notification_repository.dart';
import '../presentation/controller/notification_controller.dart';

class NotificationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NotificationDataSource>(
      () => NotificationDataSourceImpl(apiClient: Get.find<ApiClient>()),
    );
    Get.lazyPut<NotificationRepository>(
      () => NotificationRepositoryImpl(dataSource: Get.find<NotificationDataSource>()),
    );
    Get.lazyPut(() => NotificationController(repository: Get.find<NotificationRepository>()));
  }
}
