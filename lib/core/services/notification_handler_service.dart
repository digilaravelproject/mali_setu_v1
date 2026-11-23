import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:open_filex/open_filex.dart';

import '../../features/webinars/data/models/webinar_model.dart';
import 'deep_link_service.dart';
import '../constent/api_constants.dart';
import '../constent/app_constants.dart';
import '../network/api_client.dart';
import '../routes/app_routes.dart';
import '../storage/shared_prefs.dart';
import '../storage/token_manger.dart';
import '../../features/Auth/service/auth_service.dart';
import '../../features/business/data/model/res_all_business_model.dart';
import '../../features/matrimony/presentation/controller/matrimony_chat_controller.dart';
import '../../features/matrimony/presentation/controller/matrimony_requests_controller.dart';
import '../../features/matrimony/presentation/page/matrimony_profile_screen.dart';
import '../../features/matrimony/presentation/controller/matrimony_details_controller.dart';
import '../../features/matrimony/binding/matrimony_details_binding.dart';
import '../../features/notification/data/model/notification_model.dart' hide NotificationResponse;
import '../../features/notification/presentation/controller/notification_controller.dart';
import '../../features/blogs/presentation/screens/blog_detail_screen.dart';
import '../../features/blogs/presentation/screens/blogs_screen.dart';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse response) {
  final String? payloadStr = response.payload;
  if (payloadStr != null && payloadStr.trim().startsWith('{')) {
    try {
      final Map<String, dynamic> data = json.decode(payloadStr);
      NotificationHandlerService.navigateFromPayload(data);
    } catch (_) {}
  }
}

/// Centralized Notification Handler & Deep Navigation Service for Mali Setu
/// Handles:
/// 1. Terminated/Killed State (Cold Start via Notification)
/// 2. Background State (Warm Start via System Tray click)
/// 3. Foreground State (In-app Heads-up Notification & Click)
/// 4. In-App Notification Center (`/notification` screen list item click)
class NotificationHandlerService extends GetxService {
  static NotificationHandlerService get to => Get.find<NotificationHandlerService>();

  static bool isAppReady = false;
  static Map<String, dynamic>? pendingNotificationPayload;

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  static const String _fcmChannelId = 'fcm_push_channel';
  static const String _fcmChannelName = 'General Notifications';
  static const String _fcmChannelDescription = 'Notifications for messages, jobs, matrimony, and updates';

  /// Check if the user is currently authenticated
  static bool get isUserLoggedIn {
    if (Get.isRegistered<AuthService>()) {
      return Get.find<AuthService>().isLoggedIn.value;
    }
    return SharedPrefs.getBool(AppConstants.isLoggedInPref) ?? false;
  }

  /// Initialize notification listeners and channels
  Future<NotificationHandlerService> init() async {
    try {
      await _setupLocalNotifications();
    } catch (e) {
      debugPrint("❌ [NotificationHandler] Error in _setupLocalNotifications: $e");
    }
    try {
      await _setupFCM();
    } catch (e) {
      debugPrint("❌ [NotificationHandler] Error in _setupFCM: $e");
    }
    return this;
  }

  /// 1. Setup Local Notification Plugin for Foreground Banners
  Future<void> _setupLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/launcher_icon');
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        final String? payloadStr = response.payload;
        debugPrint("📲 [NotificationHandler] Foreground notification TAPPED. Payload: $payloadStr");
        if (payloadStr != null && payloadStr.isNotEmpty) {
          if (payloadStr.trim().startsWith('{')) {
            try {
              final Map<String, dynamic> data = json.decode(payloadStr);
              WidgetsBinding.instance.addPostFrameCallback((_) {
                navigateFromPayload(data);
              });
            } catch (e) {
              debugPrint("❌ [NotificationHandler] Failed to parse local notification payload: $e");
            }
          } else {
            try {
              OpenFilex.open(payloadStr);
            } catch (e) {
              debugPrint("❌ [NotificationHandler] Failed to open file: $e");
            }
          }
        }
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    // Check if a local notification launched the app from killed state
    try {
      final launchDetails = await _localNotifications.getNotificationAppLaunchDetails();
      if (launchDetails != null && launchDetails.didNotificationLaunchApp) {
        final payloadStr = launchDetails.notificationResponse?.payload;
        if (payloadStr != null && payloadStr.trim().startsWith('{')) {
          final Map<String, dynamic> data = json.decode(payloadStr);
          _handleIncomingPayload(data);
        }
      }
    } catch (e) {
      debugPrint("⚠️ [NotificationHandler] Error checking launch details: $e");
    }

