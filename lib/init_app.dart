import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/network/api_client.dart';
import 'core/storage/shared_prefs.dart';
import 'features/Auth/service/auth_service.dart';


Future<void> initApp() async {
  if (Platform.isIOS) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'AIzaSyBbGRlQRbCQS85FjCeptZ2VmKJg502HYGw',
        appId: '1:58378864066:ios:00caa59b725958f473c25b',
        messagingSenderId: '58378864066',
        projectId: 'malisetu-be0df',
        storageBucket: 'malisetu-be0df.firebasestorage.app',
        iosBundleId: 'com.malisetu.app',
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  // Initialize SharedPreferences
  await SharedPrefs.init();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style for transparent status bar
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // Initialize ApiClient as a singleton in GetX
  Get.put(ApiClient(), permanent: true);

  // Initialize AuthService as a permanent singleton
  Get.put(AuthService(), permanent: true);
}
