import 'package:edu_cluezer/core/routes/app_routes.dart';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/helper/form_validator.dart';
import '../../../../../core/helper/date_input_formatter.dart';
import '../../../../../core/utils/app_assets.dart';
import '../../../../../widgets/basic_text_field.dart';
import '../../../../../widgets/name_field_component.dart';
import '../../../../../widgets/phone_field_component.dart';
import '../../../../../widgets/custom_buttons.dart';
import '../../../../../widgets/custom_scaffold.dart';
import '../../../../../widgets/custom_image_view.dart';
import '../controller/register_controller.dart';

class RegisterPage extends GetWidget<RegisterController> {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CustomScaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 50),
              // Back button - at the top
              GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: context.theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: theme.dividerColor.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 16.0,
                    color: context.iconColor,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Header title - centered
              Center(
                child: Column(
                  children: [
                    Text(
                      "create_account".tr,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "fill_details_to_create_account".tr,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        height: 1.4,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              const SizedBox(height: 10),

              // Personal Information Section
              _buildFormSection(
                context,
                title: "personal_information".tr,
                icon: CupertinoIcons.person_circle_fill,
                children: [
                  NameFieldComponent(
                    key: controller.nameFieldKey,
                    isRequired: true,
                  ),
                  AppInputTextField(
                    label: "email_id".tr,
                    textInputType: TextInputType.emailAddress,
                    validator: FormValidator.email,
                    controller: controller.emailCtrl,
                    iconData: CupertinoIcons.mail_solid,
                    isRequired: true,
                    topPadding: 0,
                  ),
                  AppInputTextField(
                    label: "date_of_birth".tr,
                    textInputType: TextInputType.datetime,
                    controller: controller.ageCtrl,
                    isRequired: true,
                    topPadding: 0,
                    hintText: "DD/MM/YYYY",
                    validator: FormValidator.dob,
                    inputFormatters: [DateInputFormatter()],
                    prefixIcon: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () async {
                        final today = DateTime.now();
                        final initialDate = controller.selectedBirthDate.value ??
                            DateTime(today.year - 18, today.month, today.day);
                        final firstDate = DateTime(1900);
                        final lastDate =
                            DateTime(today.year - 18, today.month, today.day);

                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: initialDate,
                          firstDate: firstDate,
                          lastDate: lastDate,
                          fieldHintText: 'dd/mm/yyyy',
                          fieldLabelText: 'Date of Birth (DD/MM/YYYY)',
                          errorFormatText: 'Enter valid date',
                          errorInvalidText: 'Enter date in valid range',
                        );

                        if (pickedDate != null) {
                          controller.selectedBirthDate.value = pickedDate;
                          controller.ageCtrl.text =
                              "${pickedDate.day.toString().padLeft(2, '0')}/"
                              "${pickedDate.month.toString().padLeft(2, '0')}/"
                              "${pickedDate.year}";
                        }
                      },
                      child: const Icon(CupertinoIcons.calendar_today, size: 20),
                    ),
                  ),
                  PhoneFieldComponent(
                    key: controller.phoneFieldKey,
                    isRequired: true,
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Caste Certificate Section
              _buildFormSection(
                context,
                title: "caste_certificate".tr,
                icon: CupertinoIcons.doc_plaintext,
                isRequired: true,
                titleSize: 12,
                children: [
                  Obx(() => _buildCasteCertificateUpload(context)),
                ],
              ),

              const SizedBox(height: 8),

              // Address Details Section
              _buildFormSection(
                context,
                title: "address_details".tr,
                icon: CupertinoIcons.location_circle_fill,
                children: [
                  AppInputTextField(
                    label: "address".tr,
                    textInputType: TextInputType.text,
                    controller: controller.addressCtrl,
                    validator: (value) =>
                        FormValidator.emptycheck(value, "address".tr),
                    iconData: CupertinoIcons.location_solid,
                    isRequired: true,
                    topPadding: 0,
                  ),
                  // AppInputTextField(
                  //   label: "nearby_location".tr,
                  //   textInputType: TextInputType.text,
                  //   controller: controller.nearbyLocationCtrl,
                  //   validator: (value) =>
                  //       FormValidator.emptycheck(value, "nearby_location".tr),
                  //   iconData: CupertinoIcons.placemark_fill,
                  //   isRequired: true,
                  //   topPadding: 0,
                  // ),
                  AppInputTextField(
                    label: "pin_code".tr,
                    textInputType: TextInputType.number,
                    validator: FormValidator.pincode,
                    controller: controller.pinCodeCtrl,
                    isRequired: true,
                    iconData: CupertinoIcons.number_square_fill,
                    topPadding: 0,
                  ),
                  TwoColumnRow(
                    left: AppInputTextField(
                      label: "state".tr,
                      controller: controller.stateCtrl,
                      isRequired: true,
                      readOnly: false,
                      topPadding: 0,
                    ),
                    right: AppInputTextField(
                      label: "city".tr,
                      controller: controller.districtCtrl,
                      isRequired: true,
                      readOnly: false,
                      topPadding: 0,
                    ),
                  ),
                  TwoColumnRow(
                    left: AppInputTextField(
                      label: "country".tr,
                      controller: controller.cityCtrl,
                      isRequired: true,
                      readOnly: false,
                      topPadding: 0,
                    ),
                    right: AppInputTextField(
                      label: "taluka".tr,
                      controller: controller.destinationCtrl,
                      topPadding: 0,
                    ),

                  ),
                  // TwoColumnRow(
                  //   left: AppInputTextField(
                  //     label: "sector".tr,
                  //     controller: controller.sectorCtrl,
                  //     topPadding: 0,
                  //   ),
                  //   right: AppInputTextField(
                  //     label: "road_number".tr,
                  //     controller: controller.roadNumberCtrl,
                  //     topPadding: 0,
                  //   ),
                  // ),
                ],
              ),

              const SizedBox(height: 20),

              // Professional Details Section
              _buildFormSection(
                context,
                title: "professional_details".tr,
                icon: CupertinoIcons.briefcase_fill,
                children: [
                  AppInputTextField(
                    label: "user_type".tr,
                    controller: controller.userTypeCtrl,
                    isRequired: true,
                    isDropdown: true,
                    iconData: CupertinoIcons.person_2_fill,
                    dropdownItems: controller.usertypeList,
                    onDropdownChanged: (v) => controller.userTypeCtrl.text = v,
                    validator: (v) => FormValidator.emptycheck(v, "user_type".tr),
                    topPadding: 0,
                  ),
                  AppInputTextField(
                    label: "occupation".tr,
                    controller: controller.occupationCtrl,
                    isRequired: true,
                    iconData: CupertinoIcons.briefcase_fill,
                    validator: (v) => FormValidator.emptycheck(v, "occupation".tr),
                    topPadding: 0,
                  ),
                  AppInputTextField(
                    label: "company_name".tr,
                    controller: controller.companynameCtrl,
                    iconData: CupertinoIcons.building_2_fill,
                    topPadding: 0,
                  ),
                  AppInputTextField(
                    label: "department_name".tr,
                    controller: controller.deptCtrl,
                    iconData: CupertinoIcons.person_3_fill,
                    topPadding: 0,
                  ),
                  AppInputTextField(
                    label: "designation".tr,
                    controller: controller.designationCtrl,
                   // isRequired: true,
                    iconData: CupertinoIcons.briefcase_fill,
                   // validator: (v) => FormValidator.emptycheck(v, "designation".tr),
                    topPadding: 0,
                  ),
                  // AppInputTextField(
                  //   label: "referral_code".tr,
                  //   controller: controller.referralCtrl,
                  //   iconData: CupertinoIcons.tag_fill,
                  //   topPadding: 0,
                  // ),
                ],
              ),

              const SizedBox(height: 20),

              // Security Section
              _buildFormSection(
                context,
                title: "security".tr,
                icon: CupertinoIcons.lock_shield_fill,
                children: [
                  Obx(
                    () => AppInputTextField(
                      label: "password".tr,
                      controller: controller.passwordCtrl,
                      isRequired: true,
                      isObscure: !controller.isPasswordValue.value,
                      iconData: CupertinoIcons.lock_fill,
                      validator: FormValidator.password,
                      endIcon: controller.isPasswordValue.value
                          ? Icons.visibility_off
                          : Icons.remove_red_eye_rounded,
                      onEndIconTap: () => controller.isPasswordValue.toggle(),
                      topPadding: 0,
                    ),
                  ),
                  Obx(
                    () => AppInputTextField(
                      label: "confirm_password".tr,
                      controller: controller.confirmPasswordCtrl,
                      isRequired: true,
                      isObscure: !controller.isCnfPasswordValue.value,
                      iconData: CupertinoIcons.lock_fill,
                      endIcon: controller.isCnfPasswordValue.value
                          ? Icons.visibility_off
                          : Icons.remove_red_eye_rounded,
                      onEndIconTap: () => controller.isCnfPasswordValue.toggle(),
                      topPadding: 0,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'confirm_password_required'.tr;
                        }
                        if (value != controller.passwordCtrl.text) {
                          return 'passwords_do_not_match'.tr;
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              Obx(() => CustomButton(
                    title: "register_button".tr,
                    onPressed: controller.onRegister,
                    isLoading: controller.isLoading.value,
                  )),

              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "already_have_account".tr,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Text(
                      "login_link".tr,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

 /* Widget _buildFormSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
    bool isRequired = false,
  }) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 15,
            spreadRadius: 0,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 22,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    text: title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.9),
                    ),
                    children: isRequired
                        ? [
                            const TextSpan(
                              text: ' *',
                              style: TextStyle(color: Colors.red),
                            ),
                          ]
                        : [],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, thickness: 1, color: Color(0xFFF1F1F1)),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }*/


  Widget _buildFormSection(
      BuildContext context, {
        required String title,
        required IconData icon,
        required List<Widget> children,
        bool isRequired = false,

        // 👇 new optional params
        double? titleSize,
        FontWeight? titleWeight,
      }) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 15,
            spreadRadius: 0,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 22,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    text: title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      // 👇 default same rahega
                      fontSize: titleSize ?? theme.textTheme.titleMedium?.fontSize,
                      fontWeight: titleWeight ?? FontWeight.w800,
                      letterSpacing: -0.2,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.9),
                    ),
                    children: isRequired
                        ? const [
                      TextSpan(
                        text: ' *',
                        style: TextStyle(color: Colors.red),
                      ),
                    ]
                        : [],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, thickness: 1, color: Color(0xFFF1F1F1)),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildCasteCertificateUpload(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: controller.pickCasteCertificate,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              vertical: controller.casteCertificatePath.value.isEmpty ? 24 : 8,
              horizontal: 16,
            ),
            decoration: BoxDecoration(
              border: Border.all(
                color: controller.casteCertificateError.value.isNotEmpty
                    ? theme.colorScheme.error
                    : controller.casteCertificatePath.value.isEmpty
                        ? theme.dividerColor
                        : Colors.transparent,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(12),
              color: controller.casteCertificatePath.value.isEmpty
                  ? theme.colorScheme.surface
                  : Colors.transparent,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Center(
                  child: controller.casteCertificatePath.value.isEmpty
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.cloud_upload_outlined,
                              size: 40,
                              color: theme.primaryColor,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "upload_caste_certificate".tr,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: theme.hintColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "caste_certificate_criteria".tr,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        )
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Stack(
                              clipBehavior: Clip.none,
                              children: [
                                if (controller.casteCertificatePath.value.toLowerCase().endsWith('.pdf'))
                                  const Icon(
                                    Icons.picture_as_pdf_rounded,
                                    size: 60,
                                    color: Colors.red,
                                  )
                                else
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.file(
                                      File(controller.casteCertificatePath.value),
                                      height: 120,
                                      width: 120,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                Positioned(
                                  top: -8,
                                  right: -8,
                                  child: GestureDetector(
                                    onTap: controller.removeCasteCertificate,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white, width: 2),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.1),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ),
        if (controller.casteCertificateError.value.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 4),
            child: Text(
              controller.casteCertificateError.value,
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.red),
            ),
          ),
      ],
    );
  }
}

class TwoColumnRow extends StatelessWidget {
  final Widget left;
  final Widget right;

  const TwoColumnRow({
    super.key,
    required this.left,
    required this.right,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: left),
        const SizedBox(width: 12),
        Expanded(child: right),
      ],
    );
  }
}