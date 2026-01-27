import 'package:edu_cluezer/core/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';

import '../../../../db/shared_pref_manager.dart';

// class InitController extends GetxController
//     implements GetTickerProviderStateMixin {
//   var isLoading = true.obs;
//
//   Future<void> startNavigate() async {
//     await Future.delayed(Duration(seconds: 2));
//     Get.offNamed(AppRoutes.login);
//   }
//
//   @override
//   Ticker createTicker(TickerCallback onTick) {
//     return Ticker(onTick);
//   }
//
//   @override
//   void didChangeDependencies(BuildContext context) {}
// }




class InitController extends GetxController
    implements GetTickerProviderStateMixin {
  var isLoading = true.obs;

  Future<void> startNavigate() async {
    await Future.delayed(const Duration(seconds: 2));

    // Check login status
    if (SharedPrefManager().isLoggedIn) {
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
