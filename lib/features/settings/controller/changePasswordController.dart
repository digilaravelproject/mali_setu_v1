import 'dart:convert';
import 'package:edu_cluezer/widgets/custom_snack_bar.dart';
import 'package:edu_cluezer/core/helper/form_validator.dart';
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
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }

  String? validateNewPassword(String? value) {
    final error = FormValidator.strictPassword(value);
    if (error != null) {
      return error;
    }

    // Check if new password is same as current
    if (value == currentPasswordController.text) {
      return 'New password must be different from current password';
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
        CustomSnackBar.showSuccess(
          message: response.message ?? 'Password changed successfully',
        );
      } else {
        // Error
        CustomSnackBar.showError(
          message: response.message ?? 'Failed to change password',
        );
      }
    } catch (e) {
      // Exception
      CustomSnackBar.showError(
        message: 'Something went wrong: $e',
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
