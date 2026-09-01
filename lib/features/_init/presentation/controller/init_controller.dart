import 'package:edu_cluezer/core/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';

import '../../../../core/constent/app_constants.dart';
import '../../../../core/storage/shared_prefs.dart';
import '../../../../core/services/deep_link_service.dart';

class InitController extends GetxController
    implements GetTickerProviderStateMixin {
  var isLoading = true.obs;

  Future<void> startNavigate() async {
    await Future.delayed(const Duration(seconds: 2));

    final bool isLoggedIn = SharedPrefs.getBool(AppConstants.isLoggedInPref) ?? false;
    
    if (isLoggedIn) {
      Get.offAllNamed(AppRoutes.dashboard);
    } else {
      Get.offAllNamed(AppRoutes.login);
    }

    // Wait for the transition to fully complete before unblocking DeepLinkService
    await Future.delayed(const Duration(milliseconds: 600));

    // Mark app as ready for deep link handling
    DeepLinkService.isAppReady = true;
  }

  @override
  Ticker createTicker(TickerCallback onTick) {
    return Ticker(onTick);
  }

  @override
  void didChangeDependencies(BuildContext context) {}
}
