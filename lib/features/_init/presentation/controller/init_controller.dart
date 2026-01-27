import 'package:edu_cluezer/core/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';

import '../../../../core/constent/app_constants.dart';
import '../../../../core/storage/shared_prefs.dart';

class InitController extends GetxController
    implements GetTickerProviderStateMixin {
  var isLoading = true.obs;

  Future<void> startNavigate() async {
    await Future.delayed(const Duration(seconds: 2));

    // Check login status
    final bool isLoggedIn = SharedPrefs.getBool(AppConstants.isLoggedInPref) ?? false;

    if (isLoggedIn) {
      Get.offNamed(AppRoutes.dashboard);
    } else {
      Get.offNamed(AppRoutes.login);
    }
  }

  @override
  Ticker createTicker(TickerCallback onTick) {
    return Ticker(onTick);
  }

  @override
  void didChangeDependencies(BuildContext context) {}
}
