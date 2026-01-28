import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/constent/app_constants.dart';
import '../../../../../core/routes/app_routes.dart';
import '../../../../../core/storage/shared_prefs.dart';
import '../../../../../core/storage/token_manger.dart';
import 'package:edu_cluezer/features/Auth/service/auth_service.dart';
import '../../data/model/res_login_model.dart';
import '../../data/model/req_login_model.dart';
import '../../domain/usecase/login_usecase.dart';


class LoginController extends GetxController {
  final LoginUseCase loginUseCase;

  LoginController({required this.loginUseCase});

  var emailController = TextEditingController();
  var passwordController = TextEditingController();

  var isRemember = true.obs;
  var isPasswordVisible = true.obs;
  var isLoading = false.obs;
  
  final formKey = GlobalKey<FormState>();

  @override
  void onInit() {
    super.onInit();
  }

  Future<void> performLogin() async {
    if (!formKey.currentState!.validate()) return;

    try {
      isLoading.value = true;

      final reqModel = ReqLoginModel(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      final response = await loginUseCase(reqModel);

      if (response.success == true) {
        // Save Token
        if (response.data?.token != null) {
          await TokenManager.saveToken(response.data!.token!);
        }
        
        // Save User Data
        if (response.data?.user != null) {
          final user = response.data!.user!;
          Get.find<AuthService>().currentUser.value = user;
          await SharedPrefs.setString(
            AppConstants.userDataPref,
            jsonEncode(user.toJson()),
          );
        }

        // Set Logged In
        await SharedPrefs.setBool(AppConstants.isLoggedInPref, true);

        Get.snackbar("Success", response.message ?? "Login successful");
        Get.offAllNamed(AppRoutes.dashboard);
      } else {
        Get.snackbar("Error", response.message ?? "Login failed");
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}

