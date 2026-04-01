import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/helper/form_validator.dart';
import '../../../../../core/utils/app_assets.dart';
import '../../../../../widgets/basic_text_field.dart';
import '../../../../../widgets/custom_buttons.dart';
import '../../../../../widgets/custom_scaffold.dart';
import '../controller/register_controller.dart';

/*class RegisterPage extends GetWidget<RegisterController> {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return CustomScaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: Get.back,
          icon: Icon(AppAssets.backArrow),
          style: IconButton.styleFrom(side: BorderSide.none),
        ),
        title: const Text("Register"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 🔹 BASIC DETAILS
              Text("Basic Details", style: textTheme.titleMedium),
              const SizedBox(height: 12),

              AppInputTextField(
                label: "Full Name",
                textInputType: TextInputType.name,
                validator: FormValidator.name,
                controller: controller.nameCtrl,
                iconData: CupertinoIcons.profile_circled,
              ),

              AppInputTextField(
                label: "Email ID",
                textInputType: TextInputType.emailAddress,
                validator: FormValidator.email,
                controller: controller.emailCtrl,
                iconData: CupertinoIcons.mail,
              ),

              AppInputTextField(
                label: "Age",
                textInputType: TextInputType.none, // Keyboard na aaye
                controller: controller.ageCtrl,
                validator: (value) {
                  if (controller.selectedBirthDate.value == null) {
                    return "Please select your date of birth";
                  }
                  // Validate 18+ age
                  final today = DateTime.now();
                  final dob = controller.selectedBirthDate.value!;
                  final age = today.year - dob.year - ((today.month < dob.month || (today.month == dob.month && today.day < dob.day)) ? 1 : 0);
                  if (age < 18) return "You must be at least 18 years old";
                  return null;
                },
                onTap: () async {
                  final today = DateTime.now();
                  final initialDate = controller.selectedBirthDate.value ?? DateTime(today.year - 18, today.month, today.day);
                  final firstDate = DateTime(1900); // Minimum date
                  final lastDate = DateTime(today.year - 18, today.month, today.day); // Maximum: 18 years ago

                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: initialDate,
                    firstDate: firstDate,
                    lastDate: lastDate,
                  );

                  if (pickedDate != null) {
                    controller.selectedBirthDate.value = pickedDate;
                    controller.ageCtrl.text = "${pickedDate.day.toString().padLeft(2,'0')}-${pickedDate.month.toString().padLeft(2,'0')}-${pickedDate.year}";
                  }
                },
                iconData: CupertinoIcons.calendar,
              ),


              AppInputTextField(
                label: "Mobile Number",
                textInputType: TextInputType.phone,
                validator: FormValidator.mobile,
                controller: controller.mobileCtrl,
              ),




              AppInputTextField(
                label: "Company Name",
                textInputType: TextInputType.text,
              //  validator: FormValidator.mobile,
               // controller: controller.mobileCtrl,
              ),

              AppInputTextField(
                label: "Dept Name",
                textInputType: TextInputType.text,
                //validator: FormValidator.mobile,
               // controller: controller.mobileCtrl,
              ),

              AppInputTextField(
                label: "User Type",
                  isDropdown: true,
                  controller: controller.userTypeCtrl,
                  validator: (value) =>
                   FormValidator.emptycheck(value, "User Type"),
                  dropdownItems: controller.usertypeList),


              const SizedBox(height: 16),
              Text("Caste Certificate", style: textTheme.titleMedium),
              const SizedBox(height: 8),
              Obx(() => _buildCasteCertificateUpload(context)),

              const SizedBox(height: 20),

              /// 🔹 ADDRESS SECTION
              Text("Address Details", style: textTheme.titleMedium),

              AppInputTextField(
                label: "Address",
                textInputType: TextInputType.text,
                controller: controller.addressCtrl,
                validator: (value) =>
                    FormValidator.emptycheck(value, "Address"),
              ),

              AppInputTextField(
                label: "Nearby Location",
                textInputType: TextInputType.text,
                controller: controller.nearbyLocationCtrl,
                validator: (value) =>
                    FormValidator.emptycheck(value, "Nearby Location"),
              ),

              Obx(() => AppInputTextField(
                label: "Pin Code",
                textInputType: TextInputType.number,
                validator: FormValidator.pincode,
                controller: controller.pinCodeCtrl,
                endIcon: controller.isFetchingPincode.value
                    ? null
                    : Icons.location_on,
                suffixWidget: controller.isFetchingPincode.value
                    ? const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        ),
                      )
                    : null,
              )),

              AppInputTextField(
                label: "State",
                textInputType: TextInputType.none,
                controller: controller.stateCtrl,
                validator: controller.validateState,
                enable: false,
                hintText: "Auto-filled from pincode",
                suffixWidget: Icon(Icons.lock_outline, size: 18, color: Colors.grey),
                textColor: Colors.black,
              ),

              AppInputTextField(
                label: "District",
                textInputType: TextInputType.none,
                controller: controller.districtCtrl,
                validator: controller.validateDistrict,
                enable: false,
                hintText: "Auto-filled from pincode",
                suffixWidget: Icon(Icons.lock_outline, size: 18, color: Colors.grey),
                textColor: Colors.black,
              ),

              AppInputTextField(
                label: "City",
                textInputType: TextInputType.none,
                controller: controller.cityCtrl,
                validator: controller.validateCity,
                enable: false,
                hintText: "Auto-filled from pincode",
                suffixWidget: Icon(Icons.lock_outline, size: 18, color: Colors.grey),
                textColor: Colors.black,
              ),

              AppInputTextField(
                label: "Road Number",
                textInputType: TextInputType.text,
                validator: FormValidator.roadNumber,
                controller: controller.roadNumberCtrl,
              ),

              AppInputTextField(
                label: "Sector",
                controller: controller.sectorCtrl,
                validator: (value) =>
                    FormValidator.emptycheck(value, "Sector"),
                textInputType: TextInputType.text,
              ),

              AppInputTextField(
                label: "Destination",
                textInputType: TextInputType.text,
                validator: (value) =>
                    FormValidator.emptycheck(value, "Destination"),
                controller: controller.destinationCtrl,
              ),

              const SizedBox(height: 20),

              /// 🔹 PROFESSIONAL DETAILS
              Text("Professional Details", style: textTheme.titleMedium),
              const SizedBox(height: 12),

              AppInputTextField(
                label: "Occupation",
                textInputType: TextInputType.text,
                validator: (value) =>
                    FormValidator.emptycheck(value, "Occupation"),
                controller: controller.occupationCtrl,
              ),

              AppInputTextField(
                label: "Referral Code (Optional)",
                textInputType: TextInputType.text,
                controller: controller.referralCtrl,
              ),

              Text(
                "* Referral code is optional",
                style: textTheme.bodySmall?.copyWith(color: theme.hintColor),
              ),

              const SizedBox(height: 20),

              /// 🔹 SECURITY DETAILS
              Text("Security", style: textTheme.titleMedium),

              Obx(
                () => AppInputTextField(
                  label: "Password",
                  isObscure: !controller.isPasswordValue.value,
                  validator: FormValidator.password,
                  controller: controller.passwordCtrl,
                  endIcon: controller.isPasswordValue.value
                      ? Icons.remove_red_eye_rounded
                      : Icons.visibility_off,
                  onEndIconTap: controller.isPasswordValue.toggle,
                ),
              ),

              // Obx(
              //       () => AppInputTextField(
              //     label: "Password",
              //     iconData: CupertinoIcons.lock_fill,
              //     textInputType: TextInputType.visiblePassword,
              //     controller: controller.passwordController,
              //     hint: const [AutofillHints.password],
              //     isObscure: !controller.isPasswordVisible.value,
              //     endIcon: controller.isPasswordVisible.value
              //         ? Icons.remove_red_eye_rounded
              //         : Icons.visibility_off,
              //     onEndIconTap: () => controller.isPasswordVisible.toggle(),
              //     validator: FormValidator.password,
              //   ),
              // ),

              Obx(
                () => AppInputTextField(
                  label: "Confirm Password",
                  isObscure: !controller.isCnfPasswordValue.value,
                  validator: (value) => FormValidator.confirmPassword(
                    value,
                    controller.passwordCtrl.text,
                  ),
                  controller: controller.confirmPasswordCtrl,
                  endIcon: controller.isCnfPasswordValue.value
                      ? Icons.remove_red_eye_rounded
                      : Icons.visibility_off,
                  onEndIconTap: controller.isCnfPasswordValue.toggle,
                ),
              ),

              const SizedBox(height: 30),

              /// 🔹 SUBMIT BUTTON
              CustomButton(onPressed: controller.onRegister, title: "Register"),
              SizedBox(height: context.mediaQueryPadding.bottom),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildCasteCertificateUpload(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: controller.pickCasteCertificate,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                color: controller.casteCertificatePath.value.isEmpty
                    ? context.theme.dividerColor
                    : Colors.green,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Main content - Centre mein
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      controller.casteCertificatePath.value.isEmpty
                          ? Icons.cloud_upload
                          : Icons.check_circle,
                      size: 40,
                      color: controller.casteCertificatePath.value.isEmpty
                          ? context.iconColor
                          : Colors.green,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      controller.casteCertificatePath.value.isEmpty
                          ? "Tap to upload caste certificate"
                          : "Caste certificate uploaded",
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: controller.casteCertificatePath.value.isEmpty
                            ? context.theme.hintColor
                            : Colors.green,
                      ),
                    ),
                    if (controller.casteCertificatePath.value.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        controller.casteCertificateFileName.value,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),

                // Cross icon - Top right corner mein
                if (controller.casteCertificatePath.value.isNotEmpty)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: controller.removeCasteCertificate,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.9),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close,
                          size: 16,
                          color: context.theme.cardColor,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (controller.casteCertificateError.value.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 8),
            child: Text(
              controller.casteCertificateError.value,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.red,
              ),
            ),
          ),
      ],
    );
  }


}*/




