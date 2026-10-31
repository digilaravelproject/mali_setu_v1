import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

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
import '../../features/notification/data/model/notification_model.dart' hide NotificationResponse;
import '../../features/notification/presentation/controller/notification_controller.dart';

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
    await _setupLocalNotifications();
    await _setupFCM();
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
        if (payloadStr != null && payloadStr.isNotEmpty) {
          try {
            final Map<String, dynamic> data = json.decode(payloadStr);
            navigateFromPayload(data);
          } catch (e) {
            debugPrint("❌ [NotificationHandler] Failed to parse local notification payload: $e");
          }
        }
      },
    );

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
    final title = message.notification?.title ?? message.data['title'] ?? 'Mali Setu';
    final body = message.notification?.body ?? message.data['message'] ?? '';

    final androidDetails = AndroidNotificationDetails(
      _fcmChannelId,
      _fcmChannelName,
      channelDescription: _fcmChannelDescription,
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      icon: '@mipmap/launcher_icon',
    );

    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
      payload: json.encode(message.data),
    );
  }

  /// Sync FCM device token with backend API (PUT /api/auth/fcm-token)
  Future<void> syncFcmToken() async {
    try {
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
    if (notification.relatedId != null) {
      data['related_id'] = notification.relatedId.toString();
    }
    if (notification.relatedType != null) {
      data['related_type'] = notification.relatedType;
    }

    navigateFromPayload(data);
  }

  /// ══════════════════════════════════════════════════════════════════════════
  /// MASTER ROUTING ENGINE (HANDLES ALL 21+ NOTIFICATION TYPES)
  /// ══════════════════════════════════════════════════════════════════════════
  static void navigateFromPayload(Map<String, dynamic> data) {
    if (data.isEmpty) return;

    debugPrint("🧭 [NotificationHandler] Raw payload received: $data");

    // ── NESTED PAYLOAD PARSER ──────────────────────────────────────────────
    // Backend sometimes sends the actual FCM data payload as a JSON string
    // inside a 'message' key (e.g., message: '{"data":{"business_id":"337",...}}').
    // Extract and merge it so our routing logic can find entity IDs directly.
    try {
      final dynamic rawMessage = data['message'];
      if (rawMessage != null && rawMessage is String && rawMessage.trim().startsWith('{')) {
        final Map<String, dynamic> parsed = json.decode(rawMessage);

        // If nested 'data' object exists, merge its keys into top-level data
        if (parsed.containsKey('data') && parsed['data'] is Map) {
          final Map<String, dynamic> innerData = Map<String, dynamic>.from(parsed['data']);
          innerData.forEach((key, value) {
            // Only fill in if the top-level data does NOT already have this key
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

    // Helper functions to safely extract IDs
    int? getInt(List<String> keys) {
      for (final key in keys) {
        if (data.containsKey(key) && data[key] != null) {
          final parsed = int.tryParse(data[key].toString());
          if (parsed != null) return parsed;
        }
      }
      // Check inside nested 'data' map if present
      if (data['data'] is Map) {
        final Map inner = data['data'];
        for (final key in keys) {
          if (inner.containsKey(key) && inner[key] != null) {
            final parsed = int.tryParse(inner[key].toString());
            if (parsed != null) return parsed;
          }
        }
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
      return defaultVal;
    }

    final String titleLower = getString(['title']).toLowerCase();
    final String messageLower = getString(['message', 'body']).toLowerCase();
    final String relatedType = getString(['related_type']).toLowerCase();

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

    // ── PRIORITY CHECK 2: MATRIMONY OWN PROFILE STATUS (APPROVED, PENDING, REJECTED) ──
    final bool isMatrimonyProfileEvent = 
        type.contains('matrimony') ||
        relatedType.contains('matrimony') ||
        titleLower.contains('matrimony') ||
        messageLower.contains('matrimony');

    final bool isOwnProfileStatusEvent = 
        type.contains('pending') ||
        type.contains('reject') ||
        type.contains('approv') ||
        titleLower.contains('approved') ||
        titleLower.contains('pending') ||
        titleLower.contains('rejected') ||
        messageLower.contains('approved') ||
        messageLower.contains('pending') ||
        messageLower.contains('rejected');

    if (isMatrimonyProfileEvent && isOwnProfileStatusEvent) {
      int? myUserId;
      if (Get.isRegistered<AuthService>()) {
        myUserId = Get.find<AuthService>().currentUser.value?.id;
      }
      final int? ownId = getInt(['user_id', 'profile_user_id']) ??
          myUserId ??
          getInt(['profile_id', 'id', 'related_id']);

      if (ownId != null) {
        debugPrint("💍 [NotificationHandler] Opening own matrimony profile (status event): $ownId");
        Get.toNamed(AppRoutes.matrimonyProfileScreen, arguments: {'id': ownId});
        return;
      }
    }

    // ── PRIORITY CHECK 3: NEW MATRIMONY PROFILE CREATION (OTHER USER) ───────
    if (isMatrimonyProfileEvent && !isOwnProfileStatusEvent && !type.contains('request') && !type.contains('chat') && !type.contains('connect')) {
      int? myUserId;
      if (Get.isRegistered<AuthService>()) {
        myUserId = Get.find<AuthService>().currentUser.value?.id;
      }

      // 1. Check specific keys first that represent the newly registered user (NEVER the logged in recipient)
      int? targetProfileId = getInt([
        'new_user_id',
        'created_user_id',
        'profile_user_id',
        'matrimony_user_id',
        'related_id',
        'profile_id',
        'matrimony_id',
        'matrimony_profile_id',
        'entity_id',
        'target_user_id',
      ]);

      // If the specific key found matches my own ID, look for an alternative ID in other keys
      if (targetProfileId != null && myUserId != null && targetProfileId == myUserId) {
        final altId = getInt(['related_id', 'profile_id', 'profile_user_id', 'matrimony_id', 'entity_id', 'id']);
        if (altId != null && altId != myUserId) {
          targetProfileId = altId;
        }
      }

      // 2. If no specific key found, check 'user_id' and 'id'
      if (targetProfileId == null) {
        final candidateId = getInt(['user_id', 'id']);
        if (candidateId != null && (myUserId == null || candidateId != myUserId)) {
          targetProfileId = candidateId;
        } else if (candidateId != null && myUserId != null && candidateId == myUserId) {
          final altId = getInt(['related_id', 'profile_id', 'entity_id', 'id']);
          if (altId != null && altId != myUserId) {
            targetProfileId = altId;
          } else {
            targetProfileId = candidateId;
          }
        }
      }

      if (targetProfileId != null) {
        debugPrint("💍 [NotificationHandler] Opening MatrimonyProfileScreen for target user: $targetProfileId (myUserId=$myUserId)");
        Get.toNamed(AppRoutes.matrimonyProfileScreen, arguments: {'id': targetProfileId});
        return;
      } else {
        debugPrint("💍 [NotificationHandler] Matrimony profile notification without ID, opening members screen");
        Get.toNamed(AppRoutes.matrimonyMembers);
        return;
      }
    }

    switch (type) {
      // ──────────────────────────────────────────────────────────────────────
      // 1. ADMIN ANNOUNCEMENT
      // ──────────────────────────────────────────────────────────────────────
      case 'admin_announcement':
      case 'announcement':
      case 'broadcast':
        final String actionUrl = getString(['action_url', 'url']);
        if (actionUrl.isNotEmpty && (actionUrl.startsWith('http://') || actionUrl.startsWith('https://'))) {
          try {
            launchUrl(Uri.parse(actionUrl), mode: LaunchMode.externalApplication);
            return;
          } catch (e) {
            debugPrint("Could not open action_url: $e");
          }
        }
        final notificationModel = NotificationModel(
          id: getString(['notification_id', 'id']),
          title: getString(['title'], defaultVal: 'Announcement'.tr),
          message: getString(['message', 'body'], defaultVal: ''),
          createdAt: DateTime.now().toIso8601String(),
        );
        Get.toNamed(AppRoutes.notificationDetails, arguments: notificationModel);
        break;

      // ──────────────────────────────────────────────────────────────────────
      // 2 & 3. BUSINESS NOTIFICATIONS (VERIFIED / REJECTED)
      // ──────────────────────────────────────────────────────────────────────
      case 'business_verified':
        final int? businessId = getInt(['business_id', 'id', 'related_id']);
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
        final int? conversationId = getInt(['conversation_id']);
        final int? otherUserId = getInt(['other_user_id', 'user_id', 'profile_id']);
        final String userName = getString(['user_name', 'name', 'title'], defaultVal: 'Member');

        if (conversationId != null || otherUserId != null) {
          Get.toNamed(AppRoutes.matrimonyChat, arguments: {
            'conversation_id': conversationId,
            'other_user_id': otherUserId,
            'user_name': userName,
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
      // 8 & 9. JOBS (NEW JOB / JOB DETAILS FULL VIEW)
      // ──────────────────────────────────────────────────────────────────────
      case 'new_job':
      case 'new_job_posted':
      case 'job_posted':
      case 'job_created':
      case 'job_alert':
      case 'job_details':
      case 'job':
      case 'jobs':
      case 'job_application_received':
      case 'new_job_application':
      case 'job_application':
      case 'job_applied':
      case 'job_apply':
      case 'application_received':
      case 'job_received':
      case 'job_applicant':
        // Priority: job_id -> job_posting_id -> related_id -> id
        final int? jobId = getInt(['job_id', 'job_posting_id', 'related_id', 'id']);
        final String jobTitle = getString(['job_title', 'title']);
        if (jobId != null) {
          Get.toNamed(
            AppRoutes.jobDetails,
            arguments: Job(
              id: jobId,
              title: (jobTitle.isNotEmpty && jobTitle != 'Notification') ? jobTitle : null,
            ),
          );
        } else {
          Get.toNamed(AppRoutes.myBusiness);
        }
        break;

      case 'job_appliers':
      case 'view_applications':
        final int? appliersJobId = getInt(['job_id', 'job_posting_id', 'related_id']);
        if (appliersJobId != null) {
          Get.toNamed(AppRoutes.jobAppliers, arguments: Job(id: appliersJobId));
        } else {
          Get.toNamed(AppRoutes.jobAnalytics);
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
        // Note: Matrimony profile details API is /matrimony/profile_user_id/{user_id}, so user_id is required
        int? myUserId;
        if (Get.isRegistered<AuthService>()) {
          myUserId = Get.find<AuthService>().currentUser.value?.id;
        }
        final int? profileId = getInt(['user_id', 'profile_user_id']) ??
            myUserId ??
            getInt(['profile_id', 'id', 'related_id']);

        if (profileId != null) {
          Get.toNamed(AppRoutes.matrimonyProfileScreen, arguments: {'id': profileId});
        } else if (myUserId != null) {
          Get.toNamed(AppRoutes.matrimonyProfileScreen, arguments: {'id': myUserId});
        } else {
          Get.toNamed(AppRoutes.regMatrimony);
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
        final int? convId = getInt(['conversation_id', 'conv_id']);
        final int? senderId = getInt(['other_user_id', 'sender_id', 'sender_user_id', 'user_id']);
        final String senderName = getString(['user_name', 'sender_name', 'name', 'title'], defaultVal: 'Chat');

        // If the chat screen is already open for THIS conversation → just refresh messages
        if (Get.currentRoute == AppRoutes.matrimonyChat &&
            Get.isRegistered<MatrimonyChatController>()) {
          final chatCtrl = Get.find<MatrimonyChatController>();
          if (convId != null && chatCtrl.conversationId == convId) {
            // Already on correct chat – just refresh
            chatCtrl.fetchMessages();
            break;
          }
        }

        // If conversation_id is known → navigate directly to that chat
        if (convId != null) {
          Get.toNamed(AppRoutes.matrimonyChat, arguments: {
            'conversation_id': convId,
            'other_user_id': senderId,
            'user_name': senderName,
          });
          break;
        }

        // Fallback: only sender_id known → controller will search for conversation
        if (senderId != null) {
          Get.toNamed(AppRoutes.matrimonyChat, arguments: {
            'other_user_id': senderId,
            'user_name': senderName,
          });
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
        final int? matchId = getInt([
          'user_id',
          'profile_user_id',
          'profile_id',
          'matrimony_id',
          'matrimony_profile_id',
          'created_user_id',
          'target_user_id',
          'member_id',
          'related_id',
          'id',
        ]);
        if (matchId != null) {
          debugPrint("💍 [NotificationHandler] Opening MatrimonyProfileScreen for user_id: $matchId");
          Get.toNamed(AppRoutes.matrimonyProfileScreen, arguments: {'id': matchId});
        } else {
          debugPrint("💍 [NotificationHandler] No specific profile ID found, opening matrimony members");
          Get.toNamed(AppRoutes.matrimonyMembers);
        }
        break;

      // ──────────────────────────────────────────────────────────────────────
      // 15, 16, 17. PAYMENTS & TRANSACTIONS
      // ──────────────────────────────────────────────────────────────────────
      case 'payment_successful':
      case 'payment_failed':
      case 'payment_pending_reminder':
      case 'payment_pending':
      case 'transaction':
        Get.toNamed(AppRoutes.transactionHistory);
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
          final int? fallbackMatrimonyId = getInt([
            'user_id',
            'profile_user_id',
            'profile_id',
            'matrimony_id',
            'matrimony_profile_id',
            'created_user_id',
            'target_user_id',
            'member_id',
            'related_id',
            'id',
          ]);

          if (fallbackMatrimonyId != null) {
            debugPrint("💍 [NotificationHandler] Smart fallback matched Matrimony Profile ID: $fallbackMatrimonyId");
            Get.toNamed(AppRoutes.matrimonyProfileScreen, arguments: {'id': fallbackMatrimonyId});
            break;
          } else {
            debugPrint("💍 [NotificationHandler] Smart fallback: Matrimony notification without ID, opening members list");
            Get.toNamed(AppRoutes.matrimonyMembers);
            break;
          }
        }

        final fallbackModel = NotificationModel(
          id: getString(['notification_id', 'id']),
          title: getString(['title'], defaultVal: 'Notification'.tr),
          message: getString(['message', 'body'], defaultVal: ''),
          createdAt: DateTime.now().toIso8601String(),
        );
        Get.toNamed(AppRoutes.notificationDetails, arguments: fallbackModel);
        break;
    }
  }
}
