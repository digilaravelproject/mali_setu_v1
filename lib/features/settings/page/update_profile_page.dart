import 'package:edu_cluezer/features/matrimony/presentation/controller/reg_matrimony_controller.dart';
import 'package:edu_cluezer/widgets/basic_text_field.dart';
import 'package:edu_cluezer/widgets/custom_buttons.dart';
// import 'package:edu_cluezer/widgets/custom_scaffold.dart'; // Removed as we use standard Scaffold
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:edu_cluezer/features/Auth/service/auth_service.dart';
import 'package:edu_cluezer/widgets/custom_image_view.dart';
import '../../../../common/widgets/option_selector.dart';
import '../../../../core/helper/form_validator.dart';
import '../../../../core/utils/app_assets.dart';
import '../../business/presentation/controller/create_job_controller.dart';
import '../controller/profileController.dart';

class UpdateProfilePage extends GetView<UpProfileController> {
  const UpdateProfilePage({super.key});

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
          "Update Profile",
          style: context.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.grey[50],
        elevation: 0,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Image Section
            _buildProfileImageSection(),
            const SizedBox(height: 30),

            // Personal Information
            _buildSectionHeader(context, "PERSONAL INFORMATION"),
            _buildPersonalInfoSection(context),
            const SizedBox(height: 24),

            // Address Information
            _buildSectionHeader(context, "ADDRESS INFORMATION"),
            _buildAddressInfoSection(context),
            const SizedBox(height: 40),

            // Update Button
            CustomButton(
              title: "Update Profile",
              onPressed: () => controller.updateProfile(),
              height: 50,
              borderRadius: 16,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 16),
      child: Text(
        title,
        style: context.textTheme.labelLarge?.copyWith(
          color: Colors.grey[600],
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildProfileImageSection() {
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
                      color: Get.theme.primaryColor.withOpacity(0.2),
                      width: 2,
                    ),
                  ),
                  child: Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Get.theme.primaryColor.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: profileImage != null
                          ? Image.file(
                              profileImage,
                              fit: BoxFit.cover,
                            )
                          : CustomImageView(
                              url: user?.profileImage,
                              imagePath: AppAssets.imgAppLogo,
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: controller.showImagePickerOptions,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Get.theme.primaryColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            );
          }),
          const SizedBox(height: 16),
          Text(
            'Tap camera icon to update photo',
            style: Get.textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          AppInputTextField(
            label: "Full Name",
            controller: controller.fullNameCtrl,
            textInputType: TextInputType.name,
            iconData: Icons.person_outline_rounded,
            validator: FormValidator.name,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: AppInputTextField(
                  label: "Age",
                  controller: controller.ageCtrl,
                  textInputType: TextInputType.number,
                  iconData: Icons.cake_outlined,
                  validator: FormValidator.age,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AppInputTextField(
                  label: "Phone",
                  controller: controller.phoneNumberCtrl,
                  enable: false,
                  textInputType: TextInputType.phone,
                  iconData: Icons.phone_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          AppInputTextField(
            label: "Email Address",
            controller: controller.emailCtrl,
            enable: false,
            textInputType: TextInputType.emailAddress,
            iconData: Icons.email_outlined,
            validator: FormValidator.email,
          ),
          const SizedBox(height: 16),
          AppInputTextField(
            label: "Occupation",
            controller: controller.occupationCtrl,
            textInputType: TextInputType.text,
            iconData: Icons.work_outline_rounded,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter occupation';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAddressInfoSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          AppInputTextField(
            label: "Street Address",
            controller: controller.streetAddressCtrl,
            textInputType: TextInputType.streetAddress,
            iconData: Icons.home_outlined,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: AppInputTextField(
                  label: "Nearby",
                  controller: controller.nearbyLocationCtrl,
                  textInputType: TextInputType.text,
                  iconData: Icons.location_searching_rounded,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AppInputTextField(
                  label: "Road No.",
                  controller: controller.roadNumberCtrl,
                  textInputType: TextInputType.text,
                  iconData: Icons.signpost_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: SingleDropdown(
                  controller: controller.cityCtrl,
                  label: "City",
                  items: controller.cities,
                  icon: Icons.location_city_rounded,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: SingleDropdown(
                  controller: controller.stateCtrl,
                  label: "State",
                  items: controller.states,
                  icon: Icons.map_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: SingleDropdown(
                  controller: controller.districtCtrl,
                  label: "District",
                  items: controller.districts,
                  icon: Icons.terrain_rounded,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AppInputTextField(
                  label: "Pincode",
                  controller: controller.pincodeCtrl,
                  textInputType: TextInputType.number,
                  iconData: Icons.pin_drop_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: AppInputTextField(
                  label: "Sector",
                  controller: controller.sectorCtrl,
                  textInputType: TextInputType.text,
                  iconData: Icons.domain_rounded,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AppInputTextField(
                  label: "Destination",
                  controller: controller.destinationCtrl,
                  textInputType: TextInputType.text,
                  iconData: Icons.place_outlined,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

