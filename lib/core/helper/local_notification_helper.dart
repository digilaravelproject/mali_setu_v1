import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:open_filex/open_filex.dart';
import '../services/notification_handler_service.dart';

class LocalNotificationHelper {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    try {
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/launcher_icon');
      
      const DarwinInitializationSettings initializationSettingsDarwin =
          DarwinInitializationSettings();
      
      const InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsDarwin,
      );

      // Create download channel on Android
      final androidPlugin = _notificationsPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        await androidPlugin.createNotificationChannel(
          const AndroidNotificationChannel(
            'download_channel',
            'Downloads',
            description: 'Notifications for file downloads',
            importance: Importance.low,
          ),
        );
      }

      await _notificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) async {
          final String? payload = response.payload;
          if (payload != null && payload.isNotEmpty) {
            if (payload.trim().startsWith('{')) {
              try {
                final Map<String, dynamic> data = json.decode(payload);
                NotificationHandlerService.navigateFromPayload(data);
              } catch (e) {
                print("❌ [LocalNotificationHelper] Error navigating from payload: $e");
              }
            } else {
              try {
                await OpenFilex.open(payload);
              } catch (e) {
                print("Error opening file: $e");
              }
            }
          }
        },
      );
    } catch (e) {
      print("❌ [LocalNotificationHelper] init error: $e");
    }
  }

  static Future<void> showDownloadNotification({
    required int id,
    required String title,
    required String body,
    int? progress,
  }) async {
    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'download_channel',
      'Downloads',
      channelDescription: 'Notifications for file downloads',
      importance: Importance.low,
      priority: Priority.low,
      onlyAlertOnce: true,
      showProgress: progress != null,
      maxProgress: 100,
      progress: progress ?? 0,
      ongoing: progress != null && progress < 100,
    );

    final NotificationDetails notificationDetails = NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails,
    );
  }

  static Future<void> showDownloadCompleteNotification({
    required int id,
    required String title,
    required String body,
    required String filePath,
  }) async {
    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'download_channel',
      'Downloads',
      channelDescription: 'Notifications for file downloads',
      importance: Importance.high,
      priority: Priority.high,
    );

    final NotificationDetails notificationDetails = NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails,
      payload: filePath,
    );
  }
}
