import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../core/constent/api_constants.dart';
import '../../../../core/helper/form_validator.dart';
import '../../../../core/utils/app_assets.dart';
import '../../../../widgets/basic_text_field.dart';
import '../../../../widgets/name_field_component.dart';
import '../../../../widgets/phone_field_component.dart';
import '../../../../widgets/custom_buttons.dart';
import '../../../../widgets/custom_scaffold.dart';
import '../../../../widgets/custom_image_view.dart';
import 'package:edu_cluezer/core/widgets/full_screen_image_viewer.dart';
import 'package:edu_cluezer/features/Auth/service/auth_service.dart';
import '../controller/profileController.dart';

class UpdateProfilePage extends GetView<UpProfileController> {
  const UpdateProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Dynamic top padding to handle status bar gracefully
    final topPadding = MediaQuery.of(context).padding.top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: CustomScaffold(
        extendBodyBehindAppBar: true,
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: topPadding + 10),
                
                // Back button - plain icon as previously requested
                GestureDetector(
                  onTap: () => Get.back(),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 24.0,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 0),
                
                // Header title
                Center(
                  child: Text(
                    "update_profile".tr,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Profile Image Section
                _buildProfileImageSection(context),

                const SizedBox(height: 10),

                // Personal Information Section
                _buildFormSection(
                  context,
                  title: "personal_information".tr,
                  icon: CupertinoIcons.person_circle_fill,
                  children: [
                    NameFieldComponent(
                      key: controller.nameFieldKey,
                      initialName: Get.find<AuthService>().currentUser.value?.name,
                      isRequired: true,
                    ),
                    AppInputTextField(
                      label: "email_address".tr,
                      controller: controller.emailCtrl,
                      enable: false,
                      textInputType: TextInputType.emailAddress,
                      iconData: CupertinoIcons.mail_solid,
                      isRequired: true,
                      topPadding: 0,
                      validator: FormValidator.email,
                    ),
                    AppInputTextField(
                      label: "age".tr,
                      controller: controller.ageCtrl,
                      textInputType: TextInputType.number,
                      iconData: CupertinoIcons.calendar_today,
                      isRequired: true,
                      topPadding: 0,
                      validator: (v) => FormValidator.emptycheck(v, "age".tr),
                    ),
                    PhoneFieldComponent(
                      key: controller.phoneFieldKey,
                      initialPhone: Get.find<AuthService>().currentUser.value?.phone,
                      isRequired: true,
                    ),
                    AppInputTextField(
                      label: "occupation".tr,
                      controller: controller.occupationCtrl,
                      textInputType: TextInputType.text,
                      iconData: CupertinoIcons.briefcase_fill,
                      isRequired: true,
                      topPadding: 0,
                      validator: (v) => FormValidator.emptycheck(v, "occupation".tr),
                    ),
                  ],
                ),

                // Address Details Section
                _buildFormSection(
                  context,
                  title: "address_details".tr,
                  icon: CupertinoIcons.location_circle_fill,
                  children: [
                    AppInputTextField(
                      label: "address".tr,
                      textInputType: TextInputType.streetAddress,
                      controller: controller.streetAddressCtrl,
                      iconData: CupertinoIcons.location_solid,
                      isRequired: true,
                      topPadding: 0,
                      validator: (v) => FormValidator.emptycheck(v, "address".tr),
                    ),
                    AppInputTextField(
                      label: "pincode".tr,
                      controller: controller.pincodeCtrl,
                      textInputType: TextInputType.number,
                      iconData: CupertinoIcons.number_square_fill,
                      isRequired: true,
                      topPadding: 0,
                      validator: FormValidator.pincode,
                      suffixWidget: Obx(() => controller.isFetchingPincode.value
                          ? const Padding(
                              padding: EdgeInsets.all(12.0),
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            )
                          : const SizedBox.shrink()),
                    ),
                  /*  TwoColumnRow(
                      left: AppInputTextField(
                        label: "nearby".tr,
                        controller: controller.nearbyLocationCtrl,
                        textInputType: TextInputType.text,
                        iconData: CupertinoIcons.placemark_fill,
                        isRequired: true,
                        topPadding: 0,
                        validator: (v) => FormValidator.emptycheck(v, "nearby".tr),
                      ),
                      right: AppInputTextField(
                        label: "road_number".tr,
                        controller: controller.roadNumberCtrl,
                        textInputType: TextInputType.text,
                        iconData: CupertinoIcons.number_square_fill,
                        isRequired: true,
                        topPadding: 0,
                        validator: (v) => FormValidator.emptycheck(v, "road_number".tr),
                      ),
                    ),*/
                    TwoColumnRow(
                      left: AppInputTextField(
                        label: "country".tr,
                        controller: controller.districtCtrl,
                        isRequired: true,
                        isDropdown: true,
                        dropdownItems: controller.districts,
                        onDropdownChanged: (v) => controller.districtCtrl.text = v,
                      //  iconData: CupertinoIcons.location_fill,
                        topPadding: 0,
                        validator: (v) => FormValidator.emptycheck(v, "district".tr),
                      ),

                      right: AppInputTextField(
                        label: "state".tr,
                        controller: controller.stateCtrl,
                        isRequired: true,
                        isDropdown: true,
                        dropdownItems: controller.states,
                        onDropdownChanged: (v) => controller.stateCtrl.text = v,
                     //   iconData: CupertinoIcons.map_fill,
                        topPadding: 0,
                        validator: (v) => FormValidator.emptycheck(v, "state".tr),
                      ),
                    ),
                    TwoColumnRow(
                      left: AppInputTextField(
                        label: "city".tr,
                        controller: controller.cityCtrl,
                        isRequired: true,
                        isDropdown: true,
                        dropdownItems: controller.cities,
                        onDropdownChanged: (v) => controller.cityCtrl.text = v,
                      //  iconData: CupertinoIcons.building_2_fill,
                        topPadding: 0,
                        validator: (v) => FormValidator.emptycheck(v, "city".tr),
                      ),
                      right: AppInputTextField(
                        label: "taluka".tr,
                        controller: controller.destinationCtrl,
                        textInputType: TextInputType.text,
                      //  iconData: CupertinoIcons.location_solid,
                        isRequired: true,
                        topPadding: 0,
                        validator: (v) => FormValidator.emptycheck(v, "destination".tr),
                      ),
                    ),
                     AppInputTextField(
                      label: "village".tr,
                      controller: controller.villageCtrl,
                      isRequired: true,
                      isDropdown: true,
                      dropdownItems: controller.cities,
                     // onDropdownChanged: (v) => controller.cityCtrl.text = v,
                      topPadding: 0,
                      validator: (v) => FormValidator.emptycheck(v, "city".tr),
                    ),
                   /* TwoColumnRow(
                      left: AppInputTextField(
                        label: "sector".tr,
                        controller: controller.sectorCtrl,
                        textInputType: TextInputType.text,
                        iconData: CupertinoIcons.building_2_fill,
                        isRequired: true,
                        topPadding: 0,
                        validator: (v) => FormValidator.emptycheck(v, "sector".tr),
                      ),
                      right: AppInputTextField(
                        label: "taluka".tr,
                        controller: controller.destinationCtrl,
                        textInputType: TextInputType.text,
                        iconData: CupertinoIcons.location_solid,
                        isRequired: true,
                        topPadding: 0,
                        validator: (v) => FormValidator.emptycheck(v, "destination".tr),
                      ),
                    ),*/
                  ],
                ),

                const SizedBox(height: 16),

                Obx(() => SafeArea(
                  child: CustomButton(
                        title: "update_profile".tr,
                        onPressed: () => controller.updateProfile(),
                        isLoading: controller.isLoading.value,
                      ),
                )),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileImageSection(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        children: [
          Obx(() {
            final profileImage = controller.profileImage.value;
            final user = Get.find<AuthService>().currentUser.value;
            return Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: 0.12),
                      width: 2,
                    ),
                  ),
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withValues(alpha: 0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: GestureDetector(
                      onTap: () {
                        if (profileImage != null) {
                          Get.to(() => FullScreenImageViewer(
                            imageFile: profileImage,
                            tag: 'profile_image',
                          ));
                        } else if (user?.profileImage != null && user!.profileImage!.isNotEmpty) {
                          final url = user.profileImage!.startsWith('http')
                              ? user.profileImage!
                              : "${ApiConstants.imageBaseUrl}${user.profileImage}";
                          Get.to(() => FullScreenImageViewer(
                            imageUrl: url,
                            tag: 'profile_image',
                          ));
                        }
                      },
                      child: Hero(
                        tag: 'profile_image',
                        child: ClipOval(
                          child: profileImage != null
                              ? Image.file(
                                  profileImage,
                                  fit: BoxFit.cover,
                                )
                              : (user?.profileImage != null &&
                                      user!.profileImage!.isNotEmpty)
                                  ? CustomImageView(
                                      url: user.profileImage!.startsWith('http')
                                          ? user.profileImage!
                                          : "${ApiConstants.imageBaseUrl}${user.profileImage}",
                                      imagePath: AppAssets.imgAppLogo,
                                      fit: BoxFit.cover,
                                    )
                                  : Image.asset(
                                      AppAssets.imgAppLogo,
                                      fit: BoxFit.cover,
                                    ),
                        ),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: controller.showImagePickerOptions,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      CupertinoIcons.camera_fill,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            );
          }),
          const SizedBox(height: 4),
          Text(
            'tap_camera_update_photo'.tr,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              fontSize: 12,
            ),
          ),
        ],
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

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    text: title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                      fontSize: 14,
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
          const SizedBox(height: 6),
          const Divider(height: 1, thickness: 1, color: Color(0xFFF1F1F1)),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
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
        const SizedBox(width: 8),
        Expanded(child: right),
      ],
    );
  }
}
