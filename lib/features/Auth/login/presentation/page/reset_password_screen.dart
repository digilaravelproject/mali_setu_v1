import 'package:edu_cluezer/core/routes/app_routes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../../core/helper/form_validator.dart';
import '../../../../../widgets/basic_text_field.dart';
import '../../../../../widgets/custom_buttons.dart';
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
                    'Reset Password',
                    style: theme.textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12.0),
                  Text(
                    'Enter your email address and we\'ll send you OTP to reset your password.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 38.0),

                  Form(
                    key: controller.formKey,
                    child: Column(
                      children: [
                        AppInputTextField(
                          label: "Email ",
                          iconData: CupertinoIcons.mail_solid,
                          textInputType: TextInputType.emailAddress,
                          controller: controller.emailController,
                          hint: const [AutofillHints.email],
                          validator: FormValidator.email,
                        ),

                        const SizedBox(height: 32.0),

                        // Submit button
                        CustomButton(
                          borderRadius: 12,
                          title: "Send Otp",
                          // isLoading: controller.isLoading.value,
                          onPressed: controller.sendOtp,
                          // controller.performLogin,
                        ),
                      ],
                    ),
                  ),

                  // Email input field


                  const SizedBox(height: 24.0),

                  // Helper text
                  Center(
                    child: Text(
                      'We\'ll email you a link to reset your password',
                      style: theme.textTheme.bodyMedium?.copyWith(
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Footer/Decoration
                  Padding(
                    padding: const EdgeInsets.only(bottom: 40.0, top: 20.0),
                    child: Center(
                      child: Column(
                        children: [
                          Container(
                            width: 60.0,
                            height: 4.0,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(2.0),
                            ),
                          ),
                          const SizedBox(height: 20.0),
                          RichText(
                            text: TextSpan(
                              text: 'Need help? ',
                              style: const TextStyle(color: Colors.grey),
                              children: [
                                TextSpan(
                                  text: 'Contact Support',
                                  style: TextStyle(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
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

                  // Header section
                  Text(
                    'Create New Password',
                    style: theme.textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12.0),
                  Text(
                    'Enter OTP received on your email and set your new password',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 30.0),

                 Form(
                   key: controller.formKey,
                   child: Column(
                     children: [
                       // OTP Input Field
                       AppInputTextField(
                         label: "OTP",
                         iconData: CupertinoIcons.number_square,
                         textInputType: TextInputType.number,
                          controller: controller.otpController,
                         hint: const ["Enter 6-digit OTP"],
                         // validator: FormValidator.otp,
                         //maxLength: 6,
                       ),

                       const SizedBox(height: 16.0),

                       // New Password Field
                       Obx(
                             ()=>AppInputTextField(
                           label: "Password",
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
                         ),
                       ),

                       const SizedBox(height: 16.0),

                       // Confirm Password Field
                       Obx(
                             ()=>AppInputTextField(
                           label: "Confirm Password",
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
                         ),
                       ),

                       const SizedBox(height: 32.0),

                       // Submit button
                       CustomButton(
                           borderRadius: 12,
                           title: "Reset Password",
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
                        "Didn't receive OTP? ",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Get.back();
                        },
                        child: Text(
                          "Resend OTP",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
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
                          Container(
                            width: 60.0,
                            height: 4.0,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(2.0),
                            ),
                          ),
                          const SizedBox(height: 20.0),
                          RichText(
                            text: TextSpan(
                              text: 'Need help? ',
                              style: TextStyle(color: Colors.grey.shade600),
                              children: [
                                TextSpan(
                                  text: 'Contact Support',
                                  style: TextStyle(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
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