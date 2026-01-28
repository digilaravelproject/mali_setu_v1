import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/helper/form_validator.dart';
import '../../../../../core/routes/app_routes.dart';
import '../../../../../core/styles/app_colors.dart';
import '../../../../../core/styles/app_decoration.dart';
import '../../../../../core/utils/app_assets.dart';
import '../../../../../widgets/basic_text_field.dart';
import '../../../../../widgets/custom_buttons.dart';
import '../../../../../widgets/custom_image_view.dart';
import '../../../../../widgets/custom_scaffold.dart';
import '../controller/login_controller.dart';

class LoginPage extends GetWidget<LoginController> {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      appBar: AppBar(
        backgroundColor: AppColors.transparent,
        surfaceTintColor: AppColors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 32),
            Text(
              "Welcome Back",
              style: context.textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Login to continue your journey",
              style: context.textTheme.bodyLarge?.copyWith(
                color: context.theme.colorScheme.onSurface.withValues(
                  alpha: 0.7,
                ),
              ),
            ),
            const SizedBox(height: 32),
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
                  const SizedBox(height: 16),
                  Obx(
                    () => AppInputTextField(
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Obx(
                            () => Checkbox(
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              value: controller.isRemember.value,
                              onChanged: (value) =>
                                  controller.isRemember(value),
                            ),
                          ),
                          Text(
                            "Remember Me",
                            style: context.textTheme.labelSmall,
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () {
                          Get.toNamed(AppRoutes.emailPasswordReset);
                        },
                        child: Text("Forget Password"),
                      ),
                    ],
                  ).marginSymmetric(vertical: 12),
                  Obx(
                    () => CustomButton(
                      title: "Login",
                      isLoading: controller.isLoading.value,
                      onPressed:
                        //  (){Get.toNamed(AppRoutes.dashboard);}
                      controller.performLogin,
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: context.theme.colorScheme.outline.withValues(
                        alpha: 0.3,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      "OR",
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.theme.colorScheme.onSurface.withValues(
                          alpha: 0.5,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      color: context.theme.colorScheme.outline.withValues(
                        alpha: 0.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Social Login Buttons
            GestureDetector(
              onTap: controller.googleSignIn,
              child: Container(
                decoration: AppDecorations.cardDecoration(context),
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 12,
                  children: [
                    CustomImageView(
                      svgPath: AppAssets.icGoogle,
                      width: 24,
                      height: 24,
                    ),
                    Text(
                      "Sign in with Google",
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 24, bottom: 32),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.theme.colorScheme.onSurface.withValues(
                          alpha: 0.7,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Get.toNamed(AppRoutes.register),
                      child: Text(
                        "Register",
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: context.theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