import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/helper/form_validator.dart';
import '../../../../../core/utils/app_assets.dart';
import '../../../../../widgets/basic_text_field.dart';
import '../../../../../widgets/name_field_component.dart';
import '../../../../../widgets/phone_field_component.dart';
import '../../../../../widgets/custom_buttons.dart';
import '../../../../../widgets/custom_scaffold.dart';
import '../controller/register_controller.dart';

class RegisterPage extends GetWidget<RegisterController> {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return CustomScaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: Get.back,
          icon: Icon(AppAssets.backArrow),
          style: IconButton.styleFrom(side: BorderSide.none),
        ),
        title:  Text("create_account".tr),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: controller.formKey,
          child: Column(
            children: [
              _buildFormSection(
                context,
                title: "personal_information".tr,
                icon: Icons.person_outline_rounded,
                children: [
                  NameFieldComponent(
                    key: controller.nameFieldKey,
                    isRequired: true,
                  ),
                  const SizedBox(height: 12),
                  AppInputTextField(
                    label: "email_id".tr,
                    textInputType: TextInputType.emailAddress,
                    validator: FormValidator.email,
                    controller: controller.emailCtrl,
                    iconData: CupertinoIcons.mail,
                    isRequired: true,
                  ),
                  const SizedBox(height: 12),
                  AppInputTextField(
                    label: "date_of_birth".tr,
                    textInputType: TextInputType.none,
                    controller: controller.ageCtrl,
                    isRequired: true,
                  /*  validator: (value) {
                      // if (controller.selectedBirthDate.value == null) {
                      //   return "Please select your date of birth";
                      // }
                      final today = DateTime.now();
                      final dob = controller.selectedBirthDate.value!;
                      final age = today.year -
                          dob.year -
                          ((today.month < dob.month ||
                              (today.month == dob.month &&
                                  today.day < dob.day))
                              ? 1
                              : 0);
                      if (age < 18) return "You must be at least 18 years old";
                      return null;
                    },*/
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
                      );

                      if (pickedDate != null) {
                        controller.selectedBirthDate.value = pickedDate;
                        controller.ageCtrl.text =
                        controller.ageCtrl.text =
                        "${pickedDate.year}-"
                            "${pickedDate.month.toString().padLeft(2, '0')}-"
                            "${pickedDate.day.toString().padLeft(2, '0')}";
                      }
                    },
                    iconData: CupertinoIcons.calendar,
                  ),
                  const SizedBox(height: 12),
                  PhoneFieldComponent(
                    key: controller.phoneFieldKey,
                    isRequired: true,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildFormSection(
                context,
                title: "caste_certificate".tr,
                icon: Icons.description_outlined,
                isRequired: true,
                children: [
                  Obx(() => _buildCasteCertificateUpload(context)),
                ],
              ),
              const SizedBox(height: 20),
              _buildFormSection(
                context,
                title: "address_details".tr,
                icon: Icons.location_on_outlined,
                children: [
                  AppInputTextField(
                    label: "address".tr,
                    textInputType: TextInputType.text,
                    controller: controller.addressCtrl,
                    validator: (value) =>
                        FormValidator.emptycheck(value, "address".tr),
                    iconData: CupertinoIcons.location_solid,
                    isRequired: true,
                  ),
                  const SizedBox(height: 12),
                  AppInputTextField(
                    label: "nearby_location".tr,
                    textInputType: TextInputType.text,
                    controller: controller.nearbyLocationCtrl,
                    validator: (value) =>
                        FormValidator.emptycheck(value, "Nearby Location"),
                    iconData: CupertinoIcons.placemark,
                    isRequired: true,
                  ),
                  const SizedBox(height: 12),
                  Obx(() => AppInputTextField(
                    label: "pin_code".tr,
                    textInputType: TextInputType.number,
                    validator: FormValidator.pincode,
                    controller: controller.pinCodeCtrl,
                    isRequired: true,
                    endIcon: controller.isFetchingPincode.value
                        ? null
                        : Icons.location_on,
                    suffixWidget: controller.isFetchingPincode.value
                        ? const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      ),
                    )
                        : null,
                    iconData: CupertinoIcons.number,
                  )),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: AppInputTextField(
                          label: "state".tr,
                          textInputType: TextInputType.none,
                          controller: controller.stateCtrl,
                          validator: controller.validateState,
                          enable: false,
                          hintText: "auto_filled".tr,
                         // suffixWidget: Icon(Icons.lock_outline, size: 18, color: Colors.grey),
                          textColor: Colors.black,
                          isRequired: true,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppInputTextField(
                          label: "district".tr,
                          textInputType: TextInputType.none,
                          controller: controller.districtCtrl,
                          validator: controller.validateDistrict,
                          enable: false,
                          hintText: "auto_filled".tr,
                         // suffixWidget: Icon(Icons.lock_outline, size: 18, color: Colors.grey),
                          textColor: Colors.black,
                          isRequired: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: AppInputTextField(
                          label: "country".tr,
                          textInputType: TextInputType.none,
                          controller: controller.cityCtrl,
                          validator: controller.validateCity,
                          enable: false,
                          hintText: "auto_filled".tr,
                         // suffixWidget: Icon(Icons.lock_outline, size: 18, color: Colors.grey),
                          textColor: Colors.black,
                          isRequired: true,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppInputTextField(
                          label: "road_number".tr,
                          textInputType: TextInputType.text,
                          //  validator: FormValidator.roadNumber,
                          controller: controller.roadNumberCtrl,
                         // isRequired: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: AppInputTextField(
                          label: "sector".tr,
                          controller: controller.sectorCtrl,
                        //  validator: (value) => FormValidator.emptycheck(value, "Sector"),
                          textInputType: TextInputType.text,
                         // isRequired: true,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppInputTextField(
                          label: "destination".tr,
                          textInputType: TextInputType.text,
                         // validator: (value) => FormValidator.emptycheck(value, "Destination"),
                          controller: controller.destinationCtrl,
                          isRequired: true,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildFormSection(
                context,
                title: "professional_details".tr,
                icon: Icons.business_center_outlined,
                children: [

                  AppInputTextField(
                    label: "user_type".tr,
                    isDropdown: true,
                    controller: controller.userTypeCtrl,
                    validator: (value) =>
                        FormValidator.emptycheck(value, "User Type"),
                    dropdownItems: controller.usertypeList,
                    iconData: CupertinoIcons.person_2_fill,
                    isRequired: true,
                  ),
                  const SizedBox(height: 12),

                  AppInputTextField(
                    label: "company_name".tr,
                    textInputType: TextInputType.text,
                    controller: controller.companynameCtrl,
                    iconData: CupertinoIcons.building_2_fill,
                  ),
                  const SizedBox(height: 12),
                  AppInputTextField(
                    label: "department_name".tr,
                    textInputType: TextInputType.text,
                    controller: controller.deptCtrl,
                    iconData: CupertinoIcons.group_solid,
                  ),
                  const SizedBox(height: 12),

                  AppInputTextField(
                    label: "occupation".tr,
                    textInputType: TextInputType.text,
                   // validator: (value) => FormValidator.emptycheck(value, "Occupation"),
                    controller: controller.occupationCtrl,
                    iconData: CupertinoIcons.briefcase_fill,
                    isRequired: true,
                  ),
                  const SizedBox(height: 12),
                  AppInputTextField(
                    label: "designation".tr,
                    textInputType: TextInputType.text,
                  //  validator: (value) => FormValidator.emptycheck(value, "Designation"),
                    controller: controller.designationCtrl,
                    iconData: CupertinoIcons.briefcase_fill,
                    isRequired: true,
                  ),
                  const SizedBox(height: 12),
                  AppInputTextField(
                    label: "referral_code_optional".tr,
                    textInputType: TextInputType.text,
                    controller: controller.referralCtrl,
                    iconData: CupertinoIcons.share_up,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "referral_code_note".tr,
                    style: textTheme.bodySmall?.copyWith(
                      color: theme.hintColor,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildFormSection(
                context,
                title: "security".tr,
                icon: Icons.lock_outline_rounded,
                children: [
                  Obx(
                        () => AppInputTextField(
                      label: "password".tr,
                      isObscure: !controller.isPasswordValue.value,
                      validator: FormValidator.password,
                      controller: controller.passwordCtrl,
                      endIcon: controller.isPasswordValue.value
                          ? Icons.remove_red_eye_rounded
                          : Icons.visibility_off,
                      onEndIconTap: controller.isPasswordValue.toggle,
                      iconData: CupertinoIcons.lock_fill,
                      isRequired: true,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Obx(
                        () => AppInputTextField(
                      label: "confirm_password".tr,
                      isObscure: !controller.isCnfPasswordValue.value,
                      validator: (value) => FormValidator.confirmPassword(
                        value,
                        controller.passwordCtrl.text,
                      ),
                      controller: controller.confirmPasswordCtrl,
                      endIcon: controller.isCnfPasswordValue.value
                          ? Icons.remove_red_eye_rounded
                          : Icons.visibility_off,
                      onEndIconTap: controller.isCnfPasswordValue.toggle,
                      iconData: CupertinoIcons.lock_fill,
                      isRequired: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              CustomButton(
                onPressed: controller.onRegister,
                title: "create_account".tr,
                height: 50,
              ),
              SizedBox(height: context.mediaQueryPadding.bottom + 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormSection(
      BuildContext context, {
        required String title,
        required IconData icon,
        required List<Widget> children,
        bool isRequired = false,
      }) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: theme.dividerColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: theme.primaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (isRequired)
                  Text(
                    ' *',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.red,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildCasteCertificateUpload(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: controller.pickCasteCertificate,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border.all(
                color: controller.casteCertificatePath.value.isEmpty
                    ? context.theme.dividerColor
                    : Colors.green,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(12),
              color: controller.casteCertificatePath.value.isEmpty
                  ? null
                  : Colors.green.withOpacity(0.05),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      controller.casteCertificatePath.value.isEmpty
                          ? Icons.cloud_upload_outlined
                          : Icons.check_circle,
                      size: 48,
                      color: controller.casteCertificatePath.value.isEmpty
                          ? context.theme.primaryColor
                          : Colors.green,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      controller.casteCertificatePath.value.isEmpty
                          ? "upload_caste_certificate".tr
                          : "certificate_uploaded".tr,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: controller.casteCertificatePath.value.isEmpty
                            ? context.theme.hintColor
                            : Colors.green,
                      ),
                    ),
                    if (controller.casteCertificatePath.value.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        controller.casteCertificateFileName.value,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
                if (controller.casteCertificatePath.value.isNotEmpty)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: controller.removeCasteCertificate,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.close,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (controller.casteCertificateError.value.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 4),
            child: Row(
              children: [
                Icon(
                  Icons.error_outline,
                  size: 16,
                  color: Colors.red,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    controller.casteCertificateError.value,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}


class TwoColumnDropdownRow extends StatelessWidget {
  final Widget left;
  final Widget right;

  const TwoColumnDropdownRow({
    super.key,
    required this.left,
    required this.right,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: left),
        const SizedBox(width: 12),
        Expanded(child: right),
      ],
    );
  }
}