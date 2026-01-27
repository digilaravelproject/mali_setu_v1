import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../Auth/change_password/data/model/req_change_password_model.dart';
import '../../Auth/change_password/domain/usecase/change_password_usecase.dart';


class ChangePasswordController extends GetxController {
  final ChangePasswordUseCase changePasswordUseCase;

  ChangePasswordController({required this.changePasswordUseCase});

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

  // Check form validity
  void checkFormValidity() {
    final currentPasswordValid = validateCurrentPassword(currentPasswordController.text) == null;
    final newPasswordValid = validateNewPassword(newPasswordController.text) == null;
    final confirmPasswordValid = validateConfirmPassword(confirmPasswordController.text) == null;

    isFormValid.value = currentPasswordValid && newPasswordValid && confirmPasswordValid;
  }

  // Change Password Function
  Future<void> changePassword() async {
    print("change password : call function");
    // Form valid check
    if (!isFormValid.value) return;

    isLoading.value = true;

    try {
      final reqModel = ReqChangePasswordModel(
        currentPassword: currentPasswordController.text,
        password: newPasswordController.text,
        passwordConfirmation: confirmPasswordController.text,
      );

      final response = await changePasswordUseCase(reqModel);

      if (response.success == true) {
        // Success
        resetForm();
        Get.back(); // close screen
        Get.snackbar(
          'Success',
          response.message ?? 'Password changed successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        // Error
        Get.snackbar(
          'Error',
          response.message ?? 'Failed to change password',
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
