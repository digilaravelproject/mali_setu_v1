import 'package:edu_cluezer/core/routes/app_routes.dart';
import 'package:edu_cluezer/core/styles/theme/app_light_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'core/constent/app_constants.dart';
import 'core/localization/languages.dart';
import 'core/localization/language_controller.dart';
import 'core/storage/shared_prefs.dart';
import 'init_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initApp();
  
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
    
    return Obx(() => GetMaterialApp(
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
    ));
  }
}
