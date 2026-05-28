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
import '../domain/usecase/delete_account_usecase.dart';
import '../../Auth/service/auth_service.dart';
import '../../../../widgets/custom_snack_bar.dart';



class SettingsController extends GetxController {
  final LogoutUseCase logoutUseCase;
  final DeleteAccountUseCase deleteAccountUseCase;

  SettingsController({
    required this.logoutUseCase,
    required this.deleteAccountUseCase,
  });



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

  Future<void> performDeleteAccount() async {
    try {
      isLoading.value = true;
      final success = await deleteAccountUseCase();

      if (success) {
        await TokenManager.clearToken();
        await SharedPrefs.clear();
        
        CustomSnackBar.showSuccess(message: 'account_deleted_success'.tr);
        Get.offAllNamed(AppRoutes.login);
      }
    } catch (e) {
      // Even if API fails, we should handle it or let user know
      // For App Review, we want this to work smoothly
      CustomSnackBar.showError(message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}

