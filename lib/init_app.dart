import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'core/network/api_client.dart';
import 'core/storage/shared_prefs.dart';
import 'features/Auth/service/auth_service.dart';


Future<void> initApp() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SharedPreferences
  await SharedPrefs.init();

  // Set preferred orientations (optional)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize ApiClient as a singleton in GetX
  Get.put(ApiClient(), permanent: true);

  // Initialize AuthService as a permanent singleton
  Get.put(AuthService(), permanent: true);
}
