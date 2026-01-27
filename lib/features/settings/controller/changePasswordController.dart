import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../common/api/apiClient.dart';
import '../../../db/shared_pref_manager.dart';

class ChangePasswordController extends GetxController {
  // Text Controllers
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // Observables
  final isCurrentPasswordVisible = false.obs;
  final isNewPasswordVisible = false.obs;
  final isConfirmPasswordVisible = false.obs;
  final isLoading = false.obs;
  final isFormValid = false.obs;

  // Validations
  String? validateCurrentPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter current password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? validateNewPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter new password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }

    // Check if new password is same as current
    if (value == currentPasswordController.text) {
      return 'New password must be different from current password';
    }

    // Password strength validation (optional)
    if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d@$!%*#?&]{6,}$').hasMatch(value)) {
      return 'Password must contain letters and numbers';
    }

    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != newPasswordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  final apiClient = ApiClient(
    baseUrl: 'https://greenyellow-grouse-707123.hostingersite.com/public/api',
  );
  // Check form validity
  void checkFormValidity() {
    final currentPasswordValid = validateCurrentPassword(currentPasswordController.text) == null;
    final newPasswordValid = validateNewPassword(newPasswordController.text) == null;
    final confirmPasswordValid = validateConfirmPassword(confirmPasswordController.text) == null;

    isFormValid.value = currentPasswordValid && newPasswordValid && confirmPasswordValid;
  }

  // Change Password Function


  Future<void> changePassword() async {
    
    print("chnage password : call function");
    // Form valid check
    if (!isFormValid.value) return;

    isLoading.value = true;

    try {
      // Prepare request body
      final body = {
        "current_password": currentPasswordController.text,
        "password": newPasswordController.text,
        "password_confirmation": confirmPasswordController.text,
      };

      print("chnage p[assword :"+body.toString());
      // Make POST call using your existing method
      final response = await apiClient.post(
        '/auth/change-password',
        body: body,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${SharedPrefManager().userToken}',
          //SharedPrefManager().userToken, // token from shared prefs
        },
      );

      print("chnagepasswordresponse : "+response.body);

      print("token : "+SharedPrefManager().userToken,);
      print("response  : "+response.body);

      final decoded = jsonDecode(response.body);

      if (response.statusCode == 200 && decoded['success'] == true) {
        // Success
        resetForm();
        Get.back(); // close screen
        Get.snackbar(
          'Success',
          decoded['message'] ?? 'Password changed successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        // Error
        Get.snackbar(
          'Error',
          decoded['message'] ?? 'Failed to change password',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      // Exception
      Get.snackbar(
        'Error',
        'Something went wrong: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

 /* Future<void> changePassword() async {
    if (!isFormValid.value) return;

    isLoading.value = true;

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      // Reset form on success
      resetForm();

      Get.back();
      Get.snackbar(
        'Success',
        'Password changed successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to change password: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }*/



  /// REGISTER ACTION - API Call

  // Reset form
  void resetForm() {
    currentPasswordController.clear();
    newPasswordController.clear();
    confirmPasswordController.clear();
    isCurrentPasswordVisible.value = false;
    isNewPasswordVisible.value = false;
    isConfirmPasswordVisible.value = false;
    isFormValid.value = false;
  }

  // Dispose controllers
  @override
  void onClose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}