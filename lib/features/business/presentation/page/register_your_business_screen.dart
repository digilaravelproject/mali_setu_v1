import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:edu_cluezer/core/helper/form_validator.dart';
import 'package:edu_cluezer/widgets/basic_text_field.dart';
import 'package:edu_cluezer/widgets/phone_field_component.dart';
import 'package:edu_cluezer/core/widgets/full_screen_image_viewer.dart';
import 'package:edu_cluezer/widgets/custom_buttons.dart';
import 'package:edu_cluezer/features/business/presentation/controller/reg_business_controller.dart';

import '../../../../widgets/custom_scaffold.dart';

class RegYourBusinessScreen extends GetWidget<RegBusinessController> {
  const RegYourBusinessScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      controller.canExit.value; // Dummy read for Obx
      return CustomScaffold(
        onWillPop: () async {
          if (controller.canExit.value) return true;
          controller.handleBack();
          return false;
        },
        appBar: AppBar(
          leading: IconButton(
            onPressed: controller.handleBack,
            icon: Icon(Icons.arrow_back_ios_new_outlined, color: context.iconColor),
          ),
          title: Text(
            controller.isEditMode ? 'update_business'.tr : 'register_business'.tr,
            style: context.textTheme.titleMedium,
          ),
        ),
      body: Obx(() {
        if (controller.isDetailsLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return Form(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionTitle('business_information'.tr),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: AppInputTextField(
                        label: 'opening_time'.tr,
                        isRequired: true,
                        controller: controller.openingTimeCtrl,
                        textInputType: TextInputType.none,
                        iconData: Icons.access_time,
                        readOnly: true,
                        onTap: () => _selectTime(context, controller.openingTimeCtrl, true),
                        errorText: controller.errors['openingTime'],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppInputTextField(
                        label: 'closing_time'.tr,
                        isRequired: true,
                        controller: controller.closingTimeCtrl,
                        textInputType: TextInputType.none,
                        iconData: Icons.access_time,
                        readOnly: true,
                        onTap: () => _selectTime(context, controller.closingTimeCtrl, false),
                        errorText: controller.errors['closingTime'],
                      ),
                    ),
                  ],
                ),
               // const SizedBox(height: 20),

                AppInputTextField(
                  label: 'business_name'.tr,
                  isRequired: true,
                  controller: controller.bNameCtrl,
                  textInputType: TextInputType.text,
                  iconData: Icons.business_outlined,
                  validator: FormValidator.name,
                  errorText: controller.errors['businessName'],
                ),

                SingleDropdown(
                  controller: controller.bTypeCtrl,
                  label: 'business_type'.tr,
                  isRequired: true,
                  prefixIcon: Icons.category_rounded,
                  items: controller.businessTypes.toList(),
                  errorText: controller.errors['businessType'],
                ),

                SingleDropdown(
                  controller: controller.bCategoryCtrl,
                  label: 'business_category'.tr,
                  isRequired: true,
                  prefixIcon: Icons.category_rounded,
                  items: controller.businessCategories.toList(),
                  errorText: controller.errors['businessCategory'],
                ),

                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: controller.bCategoryCtrl,
                  builder: (context, value, child) {
                    if (value.text == "Other") {
                      return Padding(
                        padding: const EdgeInsets.only(top: 1.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
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
                              child: IconButton(
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
                              ),
                            )
                          ],
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),

                AppInputTextField(
                  label: 'business_description'.tr,
                  isRequired: true,
                  textInputType: TextInputType.text,
                  controller: controller.bDescCtrl,
                  maxLines: 4,
                  hintText: 'business_description_hint'.tr,
                  validator: (value) =>
                      FormValidator.jobDescription(value, 'business_description_hint'.tr),
                  errorText: controller.errors['description'],
                ),



               // const SizedBox(height: 20),

                Row(
                  children: [
                    SectionTitle('business_photos'.tr),
                    Text(
                      ' *',
                      style: context.theme.textTheme.titleMedium?.copyWith(
                        color: Colors.red,
                      ),
                    ),
                      ]
                ),
               // const SizedBox(height: 8),
                _buildPhotoGrid(context),
                const SizedBox(height: 24),
                SectionTitle('location_information'.tr),

                AppInputTextField(
                  label: 'address'.tr,
                  isRequired: true,
                  controller: controller.addressCtrl,
                  textInputType: TextInputType.streetAddress,
                  iconData: Icons.location_on_outlined,
                  errorText: controller.errors['address'],
                ),



                AppInputTextField(
                  label: 'pincode'.tr,
                  isRequired: true,
                  controller: controller.pinCodeCtrl,
                  textInputType: TextInputType.number,
                  iconData: Icons.pin_drop_outlined,
                  errorText: controller.errors['pincode'],
                  suffixWidget: controller.isFetchingPincode.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: Padding(
                            padding: EdgeInsets.all(12.0),
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ))
                      : null,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'enter_pincode'.tr;
                    if (value.length < 5 || value.length > 10) return 'invalid_pincode'.tr;
                    return null;
                  },
                ),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: AppInputTextField(
                        label: 'country'.tr,
                        isRequired: true,
                        controller: controller.countryCtrl,
                        textInputType: TextInputType.text,
                        iconData: Icons.public_rounded,
                        validator: FormValidator.name,
                        errorText: controller.errors['country'],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppInputTextField(
                        label: 'state'.tr,
                        // isRequired: true,
                        controller: controller.stateCtrl,
                        textInputType: TextInputType.text,
                        iconData: Icons.landscape_rounded,
                        // validator: FormValidator.name,
                        //  errorText: controller.errors['state'],
                      ),
                    ),

                  ],
                ),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: AppInputTextField(
                        label: 'city'.tr,
                      //  isRequired: true,
                        controller: controller.cityCtrl,
                        textInputType: TextInputType.text,
                        iconData: Icons.location_city_rounded,
                        //validator: FormValidator.name,
                       // errorText: controller.errors['city'],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Expanded(
                    //   child: AppInputTextField(
                    //     label: 'district'.tr,
                    //    // isRequired: true,
                    //     controller: controller.districtCtrl,
                    //     textInputType: TextInputType.text,
                    //     iconData: Icons.map_outlined,
                    //  //   validator: FormValidator.name,
                    //   //  errorText: controller.errors['district'],
                    //   ),
                    //
                    // ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppInputTextField(
                        label: 'taluka'.tr,
                        controller: controller.talukaCtrl,
                        textInputType: TextInputType.text,
                        iconData: Icons.location_on_outlined,
                      ),
                    ),
                  ],
                ),



                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  //  const SizedBox(width: 12),
                    Expanded(
                      child: AppInputTextField(
                        label: 'village'.tr,
                        controller: controller.villageCtrl,
                        textInputType: TextInputType.text,
                        iconData: Icons.location_on_outlined,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                SectionTitle('contact_information'.tr),
                PhoneFieldComponent(
                  key: controller.phoneFieldKey,
                  isRequired: true,
                  initialPhone: controller.phoneCtrl.text,
                  errorText: controller.errors['phone'],
                  onChanged: (val) {
                    controller.errors.remove('phone');
                  },
                ),
                AppInputTextField(
                  label: 'email'.tr,
                  isRequired: true,
                  iconData: CupertinoIcons.mail_solid,
                  textInputType: TextInputType.emailAddress,
                  controller: controller.emailCtrl,
                  hint: const [AutofillHints.email],
                  validator: FormValidator.email,
                  errorText: controller.errors['email'],
                ),

                AppInputTextField(
                  label: 'website'.tr,
                  iconData: Icons.language_rounded,
                  textInputType: TextInputType.webSearch,
                  controller: controller.websiteCtrl,
                ),

                const SizedBox(height: 30),

                Obx(() => CustomButton(
                  title: controller.isRegistering.value 
                    ? 'please_wait'.tr 
                    : (controller.isEditMode ? 'update_business'.tr : 'register_business'.tr),
                  onPressed: controller.isRegistering.value ? null : controller.onRegister,
                  isLoading: controller.isRegistering.value,
                )),

                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      }),
    );});
  }

  Widget _buildPhotoGrid(BuildContext context) {
    final hasImage = controller.selectedImages.isNotEmpty || controller.existingImages.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasImage)
          Container(
            width: double.infinity,
            height: 200,
            margin: const EdgeInsets.only(bottom: 16),
            child: Stack(
              children: [
                GestureDetector(
                  onTap: () {
                    if (controller.selectedImages.isNotEmpty) {
                      Get.to(() => FullScreenImageViewer(
                        imageFile: controller.selectedImages[0],
                        tag: 'business_photo',
                      ));
                    } else {
                      Get.to(() => FullScreenImageViewer(
                        imageUrl: controller.existingImages[0],
                        tag: 'business_photo',
                      ));
                    }
                  },
                  child: Hero(
                    tag: 'business_photo',
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: controller.selectedImages.isNotEmpty
                          ? Image.file(
                              controller.selectedImages[0],
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                            )
                          : Image.network(
                              controller.existingImages[0],
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                    strokeWidth: 2,
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[200],
                                  child: const Icon(Icons.broken_image, color: Colors.grey),
                                );
                              },
                            ),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () {
                      if (controller.selectedImages.isNotEmpty) {
                        controller.removeImage(0);
                      } else {
                        controller.removeExistingImage(0);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, size: 18, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        if (!hasImage)
          InkWell(
            onTap: () => controller.pickImages(context),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32),
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
                  Icon(Icons.add_a_photo_outlined,
                      size: 40, color: context.theme.primaryColor),
                  const SizedBox(height: 12),
                  Text(
                    'add_business_photos'.tr,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.theme.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tap to select a photo',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.theme.hintColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Max size 2MB, Formats: JPG, PNG',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.theme.hintColor.withValues(alpha: 0.7),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          InkWell(
            onTap: () => controller.pickImages(context),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: context.theme.primaryColor.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: context.theme.primaryColor.withValues(alpha: 0.3),
                  style: BorderStyle.solid,
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.edit, size: 18, color: context.theme.primaryColor),
                  const SizedBox(width: 8),
                  Text(
                    'Change Photo',
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.theme.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (controller.errors.containsKey('photos'))
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 4),
            child: Text(
              controller.errors['photos']!,
              style: context.textTheme.bodySmall
                  ?.copyWith(color: Colors.red, fontWeight: FontWeight.w500),
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
    FocusScope.of(context).unfocus();

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isOpening
          ? (controller.openingTime ?? TimeOfDay.now())
          : (controller.closingTime ?? TimeOfDay.now()),
      initialEntryMode: TimePickerEntryMode.dial,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: Theme(
            data: ThemeData.light().copyWith(
              colorScheme: ColorScheme.light(
                primary: Theme.of(context).primaryColor,
                onPrimary: Colors.white,
                onSurface: Colors.black,
              ),
            ),
            child: child ?? const SizedBox(),
          ),
        );
      },
    );

    if (picked != null) {
      int hour = picked.hour;
      String period = hour >= 12 ? 'PM' : 'AM';
      if (hour > 12) {
        hour -= 12;
      } else if (hour == 0) {
        hour = 12;
      }

      final String minuteStr = picked.minute.toString().padLeft(2, '0');
      timeCtrl.text = "$hour:$minuteStr $period";

      if (isOpening) {
        controller.openingTime = picked;
      } else {
        controller.closingTime = picked;
      }
    }
  }
}

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle(this.title, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 16),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).primaryColor,
            ),
      ),
    );
  }
}
