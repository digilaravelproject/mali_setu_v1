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
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 50),
            // Logo at the top - centered (language-based)
            Center(
              child: CustomImageView(
                imagePath: AppAssets.getAppLogo(),
                height: 100,
                width: 100,
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Column(
                children: [
                  Text(
                    'welcome_back'.tr,
                    style: context.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'login_to_continue'.tr,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.theme.colorScheme.onSurface.withValues(
                        alpha: 0.6,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Form(
              key: controller.formKey,
              child: Column(
                children: [
                  AppInputTextField(
                    label: 'email_label'.tr,
                    iconData: CupertinoIcons.mail_solid,
                    textInputType: TextInputType.emailAddress,
                    controller: controller.emailController,
                    hint: const [AutofillHints.email],
                    validator: FormValidator.email,
                    isRequired: true,
                  ),
                  Obx(
                    () => AppInputTextField(
                      label: 'password_label'.tr,
                      iconData: CupertinoIcons.lock_fill,
                      textInputType: TextInputType.visiblePassword,
                      controller: controller.passwordController,
                      hint: const [AutofillHints.password],
                      isObscure: !controller.isPasswordVisible.value,
                      endIcon: controller.isPasswordVisible.value
                          ? Icons.visibility_off
                          : Icons.remove_red_eye_rounded,
                      onEndIconTap: () => controller.isPasswordVisible.toggle(),
                      validator: FormValidator.password,
                      topPadding: 0,
                      isRequired: true,
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
                            'remember_me'.tr,
                            style: context.textTheme.labelSmall,
                          ),
                        ],
                      ),
                      CustomTextButton(
                        title: 'forget_password'.tr,
                        fontSize: 13,
                        onPressed: () => Get.toNamed(AppRoutes.emailPasswordReset),
                      ),
                    ],
                  ).marginSymmetric(vertical: 8),
                  Obx(
                    () => CustomButton(
                      title: 'login_button'.tr,
                      isLoading: controller.isLoading.value,
                      onPressed: controller.performLogin,
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: context.theme.colorScheme.outline.withValues(
                        alpha: 0.2,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'or'.tr,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.theme.colorScheme.onSurface.withValues(
                          alpha: 0.4,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      color: context.theme.colorScheme.outline.withValues(
                        alpha: 0.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Social Login Button
            CustomOutlinedButton(
              title: 'sign_in_with_google'.tr,
              leading: const CustomImageView(
                svgPath: AppAssets.icGoogle,
                height: 20,
                width: 20,
              ),
              onPressed: controller.googleSignIn,
              textColor: context.theme.colorScheme.onSurface,
              borderColor: context.theme.colorScheme.outline.withValues(alpha: 0.3),
            ),

            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 16, bottom: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'dont_have_account'.tr,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    CustomTextButton(
                      title: 'register'.tr,
                      onPressed: () => Get.toNamed(AppRoutes.register),
                      textColor: context.theme.colorScheme.primary,
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
