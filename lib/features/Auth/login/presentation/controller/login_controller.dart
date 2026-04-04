import 'dart:convert';
import 'package:edu_cluezer/widgets/custom_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../../core/constent/app_constants.dart';
import '../../../../../core/routes/app_routes.dart';
import '../../../../../core/storage/shared_prefs.dart';
import '../../../../../core/storage/token_manger.dart';
import 'package:edu_cluezer/features/Auth/service/auth_service.dart';
import '../../data/model/res_login_model.dart' hide User;
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

        print("usertype : "+AppConstants.userTypeUser);

        // Set Logged In
        await SharedPrefs.setBool(AppConstants.isLoggedInPref, true);

        CustomSnackBar.showSuccess(message: response.message ?? "Login successful");
        Get.offAllNamed(AppRoutes.dashboard);
      } else {
        CustomSnackBar.showError(message: response.message ?? "Login failed");
      }
    } catch (e) {
      CustomSnackBar.showError(message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }


  Future<void> googleSignIn() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      // Force sign out to ensure account selector shows up every time
      await googleSignIn.signOut();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) return; // User canceled the sign-in

      // We have the googleUser, now call our backend API
      final Map<String, String> data = {
        "google_id": googleUser.id,
        "email": googleUser.email,
      };

      isLoading.value = true;
      final response = await loginUseCase.google(data);

      print("googlelogin1 : "+response.message.toString());

      if (response.success == true) {
        print("googlelogin2 : "+response.message.toString());
         // Save Token
        if (response.data?.token != null) {
          await TokenManager.saveToken(response.data!.token!);
          print(" token : "+response.data!.token.toString());
        }

        print("DEBUG_TOKEN: Retrieved token = '${await TokenManager.getToken() ?? 'NULL/EMPTY'}'");

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

        print("googlelogin : "+response.message.toString());

        CustomSnackBar.showSuccess(message: response.message ?? "Login successful");
        Get.offAllNamed(AppRoutes.dashboard);
      } else {
        CustomSnackBar.showError(message: response.message ?? "Login failed");
      }
    } catch (e) {
      print("googlelogincatch : "+e.toString());

      CustomSnackBar.showError(message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}

