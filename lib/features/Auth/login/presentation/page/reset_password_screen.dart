import 'package:edu_cluezer/core/routes/app_routes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../../core/helper/form_validator.dart';
import '../../../../../core/utils/app_assets.dart';
import '../../../../../widgets/basic_text_field.dart';
import '../../../../../widgets/custom_buttons.dart';
import '../../../../../widgets/custom_image_view.dart';
import '../controller/reset_password_controller.dart';

class EmailResetPasswordScreen extends GetWidget<ResetPasswordController>{
  const EmailResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: size.height - MediaQuery.of(context).padding.top,
            ),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back button
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0, bottom: 20.0),
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Container(
                        // padding: const EdgeInsets.all(8.0),
                        // decoration: BoxDecoration(
                        //   color: Colors.grey.shade100,
                        //   borderRadius: BorderRadius.circular(12.0),
                       // ),
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 20.0,
                          color: context.iconColor,
                        ),
                      ),
                    ),
                  ),

                  // Header section
                  Text(
                    'reset_password'.tr,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    'enter_email_otp'.tr,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      height: 1.4,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),

                  const SizedBox(height: 24.0),

                  Form(
                    key: controller.formKey,
                    child: Column(
                      children: [
                        AppInputTextField(
                          label: "email".tr,
                          iconData: CupertinoIcons.mail_solid,
                          textInputType: TextInputType.emailAddress,
                          controller: controller.emailController,
                          hint: const [AutofillHints.email],
                          validator: FormValidator.email,
                        ),

                        const SizedBox(height: 24.0),

                        // Submit button
                        Obx(() => CustomButton(
                          title: "send_otp".tr,
                          onPressed: controller.sendOtp,
                          isLoading: controller.isLoading.value,
                        )),
                      ],
                    ),
                  ),

                  // Email input field


                  const SizedBox(height: 24.0),


                  const Spacer(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}







class ResetPasswordScreen extends GetWidget<ResetPasswordController> {
  const ResetPasswordScreen({super.key});


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;


    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: size.height - MediaQuery.of(context).padding.top,
            ),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back button
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0, bottom: 20.0),
                    child: IconButton(
                      onPressed: () => Get.back(),
                      icon: Container(
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 20.0,
                          color: context.iconColor,
                        ),
                      ),
                    ),
                  ),

            // const SizedBox(height: 50),
            // Center(
            //   child: CustomImageView(
            //     imagePath: AppAssets.getAppLogo(),
            //     height: 100,
            //     width: 100,
            //   ),
            // ),
            // const SizedBox(height: 32),
            // Header section
            Text(
              'create_new_password'.tr,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 24,
              ),
            ),
            const SizedBox(height: 12.0),
            Text(
              'enter_otp_email'.tr,
              style: theme.textTheme.bodyMedium?.copyWith(
                height: 1.4,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 20.0),

                 Form(
                   key: controller.formKey,
                   child: Column(
                     children: [
                       // OTP Input Field
                       AppInputTextField(
                         label: "otp".tr,
                         iconData: CupertinoIcons.number_square,
                         textInputType: TextInputType.number,
                          controller: controller.otpController,
                         hint:  ["enter_6_digit_otp".tr],
                         // validator: FormValidator.otp,
                         //maxLength: 6,
                       ),

                       // New Password Field
                       Obx(
                             ()=>AppInputTextField(
                           label: "password".tr,
                           iconData: CupertinoIcons.lock_fill,
                           textInputType: TextInputType.visiblePassword,
                           controller: controller.passwordController,
                           hint: const [AutofillHints.password],
                           isObscure: !controller.isPasswordVisible.value,
                           endIcon: controller.isPasswordVisible.value
                               ? Icons.remove_red_eye_rounded
                               : Icons.visibility_off,
                           onEndIconTap: () => controller.isPasswordVisible.toggle(),
                           validator: FormValidator.password,
                           topPadding: 0,
                         ),
                       ),

                       // Confirm Password Field
                       Obx(
                             ()=>AppInputTextField(
                           label: "confirm_password".tr,
                           iconData: CupertinoIcons.lock_fill,
                           textInputType: TextInputType.visiblePassword,
                           controller: controller.confPasswordController,
                           hint: const [AutofillHints.password],
                           isObscure: !controller.isPasswordVisible.value,
                           endIcon: controller.isPasswordVisible.value
                               ? Icons.remove_red_eye_rounded
                               : Icons.visibility_off,
                           onEndIconTap: () => controller.isPasswordVisible.toggle(),
                           validator: FormValidator.password,
                           topPadding: 0,
                         ),
                       ),

                       const SizedBox(height: 32.0),

                       // Submit button
                        CustomButton(
                            title: "reset_password_btn".tr,
                           // isLoading: controller.isLoading.value,
                           onPressed: () {
                             controller.resetPassword();
                           }
                       ),
                     ],
                   ),
                 ),


                  const SizedBox(height: 32.0),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "didnt_receive_otp".tr,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                       const SizedBox(width: 5.0),
                      Obx(() => GestureDetector(
                        onTap: controller.isLoading.value ? null : controller.resendOtp,
                        child: controller.isLoading.value
                            ? const SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(
                                "resend_otp".tr,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      )),
                    ],
                  ),

                  const Spacer(),

                  // Resend OTP Section
                  Padding(
                    padding: const EdgeInsets.only(bottom: 40.0, top: 30.0),
                    child: Center(
                      child: Column(
                        children: [

                          const SizedBox(height: 20.0),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}