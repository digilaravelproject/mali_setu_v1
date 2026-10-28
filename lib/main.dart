import 'package:edu_cluezer/core/routes/app_routes.dart';
import 'package:edu_cluezer/core/styles/theme/app_light_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:upgrader/upgrader.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'core/constent/app_constants.dart';
import 'core/localization/languages.dart';
import 'core/localization/language_controller.dart';
import 'core/storage/shared_prefs.dart';
import 'core/helper/local_notification_helper.dart';
import 'package:edu_cluezer/core/widgets/screen_capture_protector.dart';
import 'init_app.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("════════════════════════════════════════════════════════════");
  print("📩 [FCM BACKGROUND NOTIFICATION RECEIVED]");
  print("   Message ID: ${message.messageId}");
  print("   Title:      ${message.notification?.title}");
  print("   Body:       ${message.notification?.body}");
  print("   Data:       ${message.data}");
  print("════════════════════════════════════════════════════════════");
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initApp();
  await LocalNotificationHelper.init();
  
  // Register background notification handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  
  // Initialize LanguageController
  Get.put(LanguageController());

  runApp(MyApp());
}

final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
GlobalKey<ScaffoldMessengerState>();

class MyApp extends StatelessWidget {

  const MyApp({super.key,});

  @override
  Widget build(BuildContext context) {
    // Get the LanguageController to use saved locale
    final languageController = Get.find<LanguageController>();
    
    /// without screen capture protector
    return GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: AppConstants.appName,
        translations: Languages(),
        locale: languageController.currentLocale.value,
        fallbackLocale: const Locale('en', 'US'),
        theme: AppLightTheme.lightTheme,
        darkTheme: AppLightTheme.lightTheme,
        // darkTheme: AppDarkTheme.darkTheme,
        scaffoldMessengerKey: rootScaffoldMessengerKey,
        getPages: AppPages.getPages,
        initialRoute: AppRoutes.splash,
        builder: (context, child) {
          final mediaQuery = MediaQuery.of(context);
          return MediaQuery(
            data: mediaQuery.copyWith(
              textScaler: mediaQuery.textScaler.clamp(
                minScaleFactor: 0.85,
                maxScaleFactor: 1.15,
              ),
            ),
            child: UpgradeAlert(
              navigatorKey: Get.key,
              child: child ?? const SizedBox.shrink(),
            ),
          );
        },
    );


    /// with screen capture protector
   /* return ScreenCaptureProtector(
      child: GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppConstants.appName,
      translations: Languages(),
      locale: languageController.currentLocale.value,
      fallbackLocale: const Locale('en', 'US'),
      theme: AppLightTheme.lightTheme,
      darkTheme: AppLightTheme.lightTheme,
      // darkTheme: AppDarkTheme.darkTheme,
      scaffoldMessengerKey: rootScaffoldMessengerKey,
      getPages: AppPages.getPages,
      initialRoute: AppRoutes.splash,
      ),
    );*/
  }
}
