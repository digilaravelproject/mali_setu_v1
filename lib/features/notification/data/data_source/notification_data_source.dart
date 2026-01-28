import '../../../../../../core/network/api_client.dart';
import '../../../../../../core/constent/api_constants.dart';
import '../model/notification_model.dart';
import 'package:dio/dio.dart';

abstract class NotificationDataSource {
  Future<NotificationResponse> getNotifications({int page = 1});
  Future<UnreadCountResponse> getUnreadCount();
  Future<void> deleteNotification(String id);
  Future<void> deleteMultipleNotifications(List<String> ids);
}

class NotificationDataSourceImpl implements NotificationDataSource {
  final ApiClient apiClient;

  NotificationDataSourceImpl({required this.apiClient});

  @override
  Future<NotificationResponse> getNotifications({int page = 1}) async {
    final response = await apiClient.get('${ApiConstants.getNotifications}?page=$page');
    return NotificationResponse.fromJson(response.data);
  }

  @override
  Future<UnreadCountResponse> getUnreadCount() async {
    final response = await apiClient.get(ApiConstants.getUnreadCount);
    return UnreadCountResponse.fromJson(response.data);
  }

  @override
  Future<void> deleteNotification(String id) async {
    await apiClient.delete('${ApiConstants.deleteNotification}/$id');
  }

  @override
  Future<void> deleteMultipleNotifications(List<String> ids) async {
    await apiClient.delete(
      ApiConstants.deleteMultipleNotifications,
      data: {'notification_ids': ids},
    );
  }
}
