import 'package:edu_cluezer/widgets/custom_buttons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';

import '../../../widgets/basic_text_field.dart';
import '../controller/changePasswordController.dart';

class ChangePasswordScreen extends GetWidget<ChangePasswordController> {
  ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: Get.back,
          child: Icon(Icons.arrow_back_ios_rounded, color: context.iconColor),
        ),
        title: Text("Change Password", style: context.textTheme.headlineLarge),
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
                _buildHeader(),
                const SizedBox(height: 32),

                // Form
                _buildPasswordForm(),
                const SizedBox(height: 40),

                // CustomButton(
                //     title: "Change Password",
                //     height: 45,
                //     onPressed: (){
                //       controller.isFormValid.value && !controller.isLoading.value
                //           ? controller.changePassword
                //           : null;
                //     }),

                CustomButton(
                  title: "Change Password",
                  height: 45,
                  onPressed: () {
                    if (controller.isFormValid.value && !controller.isLoading.value) {
                      controller.changePassword(); // 👈 parentheses added to call function
                    }
                  },
                ),

                const SizedBox(height: 30),

                // Password Guidelines
                _buildPasswordGuidelines(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Get.theme.primaryColor.withOpacity(0.3), width: 2),
          ),
          child: Icon(
            Icons.lock_reset_rounded,
            size: 30,
            color: Get.theme.primaryColor
          ),
        ),
        const SizedBox(height: 16),
         Text(
          'Create a New Password',
          style: Get.textTheme.headlineSmall
        ),
        const SizedBox(height: 8),
        Text(
          'Your new password must be different from previous passwords',
          textAlign: TextAlign.center,
          style:Get.textTheme.bodyMedium

        ),
      ],
    );
  }

  Widget _buildPasswordForm() {
    return Obx(() {
      // Listen to form changes
      controller.checkFormValidity();

      return Column(
        children: [
          // Current Password
          AppInputTextField(
            label: "Current Password",
            iconData: Icons.lock_outline_rounded,
            textInputType: TextInputType.visiblePassword,
            controller: controller.currentPasswordController,
            hint: const [AutofillHints.password],
            isObscure: !controller.isCurrentPasswordVisible.value,
            endIcon: controller.isCurrentPasswordVisible.value
                ? Icons.visibility
                : Icons.visibility_off,
            onEndIconTap: () => controller.isCurrentPasswordVisible.toggle(),
            validator: controller.validateCurrentPassword,
            onChanged: (_) => controller.checkFormValidity(),
          ),
          const SizedBox(height: 16),

          // New Password
          AppInputTextField(
            label: "New Password",
            iconData: Icons.lock_reset_outlined,
            textInputType: TextInputType.visiblePassword,
            controller: controller.newPasswordController,
            hint: const [AutofillHints.newPassword],
            isObscure: !controller.isNewPasswordVisible.value,
            endIcon: controller.isNewPasswordVisible.value
                ? Icons.visibility
                : Icons.visibility_off,
            onEndIconTap: () => controller.isNewPasswordVisible.toggle(),
            validator: controller.validateNewPassword,
            onChanged: (_) => controller.checkFormValidity(),
          ),
          const SizedBox(height: 16),

          // Confirm Password
          AppInputTextField(
            label: "Confirm Password",
            iconData: Icons.lock_reset_rounded,
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
    });
  }

  Widget _buildSubmitButton() {
    return Obx(() {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: controller.isFormValid.value && !controller.isLoading.value
              ? controller.changePassword
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.blue.shade300,
            disabledForegroundColor: Colors.white.withOpacity(0.8),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
            shadowColor: Colors.blue.shade200,
          ),
          child: controller.isLoading.value
              ? const SizedBox(
            height: 24,
            width: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          )
              : const Text(
            'Change Password',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
      );
    });
  }

  Widget _buildPasswordGuidelines() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Get.theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.security_rounded, size: 20, color: Get.theme.primaryColor),
              const SizedBox(width: 10),
               Text(
                'Password Guidelines',
                style: Get.textTheme.titleMedium

              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildGuidelineItem('At least 6 characters long'),
          const SizedBox(height: 8),
          _buildGuidelineItem('Must contain letters and numbers'),
          const SizedBox(height: 8),
          _buildGuidelineItem('Different from current password'),
          const SizedBox(height: 8),
          _buildGuidelineItem('Avoid using personal information'),
          const SizedBox(height: 8),
          _buildGuidelineItem('Use a mix of uppercase & lowercase'),
        ],
      ),
    );
  }

  Widget _buildGuidelineItem(String text,) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.circle,
          size: 12,
          color: Colors.green
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style:Get.textTheme.bodyMedium
            // TextStyle(
            //   fontSize: 13,
            //   color: isRequired ? Colors.grey.shade700 : Colors.grey.shade500,
            //   fontWeight: isRequired ? FontWeight.w500 : FontWeight.w400,
            // ),
          ),
        ),
      ],
    );
  }
}