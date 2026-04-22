import 'package:edu_cluezer/widgets/custom_buttons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';

import '../../../core/helper/form_validator.dart';
import '../../../widgets/basic_text_field.dart';
import '../controller/changePasswordController.dart';

class ChangePasswordScreen extends GetWidget<ChangePasswordController> {
  ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        leading: GestureDetector(
          onTap: Get.back,
           child: Container(
             margin: const EdgeInsets.all(8),
             decoration: BoxDecoration(
               color: Colors.white,
               shape: BoxShape.circle,
               border: Border.all(color: Colors.grey[200]!)
             ),
             child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Colors.black87),
          ),
        ),
        title: Text(
          "change_password".tr,
          style: context.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.grey[50],
        elevation: 0,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            child: Column(
              children: [
                // Header
                _buildHeader(context),
                const SizedBox(height: 32),

                // Form
                _buildPasswordForm(context),
                const SizedBox(height: 40),

                Obx(() => CustomButton(
                  title: "change_password".tr,
                  height: 50,
                  borderRadius: 16,
                  isLoading: controller.isLoading.value,
                  backgroundColor: controller.isFormValid.value && !controller.isLoading.value 
                      ? Get.theme.primaryColor 
                      : Colors.grey[300],
                  onPressed: () {
                    if (controller.isFormValid.value && !controller.isLoading.value) {
                      controller.changePassword();
                    }
                  },
                )),

                const SizedBox(height: 30),

                // Password Guidelines
                _buildPasswordGuidelines(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Get.theme.primaryColor.withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Icon(
            Icons.lock_reset_rounded,
            size: 40,
            color: Get.theme.primaryColor,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'create_new_password'.tr,
          style: context.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'password_subtitle'.tr,
          textAlign: TextAlign.center,
          style: context.textTheme.bodyMedium?.copyWith(
             color: Colors.grey[600],
             height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordForm(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
         boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Obx(() {
        // Listen to form changes
        controller.checkFormValidity();
  
        return Column(
          children: [
            // Current Password
            AppInputTextField(
              label: "current_password".tr,
              iconData: Icons.lock_outline_rounded,
              textInputType: TextInputType.visiblePassword,
              controller: controller.currentPasswordController,
              hint: const [AutofillHints.password],
              isObscure: !controller.isCurrentPasswordVisible.value,
              endIcon: controller.isCurrentPasswordVisible.value
                  ? Icons.visibility
                  : Icons.visibility_off,
              onEndIconTap: () => controller.isCurrentPasswordVisible.toggle(),
              validator: FormValidator.password,
            //  controller.validateCurrentPassword,
              onChanged: (_) => controller.checkFormValidity(),
            ),
            const SizedBox(height: 20),
  
            // New Password
            AppInputTextField(
              label: "new_password".tr,
              iconData: Icons.lock_reset_outlined,
              textInputType: TextInputType.visiblePassword,
              controller: controller.newPasswordController,
              hint: const [AutofillHints.newPassword],
              isObscure: !controller.isNewPasswordVisible.value,
              endIcon: controller.isNewPasswordVisible.value
                  ? Icons.visibility
                  : Icons.visibility_off,
              onEndIconTap: () => controller.isNewPasswordVisible.toggle(),
              validator: FormValidator.password,
              onChanged: (_) => controller.checkFormValidity(),
            ),
            const SizedBox(height: 20),
  
            // Confirm Password
            AppInputTextField(
              label: "confirm_password".tr,
              iconData: Icons.check_circle_outline_rounded,
              textInputType: TextInputType.visiblePassword,
              controller: controller.confirmPasswordController,
              hint: const [AutofillHints.newPassword],
              isObscure: !controller.isConfirmPasswordVisible.value,
              endIcon: controller.isConfirmPasswordVisible.value
                  ? Icons.visibility
                  : Icons.visibility_off,
              onEndIconTap: () => controller.isConfirmPasswordVisible.toggle(),
              validator: controller.validateConfirmPassword,
              onChanged: (_) => controller.checkFormValidity(),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildPasswordGuidelines(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Get.theme.primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Get.theme.primaryColor.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.security_rounded, size: 20, color: Get.theme.primaryColor),
              const SizedBox(width: 10),
               Text(
                'password_guidelines'.tr,
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Get.theme.primaryColor,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildGuidelineItem(context, 'password_rule_length'.tr),
          const SizedBox(height: 8),
          _buildGuidelineItem(context, 'password_rule_letters_numbers'.tr),
          const SizedBox(height: 8),
          _buildGuidelineItem(context, 'password_rule_different'.tr),
          const SizedBox(height: 8),
          _buildGuidelineItem(context, 'password_rule_personal'.tr),
        ],
      ),
    );
  }

  Widget _buildGuidelineItem(BuildContext context, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Icon(
            Icons.circle,
            size: 6,
            color: Get.theme.primaryColor.withOpacity(0.6),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: context.textTheme.bodySmall?.copyWith(
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}