    // Create Android High Importance Notification Channels
    final androidPlugin = _localNotifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          _fcmChannelId,
          _fcmChannelName,
          description: _fcmChannelDescription,
          importance: Importance.max,
          playSound: true,
        ),
      );
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'high_importance_channel',
          'High Importance Notifications',
          description: 'This channel is used for important notifications.',
          importance: Importance.max,
          playSound: true,
        ),
      );
    }
  }

  /// Helper to merge notification title/body into data payload so nothing is lost
  static Map<String, dynamic> _extractRemoteMessageData(RemoteMessage message) {
    final Map<String, dynamic> data = Map<String, dynamic>.from(message.data);
    if (message.notification != null) {
      if (!data.containsKey('title') || data['title'] == null || data['title'].toString().isEmpty) {
        data['title'] = message.notification!.title;
      }
      if (!data.containsKey('message') || data['message'] == null || data['message'].toString().isEmpty) {
        data['message'] = message.notification!.body;
      }
      if (!data.containsKey('body') || data['body'] == null || data['body'].toString().isEmpty) {
        data['body'] = message.notification!.body;
      }
    }
    return data;
  }

  /// 2. Setup Firebase Cloud Messaging Listeners
  Future<void> _setupFCM() async {
    try {
      // Request Push Notification Permissions
      NotificationSettings settings = await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
      debugPrint("🔔 [NotificationHandler] Permission status: ${settings.authorizationStatus}");

      // Retrieve device FCM Token and sync with backend
      await syncFcmToken();

      // Subscribe to global topics for broadcast notifications
      try {
        await _fcm.subscribeToTopic('all_users');
        await _fcm.subscribeToTopic('general');
        debugPrint("🔔 [NotificationHandler] Subscribed to topics: all_users, general");
      } catch (e) {
        debugPrint("⚠️ [NotificationHandler] Failed to subscribe to topic: $e");
      }

      // Listen for token refreshes
      _fcm.onTokenRefresh.listen((newToken) {
        if (newToken.isNotEmpty) {
          sendFcmTokenToServer(newToken);
        }
      });

      // ── STATE 1: APP WAS KILLED / TERMINATED ──────────────────────────────
      // User tapped notification from dead state to launch the app
      RemoteMessage? initialMessage = await _fcm.getInitialMessage();
      if (initialMessage != null) {
        debugPrint("🚀 [NotificationHandler] App launched from KILLED state via notification");
        debugPrint("   Data Payload: ${initialMessage.data}");
        _handleIncomingPayload(_extractRemoteMessageData(initialMessage));
      }

      // ── STATE 2: APP WAS IN BACKGROUND ────────────────────────────────────
      // User tapped notification from system tray while app is minimized
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint("📲 [NotificationHandler] Notification CLICKED from BACKGROUND tray");
        debugPrint("   Data Payload: ${message.data}");
        navigateFromPayload(_extractRemoteMessageData(message));
      });

      // ── STATE 3: APP IS IN FOREGROUND (USER ACTIVELY USING APP) ───────────
      // Display a heads-up local notification banner with sound
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint("🔔 [NotificationHandler] FOREGROUND notification received");
        debugPrint("   Title: ${message.notification?.title}");
        debugPrint("   Data:  ${message.data}");

        // Auto-refresh unread badge in app if NotificationController is open
        if (Get.isRegistered<NotificationController>()) {
          Get.find<NotificationController>().loadUnreadCount();
        }

        // Display local heads-up notification in system tray
        _showForegroundNotification(message);
      });
    } catch (e) {
      debugPrint("❌ [NotificationHandler] Error setting up FCM: $e");
    }
  }

  /// Show a Heads-up Local Notification when app is in the foreground
  Future<void> _showForegroundNotification(RemoteMessage message) async {
    final Map<String, dynamic> extractedData = _extractRemoteMessageData(message);

    String title = (message.notification?.title ?? extractedData['title'] ?? 'Mali Setu').toString().trim();
    String body = (message.notification?.body ?? extractedData['message'] ?? extractedData['body'] ?? '').toString().trim();

    try {
      final dynamic rawInnerData = extractedData['data'];
      Map<String, dynamic>? innerMap;
      if (rawInnerData is String && rawInnerData.trim().startsWith('{')) {
        innerMap = Map<String, dynamic>.from(json.decode(rawInnerData));
      } else if (rawInnerData is Map) {
        innerMap = Map<String, dynamic>.from(rawInnerData);
      }

      final dynamic rawNotif = extractedData['notification'];
      Map<String, dynamic>? innerNotif;
      if (rawNotif is String && rawNotif.trim().startsWith('{')) {
        innerNotif = Map<String, dynamic>.from(json.decode(rawNotif));
      } else if (rawNotif is Map) {
        innerNotif = Map<String, dynamic>.from(rawNotif);
      }

      // If title is "New Blog: " or ends with ':', complete it using inner title
      if (title.isEmpty || title == 'New Blog:' || title == 'New Blog' || title.endsWith(':')) {
        final innerTitle = (innerNotif?['title'] ?? innerMap?['title'] ?? extractedData['blog_title'] ?? '')?.toString();
        if (innerTitle != null && innerTitle.isNotEmpty) {
          title = title.isNotEmpty ? "$title $innerTitle" : innerTitle;
        }
      }

      // If body starts with "published a new blog" or is empty, use inner body
      if (body.isEmpty || body.startsWith('published a new blog') || body == 'published a new blog.') {
        final innerBody = (innerNotif?['body'] ?? innerMap?['body'] ?? '')?.toString();
        if (innerBody != null && innerBody.isNotEmpty) {
          body = innerBody;
        }
      }
    } catch (_) {}

    final String? imageUrl = _extractImageUrl(message, extractedData);
    String? localImagePath;
    if (imageUrl != null && imageUrl.isNotEmpty) {
      localImagePath = await _downloadAndSaveImage(imageUrl);
    }

    AndroidNotificationDetails androidDetails;
    if (localImagePath != null && localImagePath.isNotEmpty) {
      final bigPicture = BigPictureStyleInformation(
        FilePathAndroidBitmap(localImagePath),
        largeIcon: FilePathAndroidBitmap(localImagePath),
        contentTitle: title,
        summaryText: body,
      );
      androidDetails = AndroidNotificationDetails(
        _fcmChannelId,
        _fcmChannelName,
        channelDescription: _fcmChannelDescription,
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        styleInformation: bigPicture,
        icon: '@mipmap/launcher_icon',
      );
    } else {
      androidDetails = const AndroidNotificationDetails(
        _fcmChannelId,
        _fcmChannelName,
        channelDescription: _fcmChannelDescription,
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        icon: '@mipmap/launcher_icon',
      );
    }

    DarwinNotificationDetails darwinDetails;
    if (localImagePath != null && localImagePath.isNotEmpty) {
      darwinDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        attachments: [DarwinNotificationAttachment(localImagePath)],
      );
    } else {
      darwinDetails = const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );
    }

    final details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
      payload: json.encode(extractedData),
    );
  }

  /// Normalize image URL by prepending base URL if path is relative
  static String? _normalizeImageUrl(String? rawUrl) {
    if (rawUrl == null) return null;
    final trimmed = rawUrl.trim();
    if (trimmed.isEmpty || trimmed == 'null') return null;
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    if (trimmed.startsWith('/storage/')) {
      return '${ApiConstants.baseUrl}$trimmed';
    }
    if (trimmed.startsWith('storage/')) {
      return '${ApiConstants.baseUrl}/$trimmed';
    }
    return '${ApiConstants.imageBaseUrl}${trimmed.replaceFirst(RegExp(r'^\/+'), '')}';
  }

  /// Extract image URL from FCM RemoteMessage or payload data
  static String? _extractImageUrl(RemoteMessage message, Map<String, dynamic> extractedData) {
    if (message.notification?.android?.imageUrl != null &&
        message.notification!.android!.imageUrl!.isNotEmpty) {
      return _normalizeImageUrl(message.notification!.android!.imageUrl);
    }
    if (message.notification?.apple?.imageUrl != null &&
        message.notification!.apple!.imageUrl!.isNotEmpty) {
      return _normalizeImageUrl(message.notification!.apple!.imageUrl);
    }

    const imageKeys = [
      'image',
      'image_url',
      'imageUrl',
      'media_path',
      'mediaPath',
      'media',
      'media_url',
      'picture',
      'picture_url',
      'photo',
      'photo_url',
      'banner',
      'banner_url',
      'thumbnail',
      'featured_image',
    ];

    for (final key in imageKeys) {
      final val = extractedData[key]?.toString();
      if (val != null && val.isNotEmpty && val != 'null') {
        return _normalizeImageUrl(val);
      }
    }

    try {
      final dynamic rawInner = extractedData['data'];
      Map<String, dynamic>? innerMap;
      if (rawInner is String && rawInner.trim().startsWith('{')) {
        innerMap = Map<String, dynamic>.from(json.decode(rawInner));
      } else if (rawInner is Map) {
        innerMap = Map<String, dynamic>.from(rawInner);
      }
      if (innerMap != null) {
        for (final key in imageKeys) {
          final val = innerMap[key]?.toString();
          if (val != null && val.isNotEmpty && val != 'null') {
            return _normalizeImageUrl(val);
          }
        }
      }
    } catch (_) {}

    // Check inside nested 'blog' map if present
    if (extractedData['blog'] is Map) {
      final Map b = extractedData['blog'];
      for (final key in imageKeys) {
        final val = b[key]?.toString();
        if (val != null && val.isNotEmpty && val != 'null') {
          return _normalizeImageUrl(val);
        }
      }
    }

    // Check inside nested 'post' map if present
    if (extractedData['post'] is Map) {
      final Map p = extractedData['post'];
      for (final key in imageKeys) {
        final val = p[key]?.toString();
        if (val != null && val.isNotEmpty && val != 'null') {
          return _normalizeImageUrl(val);
        }
      }
    }

    return null;
  }

  /// Download notification image from URL and save to a local temp file for BigPicture display
  static Future<String?> _downloadAndSaveImage(String? url) async {
    if (url == null || url.trim().isEmpty) return null;
    final normalizedUrl = _normalizeImageUrl(url);
    if (normalizedUrl == null) return null;

    try {
      final Uri? uri = Uri.tryParse(normalizedUrl);
      if (uri == null || (!uri.isScheme('http') && !uri.isScheme('https'))) return null;

      debugPrint("🖼️ [NotificationHandler] Downloading notification image: $normalizedUrl");
      final HttpClient client = HttpClient()..connectionTimeout = const Duration(seconds: 10);
      final HttpClientRequest request = await client.getUrl(uri);
      final HttpClientResponse response = await request.close().timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<int> bytes = await response.fold<List<int>>(<int>[], (List<int> prev, List<int> elem) => prev..addAll(elem));
        if (bytes.isNotEmpty) {
          final Directory dir = await getTemporaryDirectory();
          final String filePath = '${dir.path}/fcm_${DateTime.now().millisecondsSinceEpoch}.png';
          final File file = File(filePath);
          await file.writeAsBytes(bytes, flush: true);
          debugPrint("✅ [NotificationHandler] Image saved successfully to $filePath (${bytes.length} bytes)");
          return filePath;
        }
      } else {
        debugPrint("⚠️ [NotificationHandler] Image download failed with status: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("⚠️ [NotificationHandler] Failed to download notification image: $e");
    }
    return null;
  }

  /// Show rich notification when app is in Background or Terminated for data-only messages
  static Future<void> showBackgroundNotification(RemoteMessage message) async {
    try {
      final Map<String, dynamic> extractedData = _extractRemoteMessageData(message);

      String title = (message.notification?.title ?? extractedData['title'] ?? 'Mali Setu').toString().trim();
      String body = (message.notification?.body ?? extractedData['message'] ?? extractedData['body'] ?? '').toString().trim();

      if (title.isEmpty && body.isEmpty) {
        return;
      }

      final String? imageUrl = _extractImageUrl(message, extractedData);
      String? localImagePath;
      if (imageUrl != null && imageUrl.isNotEmpty) {
        localImagePath = await _downloadAndSaveImage(imageUrl);
      }

      final FlutterLocalNotificationsPlugin localPlugin = FlutterLocalNotificationsPlugin();
      const androidSettings = AndroidInitializationSettings('@mipmap/launcher_icon');
      const darwinSettings = DarwinInitializationSettings();
      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
      );
      await localPlugin.initialize(initSettings);

      AndroidNotificationDetails androidDetails;
      if (localImagePath != null && localImagePath.isNotEmpty) {
        final bigPicture = BigPictureStyleInformation(
          FilePathAndroidBitmap(localImagePath),
          largeIcon: FilePathAndroidBitmap(localImagePath),
          contentTitle: title,
          summaryText: body,
        );
        androidDetails = AndroidNotificationDetails(
          _fcmChannelId,
          _fcmChannelName,
          channelDescription: _fcmChannelDescription,
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          styleInformation: bigPicture,
          icon: '@mipmap/launcher_icon',
        );
      } else {
        androidDetails = const AndroidNotificationDetails(
          _fcmChannelId,
          _fcmChannelName,
          channelDescription: _fcmChannelDescription,
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          icon: '@mipmap/launcher_icon',
        );
      }

      DarwinNotificationDetails darwinDetails;
      if (localImagePath != null && localImagePath.isNotEmpty) {
        darwinDetails = DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          attachments: [DarwinNotificationAttachment(localImagePath)],
        );
      } else {
        darwinDetails = const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        );
      }

      final NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: darwinDetails,
      );

      final int notifId = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      await localPlugin.show(
        notifId,
        title,
        body,
        details,
        payload: json.encode(extractedData),
      );
    } catch (e) {
      debugPrint("❌ [NotificationHandler] Error in showBackgroundNotification: $e");
    }
  }

  /// Sync FCM device token with backend API (PUT /api/auth/fcm-token)
  Future<void> syncFcmToken() async {
    try {
      if (Platform.isIOS) {
        final apnsToken = await _fcm.getAPNSToken();
        if (apnsToken == null) {
          debugPrint("⚠️ [NotificationHandler] APNs token is not yet ready on iOS. Skipping immediate getToken.");
          return;
        }
      }
      String? token = await _fcm.getToken();
      if (token != null && token.isNotEmpty) {
        await sendFcmTokenToServer(token);
      }
    } catch (e) {
      debugPrint("❌ [NotificationHandler] Error retrieving FCM token: $e");
    }
  }

  /// Call backend to update FCM token
  Future<void> sendFcmTokenToServer(String token) async {
    try {
      final authToken = await TokenManager.getToken();
      if (authToken.isEmpty) {
        return;
      }
      final apiClient = Get.find<ApiClient>();
      await apiClient.put(
        ApiConstants.updateFcmToken,
        data: {"fcm_token": token},
      );
      debugPrint("✅ [NotificationHandler] FCM token synced with backend.");
    } catch (e) {
      debugPrint("⚠️ [NotificationHandler] Could not sync FCM token: $e");
    }
  }

  /// Handle incoming payload safely (stores if splash/init is still running)
  static void _handleIncomingPayload(Map<String, dynamic> data) {
    if (!isAppReady) {
      debugPrint("⏳ [NotificationHandler] App not ready yet. Storing pending notification payload.");
      pendingNotificationPayload = data;
    } else {
      navigateFromPayload(data);
    }
  }

  /// Trigger pending notification after splash screen transition completes
  static void executePendingNotification() {
    final payload = pendingNotificationPayload;
    pendingNotificationPayload = null;
    if (payload != null && payload.isNotEmpty) {
      debugPrint("🎯 [NotificationHandler] Executing pending notification after app ready: $payload");
      Future.delayed(const Duration(milliseconds: 400), () {
        navigateFromPayload(payload);
      });
    }
  }

  /// Helper to route from an In-App Notification Center model
  static void navigateFromNotification(NotificationModel notification) {
    final Map<String, dynamic> data = Map<String, dynamic>.from(notification.data ?? {});

    // Ensure fallback keys exist
    if (!data.containsKey('type') && notification.type != null) {
      data['type'] = notification.type;
    }
    if (!data.containsKey('action_key') && notification.type != null) {
      data['action_key'] = notification.type;
    }
    if (!data.containsKey('title') && notification.title != null) {
      data['title'] = notification.title;
    }
    if (!data.containsKey('message') && notification.message != null) {
      data['message'] = notification.message;
    }
    if (!data.containsKey('action_url') && notification.actionUrl != null) {
      data['action_url'] = notification.actionUrl;
    }
    if (!data.containsKey('notification_id') && notification.id != null) {
      data['notification_id'] = notification.id;
    }
    if ((!data.containsKey('related_id') || data['related_id'] == null || data['related_id'].toString().isEmpty) && notification.relatedId != null) {
      data['related_id'] = notification.relatedId.toString();
    }
    if ((!data.containsKey('related_type') || data['related_type'] == null || data['related_type'].toString().isEmpty) && notification.relatedType != null) {
      data['related_type'] = notification.relatedType;
    }
    if (!data.containsKey('created_at') && notification.createdAt != null) {
      data['created_at'] = notification.createdAt;
    }

    navigateFromPayload(data);
  }

  static bool _isGenericWord(String str) {
    final lower = str.trim().toLowerCase();
    return lower.isEmpty ||
        lower == 'chat' ||
        lower == 'member' ||
        lower == 'new message' ||
        lower == 'new messages' ||
        lower == 'new chat message' ||
        lower == 'chat message' ||
        lower == 'message' ||
        lower == 'messages' ||
        lower == 'notification' ||
        lower == 'notifications' ||
        lower == 'mali setu' ||
        lower == 'mali_setu' ||
        lower == 'null';
  }

  static String _extractSenderNameFromTitle(String rawTitle) {
    if (rawTitle.isEmpty) return '';
    final title = rawTitle.trim();
    final lower = title.toLowerCase();

    if (_isGenericWord(lower)) return '';

    final fromPrefixes = [
      'new message from ',
      'message from ',
      'new chat message from ',
      'chat message from ',
    ];
    for (final prefix in fromPrefixes) {
      if (lower.startsWith(prefix)) {
        return title.substring(prefix.length).trim();
      }
    }

    final sentSuffixes = [
      ' sent you a message',
      ' sent a message',
      ' has sent you a message',
    ];
    for (final suffix in sentSuffixes) {
      if (lower.endsWith(suffix)) {
        return title.substring(0, title.length - suffix.length).trim();
      }
    }

    if (title.contains(':')) {
      final parts = title.split(':');
      if (parts.first.trim().isNotEmpty && parts.first.trim().split(' ').length <= 4) {
        final candidate = parts.first.trim();
        if (!_isGenericWord(candidate)) {
          return candidate;
        }
      }
    }

    if (!lower.contains('message') && !lower.contains('notification') && !lower.contains('mali setu')) {
      return title;
    }

    return '';
  }

  /// ══════════════════════════════════════════════════════════════════════════
  /// MASTER ROUTING ENGINE (HANDLES ALL 21+ NOTIFICATION TYPES)
  /// ══════════════════════════════════════════════════════════════════════════
  static void navigateFromPayload(Map<String, dynamic> data) {
    if (data.isEmpty) return;

    debugPrint("🧭 [NotificationHandler] Raw payload received: $data");

    // ── NESTED PAYLOAD PARSER ──────────────────────────────────────────────
    // 1. Backend (Laravel FCM) sends the data payload as a JSON string inside 'data' key:
    // e.g. data['data'] = '{"type":"blog_published","blog_id":"250","action_url":"https://malisetu.com/blogs/250",...}'
    try {
      final dynamic rawInnerData = data['data'];
      if (rawInnerData != null && rawInnerData is String && rawInnerData.trim().startsWith('{')) {
        final Map<String, dynamic> parsedInner = Map<String, dynamic>.from(json.decode(rawInnerData));
        data['data'] = parsedInner;
        // Merge fields into top-level data only as a fallback (never overwrite existing non-empty top-level values)
        parsedInner.forEach((key, value) {
          if (!data.containsKey(key) || data[key] == null || data[key].toString().trim().isEmpty) {
            data[key] = value;
          }
        });
        debugPrint("🔍 [NotificationHandler] Decoded and merged stringified 'data' payload: $parsedInner");
      }
    } catch (e) {
      debugPrint("⚠️ [NotificationHandler] Could not parse nested 'data' string field: $e");
    }

    // 2. Backend sometimes sends notification as JSON string
    try {
      final dynamic rawNotif = data['notification'];
      if (rawNotif != null && rawNotif is String && rawNotif.trim().startsWith('{')) {
        final Map<String, dynamic> parsedNotif = Map<String, dynamic>.from(json.decode(rawNotif));
        data['notification'] = parsedNotif;
        if (parsedNotif['title'] != null && (!data.containsKey('title') || data['title'] == null || data['title'].toString().isEmpty)) {
          data['title'] = parsedNotif['title'];
        }
        if (parsedNotif['body'] != null && (!data.containsKey('body') || data['body'] == null || data['body'].toString().isEmpty)) {
          data['body'] = parsedNotif['body'];
        }
      }
    } catch (_) {}

    // 3. Backend sometimes sends nested payload inside 'message' key
    try {
      final dynamic rawMessage = data['message'];
      if (rawMessage != null && rawMessage is String && rawMessage.trim().startsWith('{')) {
        final Map<String, dynamic> parsed = json.decode(rawMessage);

        if (parsed.containsKey('data') && parsed['data'] is Map) {
          final Map<String, dynamic> innerData = Map<String, dynamic>.from(parsed['data']);
          innerData.forEach((key, value) {
            if (!data.containsKey(key) || data[key] == null || data[key].toString().isEmpty) {
              data[key] = value;
            }
          });
          debugPrint("🔍 [NotificationHandler] Extracted nested payload from 'message' key: $innerData");
        }
      }
    } catch (e) {
      debugPrint("⚠️ [NotificationHandler] Could not parse nested 'message' field: $e");
    }
    // ── END NESTED PAYLOAD PARSER ──────────────────────────────────────────

    debugPrint("🧭 [NotificationHandler] Final resolved payload: $data");

    // Check login state: If not logged in, defer until login completes
    if (!isUserLoggedIn) {
      debugPrint("🔒 [NotificationHandler] User not logged in. Deferring navigation.");
      pendingNotificationPayload = data;
      return;
    }

    // Determine normalized event type (supports 'type', 'action_key', and 'related_type')
    final String rawType = (data['type'] ?? data['action_key'] ?? data['related_type'] ?? '')
        .toString()
        .trim()
        .toLowerCase();
    final String type = rawType.replaceAll(' ', '_').replaceAll('-', '_');

    // Helper functions to safely extract IDs (guards generic 'id' against colliding with 'notification_id')
    final int? _notifRecordId = int.tryParse((data['notification_id'] ?? '').toString());
    int? getInt(List<String> keys) {
      // 1. Check top-level keys in data FIRST (top-level holds the actual current event's parameters)
      for (final key in keys) {
        if (data.containsKey(key) && data[key] != null) {
          final parsed = int.tryParse(data[key].toString());
          if (parsed != null) {
            if (key == 'id' && _notifRecordId != null && parsed == _notifRecordId) continue;
            return parsed;
          }
        }
      }
      // 2. Check inside nested 'data' map only as a fallback
      if (data['data'] is Map) {
        final Map inner = data['data'];
        for (final key in keys) {
          if (inner.containsKey(key) && inner[key] != null) {
            final parsed = int.tryParse(inner[key].toString());
            if (parsed != null) {
              if (key == 'id' && _notifRecordId != null && parsed == _notifRecordId) continue;
              return parsed;
            }
          }
        }
      }
      // Check inside nested 'blog' map if present
      if (data['blog'] is Map && data['blog']['id'] != null) {
        final parsed = int.tryParse(data['blog']['id'].toString());
        if (parsed != null) return parsed;
      }
      // Check inside nested 'post' map if present
      if (data['post'] is Map && data['post']['id'] != null) {
        final parsed = int.tryParse(data['post']['id'].toString());
        if (parsed != null) return parsed;
      }
      // Check inside nested 'job' map if present
      if (data['job'] is Map && data['job']['id'] != null) {
        final parsed = int.tryParse(data['job']['id'].toString());
        if (parsed != null) return parsed;
      }
      // Check inside nested 'profile' map if present
      if (data['profile'] is Map) {
        final Map p = data['profile'];
        for (final key in ['user_id', 'id', 'profile_id', 'profile_user_id']) {
          if (p.containsKey(key) && p[key] != null) {
            final parsed = int.tryParse(p[key].toString());
            if (parsed != null) return parsed;
          }
        }
      }
      // Check inside nested 'user' map if present
      if (data['user'] is Map && data['user']['id'] != null) {
        final parsed = int.tryParse(data['user']['id'].toString());
        if (parsed != null) return parsed;
      }
      // Check inside nested 'matrimony' map if present
      if (data['matrimony'] is Map) {
        final Map m = data['matrimony'];
        for (final key in ['user_id', 'id', 'profile_id', 'profile_user_id']) {
          if (m.containsKey(key) && m[key] != null) {
            final parsed = int.tryParse(m[key].toString());
            if (parsed != null) return parsed;
          }
        }
      }
      return null;
    }

    String getString(List<String> keys, {String defaultVal = ''}) {
      for (final key in keys) {
        if (data.containsKey(key) && data[key] != null && data[key].toString().isNotEmpty) {
          return data[key].toString();
        }
      }
      if (data['data'] is Map) {
        final Map inner = data['data'];
        for (final key in keys) {
          if (inner.containsKey(key) && inner[key] != null && inner[key].toString().isNotEmpty) {
            return inner[key].toString();
          }
        }
      }
      if (data['sender'] is Map) {
        final Map s = data['sender'];
        for (final key in keys) {
          if (s.containsKey(key) && s[key] != null && s[key].toString().isNotEmpty) {
            return s[key].toString();
          }
        }
      }
      if (data['blog'] is Map) {
        final Map b = data['blog'];
        for (final key in keys) {
          if (b.containsKey(key) && b[key] != null && b[key].toString().isNotEmpty) {
            return b[key].toString();
          }
        }
      }
      if (data['post'] is Map) {
        final Map p = data['post'];
        for (final key in keys) {
          if (p.containsKey(key) && p[key] != null && p[key].toString().isNotEmpty) {
            return p[key].toString();
          }
        }
      }
      if (data['user'] is Map) {
        final Map u = data['user'];
        for (final key in keys) {
          if (u.containsKey(key) && u[key] != null && u[key].toString().isNotEmpty) {
            return u[key].toString();
          }
        }
      }
      return defaultVal;
    }

    final String titleLower = getString(['title']).toLowerCase();
    final String messageLower = getString(['message', 'body']).toLowerCase();
    final String relatedType = getString(['related_type']).toLowerCase();

    // ── PRIORITY CHECK: BLOG NOTIFICATIONS (POST, LIKE, COMMENT) ──────────
    final bool isBlogEvent = 
        type == 'blog' ||
        type == 'blogs' ||
        type == 'new_blog' ||
        type == 'blog_post' ||
        type == 'new_blog_posted' ||
        type == 'blog_posted' ||
        type == 'blog_created' ||
        type == 'blog_published' ||
        type == 'blog_approved' ||
        type == 'new_blog_post' ||
        type == 'post_created' ||
        type == 'new_post' ||
        type == 'blog_like' ||
        type == 'blog_liked' ||
        type == 'like_blog' ||
        type == 'post_liked' ||
        type == 'post_like' ||
        type == 'blog_comment' ||
        type == 'blog_commented' ||
        type == 'comment_blog' ||
        type == 'comment_on_blog' ||
        type == 'new_comment' ||
        type == 'post_comment' ||
        type == 'blog_reply' ||
        type.contains('blog') ||
        relatedType == 'blog' ||
        relatedType == 'blogs' ||
        relatedType == 'blog_post' ||
        relatedType == 'post' ||
        relatedType == 'blog_comment' ||
        relatedType == 'blog_like' ||
        titleLower.contains('blog') ||
        messageLower.contains('blog') ||
        titleLower.contains('ब्लॉग') ||
        messageLower.contains('ब्लॉग') ||
        titleLower.contains('commented on your post') ||
        messageLower.contains('commented on your post') ||
        titleLower.contains('liked your post') ||
        messageLower.contains('liked your post');

    if (isBlogEvent) {
      // 1. Check direct blog ID keys (top-level first)
      int? blogId = getInt([
        'blog_id',
        'post_id',
        'article_id',
      ]);

      // 2. Check top-level action_url (e.g. "/blogs/253" or "https://malisetu.com/blogs/253")
      if (blogId == null) {
        final String topActionUrl = (data['action_url'] ?? data['url'] ?? '').toString();
        if (topActionUrl.isNotEmpty) {
          final match = RegExp(r'blogs?/(\d+)').firstMatch(topActionUrl);
          if (match != null) {
            blogId = int.tryParse(match.group(1)!);
          }
        }
      }

      // 3. Check related_id, entity_id
      if (blogId == null) {
        blogId = getInt(['related_id', 'entity_id']);
      }

      // 4. Check nested action_url as fallback
      if (blogId == null) {
        String actionUrl = '';
        if (data['data'] is Map && (data['data']['action_url'] ?? '').toString().isNotEmpty) {
          actionUrl = data['data']['action_url'].toString();
        }
        if (actionUrl.isNotEmpty) {
          final match = RegExp(r'blogs?/(\d+)').firstMatch(actionUrl);
          if (match != null) {
            blogId = int.tryParse(match.group(1)!);
          }
        }
      }

      // 4. Fallback to 'id' (only if it doesn't match notification_id)
      if (blogId == null) {
        final notifId = getInt(['notification_id']);
        final directId = getInt(['id']);
        if (directId != null && directId != notifId) {
          blogId = directId;
        }
      }

      if (blogId != null && blogId > 0) {
        debugPrint("📝 [NotificationHandler] Priority matched Blog event -> Opening BlogDetailScreen for blogId: $blogId (type=$type)");
        Get.to(() => BlogDetailScreen(blogId: blogId!), preventDuplicates: false);
        return;
      } else {
        debugPrint("📝 [NotificationHandler] Blog notification without specific blogId -> Opening BlogsScreen");
        Get.to(() => const BlogsScreen());
        return;
      }
    }

    // ── PRIORITY CHECK 1: CONNECTION REQUEST RECEIVED ─────────────────────
    final bool isConnectionRequest = 
        type == 'connection_request' ||
        type == 'new_connection_request' ||
        type == 'matrimony_connection_request' ||
        type == 'connect_request' ||
        type == 'matrimony_request' ||
        type == 'request_received' ||
        type == 'connection_received' ||
        type == 'interest_received' ||
        titleLower.contains('connection request') ||
        messageLower.contains('connection request') ||
        titleLower.contains('sent you a connection') ||
        messageLower.contains('sent you a connection') ||
        titleLower.contains('कनेक्शन अनुरोध') ||
        messageLower.contains('कनेक्शन अनुरोध');

    if (isConnectionRequest) {
      debugPrint("💍 [NotificationHandler] Priority matched Connection Request -> Opening MatrimonyRequestsScreen");
      if (Get.currentRoute == AppRoutes.matrimonyRequests && Get.isRegistered<MatrimonyRequestsController>()) {
        Get.find<MatrimonyRequestsController>().fetchRequests();
      } else {
        Get.toNamed(AppRoutes.matrimonyRequests);
      }
      return;
    }

    // Helper to safely navigate to MatrimonyProfileScreen
    void navigateToMatrimonyProfile(int profileId) {
      debugPrint("💍 [NotificationHandler] Navigating to MatrimonyProfileScreen for profile ID: $profileId");
      if (Get.isRegistered<MatrimonyDetailsController>()) {
        Get.find<MatrimonyDetailsController>().fetchProfileDetails(profileId);
      }
      Get.to(
        () => MatrimonyProfileScreen(profileId: profileId),
        binding: MatrimonyDetailsBinding(),
        arguments: {'id': profileId},
        preventDuplicates: false,
      );
    }

    // Helper to extract the newly created/target matrimony profile ID (never the logged-in recipient's ID)
    int? extractMatrimonyTargetId() {
      int? myUserId;
      if (Get.isRegistered<AuthService>()) {
        myUserId = Get.find<AuthService>().currentUser.value?.id;
      }

      // 1. Try extracting from action_url (e.g. /matrimony/253, /matrimony/profile/253, /matrimony/profile_user_id/1733)
      final String topActionUrl = (data['action_url'] ?? data['url'] ?? '').toString();
      final String nestedActionUrl = (data['data'] is Map ? (data['data']['action_url'] ?? data['data']['url'] ?? '') : '').toString();
      for (final url in [topActionUrl, nestedActionUrl]) {
        if (url.isNotEmpty) {
          final match = RegExp(r'matrimony/(?:profile_user_id/|profile/)?(\d+)').firstMatch(url);
          if (match != null) {
            final parsed = int.tryParse(match.group(1)!);
            if (parsed != null && (myUserId == null || parsed != myUserId)) {
              return parsed;
            }
          }
        }
      }

      // 2. Specific keys representing the newly created profile / target user
      final specificProfileKeys = [
        'profile_id',
        'matrimony_profile_id',
        'matrimony_id',
        'new_user_id',
        'created_user_id',
        'profile_user_id',
        'matrimony_user_id',
        'target_user_id',
        'member_id',
        'creator_id',
        'author_id',
        'related_id',
        'entity_id',
      ];

      for (final key in specificProfileKeys) {
        final val = getInt([key]);
        if (val != null && (myUserId == null || val != myUserId)) {
          return val;
        }
      }

      // 3. Check inside nested maps: 'profile', 'matrimony', 'user', 'data'
      if (data['profile'] is Map) {
        final p = data['profile'];
        for (final k in ['id', 'user_id', 'profile_id', 'profile_user_id']) {
          if (p[k] != null) {
            final parsed = int.tryParse(p[k].toString());
            if (parsed != null && (myUserId == null || parsed != myUserId)) {
              return parsed;
            }
          }
        }
      }

      if (data['matrimony'] is Map) {
        final m = data['matrimony'];
        for (final k in ['id', 'user_id', 'profile_id', 'profile_user_id']) {
          if (m[k] != null) {
            final parsed = int.tryParse(m[k].toString());
            if (parsed != null && (myUserId == null || parsed != myUserId)) {
              return parsed;
            }
          }
        }
      }

      // 4. Check 'id' if not notification_id and not myUserId
      final notifId = getInt(['notification_id']);
      final directId = getInt(['id']);
      if (directId != null && directId != notifId && (myUserId == null || directId != myUserId)) {
        return directId;
      }

      // 5. Check 'user_id' ONLY IF it is different from myUserId
      final uid = getInt(['user_id']);
      if (uid != null && (myUserId == null || uid != myUserId)) {
        return uid;
      }

      return null;
    }

    // ── PRIORITY CHECK 2: MATRIMONY OWN PROFILE STATUS (APPROVED, PENDING, REJECTED) ──
    final bool isMatrimonyProfileEvent = 
        type.contains('matrimony') ||
        relatedType.contains('matrimony') ||
        titleLower.contains('matrimony') ||
        messageLower.contains('matrimony') ||
        titleLower.contains('विवाह') ||
        messageLower.contains('विवाह') ||
        titleLower.contains('मॅट्रिमोनी') ||
        messageLower.contains('मॅट्रिमोनी') ||
        type == 'new_profile' ||
        type == 'new_profile_created';

    final bool isChatOrRequestEvent =
        type.contains('request') ||
        type.contains('chat') ||
        type.contains('message') ||
        type.contains('connect') ||
        type.contains('accept') ||
        type.contains('interest');

    final bool hasNewProfileIndicator =
        type.contains('created') ||
        type.contains('create') ||
        type.contains('new_') ||
        type.contains('_new') ||
        type.contains('match') ||
        type.contains('register') ||
        titleLower.contains('new ') ||
        titleLower.contains('नवीन ') ||
        titleLower.contains('नया ') ||
        titleLower.contains('created') ||
        titleLower.contains('registered') ||
        titleLower.contains('तयार') ||
        messageLower.contains('new ') ||
        messageLower.contains('नवीन ') ||
        messageLower.contains('नया ') ||
        messageLower.contains('created') ||
        messageLower.contains('registered');

    final bool isExplicitOwnProfileNotification =
        titleLower.contains('your matrimony') ||
        titleLower.contains('your profile') ||
        messageLower.contains('your matrimony') ||
        messageLower.contains('your profile') ||
        titleLower.contains('तुमचे प्रोफाइल') ||
        titleLower.contains('तुमचे मॅट्रिमोनी') ||
        messageLower.contains('तुमचे प्रोफाइल') ||
        messageLower.contains('तुमचे मॅट्रिमोनी') ||
        titleLower.contains('आपका प्रोफाइल') ||
        titleLower.contains('आपका वैवाहिक') ||
        messageLower.contains('आपका प्रोफाइल') ||
        messageLower.contains('आपका वैवाहिक') ||
        type == 'my_matrimony_profile' ||
        type == 'matrimony_profile_rejected' ||
        type == 'matrimony_rejected' ||
        type == 'profile_rejected';

    final bool isOwnProfileStatusEvent = !isChatOrRequestEvent &&
        !hasNewProfileIndicator &&
        isExplicitOwnProfileNotification;

    if (isMatrimonyProfileEvent && isOwnProfileStatusEvent) {
      int? myUserId;
      if (Get.isRegistered<AuthService>()) {
        myUserId = Get.find<AuthService>().currentUser.value?.id;
      }
      final int? ownId = getInt(['user_id', 'profile_user_id']) ??
          myUserId ??
          getInt(['profile_id', 'related_id', 'id']);

      if (ownId != null) {
        debugPrint("💍 [NotificationHandler] Opening own matrimony profile (status event): $ownId");
        navigateToMatrimonyProfile(ownId);
        return;
      }
    }

    // ── PRIORITY CHECK 3: NEW MATRIMONY PROFILE CREATION (OTHER USER) ───────
    if (isMatrimonyProfileEvent && !isOwnProfileStatusEvent && !isChatOrRequestEvent && !type.contains('reject')) {
      final targetProfileId = extractMatrimonyTargetId();

      if (targetProfileId != null) {
        debugPrint("💍 [NotificationHandler] Priority matched new Matrimony profile for user: $targetProfileId");
        navigateToMatrimonyProfile(targetProfileId);
        return;
      } else {
        debugPrint("💍 [NotificationHandler] Matrimony profile notification without other ID, opening members screen (never own profile)");
        Get.toNamed(AppRoutes.matrimonyMembers);
        return;
      }
    }

    switch (type) {
      // ──────────────────────────────────────────────────────────────────────
      // 0. BLOG NOTIFICATIONS (POST, LIKE, COMMENT, REPLY)
      // ──────────────────────────────────────────────────────────────────────
      case 'blog':
      case 'blogs':
      case 'new_blog':
      case 'blog_post':
      case 'new_blog_posted':
      case 'blog_posted':
      case 'blog_created':
      case 'blog_published':
      case 'blog_approved':
      case 'new_blog_post':
      case 'post_created':
      case 'new_post':
      case 'blog_like':
      case 'blog_liked':
      case 'like_blog':
      case 'post_liked':
      case 'post_like':
      case 'blog_comment':
      case 'blog_commented':
      case 'comment_blog':
      case 'comment_on_blog':
      case 'new_comment':
      case 'post_comment':
      case 'blog_reply':
        int? blogId = getInt(['blog_id', 'post_id', 'article_id']);
        if (blogId == null) {
          final String topActionUrl = (data['action_url'] ?? data['url'] ?? '').toString();
          if (topActionUrl.isNotEmpty) {
            final match = RegExp(r'blogs?/(\d+)').firstMatch(topActionUrl);
            if (match != null) {
              blogId = int.tryParse(match.group(1)!);
            }
          }
        }
        if (blogId == null) {
          blogId = getInt(['related_id', 'entity_id']);
        }
        if (blogId == null) {
          String actionUrl = '';
          if (data['data'] is Map && (data['data']['action_url'] ?? '').toString().isNotEmpty) {
            actionUrl = data['data']['action_url'].toString();
          }
          if (actionUrl.isNotEmpty) {
            final match = RegExp(r'blogs?/(\d+)').firstMatch(actionUrl);
            if (match != null) {
              blogId = int.tryParse(match.group(1)!);
            }
          }
        }
        if (blogId == null) {
          final notifId = getInt(['notification_id']);
          final directId = getInt(['id']);
          if (directId != null && directId != notifId) {
            blogId = directId;
          }
        }
        if (blogId != null && blogId > 0) {
          debugPrint("📝 [NotificationHandler] Switch case Blog -> Opening BlogDetailScreen for blogId: $blogId");
          Get.to(() => BlogDetailScreen(blogId: blogId!), preventDuplicates: false);
        } else {
          debugPrint("📝 [NotificationHandler] Switch case Blog without ID -> Opening BlogsScreen");
          Get.to(() => const BlogsScreen());
        }
        break;

      // ──────────────────────────────────────────────────────────────────────
      // 1. ADMIN ANNOUNCEMENT
      // ──────────────────────────────────────────────────────────────────────
      case 'admin_announcement':
      case 'announcement':
      case 'broadcast':
        final String actionUrl = getString(['action_url', 'url']);
        if (actionUrl.isNotEmpty && (actionUrl.startsWith('http://') || actionUrl.startsWith('https://'))) {
          final uri = Uri.tryParse(actionUrl);
          if (uri != null && uri.host.contains('malisetu.com') && DeepLinkService.canHandleUri(uri)) {
            DeepLinkService.navigateToUri(uri);
            return;
          }
          if (uri != null) {
            launchUrl(uri, mode: LaunchMode.externalApplication).catchError((e) {
              debugPrint("Could not open action_url: $e");
              return false;
            });
            return;
          }
        }
        final notificationModel = NotificationModel(
          id: getString(['notification_id', 'id']),
          title: getString(['title'], defaultVal: 'Announcement'.tr),
          message: getString(['message', 'body'], defaultVal: ''),
          createdAt: getString(['created_at'], defaultVal: DateTime.now().toIso8601String()),
        );
        Get.toNamed(AppRoutes.notificationDetails, arguments: notificationModel);
        break;

      // ──────────────────────────────────────────────────────────────────────
      // 2 & 3. BUSINESS NOTIFICATIONS (VERIFIED / APPROVED / REJECTED)
      // ──────────────────────────────────────────────────────────────────────
      case 'business_verified':
      case 'business_approved':
        final int? businessId = getInt(['business_id', 'related_id', 'id']);
        if (businessId != null) {
          Get.toNamed(
            AppRoutes.businessDetails,
            arguments: Business(id: businessId),
          );
        } else {
          Get.toNamed(AppRoutes.myBusiness);
        }
        break;

      case 'business_rejected':
      case 'business_pending':
      case 'my_business':
        Get.toNamed(AppRoutes.myBusiness);
        break;

      // ──────────────────────────────────────────────────────────────────────
      // 4, 5, 6. MATRIMONY CONNECTION REQUESTS
      // ──────────────────────────────────────────────────────────────────────
      case 'connection_request':
      case 'new_connection_request':
      case 'matrimony_connection_request':
      case 'matrimony_request':
      case 'connection_received':
      case 'request_received':
      case 'interest_received':
      case 'connect_request':
        if (Get.currentRoute == AppRoutes.matrimonyRequests && Get.isRegistered<MatrimonyRequestsController>()) {
          Get.find<MatrimonyRequestsController>().fetchRequests();
        } else {
          Get.toNamed(AppRoutes.matrimonyRequests);
        }
        break;

      case 'connection_accepted':
        int? myUserIdForConn;
        if (Get.isRegistered<AuthService>()) {
          myUserIdForConn = Get.find<AuthService>().currentUser.value?.id;
        }
        final int? conversationId = getInt(['conversation_id', 'conv_id']);
        int? otherUserId = getInt(['other_user_id', 'sender_id', 'user_id', 'profile_id']);
        if (otherUserId != null && myUserIdForConn != null && otherUserId == myUserIdForConn) {
          final altId = getInt(['related_id', 'sender_id', 'other_user_id']);
          otherUserId = (altId != null && altId != myUserIdForConn) ? altId : null;
        }

        String userName = getString(['user_name', 'sender_name', 'name']);
        if (userName.trim().isEmpty || _isGenericWord(userName)) {
          final rawTitle = getString(['title']);
          userName = _extractSenderNameFromTitle(rawTitle);
        }

        if (conversationId != null || otherUserId != null) {
          Get.toNamed(AppRoutes.matrimonyChat, arguments: {
            if (conversationId != null) 'conversation_id': conversationId,
            if (otherUserId != null) 'other_user_id': otherUserId,
            if (userName.isNotEmpty) 'user_name': userName,
          });
        } else {
          Get.toNamed(AppRoutes.matrimonyMembers);
        }
        break;

      case 'connection_rejected':
        Get.toNamed(AppRoutes.matrimonyRequests);
        break;

      // ──────────────────────────────────────────────────────────────────────
      // 7. DONATION RECEIVED
      // ──────────────────────────────────────────────────────────────────────
      case 'donation_received':
      case 'donation':
        Get.toNamed(AppRoutes.transactionHistory);
        break;

      // ──────────────────────────────────────────────────────────────────────
      // 8 & 9. JOBS (NEW JOB / JOB DETAILS / JOB APPLICATIONS)
      // ──────────────────────────────────────────────────────────────────────
      case 'new_job':
      case 'new_job_posted':
      case 'job_posted':
      case 'job_created':
      case 'job_alert':
      case 'job_details':
      case 'job':
      case 'jobs':
      case 'job_applied':
      case 'job_apply':
        final int? jobId = getInt(['job_id', 'job_posting_id', 'related_id', 'id']);
        final String jobTitle = getString(['job_title']);
        if (jobId != null) {
          Get.toNamed(
            AppRoutes.jobDetails,
            arguments: Job(
              id: jobId,
              title: jobTitle.isNotEmpty ? jobTitle : null,
            ),
          );
        } else {
          Get.toNamed(AppRoutes.jobs);
        }
        break;

      case 'job_application_received':
      case 'new_job_application':
      case 'job_application':
      case 'application_received':
      case 'job_received':
      case 'job_applicant':
      case 'job_appliers':
      case 'view_applications':
        final int? appliersJobId = getInt(['job_id', 'job_posting_id', 'related_id']);
        final int? appliersBusinessId = getInt(['business_id']);
        if (appliersJobId != null) {
          Get.toNamed(AppRoutes.jobAppliers, arguments: Job(id: appliersJobId));
        } else if (appliersBusinessId != null) {
          Get.toNamed(AppRoutes.jobAnalytics, arguments: {'business_id': appliersBusinessId});
        } else {
          Get.toNamed(AppRoutes.myBusiness);
        }
        break;

      case 'job_application_status':
      case 'job_status_update':
      case 'applied_job':
        Get.toNamed(AppRoutes.appliedJobList);
        break;

      // ──────────────────────────────────────────────────────────────────────
      // 10, 11, 12. MATRIMONY PROFILE APPROVAL STATUS
      // ──────────────────────────────────────────────────────────────────────
      case 'matrimony_profile_approved':
      case 'matrimony_approved':
      case 'profile_approved':
      case 'matrimony_profile_approval':
      case 'matrimony_approval':
      case 'matrimony_profile_pending':
      case 'matrimony_pending':
      case 'profile_pending':
      case 'matrimony_profile_rejected':
      case 'matrimony_rejected':
      case 'profile_rejected':
        int? myUserId;
        if (Get.isRegistered<AuthService>()) {
          myUserId = Get.find<AuthService>().currentUser.value?.id;
        }

        // Check if this notification refers to another user's profile
        final int? targetOtherId = extractMatrimonyTargetId();
        if (targetOtherId != null) {
          navigateToMatrimonyProfile(targetOtherId);
          break;
        }

        // Only if it's explicitly own profile event, use myUserId
        if (isOwnProfileStatusEvent && myUserId != null) {
          navigateToMatrimonyProfile(myUserId);
        } else {
          Get.toNamed(AppRoutes.matrimonyMembers);
        }
        break;

      // ──────────────────────────────────────────────────────────────────────
      // 13. CHAT MESSAGES
      // ──────────────────────────────────────────────────────────────────────
      case 'new_chat_message':
      case 'chat_message':
      case 'chat':
      case 'message':
      case 'new_message':
        int? myUserId;
        if (Get.isRegistered<AuthService>()) {
          myUserId = Get.find<AuthService>().currentUser.value?.id;
        }

        final int? convId = getInt(['conversation_id', 'conv_id', 'chat_id']);

        // Priority for sender ID: sender_id, other_user_id, sender_user_id, from_user_id, from_id
        int? senderId = getInt(['sender_id', 'other_user_id', 'sender_user_id', 'from_user_id', 'from_id']);
        if (senderId == null || (myUserId != null && senderId == myUserId)) {
          final candidateId = getInt(['user_id', 'related_id', 'id']);
          if (candidateId != null && candidateId != myUserId) {
            senderId = candidateId;
          } else if (senderId == myUserId) {
            senderId = null; // Do not use logged-in user ID as other user!
          }
        }

        // Priority for sender name: check dedicated sender fields first
        String senderName = getString([
          'sender_name',
          'senderName',
          'other_user_name',
          'from_name',
          'user_name',
          'userName',
        ]);

        if (senderName.trim().isEmpty || _isGenericWord(senderName)) {
          final rawTitle = getString(['title']);
          final extracted = _extractSenderNameFromTitle(rawTitle);
          if (extracted.isNotEmpty) {
            senderName = extracted;
          } else {
            senderName = '';
          }
        }

        // If the chat screen is already open
        if (Get.currentRoute == AppRoutes.matrimonyChat &&
            Get.isRegistered<MatrimonyChatController>()) {
          final chatCtrl = Get.find<MatrimonyChatController>();
          if ((convId != null && chatCtrl.conversationId == convId) ||
              (convId == null && senderId != null && chatCtrl.otherUserId == senderId)) {
            // Already on correct chat – just refresh
            chatCtrl.fetchMessages();
            break;
          } else {
            // Chat screen is open but for a DIFFERENT conversation – update it
            chatCtrl.updateConversation(
              convId: convId,
              otherUserId: senderId,
              userName: senderName.isNotEmpty ? senderName : null,
            );
            break;
          }
        }

        // If conversation_id is known → navigate directly to that chat
        if (convId != null) {
          Get.toNamed(AppRoutes.matrimonyChat, arguments: {
            'conversation_id': convId,
            if (senderId != null) 'other_user_id': senderId,
            if (senderName.isNotEmpty) 'user_name': senderName,
          });
          break;
        }

        // Fallback: only sender_id known → controller will search for conversation
        if (senderId != null) {
          Get.toNamed(AppRoutes.matrimonyChat, arguments: {
            'other_user_id': senderId,
            if (senderName.isNotEmpty) 'user_name': senderName,
          });
        } else {
          Get.toNamed(AppRoutes.matrimonyMembers);
        }
        break;

      // ──────────────────────────────────────────────────────────────────────
      // 14. NEW MATRIMONY PROFILE (MATCH RECOMMENDATION / CREATED)
      // ──────────────────────────────────────────────────────────────────────
      case 'new_matrimony_profile':
      case 'new_matrimony_profile_created':
      case 'matrimony_profile_created':
      case 'matrimony_profile_create':
      case 'matrimony_profile':
      case 'matrimony_created':
      case 'matrimony_new_profile':
      case 'new_profile_created':
      case 'new_matrimony':
      case 'matrimony_match':
      case 'matrimony_user':
      case 'create_matrimony_profile':
        final int? matchId = extractMatrimonyTargetId();
        if (matchId != null) {
          debugPrint("💍 [NotificationHandler] Opening MatrimonyProfileScreen for user_id: $matchId");
          navigateToMatrimonyProfile(matchId);
        } else {
          debugPrint("💍 [NotificationHandler] No specific profile ID found, opening matrimony members");
          Get.toNamed(AppRoutes.matrimonyMembers);
        }
        break;

      // ──────────────────────────────────────────────────────────────────────
      // 15, 16, 17. PAYMENTS & TRANSACTIONS
      // ──────────────────────────────────────────────────────────────────────
      case 'payment_success':
      case 'payment_successful':
      case 'payment_completed':
      case 'payment_failed':
      case 'payment_pending_reminder':
      case 'payment_pending':
      case 'transaction':
        Get.toNamed(AppRoutes.transactionHistory);
        break;

      // ──────────────────────────────────────────────────────────────────────
      // WEBINARS / VOLUNTEER / REFERRAL
      // ──────────────────────────────────────────────────────────────────────
      case 'webinar':
      case 'webinar_started':
      case 'webinar_reminder':
      case 'new_webinar':
      case 'webinar_live':
        final int? webinarId = getInt(['webinar_id', 'related_id', 'id']);
        if (webinarId != null) {
          Get.toNamed(AppRoutes.webinarDetails, arguments: Webinar.fromApiJson({'id': webinarId}));
        } else {
          Get.toNamed(AppRoutes.webinars);
        }
        break;

      case 'volunteer':
      case 'volunteer_opportunity':
      case 'new_volunteer_opportunity':
      case 'volunteer_approved':
      case 'volunteer_rejected':
        final int? oppId = getInt(['opportunity_id', 'volunteer_opportunity_id']);
        if (oppId != null) {
          Get.toNamed(AppRoutes.volunteerOpportunityDetails, arguments: {'id': oppId});
        } else {
          Get.toNamed(AppRoutes.volunteer);
        }
        break;

      case 'referral':
      case 'referral_reward':
      case 'referral_joined':
      case 'new_referral':
      case 'commission_earned':
        Get.toNamed(AppRoutes.referral);
        break;

      // ──────────────────────────────────────────────────────────────────────
      // 18. PROFILE UPDATE
      // ──────────────────────────────────────────────────────────────────────
      case 'profile_update':
        Get.toNamed(AppRoutes.profileScreen);
        break;

      // ──────────────────────────────────────────────────────────────────────
      // 19 & 20. REGISTRATION (COMMUNITY / CASTE VERIFICATION)
      // ──────────────────────────────────────────────────────────────────────
      case 'registration_approved':
        Get.toNamed(AppRoutes.profileScreen);
        break;

      case 'registration_rejected':
        Get.toNamed(AppRoutes.updateProfile);
        break;

      // ──────────────────────────────────────────────────────────────────────
      // 21. SUBSCRIPTION EXPIRY REMINDER
      // ──────────────────────────────────────────────────────────────────────
      case 'subscription_expiry_reminder':
      case 'subscription_expiring':
      case 'subscription':
        final String module = getString(['module']).toLowerCase();
        if (module == 'business' || data.containsKey('business_id')) {
          Get.toNamed(AppRoutes.myBusiness);
        } else {
          Get.toNamed(AppRoutes.transactionHistory);
        }
        break;

      // ──────────────────────────────────────────────────────────────────────
      // FALLBACK DEFAULT
      // ──────────────────────────────────────────────────────────────────────
      default:
        debugPrint("⚠️ [NotificationHandler] Unrecognized notification type: '$type'. Checking smart entity fallback.");

        // Smart fallback 1: If job_id exists in payload or type/related_type indicates job
        final int? fallbackJobId = getInt(['job_id', 'job_posting_id', 'related_id', 'id']);
        final bool isJobRelated = data.containsKey('job_id') ||
            data.containsKey('job_posting_id') ||
            type.contains('job') ||
            type.contains('appli') ||
            data['related_type']?.toString().toLowerCase() == 'job' ||
            data['related_type']?.toString().toLowerCase() == 'job_application';

        if (fallbackJobId != null && isJobRelated) {
          final String fallbackTitle = getString(['job_title', 'title']);
          Get.toNamed(
            AppRoutes.jobDetails,
            arguments: Job(
              id: fallbackJobId,
              title: (fallbackTitle.isNotEmpty && fallbackTitle != 'Notification') ? fallbackTitle : null,
            ),
          );
          break;
        }

        // Smart fallback 2: Matrimony / Profile notification fallback
        final String titleLower = (data['title'] ?? '').toString().toLowerCase();
        final String messageLower = (data['message'] ?? data['body'] ?? '').toString().toLowerCase();
        final String relatedType = (data['related_type'] ?? '').toString().toLowerCase();

        final bool isMatrimonyRelated = type.contains('matrimony') ||
            type.contains('match') ||
            relatedType.contains('matrimony') ||
            titleLower.contains('matrimony') ||
            messageLower.contains('matrimony');

        if (isMatrimonyRelated) {
          final int? fallbackMatrimonyId = extractMatrimonyTargetId();

          if (fallbackMatrimonyId != null) {
            debugPrint("💍 [NotificationHandler] Smart fallback matched Matrimony Profile ID: $fallbackMatrimonyId");
            navigateToMatrimonyProfile(fallbackMatrimonyId);
            break;
          } else {
            debugPrint("💍 [NotificationHandler] Smart fallback: Matrimony notification without ID, opening members list");
            Get.toNamed(AppRoutes.matrimonyMembers);
            break;
          }
        }

        // Smart fallback 3: Blog / Post notification fallback
        final int? fallbackBlogId = getInt(['blog_id', 'post_id', 'article_id']);
        final bool isFallbackBlog = fallbackBlogId != null ||
            data.containsKey('blog_id') ||
            data.containsKey('post_id') ||
            type.contains('blog') ||
            type.contains('comment') ||
            type.contains('like') ||
            relatedType.contains('blog') ||
            relatedType.contains('post') ||
            titleLower.contains('blog') ||
            messageLower.contains('blog');

        if (isFallbackBlog) {
          final int? finalBlogId = fallbackBlogId ?? getInt(['related_id', 'entity_id', 'id']);
          if (finalBlogId != null && finalBlogId > 0) {
            debugPrint("📝 [NotificationHandler] Smart fallback matched Blog ID: $finalBlogId");
            Get.to(() => BlogDetailScreen(blogId: finalBlogId), preventDuplicates: false);
            break;
          } else {
            debugPrint("📝 [NotificationHandler] Smart fallback: Blog notification without ID, opening BlogsScreen");
            Get.to(() => const BlogsScreen());
            break;
          }
        }

        final fallbackModel = NotificationModel(
          id: getString(['notification_id', 'id']),
          title: getString(['title'], defaultVal: 'Notification'.tr),
          message: getString(['message', 'body'], defaultVal: ''),
          createdAt: getString(['created_at'], defaultVal: DateTime.now().toIso8601String()),
        );
        Get.toNamed(AppRoutes.notificationDetails, arguments: fallbackModel);
        break;
    }
  }
}
