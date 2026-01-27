import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/helper/form_validator.dart';
import '../../../../../core/utils/app_assets.dart';
import '../../../../../widgets/basic_text_field.dart';
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
                textInputType: TextInputType.number,
                validator: FormValidator.age,
                controller: controller.ageCtrl,
              ),

              AppInputTextField(
                label: "Mobile Number",
                textInputType: TextInputType.phone,
                validator: FormValidator.mobile,
                controller: controller.mobileCtrl,
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

              AppInputTextField(
                label: "Pin Code",
                textInputType: TextInputType.number,
                validator: FormValidator.pincode,
                controller: controller.pinCodeCtrl,
              ),

              AppInputTextField(
                label: "Road Number",
                textInputType: TextInputType.text,
                validator: FormValidator.roadNumber,
                controller: controller.roadNumberCtrl,
              ),


              AppInputTextField(
                label: "Destination",
                textInputType: TextInputType.text,
                validator: (value) =>
                    FormValidator.emptycheck(value, "Destination"),
                controller: controller.destinationCtrl,
              ),


              TwoColumnDropdownRow(
                left: Obx(() => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppInputTextField(
                      controller: controller.stateCtrl,
                      label: "State *",
                      isDropdown: true,
                      dropdownItems: controller.stateList,
                      validator: controller.validateState,
                    onDropdownChanged: (value) {
                      controller.stateCtrl.text = value;
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        controller.selectedState.value = value;
                      });
                    }

                    // onChanged: (value) {
                    //     //controller.selectedState.value = value;
                    //     controller.stateCtrl.text = value;        // ✅ ADD THIS
                    //     controller.selectedState.value = value;
                    //   },

                    ),
                    if (controller.stateError.value.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4, left: 12),
                        child: Text(
                          controller.stateError.value,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.red,
                          ),
                        ),
                      ),
                  ],
                )),
                right: Obx(() => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppInputTextField(
                      controller: controller.districtCtrl,
                      label: "District *",
                      isDropdown: true,
                      dropdownItems: controller.districtList,
                      validator: controller.validateDistrict,
                    onDropdownChanged: (value) {
                      controller.districtCtrl.text = value;
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        controller.selectedDistrict.value = value;
                      });
                    }
                    // onChanged: (value) {
                    //   controller.districtCtrl.text = value;     // ✅ ADD THIS
                    //   controller.selectedDistrict.value = value;
                    // }

                    // onChanged: (value) {
                    //     controller.selectedDistrict.value = value;
                    //   },
                      // onChanged: (value) {
                      //   // This will trigger the ever() listener in controller
                      // },
                    ),
                    if (controller.districtError.value.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4, left: 12),
                        child: Text(
                          controller.districtError.value,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.red,
                          ),
                        ),
                      ),
                  ],
                )),
              ),


              // TwoColumnDropdownRow(
              //   left: AppInputTextField(
              //     controller: controller.stateCtrl,
              //     label: "State",
              //     isDropdown: true,
              //     dropdownItems: controller.stateList,
              //   ),
              //   right: AppInputTextField(
              //     controller: controller.districtCtrl,
              //     label: "District",
              //     isDropdown: true,
              //     dropdownItems: controller.cityList,
              //   ),
              // ),

              TwoColumnDropdownRow(
                left: Obx(() => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppInputTextField(
                      controller: controller.cityCtrl,
                      label: "City *",
                      isDropdown: true,
                      dropdownItems: controller.cityList,
                     // validator: controller.validateCity,
                    onDropdownChanged: (value) {
                      controller.cityCtrl.text = value;
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        controller.cityCtrl.text = value;
                      });
                    }
                        // onChanged: (value) {
                        //   controller.cityCtrl.text = value;
                        // }

                    ),
                    if (controller.cityError.value.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4, left: 12),
                        child: Text(
                          controller.cityError.value,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.red,
                          ),
                        ),
                      ),
                    const SizedBox(height: 12),
                  ],
                )),
                // AppInputTextField(
                //   controller: controller.cityCtrl,
                //   label: "City",
                //   isDropdown: true,
                //   dropdownItems: controller.cityList,
                // ),
                right: AppInputTextField(
                  controller: controller.sectorCtrl,
                  label: "sector",
                  validator: (value) =>
                      FormValidator.emptycheck(value, "Sector"),
                  textInputType: TextInputType.text,
                ),
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
                  isObscure: true,
                  validator: FormValidator.password,
                  controller: controller.passwordCtrl,
                  endIcon: controller.isPasswordValue.value
                      ? Icons.remove_red_eye_rounded
                      : Icons.visibility_off,
                  onEndIconTap: controller.isPasswordValue.toggle,
                ),
              ),

              Obx(
                () => AppInputTextField(
                  label: "Confirm Password",
                  isObscure: controller.isCnfPasswordValue.value,
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