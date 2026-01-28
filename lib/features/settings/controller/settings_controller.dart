import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../../core/constent/app_constants.dart';
import '../../../../../core/routes/app_routes.dart';
import '../../../../../core/storage/shared_prefs.dart';
import '../../../../../core/storage/token_manger.dart';
import '../domain/usecase/logout_usecase.dart';



class SettingsController extends GetxController {
  final LogoutUseCase logoutUseCase;

  SettingsController({required this.logoutUseCase});



  var isLoading = false.obs;


  @override
  void onInit() {
    super.onInit();
  }

  Future<void> performLogout() async {
    try {
      isLoading.value = true;

      final success = await logoutUseCase();

      if (success) {
        await TokenManager.clearToken();
        await SharedPrefs.clear();

        Get.offAllNamed(AppRoutes.login);
      }
    } finally {
      isLoading.value = false;
    }
  }


}

