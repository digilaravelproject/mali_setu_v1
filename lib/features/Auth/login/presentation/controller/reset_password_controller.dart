import 'dart:convert';

import 'package:edu_cluezer/features/Auth/login/data/model/req_reset_password_model.dart';
import 'package:edu_cluezer/features/Auth/login/domain/usecase/reset_password_usecase.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_ticket_provider_mixin.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

import '../../../../../core/constent/app_constants.dart';
import '../../../../../core/helper/logger_helper.dart';
import '../../../../../core/routes/app_routes.dart';
import '../../../../../core/storage/shared_prefs.dart';
import '../../../../../core/storage/token_manger.dart';
import '../../../../../widgets/custom_snack_bar.dart';
import '../../data/data_source/login_data_source.dart';
import '../page/otp_verification_bts.dart';

class ResetPasswordController extends GetxController {
  final ResetPasswordUseCase resetPasswordUseCase;
  var resetEmail = ''.obs;

  ResetPasswordController({required this.resetPasswordUseCase});

  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  var confPasswordController = TextEditingController();
  var otpController = TextEditingController();

  var isPasswordVisible = true.obs;

  var countryController = TextEditingController();
  var isLoading = false.obs;
  final formKey = GlobalKey<FormState>();
  final formKeyReset = GlobalKey<FormState>();

  @override
  void onInit() {
    super.onInit();

    // Agar email argument me aaya ho
    final args = Get.arguments;
    if (args != null && args['email'] != null) {
      emailController.text = args['email'];
      resetEmail.value = args['email'];
    }
  }

  Future<void> sendOtp() async {
    if (!formKey.currentState!.validate()) return;
    try {
      isLoading.value = true;

      final reqModel = ReqResetPasswordModel(
        email: emailController.text.trim(),
      );

      final response = await resetPasswordUseCase.sendOtp(reqModel);

      if (response.success == true) {
        resetEmail.value = emailController.text.trim();

        CustomSnackBar.showSuccess(message: response.message ?? "OTP send successful");
        Get.toNamed(
          AppRoutes.resetPasswordScreen,
          arguments: {
            'email': resetEmail.value, // pass email to next screen
          },
        );
      } else {
        CustomSnackBar.showError(message: response.message ?? "OTP send failed");
      }
    } catch (e) {
      CustomSnackBar.showError(message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resendOtp() async {
    try {
      isLoading.value = true;

      final reqModel = ReqResetPasswordModel(
        email: emailController.text.trim(),
      );

      final response = await resetPasswordUseCase.sendOtp(reqModel);

      if (response.success == true) {
        CustomSnackBar.showSuccess(message: response.message ?? "OTP resent successful");
      } else {
        CustomSnackBar.showError(message: response.message ?? "OTP resend failed");
      }
    } catch (e) {
      CustomSnackBar.showError(message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resetPassword() async {
    if (!formKeyReset.currentState!.validate()) return;
    try {
      isLoading.value = true;

      final reqModel = RequestResetPasswordModel(
        email: emailController.text,
        otp: otpController.text,
        password: passwordController.text,
        passwordConfirmation: confPasswordController.text,
      );

      final success = await resetPasswordUseCase.callReset(reqModel);

      if (success) {
        CustomSnackBar.showSuccess(message: "Password reset successful");
        Get.offNamed(AppRoutes.login);
      }
    } catch (e) {
      CustomSnackBar.showError(message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void _initCountry() {}
}
