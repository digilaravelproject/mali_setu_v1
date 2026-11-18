import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/helper/form_validator.dart';
import '../../../../../core/routes/app_routes.dart';
import '../../../../../core/utils/app_assets.dart';
import '../../../../../widgets/basic_text_field.dart';
import '../../../../../widgets/custom_buttons.dart';
import '../../../../../widgets/custom_image_view.dart';
import '../../../../../widgets/custom_scaffold.dart';
import '../../../../../widgets/language_selection_dialog.dart';
import '../controller/login_controller.dart';

class LoginPage extends GetWidget<LoginController> {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      showWhatsAppFab: true,
      enableDoubleTapExit: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Bar with Language Switcher
              Align(
                alignment: Alignment.topRight,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: context.theme.cardColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: context.theme.dividerColor.withValues(alpha: 0.15),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const LanguageAppBarButton(),
                ),
              ),
              const SizedBox(height: 12),

              // Logo with soft elevated halo
              Center(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: context.theme.primaryColor.withValues(alpha: 0.12),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Hero(
                    tag: 'app_logo',
                    child: CustomImageView(
                      imagePath: AppAssets.getAppLogo(),
                      height: 84,
                      width: 84,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // Welcome Text
              Text(
                'welcome_back'.tr,
                textAlign: TextAlign.center,
                style: context.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 26,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'login_to_continue'.tr,
                textAlign: TextAlign.center,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.theme.colorScheme.onSurface.withValues(
                    alpha: 0.6,
                  ),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 28),
              
              // Continue with Google Button
              Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFFE2E8F0),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: controller.googleSignIn,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CustomImageView(
                          svgPath: AppAssets.icGoogle,
                          height: 22,
                          width: 22,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'continue_with_google'.tr,
                          style: context.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (GetPlatform.isIOS) ...[
                const SizedBox(height: 14),
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
              
              const SizedBox(height: 22),
              
              // Divider with pill
              Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: context.theme.colorScheme.outline.withValues(alpha: 0.2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'or'.tr,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey.shade500,
                          letterSpacing: 1.2,
                        ),
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
              const SizedBox(height: 14),

              // Text under OR: Continue with mobile number(otp)
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: context.theme.primaryColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: context.theme.primaryColor.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.phone_android_rounded,
                        size: 16,
                        color: context.theme.primaryColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'continue_with_mobile_otp'.tr,
                        style: TextStyle(
                          color: context.theme.primaryColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Email Form Section
              Container(
                decoration: BoxDecoration(
                  color: context.theme.cardColor,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: context.theme.colorScheme.outline.withValues(alpha: 0.12),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: context.theme.colorScheme.shadow.withValues(alpha: 0.04),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
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
                                  width: 22,
                                  height: 22,
                                  child: Checkbox(
                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    value: controller.isRemember.value,
                                    onChanged: (value) => controller.isRemember(value),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                    activeColor: context.theme.primaryColor,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'remember_me'.tr,
                                style: context.textTheme.labelMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF475569),
                                ),
                              ),
                            ],
                          ),
                          CustomTextButton(
                            title: 'forget_password'.tr,
                            fontSize: 13,
                            textColor: context.theme.primaryColor,
                            onPressed: () => Get.toNamed(AppRoutes.emailPasswordReset),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
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
              
              const SizedBox(height: 28),
              
              // Register
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'dont_have_account'.tr,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF64748B),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 4),
                  CustomTextButton(
                    title: 'register'.tr,
                    onPressed: () => Get.toNamed(AppRoutes.register),
                    textColor: context.theme.colorScheme.primary,
                    fontSize: 14,
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
