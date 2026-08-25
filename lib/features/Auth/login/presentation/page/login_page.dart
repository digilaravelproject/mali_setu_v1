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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              // Logo
              Center(
                child: Hero(
                  tag: 'app_logo',
                  child: CustomImageView(
                    imagePath: AppAssets.getAppLogo(),
                    height: 100,
                    width: 100,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Welcome Text
              Text(
                'welcome_back'.tr,
                textAlign: TextAlign.center,
                style: context.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 28,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'login_to_continue'.tr,
                textAlign: TextAlign.center,
                style: context.textTheme.bodyLarge?.copyWith(
                  color: context.theme.colorScheme.onSurface.withValues(
                    alpha: 0.6,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              
              // Social Logins First
              Container(
                height: 48,
                decoration: BoxDecoration(
                  color: context.theme.cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: context.theme.colorScheme.outline.withValues(alpha: 0.15),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: context.theme.colorScheme.shadow.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: controller.googleSignIn,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CustomImageView(
                          svgPath: AppAssets.icGoogle,
                          height: 24,
                          width: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'sign_in_with_google'.tr,
                          style: context.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (GetPlatform.isIOS) ...[
                const SizedBox(height: 16),
                CustomButton(
                  title: 'sign_in_with_apple'.tr,
                  backgroundColor: Colors.black,
                  textColor: Colors.white,
                  leading: const Icon(
                    Icons.apple,
                    color: Colors.white,
                    size: 26,
                  ),
                  onPressed: controller.appleSignIn,
                ),
              ],
              
              const SizedBox(height: 28),
              
              // Divider
              Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: context.theme.colorScheme.outline.withValues(alpha: 0.2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'or'.tr,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      color: context.theme.colorScheme.outline.withValues(alpha: 0.2),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              
              // Email Form Section
              Container(
                decoration: BoxDecoration(
                  color: context.theme.cardColor,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: context.theme.colorScheme.outline.withValues(alpha: 0.1),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: context.theme.colorScheme.shadow.withValues(alpha: 0.04),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(24),
                child: Form(
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
                      const SizedBox(height: 16),
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
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Obx(
                                () => SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: Checkbox(
                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    value: controller.isRemember.value,
                                    onChanged: (value) => controller.isRemember(value),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'remember_me'.tr,
                                style: context.textTheme.labelMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          CustomTextButton(
                            title: 'forget_password'.tr,
                            fontSize: 13,
                            onPressed: () => Get.toNamed(AppRoutes.emailPasswordReset),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
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
              ),
              
              const SizedBox(height: 32),
              
              // Register
              Row(
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
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
