import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_state_manager/src/simple/get_view.dart';
import 'package:get/get_utils/src/extensions/context_extensions.dart';

import 'package:edu_cluezer/core/helper/form_validator.dart';
import 'package:edu_cluezer/widgets/basic_text_field.dart';
import 'package:edu_cluezer/widgets/custom_buttons.dart';
import 'package:edu_cluezer/features/business/presentation/controller/reg_business_controller.dart';

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
          controller.isEditMode ? 'update_business'.tr : 'register_business'.tr, 
          style: context.textTheme.titleMedium
        ),
      ),
      body: Form(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionTitle('business_information'.tr),
              AppInputTextField(
                label: '${'business_name'.tr} *',
                controller: controller.bNameCtrl,
                textInputType: TextInputType.text,
                iconData: Icons.business_outlined,
                validator: FormValidator.name,
              ),

              Obx(() => SingleDropdown(
                controller: controller.bTypeCtrl,
                label: '${'business_type'.tr} *',
                prefixIcon: Icons.category_rounded,
                items: controller.businessTypes.toList(), // Using observable list
              )),

              Obx(() => SingleDropdown(
                controller: controller.bCategoryCtrl,
                label: '${'business_category'.tr} *',
                prefixIcon: Icons.category_rounded,
                items: controller.businessCategories.toList(),
              )),

              ValueListenableBuilder<TextEditingValue>(
                valueListenable: controller.bCategoryCtrl, 
                builder: (context, value, child) {
                  if (value.text == "Other") {
                    return Padding(
                      padding: const EdgeInsets.only(top: 1.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end, // 👈 ye add karo
                        children: [
                          Expanded(
                            child: AppInputTextField(
                              label: 'enter_custom_category'.tr,
                              controller: controller.customCategoryCtrl,
                              textInputType: TextInputType.text,
                              iconData: Icons.add,
                              validator: FormValidator.name,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Obx(() => IconButton(
                              onPressed: controller.isRegisteringCategory.value
                                  ? null
                                  : () {
                                if (controller.customCategoryCtrl.text.isNotEmpty) {
                                  controller.registerCustomCategory(
                                      controller.customCategoryCtrl.text);
                                }
                              },
                              icon: controller.isRegisteringCategory.value
                                  ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                                  : const Icon(Icons.check_circle,
                                  color: Colors.green, size: 30),
                            )),
                          )
                        ],
                      ),

                      /*child: Row(
                        children: [
                          Expanded(
                            child: AppInputTextField(
                              label: 'enter_custom_category'.tr,
                              controller: controller.customCategoryCtrl,
                              textInputType: TextInputType.text,
                              iconData: Icons.add,
                              validator: FormValidator.name,
                            ),
                          ),
                          const SizedBox(height: 8,),
                          Obx(() => IconButton(
                            onPressed: controller.isRegisteringCategory.value 
                                ? null 
                                : () {
                                    if (controller.customCategoryCtrl.text.isNotEmpty) {
                                       controller.registerCustomCategory(controller.customCategoryCtrl.text);
                                    }
                                  },
                            icon: controller.isRegisteringCategory.value 
                                ? const SizedBox(
                                    width: 20, 
                                    height: 20, 
                                    child: CircularProgressIndicator(strokeWidth: 2)
                                  ) 
                                : const Icon(Icons.check_circle, color: Colors.green, size: 30),
                          ))
                        ],
                      ),*/
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),

              AppInputTextField(
                label: '${'business_description'.tr} *',
                textInputType: TextInputType.text,
                controller: controller.bDescCtrl,
                maxLines: 4,
                hintText: 'business_description_hint'.tr,
                validator: FormValidator.name,
              ),
             // const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: AppInputTextField(
                      label: '${'opening_time'.tr} *',
                      controller: controller.openingTimeCtrl,
                      textInputType: TextInputType.none,
                      iconData: Icons.sunny,
                      readOnly: true,
                      onTap: () => _selectTime(context, controller.openingTimeCtrl, true),
                      suffixWidget: Icon(Icons.access_time),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'select_opening_time'.tr;
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppInputTextField(
                      label: '${'closing_time'.tr} *',
                      controller: controller.closingTimeCtrl,
                      textInputType: TextInputType.none,
                      iconData: Icons.nightlight_outlined,
                      readOnly: true,
                      onTap: () => _selectTime(context, controller.closingTimeCtrl, false),
                      suffixWidget: Icon(Icons.access_time),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'select_closing_time'.tr;
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              SectionTitle('business_photos'.tr),
              const SizedBox(height: 8),
              Obx(() => _buildPhotoGrid(context)),
              const SizedBox(height: 24),

              SectionTitle('contact_information'.tr),
              AppInputTextField(
                label: '${'contact_number'.tr} *',
                iconData: CupertinoIcons.phone,
                textInputType: TextInputType.phone,
                controller: controller.phoneCtrl,
                validator: FormValidator.mobile,
                hint: const [AutofillHints.telephoneNumber],
              ),
              AppInputTextField(
                label: '${'email'.tr} *',
                iconData: CupertinoIcons.mail_solid,
                textInputType: TextInputType.emailAddress,
                controller: controller.emailCtrl,
                hint: const [AutofillHints.email],
                validator: FormValidator.email,
              ),
              AppInputTextField(
                label: '${'website'.tr} *',
                iconData: Icons.language_rounded,
                textInputType: TextInputType.webSearch,
                controller: controller.websiteCtrl,
              ),

              const SizedBox(height: 30),

              CustomButton(
                title: controller.isEditMode ? 'update_business'.tr : 'register_business'.tr, 
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
                    ? 'add_business_photos'.tr
                    : 'add_more_photos'.tr,
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

  Future<void> _selectTime(
      BuildContext context,
      TextEditingController timeCtrl,
      bool isOpening,
      ) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            alwaysUse24HourFormat: true, // ⛔ hides keyboard input
            textScaleFactor: 1.0,
          ),
          child: Theme(
            data: ThemeData.light().copyWith(
              colorScheme: ColorScheme.light(
                primary: Theme.of(context).primaryColor,
                onPrimary: Colors.white,
              ),
            ),
            child: child!,
          ),
        );
      },
    );

    if (picked != null) {
      // timeCtrl.text = picked.format(context); // This uses localized format (e.g. 5:30 PM) which fails validation
      
      // Format to HH:mm (24-hour format) for API validation
      final hour = picked.hour.toString().padLeft(2, '0');
      final minute = picked.minute.toString().padLeft(2, '0');
      timeCtrl.text = "$hour:$minute";
      
      if (isOpening) {
        controller.openingTime = picked;
      } else {
        controller.closingTime = picked;
      }
    }
  }

}




// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:get/get_core/src/get_main.dart';
// import 'package:get/get_navigation/src/extension_navigation.dart';
// import 'package:get/get_state_manager/src/simple/get_view.dart';
// import 'package:get/get_utils/src/extensions/context_extensions.dart';
//
// import 'package:edu_cluezer/core/helper/form_validator.dart';
// import 'package:edu_cluezer/widgets/basic_text_field.dart';
// import 'package:edu_cluezer/widgets/custom_buttons.dart';
// import 'package:edu_cluezer/features/business/presentation/controller/reg_business_controller.dart';
//
// class RegYourBusinessScreen extends GetWidget<RegBusinessController> {
//   const RegYourBusinessScreen({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final textTheme = theme.textTheme;
//
//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           onPressed: Get.back,
//           icon: Icon(
//             Icons.arrow_back_ios_new_outlined,
//             color: context.iconColor,
//           ),
//         ),
//         title: Text(
//           controller.isEditMode ? "Update Business" : "Register Business",
//           style: textTheme.titleMedium?.copyWith(
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//       ),
//       body: Form(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Business Information Section
//               _buildSectionCard(
//                 context,
//                 title: "Business Information",
//                 icon: Icons.business_outlined,
//                 children: [
//                   AppInputTextField(
//                     label: "Business Name",
//                     controller: controller.bNameCtrl,
//                     textInputType: TextInputType.text,
//                     iconData: Icons.business_outlined,
//                     validator: FormValidator.name,
//                   ),
//                   const SizedBox(height: 16),
//                   Row(
//                     children: [
//                       Expanded(
//                         child: Obx(() => SingleDropdown(
//                           controller: controller.bTypeCtrl,
//                           label: "Business Type",
//                           prefixIcon: Icons.category_rounded,
//                           items: controller.businessTypes.toList(),
//                         )),
//                       ),
//                       const SizedBox(width: 12),
//                       Expanded(
//                         child: Obx(() => SingleDropdown(
//                           controller: controller.bCategoryCtrl,
//                           label: "Business Category",
//                           prefixIcon: Icons.category_rounded,
//                           items: controller.businessCategories.toList(),
//                         )),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 16),
//                   AppInputTextField(
//                     label: "Business Description",
//                     textInputType: TextInputType.text,
//                     controller: controller.bDescCtrl,
//                     maxLines: 4,
//                     hintText: "Describe your business, products, or services...",
//                     validator: FormValidator.name,
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 20),
//
//               // Business Hours Section
//               _buildSectionCard(
//                 context,
//                 title: "Business Hours",
//                 icon: Icons.access_time_outlined,
//                 children: [
//                   Row(
//                     children: [
//                       Expanded(
//                         child: AppInputTextField(
//                           label: "Opening Time",
//                           controller: controller.openingTimeCtrl,
//                           textInputType: TextInputType.none,
//                           iconData: Icons.sunny,
//                          // readOnly: true,
//                           onTap: () => _selectTime(context, controller.openingTimeCtrl, true),
//                           suffixWidget: Icon(Icons.access_time),
//                           validator: (value) {
//                             if (value == null || value.isEmpty) {
//                               return "Please select opening time";
//                             }
//                             return null;
//                           },
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       Expanded(
//                         child: AppInputTextField(
//                           label: "Closing Time",
//                           controller: controller.closingTimeCtrl,
//                           textInputType: TextInputType.none,
//                           iconData: Icons.nightlight_outlined,
//                         //  readOnly: true,
//                           onTap: () => _selectTime(context, controller.closingTimeCtrl, false),
//                           suffixWidget: Icon(Icons.access_time),
//                           validator: (value) {
//                             if (value == null || value.isEmpty) {
//                               return "Please select closing time";
//                             }
//                             return null;
//                           },
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     "Select your business operating hours",
//                     style: textTheme.bodySmall?.copyWith(
//                       color: theme.hintColor,
//                       fontStyle: FontStyle.italic,
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 20),
//
//               // Business Photos Section
//               _buildSectionCard(
//                 context,
//                 title: "Business Photos",
//                 icon: Icons.photo_library_outlined,
//                 children: [
//                   Obx(() => _buildPhotoGrid(context)),
//                 ],
//               ),
//               const SizedBox(height: 20),
//
//               // Contact Information Section
//               _buildSectionCard(
//                 context,
//                 title: "Contact Information",
//                 icon: Icons.contact_phone_outlined,
//                 children: [
//                   AppInputTextField(
//                     label: "Contact Number",
//                     iconData: CupertinoIcons.phone,
//                     textInputType: TextInputType.phone,
//                     controller: controller.phoneCtrl,
//                     hint: const [AutofillHints.telephoneNumber],
//                     validator: FormValidator.mobile,
//                   ),
//                   const SizedBox(height: 16),
//                   AppInputTextField(
//                     label: "Email Address",
//                     iconData: CupertinoIcons.mail_solid,
//                     textInputType: TextInputType.emailAddress,
//                     controller: controller.emailCtrl,
//                     hint: const [AutofillHints.email],
//                     validator: FormValidator.email,
//                   ),
//                   const SizedBox(height: 16),
//                   AppInputTextField(
//                     label: "Website (Optional)",
//                     iconData: Icons.language_rounded,
//                     textInputType: TextInputType.url,
//                     controller: controller.websiteCtrl,
//                    // hint: "https://example.com",
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 30),
//
//               // Submit Button
//               Container(
//                 width: double.infinity,
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(16),
//                   gradient: LinearGradient(
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                     colors: [
//                       theme.primaryColor,
//                       theme.primaryColor.withOpacity(0.8),
//                     ],
//                   ),
//                   boxShadow: [
//                     BoxShadow(
//                       color: theme.primaryColor.withOpacity(0.3),
//                       blurRadius: 10,
//                       offset: const Offset(0, 4),
//                     ),
//                   ],
//                 ),
//                 child: CustomButton(
//                   title: controller.isEditMode ? "Update Business" : "Register Business",
//                   onPressed: controller.onRegister,
//                   backgroundColor: Colors.transparent,
//                   textColor: Colors.white,
//                  // elevation: 0,
//                 ),
//               ),
//
//               const SizedBox(height: 40),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildSectionCard(
//       BuildContext context, {
//         required String title,
//         required IconData icon,
//         required List<Widget> children,
//       }) {
//     final theme = Theme.of(context);
//     final textTheme = theme.textTheme;
//
//     return Container(
//       decoration: BoxDecoration(
//         color: theme.cardColor,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//         border: Border.all(
//           color: theme.dividerColor.withOpacity(0.2),
//           width: 1,
//         ),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Section Header
//             Row(
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(8),
//                   decoration: BoxDecoration(
//                     color: theme.primaryColor.withOpacity(0.1),
//                     shape: BoxShape.circle,
//                   ),
//                   child: Icon(
//                     icon,
//                     size: 20,
//                     color: theme.primaryColor,
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Text(
//                   title,
//                   style: textTheme.titleMedium?.copyWith(
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             const Divider(height: 1),
//             const SizedBox(height: 20),
//
//             // Section Content
//             ...children,
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildPhotoGrid(BuildContext context) {
//     final hasImages = controller.selectedImages.isNotEmpty ||
//         controller.existingImages.isNotEmpty;
//     final totalImages = controller.existingImages.length +
//         controller.selectedImages.length;
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Instructions
//         Text(
//           "Upload clear photos of your business (up to 6)",
//           style: Theme.of(context).textTheme.bodySmall?.copyWith(
//             color: Theme.of(context).hintColor,
//           ),
//         ),
//         const SizedBox(height: 12),
//
//         // Grid View for Images
//         if (hasImages)
//           GridView.builder(
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: 3,
//               crossAxisSpacing: 8,
//               mainAxisSpacing: 8,
//               childAspectRatio: 1,
//             ),
//             itemCount: totalImages,
//             itemBuilder: (context, index) {
//               // Existing Image
//               if (index < controller.existingImages.length) {
//                 final imageUrl = controller.existingImages[index];
//                 return _buildImageItem(
//                   context,
//                   imageProvider: NetworkImage(imageUrl),
//                   onRemove: () => controller.removeExistingImage(index),
//                   isNetworkImage: true,
//                 );
//               }
//               // New Selected Image
//               else {
//                 final newIndex = index - controller.existingImages.length;
//                 return _buildImageItem(
//                   context,
//                   imageProvider: FileImage(controller.selectedImages[newIndex]),
//                   onRemove: () => controller.removeImage(newIndex),
//                   isNetworkImage: false,
//                 );
//               }
//             },
//           ).marginOnly(bottom: 16),
//
//         // Add Photo Button
//         InkWell(
//           onTap: () => controller.pickImages(context),
//           borderRadius: BorderRadius.circular(12),
//           child: Container(
//             width: double.infinity,
//             padding: const EdgeInsets.symmetric(vertical: 20),
//             decoration: BoxDecoration(
//               color: context.theme.primaryColor.withOpacity(0.05),
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(
//                 color: context.theme.primaryColor.withOpacity(0.3),
//                 width: 1.5,
//                 style: BorderStyle.solid,
//               ),
//             ),
//             child: Column(
//               children: [
//                 Icon(
//                   hasImages ? Icons.add_photo_alternate_outlined : Icons.add_a_photo_outlined,
//                   size: 36,
//                   color: context.theme.primaryColor,
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   hasImages ? "Add More Photos" : "Upload Business Photos",
//                   style: context.textTheme.bodyMedium?.copyWith(
//                     color: context.theme.primaryColor,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//                 if (!hasImages) ...[
//                   const SizedBox(height: 4),
//                   Text(
//                     "Tap to select from gallery",
//                     style: context.textTheme.bodySmall?.copyWith(
//                       color: context.theme.hintColor,
//                     ),
//                   ),
//                 ],
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildImageItem(
//       BuildContext context, {
//         required ImageProvider imageProvider,
//         required VoidCallback onRemove,
//         required bool isNetworkImage,
//       }) {
//     return Stack(
//       children: [
//         ClipRRect(
//           borderRadius: BorderRadius.circular(12),
//           child: Container(
//             decoration: BoxDecoration(
//               border: Border.all(
//                 color: Colors.grey.shade200,
//                 width: 1,
//               ),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: isNetworkImage
//                 ? Image.network(
//               '',
//             //  scale: imageProvider,
//               width: double.infinity,
//               height: double.infinity,
//               fit: BoxFit.cover,
//               loadingBuilder: (context, child, loadingProgress) {
//                 if (loadingProgress == null) return child;
//                 return Center(
//                   child: CircularProgressIndicator(
//                     value: loadingProgress.expectedTotalBytes != null
//                         ? loadingProgress.cumulativeBytesLoaded /
//                         loadingProgress.expectedTotalBytes!
//                         : null,
//                     strokeWidth: 2,
//                   ),
//                 );
//               },
//               errorBuilder: (context, error, stackTrace) => Container(
//                 color: Colors.grey[200],
//                 child: const Icon(
//                   Icons.broken_image,
//                   color: Colors.grey,
//                   size: 30,
//                 ),
//               ),
//             )
//                 : Image(
//               image: imageProvider,
//               width: double.infinity,
//               height: double.infinity,
//               fit: BoxFit.cover,
//             ),
//           ),
//         ),
//         // Remove Button
//         Positioned(
//           top: 4,
//           right: 4,
//           child: GestureDetector(
//             onTap: onRemove,
//             child: Container(
//               padding: const EdgeInsets.all(4),
//               decoration: BoxDecoration(
//                 color: Colors.red,
//                 shape: BoxShape.circle,
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.2),
//                     blurRadius: 4,
//                   ),
//                 ],
//               ),
//               child: const Icon(
//                 Icons.close,
//                 size: 16,
//                 color: Colors.white,
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Future<void> _selectTime(
//       BuildContext context, TextEditingController timeCtrl, bool isOpening) async {
//     final TimeOfDay? picked = await showTimePicker(
//       context: context,
//       initialTime: TimeOfDay.now(),
//       builder: (BuildContext context, Widget? child) {
//         return Theme(
//           data: ThemeData.light().copyWith(
//             colorScheme: ColorScheme.light(
//               primary: Theme.of(context).primaryColor,
//               onPrimary: Colors.white,
//             ),
//           ),
//           child: child!,
//         );
//       },
//     );
//
//     if (picked != null) {
//       final time = picked.format(context);
//       timeCtrl.text = time;
//
//       // You can also save the TimeOfDay object in your controller if needed
//       if (isOpening) {
//         controller.openingTime = picked;
//       } else {
//         controller.closingTime = picked;
//       }
//     }
//   }
// }
//
// class SectionTitle extends StatelessWidget {
//   final String title;
//
//   const SectionTitle(this.title, {Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 16),
//       child: Text(
//         title,
//         style: Theme.of(context).textTheme.titleMedium?.copyWith(
//           fontWeight: FontWeight.w600,
//           color: Theme.of(context).primaryColor,
//         ),
//       ),
//     );
//   }
// }




