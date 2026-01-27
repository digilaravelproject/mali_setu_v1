import 'package:edu_cluezer/features/matrimony/presentation/controller/reg_matrimony_controller.dart';
import 'package:edu_cluezer/widgets/basic_text_field.dart';
import 'package:edu_cluezer/widgets/custom_buttons.dart';
import 'package:edu_cluezer/widgets/custom_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../common/widgets/option_selector.dart';
import '../../../../core/helper/form_validator.dart';
import '../../../../core/utils/app_assets.dart';
import '../../business/presentation/controller/create_job_controller.dart';
import '../controller/profileController.dart';


/*
class UpdateProfilePage extends GetWidget<UpProfileController> {
  const UpdateProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: Get.back,
          child: Icon(Icons.arrow_back_ios_rounded, color: context.iconColor),
        ),
        title: Text("Update Profile", style: context.textTheme.headlineLarge),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionTitle("Personal Information"),
            AppInputTextField(
              label: "Full Name",
            //  controller: controller.bNameCtrl,
              textInputType: TextInputType.text,
              validator: FormValidator.name,
            ),

            AppInputTextField(
              label: "Age",
              //  controller: controller.bNameCtrl,
              textInputType: TextInputType.number,
              validator: FormValidator.age,
            ),

            AppInputTextField(
              label: "Phone Number",
              //  controller: controller.bNameCtrl,
              textInputType: TextInputType.phone,
            //  validator: FormValidator.age,
            ),

            AppInputTextField(
              label: "Occupation",
              //  controller: controller.bNameCtrl,
              textInputType: TextInputType.text,
             // validator: FormValidator.age,
            ),
            const SizedBox(height: 16),
            const SectionTitle("Address Information"),
            AppInputTextField(
              label: "Street Address",
              //  controller: controller.bNameCtrl,
              textInputType: TextInputType.streetAddress,
            //  validator: FormValidator.name,
            ),

            AppInputTextField(
              label: "Nearby Location",
              //  controller: controller.bNameCtrl,
              textInputType: TextInputType.text,
              //  validator: FormValidator.name,
            ),

            AppInputTextField(
              label: "Road Number",
              //  controller: controller.bNameCtrl,
              textInputType: TextInputType.number,
              //  validator: FormValidator.name,
            ),

            SingleDropdown(
              controller: controller.cityCtrl,
              label: "City",
              items: controller.cities,
            ),

            SingleDropdown(
              controller: controller.stateCtrl,
              label: "State",
              items: controller.states,
            ),

            SingleDropdown(
              controller: controller.stateCtrl,
              label: "District",
              items: controller.states,
            ),

            AppInputTextField(
              label: "PinCode",
              //  controller: controller.bNameCtrl,
              textInputType: TextInputType.number,
              //  validator: FormValidator.name,
            ),

            AppInputTextField(
              label: "Sector",
              //  controller: controller.bNameCtrl,
              textInputType: TextInputType.number,
              //  validator: FormValidator.name,
            ),
            AppInputTextField(
              label: "Destination",
              //  controller: controller.bNameCtrl,
              textInputType: TextInputType.text,
              //  validator: FormValidator.name,
            ),

            const SizedBox(height: 20),
            CustomButton(
              title: "Update Profile",
              onPressed: controller.onRegister,
            ),

            const SizedBox(height: 70),


          ],
        ),
      ),
      // bottomNavigationBar: BottomAppBar(
      //   padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      //   child: CustomButton(
      //     title: "Update Profile",
      //     onPressed: controller.onRegister,
      //   ),
      // ),
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
}*/





