import 'package:flutter/cupertino.dart';
import 'package:edu_cluezer/widgets/custom_image_view.dart';
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
        onWillPop: controller.handleBack,
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => Get.back(),
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

                  // 24*7 Attractive Toggle Card
                  Obx(() {
                    final isOpen24x7 = controller.isOpen24x7.value;
                    final primaryColor = Theme.of(context).primaryColor;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(
                        color: isOpen24x7
                            ? primaryColor.withValues(alpha: 0.08)
                            : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isOpen24x7
                              ? primaryColor.withValues(alpha: 0.7)
                              : Colors.grey.shade300,
                          width: isOpen24x7 ? 1.6 : 1.0,
                        ),
                        boxShadow: isOpen24x7
                            ? [
                                BoxShadow(
                                  color: primaryColor.withValues(alpha: 0.08),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                )
                              ]
                            : null,
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => controller.toggleOpen24x7(!isOpen24x7),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            child: Row(
                              children: [
                                Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: isOpen24x7
                                        ? primaryColor
                                        : Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.all_inclusive_rounded,
                                    color: isOpen24x7 ? Colors.white : Colors.grey.shade600,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            'open_24_7'.tr,
                                            style: TextStyle(
                                              fontSize: 14.5,
                                              fontWeight: FontWeight.w600,
                                              color: isOpen24x7
                                                  ? primaryColor
                                                  : Colors.black87,
                                            ),
                                          ),
                                          if (isOpen24x7) ...[
                                            const SizedBox(width: 6),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: primaryColor.withValues(alpha: 0.15),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                "Active",
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                  color: primaryColor,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        isOpen24x7
                                            ? 'open_24_7_active_desc'.tr
                                            : 'open_24_7_desc'.tr,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: isOpen24x7
                                              ? primaryColor.withValues(alpha: 0.8)
                                              : Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Checkbox(
                                  value: isOpen24x7,
                                  onChanged: (val) => controller.toggleOpen24x7(val),
                                  activeColor: primaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),

                  // Custom Timing Fields (Hidden when 24*7 is selected)
                  Obx(() {
                    if (controller.isOpen24x7.value) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: AppInputTextField(
                              label: 'opening_time'.tr,
                              isRequired: false,
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
                              isRequired: false,
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
                    );
                  }),
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

                  Obx(
                    () => SingleDropdown(
                      controller: controller.bTypeCtrl,
                      label: 'business_type'.tr,
                      isRequired: true,
                      prefixIcon: Icons.category_rounded,
                      items: controller.businessTypes.toList(),
                      errorText: controller.errors['businessType'],
                    ),
                  ),

                  GestureDetector(
                    onTap: () => controller.openCategorySelection(context),
                    child: AbsorbPointer(
                      child: AppInputTextField(
                        controller: controller.bCategoryCtrl,
                        label: 'business_category'.tr,
                        isRequired: true,
                        iconData: Icons.category_rounded,
                        endIcon: Icons.arrow_drop_down,
                        errorText: controller.errors['businessCategory'],
                      ),
                    ),
                  ),

                  /* ValueListenableBuilder<TextEditingValue>(
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
                  ), */

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

                  _buildGooglePlacesSearchSection(context),

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
                    onVerificationChanged: (val) {
                      controller.isPhoneVerified.value = val;
                    },
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

                  Obx(() => Row(
                    children: [
                      Checkbox(
                        value: controller.hasWebsite.value,
                        onChanged: (val) {
                          controller.hasWebsite.value = val ?? false;
                          if (!controller.hasWebsite.value) {
                            controller.websiteCtrl.text = "https://";
                          }
                        },
                      ),
                      Text(
                        'Do you have a website?',
                        style: TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                    ],
                  )),
                  
                  Obx(() => controller.hasWebsite.value 
                    ? AppInputTextField(
                        label: 'website'.tr,
                        subLabel: 'website_example_hint'.tr,
                        hintText: 'https://www.example.com',
                        iconData: Icons.language_rounded,
                        textInputType: TextInputType.url,
                        controller: controller.websiteCtrl,
                      )
                    : const SizedBox.shrink(),
                  ),

                  const SizedBox(height: 30),

                  Obx(() {
                    final bool isVerified = controller.isEditMode || controller.isPhoneVerified.value;
                    return CustomButton(
                      title: controller.isRegistering.value
                          ? 'please_wait'.tr
                          : (controller.isEditMode ? 'update_business'.tr : 'register_business'.tr),
                      onPressed: controller.isRegistering.value
                          ? null
                          : (isVerified
                              ? controller.onRegister
                              : () {
                                  if (Get.context != null) {
                                    PhoneFieldComponent.showNotVerifiedDialog(
                                      context: Get.context!,
                                      onVerifyTap: () {
                                        if (controller.phoneFieldKey.currentState?.isOtpSentState == true) {
                                          controller.phoneFieldKey.currentState?.focusFirstOtpBox();
                                        } else {
                                          controller.phoneFieldKey.currentState?.sendOtp();
                                        }
                                      },
                                    );
                                  } else {
                                    controller.onRegister();
                                  }
                                }),
                      isLoading: controller.isRegistering.value,
                    );
                  }),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        }),
      );});
  }

  Widget _buildGooglePlacesSearchSection(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Obx(() {
      final hasPinnedLocation = controller.selectedLatitude.value != null &&
          controller.selectedLongitude.value != null;
      final lat = controller.selectedLatitude.value;
      final lng = controller.selectedLongitude.value;
      final isSearching = controller.isSearchingLocation.value;
      final isFetchingDetails = controller.isFetchingLocationDetails.value;
      final suggestions = controller.locationSuggestions;

      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pinned Location Badge Card (if coordinates are selected)
            if (hasPinnedLocation)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF86EFAC), width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0xFF22C55E),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'location_pinned'.tr,
                            style: const TextStyle(
                              color: Color(0xFF15803D),
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            "Lat: ${lat?.toStringAsFixed(5)}, Lng: ${lng?.toStringAsFixed(5)}",
                            style: const TextStyle(
                              color: Color(0xFF166534),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (controller.selectedLocationName.value.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(
                                controller.selectedLocationName.value,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        controller.clearSelectedLocation();
                      },
                      icon: const Icon(Icons.refresh_rounded, size: 16, color: Color(0xFF15803D)),
                      label: Text(
                        'change_location'.tr,
                        style: const TextStyle(
                          color: Color(0xFF15803D),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ],
                ),
              ),

            // Search Bar Input
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: TextField(
                controller: controller.locationSearchCtrl,
                onChanged: controller.onLocationSearchChanged,
                decoration: InputDecoration(
                  labelText: 'search_location_map'.tr,
                  hintText: 'search_location_hint'.tr,
                  hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13.5),
                  labelStyle: TextStyle(
                    color: primaryColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  prefixIcon: Container(
                    padding: const EdgeInsets.all(10),
                    child: Icon(
                      Icons.search_rounded,
                      color: primaryColor,
                      size: 24,
                    ),
                  ),
                  suffixIcon: isSearching || isFetchingDetails
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: Padding(
                            padding: EdgeInsets.all(13.0),
                            child: CircularProgressIndicator(strokeWidth: 2.2),
                          ),
                        )
                      : controller.locationSearchCtrl.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 20),
                              onPressed: () {
                                controller.clearSelectedLocation();
                              },
                            )
                          : null,
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: primaryColor, width: 1.8),
                  ),
                ),
              ),
            ),

            // Suggestions Dropdown List
            if (suggestions.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 6),
                constraints: const BoxConstraints(maxHeight: 260),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    itemCount: suggestions.length,
                    separatorBuilder: (_, __) => Divider(
                      height: 1,
                      thickness: 0.8,
                      color: Colors.grey.shade200,
                    ),
                    itemBuilder: (context, index) {
                      final item = suggestions[index];
                      return ListTile(
                        dense: true,
                        horizontalTitleGap: 8,
                        leading: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.location_on_rounded,
                            color: primaryColor,
                            size: 18,
                          ),
                        ),
                        title: Text(
                          item.mainText,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        subtitle: item.secondaryText.isNotEmpty
                            ? Text(
                                item.secondaryText,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              )
                            : null,
                        onTap: () {
                          FocusScope.of(context).unfocus();
                          controller.selectLocation(item);
                        },
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      );
    });
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
                          : CustomImageView(url: 
                        controller.existingImages[0],
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,

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
