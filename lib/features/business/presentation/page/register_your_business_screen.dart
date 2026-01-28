import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_state_manager/src/simple/get_view.dart';
import 'package:get/get_utils/src/extensions/context_extensions.dart';

import '../../../../core/helper/form_validator.dart';
import '../../../../widgets/basic_text_field.dart';
import '../../../../widgets/custom_buttons.dart';
import '../controller/reg_business_controller.dart';

class RegYourBusinessScreen extends GetWidget<RegBusinessController>{
  const RegYourBusinessScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: Get.back,
          icon: Icon(Icons.arrow_back_ios_new_outlined, color: context.iconColor),
        ),
        title: Text(
          controller.isEditMode ? "Update Business" : "Register Business", 
          style: context.textTheme.titleMedium
        ),
      ),
      body: Form(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionTitle("Business Information"),
              AppInputTextField(
                label: "Business Name",
                controller: controller.bNameCtrl,
                textInputType: TextInputType.text,
                iconData: Icons.business_outlined,
                validator: FormValidator.name,
              ),

              Obx(() => SingleDropdown(
                controller: controller.bTypeCtrl,
                label: "Business Type",
                prefixIcon: Icons.category_rounded,
                items: controller.businessTypes.toList(), // Using observable list
              )),

              Obx(() => SingleDropdown(
                controller: controller.bCategoryCtrl,
                label: "Business Category",
                prefixIcon: Icons.category_rounded,
                items: controller.businessCategories.toList(), // Using observable list
              )),

              AppInputTextField(
                label: "Business Description",
                textInputType: TextInputType.text,
                controller: controller.bDescCtrl,
                maxLines: 4,
                hintText: "Describe your business, products",
                validator: FormValidator.name,
              ),
              const SizedBox(height: 20),

              const SectionTitle("Business Photos"),
              const SizedBox(height: 8),
              Obx(() => _buildPhotoGrid(context)),
              const SizedBox(height: 24),

              const SectionTitle("Contact Information"),
              AppInputTextField(
                label: "Contact Number ",
                iconData: CupertinoIcons.phone,
                textInputType: TextInputType.phone,
                controller: controller.phoneCtrl,
                hint: const [AutofillHints.telephoneNumber],
              ),
              AppInputTextField(
                label: "Email ",
                iconData: CupertinoIcons.mail_solid,
                textInputType: TextInputType.emailAddress,
                controller: controller.emailCtrl,
                hint: const [AutofillHints.email],
                validator: FormValidator.email,
              ),
              AppInputTextField(
                label: "Website ",
                iconData: Icons.language_rounded,
                textInputType: TextInputType.webSearch,
                controller: controller.websiteCtrl,
              ),

              const SizedBox(height: 30),

              CustomButton(
                title: controller.isEditMode ? "Update Business" : "Register Business", 
                onPressed: controller.onRegister,
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoGrid(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (controller.selectedImages.isNotEmpty || controller.existingImages.isNotEmpty)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            // Total count = existing + new
            itemCount: controller.existingImages.length + controller.selectedImages.length,
            itemBuilder: (context, index) {
              // Check if index is within existing images range
              if (index < controller.existingImages.length) {
                  // Show Existing Image
                  final imageUrl = controller.existingImages[index];
                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          imageUrl,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[200], child: Icon(Icons.broken_image, color: Colors.grey)),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => controller.removeExistingImage(index),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close, size: 16, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  );
              } else {
                  // Show New Selected Image
                  // Adjust index for selectedImages list
                  final newIndex = index - controller.existingImages.length;
                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          controller.selectedImages[newIndex],
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => controller.removeImage(newIndex),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close, size: 16, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  );
              }
            },
          ).marginOnly(bottom: 16),
        
        InkWell(
          onTap: () => controller.pickImages(context),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(
              color: context.theme.primaryColor.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: context.theme.primaryColor.withValues(alpha: 0.3),
                style: BorderStyle.solid,
                width: 1.5,
              ),
            ),
            child: Column(
              children: [
                Icon(Icons.add_a_photo_outlined, size: 32, color: context.theme.primaryColor),
                const SizedBox(height: 8),
                Text(
                  controller.selectedImages.isEmpty 
                    ? "Add Business Photos" 
                    : "Add More Photos",
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.theme.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
