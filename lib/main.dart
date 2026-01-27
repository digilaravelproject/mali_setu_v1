import 'package:edu_cluezer/core/routes/app_routes.dart';
import 'package:edu_cluezer/core/styles/theme/app_dark_theme.dart';
import 'package:edu_cluezer/core/styles/theme/app_light_theme.dart';
import 'package:edu_cluezer/core/utils/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'init_app.dart';

Future<void> main() async {
  await initApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppConstants.appName,
      theme: AppLightTheme.lightTheme,
      darkTheme: AppDarkTheme.darkTheme,
      getPages: AppPages.getPages,
    );
  }
}
