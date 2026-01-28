import '../../data/model/notification_model.dart';

abstract class NotificationRepository {
  Future<NotificationResponse> getNotifications({int page = 1});
  Future<UnreadCountResponse> getUnreadCount();
  Future<void> deleteNotification(String id);
  Future<void> deleteMultipleNotifications(List<String> ids);
}
