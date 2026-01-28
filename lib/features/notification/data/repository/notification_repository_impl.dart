import '../../domain/repository/notification_repository.dart';
import '../../data/data_source/notification_data_source.dart';
import '../../data/model/notification_model.dart';
import 'package:get/get.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationDataSource dataSource;

  NotificationRepositoryImpl({required this.dataSource});

  @override
  Future<NotificationResponse> getNotifications({int page = 1}) async {
    return await dataSource.getNotifications(page: page);
  }

  @override
  Future<UnreadCountResponse> getUnreadCount() async {
    return await dataSource.getUnreadCount();
  }

  @override
  Future<void> deleteNotification(String id) async {
    await dataSource.deleteNotification(id);
  }

  @override
  Future<void> deleteMultipleNotifications(List<String> ids) async {
    await dataSource.deleteMultipleNotifications(ids);
  }
}
