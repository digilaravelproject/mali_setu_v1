import 'package:edu_cluezer/core/styles/app_colors.dart';
import 'package:edu_cluezer/features/matrimony/presentation/controller/reg_matrimony_controller.dart';
import 'package:edu_cluezer/core/widgets/full_screen_image_viewer.dart';
import 'package:edu_cluezer/widgets/basic_text_field.dart';
import 'package:edu_cluezer/widgets/name_field_component.dart';
import 'package:edu_cluezer/widgets/custom_buttons.dart';
import 'package:edu_cluezer/widgets/custom_scaffold.dart';
import 'package:edu_cluezer/widgets/custom_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../common/widgets/selection_tile.dart';
import '../../../../core/utils/app_assets.dart';
import '../../../../core/helper/date_input_formatter.dart';
import '../../../../core/helper/form_validator.dart';
import '../../../../core/constent/api_constants.dart';

class RegMatrimonyPage extends GetWidget<RegMatrimonyController> {
  const RegMatrimonyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: Get.back,
          icon: Icon(AppAssets.backArrow),
        ),
        title: Obx(() => Text(
          controller.isEditMode.value ? "edit_matrimony_profile".tr : "register_matrimony".tr,
        )),
      ),
      body: Obx(
            () => Stack(
          children: [
            Column(
              children: [
                /// Progress Indicator
                _buildProgressIndicator(context),

                Expanded(
                  child: SingleChildScrollView(
                    controller: controller.scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// Status Badge (Visible in Edit Mode)
                        Obx(() {
                          if (!controller.isEditMode.value || controller.approvalStatus.value.isEmpty) {
                            return const SizedBox.shrink();
                          }

                          Color getStatusColor(String status) {
                            switch (status.toLowerCase().trim()) {
                              case 'approved':
                              case 'active':
                                return Colors.green;
                              case 'pending':
                                return Colors.orange;
                              case 'rejected':
                              case 'inactive':
                                return Colors.red;
                              default:
                                return Colors.grey;
                            }
                          }

                          return Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 20),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: getStatusColor(controller.approvalStatus.value).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: getStatusColor(controller.approvalStatus.value).withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline_rounded,
                                  color: getStatusColor(controller.approvalStatus.value),
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Profile Status",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    Text(
                                      controller.approvalStatus.value.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: getStatusColor(controller.approvalStatus.value),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }),
                        if (controller.currentStep.value == 0) _buildPersonalStep(context),
                        if (controller.currentStep.value == 1) _buildReligiousStep(context),
                        if (controller.currentStep.value == 2) _buildEducationCareerStep(context),
                        if (controller.currentStep.value == 3) _buildFamilyLocationStep(context),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (controller.isPreFilling.value)
              Container(
                color: Colors.black.withOpacity(0.3),
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
          border: const Border(
            top: BorderSide(
              color: AppColors.lightBorder,
              width: 0.5,
            ),
          ),
        ),
        child: SafeArea(
          child: Obx(
                () => BottomAppBar(
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Row(
                children: [
                  if (controller.currentStep.value > 0)
                    Expanded(
                      child: CustomOutlinedButton(
                        title: "back".tr,
                        onPressed: controller.previousStep,
                      ).marginOnly(right: 8),
                    ),
                  Expanded(
                    child: CustomButton(
                      title: controller.currentStep.value == 3
                          ? (controller.isEditMode.value ? "update".tr : "register".tr)
                          : "next".tr,
                      onPressed: controller.currentStep.value == 3
                          ? controller.onRegister
                          : controller.nextStep,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }



  Widget _buildProgressIndicator(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: context.theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min, // take only as much space as needed
          children: List.generate(4, (index) {
            final isCompleted = index < controller.currentStep.value;
            final isActive = index == controller.currentStep.value;

            return Row(
              children: [
                // Circle Step
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted || isActive
                        ? context.theme.primaryColor
                        : context.theme.dividerColor.withValues(alpha: 0.5),
                  ),
                  child: Center(
                    child: isCompleted
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : Text(
                      "${index + 1}",
                      style: TextStyle(
                        color: isCompleted || isActive
                            ? Colors.white
                            : context.theme.iconTheme.color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                // Connector line
                if (index < 3)
                  Container(
                    width: 40, // control spacing
                    height: 2,
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    color: index < controller.currentStep.value
                        ? context.theme.primaryColor
                        : context.theme.dividerColor.withValues(alpha: 0.5),
                  ),
              ],
            );
          }),
        ),
      ),
    );
  }

  /// Step 1: Personal Details
  Widget _buildPersonalStep(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepHeader("personal_details".tr, "personal_details_sub".tr),

        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: context.theme.dividerColor.withValues(alpha: 0.1))),
          child: Padding(
            padding: const EdgeInsets.only(left: 16,right: 16,bottom: 16),
            child: Column(
              children: [
                Obx(() {
                  final _ = controller.nameWidgetKey.value;
                  return NameFieldComponent(
                    key: controller.nameFieldKey,
                    showTitle: false,
                    externalTitleCtrl: controller.titleCtrl,
                    externalFirstNameCtrl: controller.firstNameCtrl,
                    externalMiddleNameCtrl: controller.middleNameCtrl,
                    externalLastNameCtrl: controller.lastNameCtrl,
                    isRequired: true,
                    onChanged: (_) {},
                    titleItems: const ['Ms.', 'Dr.', 'Prof.'],
                  );
                }),
                const SizedBox(height: 12),

                Obx(() => SelectionTile(
                  label: "profile_created_by".tr,
                  value: controller.profileCreatedBy.value,
                  icon: Icons.person_add_alt,
                  isRequired: true,
                  errorText: controller.errors['profileCreatedBy'],
                  onTap: () => _showSingleSelectBottomSheet(
                      context, "Created By", controller.profileCreatedByList, controller.profileCreatedBy.call),
                )),
                const SizedBox(height: 12),

                Obx(() => SelectionTile(
                  label: "gender".tr,
                  value: controller.gender.value,
                  icon: Icons.person_outline,
                  isRequired: true,
                  errorText: controller.errors['gender'],
                  onTap: () => _showSingleSelectBottomSheet(
                      context, "Gender", controller.genderList, controller.gender.call),
                )),
                const SizedBox(height: 12),

                Obx(() => AppInputTextField(
                  label: "date_of_birth".tr,
                  controller: controller.dobCtrl,
                  isRequired: true,
                  topPadding: 0,
                  hintText: "DD/MM/YYYY",
                  errorText: controller.errors['dob'],
                  validator: FormValidator.dob,
                  inputFormatters: [DateInputFormatter()],
                  prefixIcon: GestureDetector(
                    onTap: () => controller.selectDate(context),
                    child: const Icon(Icons.calendar_today, size: 20),
                  ),
                )),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: AppInputTextField(
                        controller: controller.heightCtrl,
                        label: "height".tr,
                        hintText: "Enter height",
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppInputTextField(
                        controller: controller.weightCtrl,
                        label: "weight".tr,
                        hintText: "Enter weight",
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                Obx(() => SelectionTile(
                  label: "complexion".tr,
                  value: controller.complexion.value,
                  icon: Icons.face,
                  onTap: () => _showSingleSelectBottomSheet(
                      context, "Select Complexion", controller.complexionList, controller.complexion.call),
                )),
                const SizedBox(height: 12),

                Obx(() => SelectionTile(
                  label: "marital_status".tr,
                  value: controller.maritalStatus.value,
                  icon: Icons.favorite_border,
                  onTap: () => _showSingleSelectBottomSheet(
                      context, "Marital Status", controller.maritalStatusList, controller.maritalStatus.call),
                )),
                const SizedBox(height: 12),

                Obx(() => SelectionTile(
                  label: "physical_status".tr,
                  value: controller.physicalStatus.value,
                  icon: Icons.accessibility_new,
                  onTap: () => _showSingleSelectBottomSheet(
                      context, "Physical Status", controller.physicalStatusList, controller.physicalStatus.call),
                )),
                const SizedBox(height: 12),

                Obx(() => SelectionTile(
                  label: "mother_tongue".tr,
                  value: controller.language.value,
                  icon: Icons.language,
                  onTap: () => _showSingleSelectBottomSheet(
                      context, "Language", controller.languageList, controller.language.call),
                )),
                const SizedBox(height: 12),

                Obx(() => SelectionTile(
                  label: "citizenship".tr,
                  value: controller.citizenship.value,
                  icon: Icons.flag_outlined,
                  onTap: () => _showSingleSelectBottomSheet(
                      context, "Citizenship", controller.citizenshipList, controller.citizenship.call),
                )),
                const SizedBox(height: 12),
                Obx(() => SelectionTile(
                  label: "blood_group".tr,
                  value: controller.bloodGroup.value,
                  icon: Icons.bloodtype,
                  onTap: () => _showSingleSelectBottomSheet(
                      context, "Blood Group", controller.bloodGroupList, controller.bloodGroup.call),
                )),
                const SizedBox(height: 12),
                AppInputTextField(
                  controller: controller.ref_nameCtrl,
                  label: "referral_name".tr,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Step 2: Religious & Horoscope
  Widget _buildReligiousStep(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepHeader("religious_horoscope".tr, "religious_horoscope_sub".tr),

        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: context.theme.dividerColor.withValues(alpha: 0.1))),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Obx(() => SelectionTile(
                  label: "caste".tr, // Formerly Religion
                  value: controller.religion.value,
                  icon: Icons.group_work,
                  isRequired: true,
                  errorText: controller.errors['religion'],
                  onTap: () => _showSingleSelectBottomSheet(
                      context,
                      "Select Caste",
                      controller.casteList.map((e) => e.name ?? "").toList(),
                      controller.onCasteSelected
                  ),
                )),
                const SizedBox(height: 12),

                Obx(() => SelectionTile(
                  label: "subcaste".tr, // Formerly Caste
                  value: controller.casteCtrl.text, // Using controller text
                  icon: Icons.subdirectory_arrow_right,
                  isRequired: true,
                  errorText: controller.errors['caste'],
                  onTap: () {
                    if (controller.casteList.isEmpty) {
                      CustomSnackBar.showError(message: "Please select Caste first");
                      return;
                    }
                    _showSingleSelectBottomSheet(
                        context,
                        "Select Sub-Caste",
                        controller.subCasteList.map((e) => e.name ?? "").toList(),
                        controller.onSubCasteSelected
                    );
                  },
                )),
                const SizedBox(height: 12),

                Obx(() => SelectionTile(
                  label: "star".tr,
                  value: controller.star.value,
                  icon: Icons.star_border,
                  onTap: () => _showSingleSelectBottomSheet(
                      context, "Star", controller.starList, controller.star.call),
                )),
                const SizedBox(height: 12),

                Obx(() => SelectionTile(
                  label: "raasi".tr,
                  value: controller.raasi.value,
                  icon: Icons.nightlight_round,
                  onTap: () => _showSingleSelectBottomSheet(
                      context, "Raasi", controller.raasiList, controller.raasi.call),
                )),
                const SizedBox(height: 12),

                Obx(() => SelectionTile(
                  label: "manglik".tr,
                  value: controller.manglik.value,
                  icon: Icons.warning_amber_rounded,
                  onTap: () => _showSingleSelectBottomSheet(
                      context, "Manglik", controller.manglikList, controller.manglik.call),
                )),
                const SizedBox(height: 12),

                Obx(() => SelectionTile(
                  label: "dosh".tr,
                  value: controller.dosh.value,
                  icon: Icons.error_outline,
                  onTap: () => _showSingleSelectBottomSheet(
                      context, "Dosh", controller.doshList, controller.dosh.call),
                )),
                const SizedBox(height: 24),

                // Photos Section
                _buildSectionHeader("Photos (Up to 5)"),
                Obx(() {
                  final totalExisting = controller.existingPhotos.length;
                  final totalSelected = controller.selectedPhotos.length;
                  final totalPhotos = totalExisting + totalSelected;

                  if (totalPhotos == 0) {
                    return GestureDetector(
                      onTap: controller.pickPhotos,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        decoration: BoxDecoration(
                          color: context.theme.primaryColor.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: context.theme.primaryColor.withValues(alpha: 0.3),
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.add_photo_alternate_outlined,
                                size: 40, color: context.theme.primaryColor),
                            const SizedBox(height: 8),
                            Text(
                              "Tap to upload photos",
                              style: context.textTheme.bodyMedium?.copyWith(
                                color: context.theme.primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Max size 2MB, Formats: JPG, PNG",
                              style: context.textTheme.bodySmall?.copyWith(
                                color: context.theme.primaryColor.withValues(alpha: 0.7),
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return SizedBox(
                    height: 100,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: totalPhotos < 5 ? totalPhotos + 1 : 5,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        // "Add Photo" button at the end
                        if (index == totalPhotos) {
                          return GestureDetector(
                            onTap: controller.pickPhotos,
                            child: Container(
                              width: 100,
                              decoration: BoxDecoration(
                                color: context.theme.primaryColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: context.theme.primaryColor.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Icon(Icons.add_a_photo, color: context.theme.primaryColor),
                            ),
                          );
                        }

                        // Display existing (network) photos first
                        if (index < totalExisting) {
                          final photoUrl = controller.existingPhotos[index];
                          return Stack(
                            children: [
                              GestureDetector(
                                onTap: () => Get.to(() => FullScreenImageViewer(
                                  imageUrl: ApiConstants.imageBaseUrl + photoUrl,
                                  tag: 'matrimony_existing_$index',
                                )),
                                child: Hero(
                                  tag: 'matrimony_existing_$index',
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      ApiConstants.imageBaseUrl + photoUrl,
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                      errorBuilder: (ctx, err, stack) => Container(
                                        width: 100,
                                        height: 100,
                                        color: Colors.grey[200],
                                        child: const Icon(Icons.error_outline, color: Colors.grey),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: GestureDetector(
                                  onTap: () => controller.removeExistingPhoto(index),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.delete_outline, size: 14, color: Colors.white),
                                  ),
                                ),
                              ),
                              // Badge indicating "Server Photo"
                              Positioned(
                                bottom: 4,
                                right: 4,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text("Saved", style: TextStyle(color: Colors.white, fontSize: 8)),
                                ),
                              ),
                            ],
                          );
                        }

                        // Display newly selected (local file) photos
                        final localIndex = index - totalExisting;
                        return Stack(
                          children: [
                            GestureDetector(
                              onTap: () => Get.to(() => FullScreenImageViewer(
                                imageFile: controller.selectedPhotos[localIndex],
                                tag: 'matrimony_local_$localIndex',
                              )),
                              child: Hero(
                                tag: 'matrimony_local_$localIndex',
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.file(
                                    controller.selectedPhotos[localIndex],
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: () => controller.removePhoto(localIndex),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.close, size: 14, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Step 3: Education & Career
  Widget _buildEducationCareerStep(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepHeader("education_career".tr, "education_career_sub".tr),

        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: context.theme.dividerColor.withValues(alpha: 0.1))),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Obx(() => SelectionTile(
                  label: "highest_qualification".tr,
                  value: controller.education.value,
                  icon: Icons.school_outlined,
                  isRequired: true,
                  errorText: controller.errors['education'],
                  onTap: () => _showSingleSelectBottomSheet(
                      context, "Highest Qualification", controller.educationList, controller.education.call),
                )),
                const SizedBox(height: 12),

                AppInputTextField(
                  controller: controller.collegeCtrl,
                  label: "college".tr,
                ),
                const SizedBox(height: 12),

                Obx(() => SelectionTile(
                  label: "employment_type".tr,
                  value: controller.employmentType.value,
                  icon: Icons.work_outline,
                  isRequired: true,
                  errorText: controller.errors['employmentType'],
                  onTap: () => _showSingleSelectBottomSheet(
                      context, "Employment Type", controller.employmentTypeList, controller.employmentType.call),
                )),
                const SizedBox(height: 12),

                Obx(() => controller.employmentType.value == 'Not Working'
                    ? const SizedBox.shrink()
                    : Column(
                  children: [
                    AppInputTextField(
                      controller: controller.jobTitleCtrl,
                      label: "job_title".tr,
                    ),
                    const SizedBox(height: 12),

                    AppInputTextField(
                      controller: controller.companyCtrl,
                      label: "company_name".tr,
                    ),
                    const SizedBox(height: 12),

                    AppInputTextField(
                      controller: controller.annualIncomeCtrl,
                      label: "annual_income".tr,
                      hintText: "e.g. 4 Lakh",
                      textInputType: TextInputType.number,
                    ),
                  ],
                ),

                  //   children: [
                  //     AppInputTextField(
                  //       controller: controller.jobTitleCtrl,
                  //       label: "job_title".tr,
                  //     ),
                  //     const SizedBox(height: 12),
                  //
                  //     AppInputTextField(
                  //       controller: controller.companyCtrl,
                  //       label: "company_name".tr,
                  //     ),
                  //     const SizedBox(height: 12),
                  //
                  //     AppInputTextField(
                  //       controller: controller.annualIncomeCtrl,
                  //       label: "annual_income".tr,
                  //       hintText: "annual_income".tr,
                  //       textInputType: TextInputType.number,
                  //     ),
                  //   ],
                  // ),

                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Step 4: Family, Lifestyle & Location
  Widget _buildFamilyLocationStep(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepHeader("family_lifestyle".tr, "family_lifestyle_sub".tr),

        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: context.theme.dividerColor.withValues(alpha: 0.1))),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Family
                Obx(() => SelectionTile(
                  label: "family_type".tr,
                  value: controller.familyType.value,
                  icon: Icons.family_restroom,
                  isRequired: true,
                  errorText: controller.errors['familyType'],
                  onTap: () => _showSingleSelectBottomSheet(
                      context, "Family Type", controller.familyTypeList, controller.familyType.call),
                )),
                const SizedBox(height: 12),

                Obx(() => SelectionTile(
                  label: "family_class".tr,
                  value: controller.familyClass.value,
                  icon: Icons.monetization_on_outlined,
                  onTap: () => _showSingleSelectBottomSheet(
                      context, "Family Class", controller.familyClassList, controller.familyClass.call),
                )),
                const SizedBox(height: 12),

                Obx(() => SelectionTile(
                  label: "family_value".tr,
                  value: controller.familyValue.value,
                  icon: Icons.volunteer_activism,
                  onTap: () => _showSingleSelectBottomSheet(
                      context, "Family Value", controller.familyValueList, controller.familyValue.call),
                )),
                const SizedBox(height: 12),

                AppInputTextField(
                  controller: controller.fatherOccupationCtrl,
                  label: "father_occupation".tr,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 12),
                AppInputTextField(
                  controller: controller.motherOccupationCtrl,
                  label: "mother_occupation".tr,
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: 20),

                // Lifestyle
                _buildSectionHeader("lifestyle".tr),
                Obx(() => SelectionTile(
                  label: "diet".tr,
                  value: controller.diet.value,
                  icon: Icons.restaurant,
                  onTap: () => _showSingleSelectBottomSheet(
                      context, "Diet", controller.dietList, controller.diet.call),
                )),
                const SizedBox(height: 12),
                Obx(() => SelectionTile(
                  label: "smoking".tr,
                  value: controller.smoking.value,
                  icon: Icons.smoking_rooms,
                  onTap: () => _showSingleSelectBottomSheet(
                      context, "Smoking", controller.smokingList, controller.smoking.call),
                )),
                const SizedBox(height: 12),
                Obx(() => SelectionTile(
                  label: "drinking".tr,
                  value: controller.drinking.value,
                  icon: Icons.local_bar,
                  onTap: () => _showSingleSelectBottomSheet(
                      context, "Drinking", controller.drinkingList, controller.drinking.call),
                )),
                const SizedBox(height: 20),

                // Location
                _buildSectionHeader("location".tr),
                AppInputTextField(
                  controller: controller.addressCtrl,
                  label: "address".tr,
                  textInputType: TextInputType.streetAddress,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 12),
                Obx(() => AppInputTextField(
                  controller: controller.pinCodeCtrl,
                  label: "pincode".tr,
                  isRequired: true,
                  validator: (val) => controller.errors['pincode'],
                  textInputType: TextInputType.number,
                  textInputAction: TextInputAction.next,
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
                const SizedBox(height: 12),
                AppInputTextField(
                  controller: controller.talukaCtrl,
                  label: "taluka".tr,
                  textInputType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 12),
                Obx(() => SelectionTile(
                  label: "country".tr,
                  value: controller.country.value,
                  icon: Icons.public,
                  isRequired: true,
                  errorText: controller.errors['country'],
                  onTap: () => _showSingleSelectBottomSheet(
                      context, "Country", controller.countryList, controller.onCountryChanged),
                )),
                const SizedBox(height: 12),
                Obx(() => SelectionTile(
                  label: "state".tr,
                  value: controller.state.value,
                  icon: Icons.map,
                  isRequired: true,
                  errorText: controller.errors['state'],
                  onTap: () => _showSingleSelectBottomSheet(
                      context, "State", controller.stateList, controller.state.call),
                )),
                const SizedBox(height: 12),
                Obx(() => AppInputTextField(
                  controller: controller.cityCtrl,
                  label: "city".tr,
                  isRequired: true,
                  validator: (val) => controller.errors['city'],
                  textInputAction: TextInputAction.done,
                )),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 🔽 Helper Widgets & Methods
  Widget _buildStepHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Get.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          subtitle,
          style: Get.textTheme.bodyMedium?.copyWith(color: Colors.grey),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: Get.textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          color: Get.theme.primaryColor,
        ),
      ),
    );
  }

  void _showSingleSelectBottomSheet(
      BuildContext context,
      String title,
      List<String> options,
      ValueChanged<String> onSelected
      ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        List<String> filteredItems = List.from(options);
        final bool showSearch = options.length > 5;

        return StatefulBuilder(
          builder: (context, setState) {
            final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.85,
              ),
              padding: EdgeInsets.only(bottom: bottomPadding),
              decoration: BoxDecoration(
                color: context.theme.scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Handle bar
                    Container(
                      margin: const EdgeInsets.only(top: 12, bottom: 8),
                      width: 48,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),

                    // Premium Header
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 8, 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              "Select $title",
                              style: context.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.grey.shade300, width: 1),
                              ),
                              child: const Icon(Icons.close, color: Colors.grey, size: 20),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1, thickness: 1, color: Color(0xFFF0F0F0)),

                    // Search Bar
                    if (showSearch)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: TextField(
                          autofocus: false,
                          decoration: InputDecoration(
                            hintText: "Search $title...",
                            hintStyle: TextStyle(color: Colors.grey[400]),
                            prefixIcon: Icon(Icons.search, size: 20, color: Colors.grey[400]),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: Colors.grey[200]!),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: Colors.grey[200]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: context.theme.primaryColor, width: 1.5),
                            ),
                            contentPadding: const EdgeInsets.symmetric(vertical: 14),
                            fillColor: const Color(0xFFF9F9F9),
                            filled: true,
                          ),
                          onChanged: (value) {
                            setState(() {
                              filteredItems = options
                                  .where((item) => item.toLowerCase().contains(value.toLowerCase()))
                                  .toList();
                            });
                          },
                        ),
                      ),

                    Flexible(
                      child: filteredItems.isEmpty
                          ? const Padding(
                        padding: EdgeInsets.all(40.0),
                        child: Text("No results found"),
                      )
                          : ListView.separated(
                        shrinkWrap: true,
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                        itemCount: filteredItems.length,
                        separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFF0F0F0)),
                        itemBuilder: (context, index) {
                          final option = filteredItems[index];
                          // We check if this option is selected using a simple string match
                          // Note: For better accuracy, we could pass current value to this method

                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            title: Text(
                              option,
                              style: context.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            trailing: const Icon(Icons.radio_button_unchecked, color: Colors.grey),
                            onTap: () {
                              onSelected(option);
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}



/*Widget _buildProgressIndicator(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      decoration: BoxDecoration(
        color: context.theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(4, (index) {
            final isCompleted = index < controller.currentStep.value;
            final isActive = index == controller.currentStep.value;

            return
              Expanded(
              child:
              Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCompleted || isActive
                          ? context.theme.primaryColor
                          : context.theme.dividerColor.withValues(alpha: 0.5),
                    ),
                    child: Center(
                      child: isCompleted
                          ? const Icon(Icons.check, size: 16, color: Colors.white)
                          : Text(
                              "${index + 1}",
                              style: TextStyle(
                                color: isCompleted || isActive
                                    ? Colors.white
                                    : context.theme.iconTheme.color,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  if (index < 3)
                    Expanded(
                      child: Container(
                        height: 2,
                        color: index < controller.currentStep.value
                            ? context.theme.primaryColor
                            : context.theme.dividerColor.withValues(alpha: 0.5),
                      ),
                    ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }*/