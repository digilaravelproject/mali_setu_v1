import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../page/email_display_page.dart';

import '../../../../../core/constent/app_constants.dart';
import '../../../../../core/routes/app_routes.dart';
import '../../../../../core/storage/shared_prefs.dart';
import '../../../../../core/storage/token_manger.dart';
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
           await SharedPrefs.setString(
            AppConstants.userDataPref,
            jsonEncode(response.data!.user!.toJson()),
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


  Future<void> googleSignIn() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return; // User canceled the sign-in

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        Get.snackbar("Success", "Google Login Successful");
       // Get.to(() => EmailDisplayPage(email: user.email));
      }

    } catch (e) {
      Get.snackbar("Error", "Google Sign-In failed: $e");
    }
  }





}

