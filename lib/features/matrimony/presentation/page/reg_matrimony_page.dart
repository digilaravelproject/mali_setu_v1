import 'package:edu_cluezer/features/matrimony/presentation/controller/reg_matrimony_controller.dart';
import 'package:edu_cluezer/widgets/basic_text_field.dart';
import 'package:edu_cluezer/widgets/custom_buttons.dart';
import 'package:edu_cluezer/widgets/custom_scaffold.dart';
import 'package:edu_cluezer/widgets/custom_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../common/widgets/selection_tile.dart';
import '../../../../core/utils/app_assets.dart';

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
        title:  Text("register_matrimony".tr),
      ),
      body: Obx(
        () => Column(
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
      ),
      bottomNavigationBar: Obx(
        () => BottomAppBar(
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
                  title: controller.currentStep.value == 3 ? "register".tr : "next".tr,
                  onPressed: controller.currentStep.value == 3
                      ? controller.onRegister
                      : controller.nextStep,
                ),
              ),
            ],
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
                AppInputTextField(
                  controller: controller.nameCtrl,
                  label: "full_name".tr,
                ),
                const SizedBox(height: 12),
                
                Obx(() => SelectionTile(
                  label: "profile_created_by".tr,
                  value: controller.profileCreatedBy.value,
                  icon: Icons.person_add_alt,
                  onTap: () => _showSingleSelectBottomSheet(
                      context, "Created By", controller.profileCreatedByList, controller.profileCreatedBy.call),
                )),
                const SizedBox(height: 12),

                Obx(() => SelectionTile(
                  label: "gender".tr,
                  value: controller.gender.value,
                  icon: Icons.person_outline,
                  onTap: () => _showSingleSelectBottomSheet(
                      context, "Gender", controller.genderList, controller.gender.call),
                )),
                const SizedBox(height: 12),

                Obx(() => SelectionTile(
                  label: "date_of_birth".tr,
                  value: controller.rxDob.value,
                  icon: Icons.calendar_today,
                  onTap: () => controller.selectDate(context),
                )),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: AppInputTextField(
                        controller: controller.heightCtrl,
                        label: "height".tr,
                        hintText: "5.6",
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppInputTextField(
                        controller: controller.weightCtrl,
                        label: "weight".tr,
                        hintText: "65",
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
                  label: "language".tr,
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
                AppInputTextField(
                  controller: controller.bloodGroupCtrl,
                  label: "blood_group".tr,
                ),
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
                  label: "Caste", // Formerly Religion
                  value: controller.religion.value,
                  icon: Icons.group_work, 
                  onTap: () => _showSingleSelectBottomSheet(
                      context, 
                      "Select Caste", 
                      controller.casteList.map((e) => e.name ?? "").toList(), 
                      controller.onCasteSelected
                  ),
                )),
                const SizedBox(height: 12),
                
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: controller.casteCtrl,
                  builder: (context, value, child) {
                    return SelectionTile(
                      label: "Sub-Caste", // Formerly Caste
                      value: value.text, // Using text controller value for display in tile
                      icon: Icons.subdirectory_arrow_right,
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
                    );
                  }
                ),
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
                  onTap: () => _showSingleSelectBottomSheet(
                      context, "Employment Type", controller.employmentTypeList, controller.employmentType.call),
                )),
                const SizedBox(height: 12),

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
                  hintText: "annual_income".tr,
                  textInputType: TextInputType.number,
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
                ),
                const SizedBox(height: 12),
                 AppInputTextField(
                  controller: controller.motherOccupationCtrl,
                  label: "mother_occupation".tr,
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
                 Obx(() => SelectionTile(
                  label: "country".tr,
                  value: controller.country.value,
                  icon: Icons.public,
                  onTap: () => _showSingleSelectBottomSheet(
                      context, "Country", controller.countryList, controller.country.call),
                )),
                const SizedBox(height: 12),
                 Obx(() => SelectionTile(
                  label: "state".tr,
                  value: controller.state.value,
                  icon: Icons.map,
                  onTap: () => _showSingleSelectBottomSheet(
                      context, "State", controller.stateList, controller.state.call),
                )),
                const SizedBox(height: 12),
                 AppInputTextField(
                  controller: controller.cityCtrl,
                  label: "city".tr,
                ),
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
      builder: (context) => Container(
        height: Get.height * 0.6,
        decoration: BoxDecoration(
          color: context.theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.theme.dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: options.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final option = options[index];
                  return ListTile(
                    title: Text(
                      option,
                      style: context.textTheme.bodyLarge,
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                    onTap: () {
                      onSelected(option);
                      Get.back();
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: context.theme.dividerColor.withValues(alpha: 0.1)),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
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