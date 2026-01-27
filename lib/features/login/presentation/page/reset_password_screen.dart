import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../core/helper/form_validator.dart';
import '../../../../widgets/basic_text_field.dart';
import '../../../../widgets/custom_buttons.dart';

class EmailResetPasswordScreen GetWidget<> {
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

                  // Email input field
                  AppInputTextField(
                    label: "Email ",
                    iconData: CupertinoIcons.mail_solid,
                    textInputType: TextInputType.emailAddress,
                   // controller: controller.mobileController,
                    hint: const [AutofillHints.email],
                    validator: FormValidator.email,
                  ),

                  const SizedBox(height: 32.0),

                  // Submit button
                  CustomButton(
                    borderRadius: 12,
                    title: "Send Otp",
                   // isLoading: controller.isLoading.value,
                    onPressed: (){

                    }
                   // controller.performLogin,
                  ),

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







class ResetPasswordScreen extends StatelessWidget {
  const ResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final List<TextEditingController> otpControllers = List.generate(
      6,
          (_) => TextEditingController(),
    );

    final List<FocusNode> otpFocusNodes = List.generate(6, (_) => FocusNode());

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

                  const SizedBox(height: 38.0),

                  // OTP Input Field
                  // AppInputTextField(
                  //   label: "OTP",
                  //   iconData: CupertinoIcons.number_square,
                  //   textInputType: TextInputType.number,
                  //   // controller: controller.otpController,
                  //   hint: const ["Enter 6-digit OTP"],
                  //   validator: FormValidator.otp,
                  //   maxLength: 6,
                  // ),


                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(6, (index) {
                      return TextFormField(
                       // controller: otpControllers[index],
                       // focusNode: otpFocusNodes[index],
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        maxLength: 1,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        cursorHeight: 20,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.zero,
                          counterText: '',
                          constraints: const BoxConstraints.tightFor(
                            height: 50,
                            width: 50,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onChanged: (value) {
                          if (value.isNotEmpty && index < 5) {
                            otpFocusNodes[index + 1].requestFocus();
                          } else if (value.isEmpty && index > 0) {
                            otpFocusNodes[index - 1].requestFocus();
                          }
                        },
                      );
                    }),
                  ),

                  const SizedBox(height: 24.0),

                  // New Password Field
                  AppInputTextField(
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

                  const SizedBox(height: 24.0),

                  // Confirm Password Field
                  AppInputTextField(
                    label: "Confirm Password",
                    iconData: CupertinoIcons.lock_fill,
                    textInputType: TextInputType.visiblePassword,
                    // controller: controller.confirmPasswordController,
                    hint: const ["Re-enter new password"],
                    validator: (value) {
                      // You can add custom validation to match both passwords
                      // if (value != controller.newPasswordController.text) {
                      //   return 'Passwords do not match';
                      // }
                      return FormValidator.password(value);
                    },
                    isPassword: true,
                  ),

                  // Password requirements
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0, left: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Password must contain:',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        Row(
                          children: [
                            Icon(
                              Icons.check_circle_outline,
                              size: 14,
                              color: Colors.green.shade600,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'At least 8 characters',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2.0),
                        Row(
                          children: [
                            Icon(
                              Icons.check_circle_outline,
                              size: 14,
                              color: Colors.green.shade600,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'One uppercase & lowercase letter',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2.0),
                        Row(
                          children: [
                            Icon(
                              Icons.check_circle_outline,
                              size: 14,
                              color: Colors.green.shade600,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'One number and special character',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32.0),

                  // Submit button
                  CustomButton(
                      borderRadius: 12,
                      title: "Reset Password",
                      // isLoading: controller.isLoading.value,
                      onPressed: () {
                        // controller.verifyOtpAndResetPassword();
                      }
                  ),

                  const Spacer(),

                  // Resend OTP Section
                  Padding(
                    padding: const EdgeInsets.only(bottom: 40.0, top: 20.0),
                    child: Center(
                      child: Column(
                        children: [
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
                                  // controller.resendOtp();
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
                          const SizedBox(height: 10.0),
                          Text(
                            "OTP expires in 05:00",
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.red.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
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