class UpdateProfilePage extends GetView<UpProfileController> {
  const UpdateProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: Get.back,
          child: Icon(Icons.arrow_back_ios_rounded, color: context.iconColor),
        ),
        title: Text(
          "Update Profile",
          style: context.textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Image Section
              _buildProfileImageSection(),
              const SizedBox(height: 20),

              // Personal Information
              SectionTitle('Personal Information'),
              _buildPersonalInfoSection(),
              const SizedBox(height: 24),

              // Address Information
              //_buildSectionHeader('Address Information'),
              SectionTitle('Address Information'),
              _buildAddressInfoSection(),
              const SizedBox(height: 40),

              // Update Button
             // _buildUpdateButton(),
              CustomButton(title: "Update Profile", onPressed: (){

              }),
              const SizedBox(height: 40),
            ],
          ),
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
            return Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Get.theme.primaryColor,
                      width: 3,
                    ),

                  ),
                  child: ClipOval(
                    child: Image.network(
                      '',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        // fallback to local asset image
                        return Image.asset(
                          AppAssets.imgAppLogo, // your asset image path
                          fit: BoxFit.cover,
                        );
                      },
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: controller.showImagePickerOptions,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Get.theme.primaryColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            );
          }),
          const SizedBox(height: 12),
          Text(
            'Tap camera icon to update photo',
            style:  Get.theme.textTheme.bodyLarge,
            // TextStyle(
            //   fontSize: 13,
            //   color: Colors.grey.shade600,
            // ),
          ),
        ],
      ),
    );
  }



  Widget _buildPersonalInfoSection() {
    return Column(
      children: [
        AppInputTextField(
          label: "Full Name",
          controller: controller.fullNameCtrl,
          textInputType: TextInputType.name,
          iconData: Icons.person_outline,
          validator: FormValidator.name,
        ),
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
                label: "Phone Number",
                controller: controller.phoneNumberCtrl,
                textInputType: TextInputType.phone,
                iconData: Icons.phone_outlined,
              //  validator: FormValidator.phone,
              ),
            ),
          ],
        ),
        AppInputTextField(
          label: "Email Address",
          controller: controller.emailCtrl,
          textInputType: TextInputType.emailAddress,
          iconData: Icons.email_outlined,
          validator: FormValidator.email,
        ),
        AppInputTextField(
          label: "Occupation",
          controller: controller.occupationCtrl,
          textInputType: TextInputType.text,
          iconData: Icons.work_outline,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter occupation';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildAddressInfoSection() {
    return Column(
      children: [
        AppInputTextField(
          label: "Street Address",
          controller: controller.streetAddressCtrl,
          textInputType: TextInputType.streetAddress,
          iconData: Icons.home_outlined,
        ),
        Row(
          children: [
            Expanded(
              child: AppInputTextField(
                label: "Nearby Location",
                controller: controller.nearbyLocationCtrl,
                textInputType: TextInputType.text,
                iconData: Icons.location_searching_outlined,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: AppInputTextField(
                label: "Road Number",
                controller: controller.roadNumberCtrl,
                textInputType: TextInputType.text,
                iconData: Icons.signpost_outlined,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: SingleDropdown(
                controller: controller.cityCtrl,
                label: "City",
                items: controller.cities,
                icon: Icons.location_city_outlined,
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

        Row(
          children: [
            Expanded(
              child: SingleDropdown(
                controller: controller.districtCtrl,
                label: "District",
                items: controller.districts,
                icon: Icons.terrain_outlined,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: AppInputTextField(
                label: "Pincode",
                controller: controller.pincodeCtrl,
                textInputType: TextInputType.number,
                iconData: Icons.pin_outlined,
               // validator: FormValidator.pincode,
              ),
            ),
          ],
        ),

        Row(
          children: [
            Expanded(
              child: AppInputTextField(
                label: "Sector",
                controller: controller.sectorCtrl,
                textInputType: TextInputType.text,
                iconData: Icons.domain_outlined,
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
    );
  }

  // Widget _buildDropdown({
  //   required TextEditingController controller,
  //   required String label,
  //   required List<String> items,
  //   required IconData icon,
  // }) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Text(
  //         label,
  //         style: TextStyle(
  //           fontSize: 14,
  //           color: Colors.grey.shade700,
  //           fontWeight: FontWeight.w500,
  //         ),
  //       ),
  //       const SizedBox(height: 6),
  //       Container(
  //         decoration: BoxDecoration(
  //           color: Colors.white,
  //           borderRadius: BorderRadius.circular(12),
  //           border: Border.all(color: Colors.grey.shade300),
  //         ),
  //         child: DropdownButtonFormField<String>(
  //           value: controller.text.isNotEmpty ? controller.text : null,
  //           items: items.map((String value) {
  //             return DropdownMenuItem<String>(
  //               value: value,
  //               child: Text(value),
  //             );
  //           }).toList(),
  //           onChanged: (value) {
  //             controller.text = value ?? '';
  //           },
  //           decoration: InputDecoration(
  //             prefixIcon: Icon(icon, color: Colors.grey.shade600),
  //             border: InputBorder.none,
  //             contentPadding: const EdgeInsets.symmetric(horizontal: 16),
  //           ),
  //           style: const TextStyle(
  //             fontSize: 15,
  //             fontWeight: FontWeight.w500,
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }
  //
  // Widget _buildUpdateButton() {
  //   return SizedBox(
  //     width: double.infinity,
  //     child: CustomButton(
  //       title: "Update Profile",
  //       onPressed: controller.updateProfile,
  //       backgroundColor: Get.theme.primaryColor,
  //       textColor: Colors.white,
  //       height: 56,
  //       borderRadius: 12,
  //       elevation: 2,
  //       child: Row(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: [
  //           const Icon(Icons.check_circle_outline, color: Colors.white),
  //           const SizedBox(width: 10),
  //           Text(
  //             "Update Profile",
  //             style: TextStyle(
  //               fontSize: 16,
  //               fontWeight: FontWeight.w600,
  //               color: Colors.white,
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }
}

// Helper widget for AppInputTextField with prefix icon
/*class AppInputTextField extends StatelessWidget {
  final String label;
  final TextEditingController? controller;
  final TextInputType textInputType;
  final IconData? prefixIcon;
  final String? Function(String?)? validator;
  final int? maxLines;

  const AppInputTextField({
    super.key,
    required this.label,
    this.controller,
    required this.textInputType,
    this.prefixIcon,
    this.validator,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        BasicTextField(
          controller: controller,
          keyboardType: textInputType,
          validator: validator,
          maxLines: maxLines,
          decoration: InputDecoration(
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, color: Colors.grey.shade600)
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Get.theme.primaryColor, width: 2),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }
}*/
