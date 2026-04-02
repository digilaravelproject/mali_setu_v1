import 'package:edu_cluezer/features/matrimony/presentation/controller/reg_matrimony_controller.dart';
import 'package:edu_cluezer/widgets/basic_text_field.dart';
import 'package:edu_cluezer/widgets/custom_buttons.dart';
import 'package:edu_cluezer/widgets/custom_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:edu_cluezer/common/widgets/option_selector.dart';
import 'package:edu_cluezer/core/helper/form_validator.dart';
import 'package:edu_cluezer/core/utils/app_assets.dart';
import 'package:edu_cluezer/features/business/presentation/controller/create_job_controller.dart';

class CreateJobPage extends GetWidget<CreateJobController> {
  const CreateJobPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: Get.back,
          icon: Icon(AppAssets.backArrow),
        ),
        title: Obx(() => Text(controller.isEditMode.value ? 'update_job_posting'.tr : 'create_job_posting'.tr)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(controller.isEditMode.value ? 'edit_job_details'.tr : 'job_details'.tr, style: context.textTheme.displaySmall),
            Text(
              controller.isEditMode.value 
                  ? 'update_job_info'.tr
                  : 'fill_job_details'.tr,
              style: context.textTheme.labelMedium,
            ),

            const SizedBox(height: 16),
            SectionTitle('basic_information'.tr),

            AppInputTextField(
              label: 'job_title'.tr,
              isRequired: true,
              hintText: 'job_title_hint'.tr,
              textInputType: TextInputType.text,
              controller: controller.titleCtrl,
              validator: FormValidator.jobTitle,
            ),

            AppInputTextField(
              label: 'job_description'.tr,
              isRequired: true,
              hintText: 'job_description_hint'.tr,
              textInputType: TextInputType.text,
              controller: controller.descriptionCtrl,
              maxLines: 4,
              validator: (value) =>
                  FormValidator.jobDescription(value, 'job_description'.tr),
            ),

            AppInputTextField(
              label: 'requirements'.tr,
              isRequired: true,
              hintText: 'requirements_hint'.tr,
              textInputType: TextInputType.text,
              controller: controller.requirementsCtrl,
              maxLines: 4,
              validator: (value) =>
                  FormValidator.jobDescription(value, 'requirements'.tr),
            ),

            const SizedBox(height: 16),

            SectionTitle('job_details'.tr),
            AppInputTextField(
              label: 'salary_range'.tr,
              isRequired: true,
              hintText: 'salary_range_hint'.tr,
              textInputType: TextInputType.text,
              controller: controller.salaryRangeCtrl,
              validator: (v) => v!.isEmpty ? 'salary_required'.tr : null,
            ),
            SingleDropdown(
              controller: controller.jobTypeCtrl,
              label: 'job_type'.tr,
              isRequired: true,
              items: controller.getJobTypes(),
            ),
            AppInputTextField(
              label: 'location'.tr,
              isRequired: true,
              hintText: 'location_hint'.tr,
              textInputType: TextInputType.text,
              controller: controller.locationCtrl,
              validator: (v) => v!.isEmpty ? 'location_required'.tr : null,
            ),
            SingleDropdown(
              controller: controller.experienceCtrl,
              label: 'experience_level'.tr,
              isRequired: true,
              items: controller.getExperienceLevels(),
            ),
            SingleDropdown(
              controller: controller.employmentCtrl,
              label: 'employment_type'.tr,
              isRequired: true,
              items: controller.getEmploymentTypes(),
            ),
            SingleDropdown(
              controller: controller.categoryCtrl,
              label: 'job_category'.tr,
              isRequired: true,
              items: controller.getCategories(),
              onOtherSelected: () => _showCustomCategoryDialog(context),
            ),

            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => controller.selectDate(context, controller.deadlineCtrl),
                    child: AbsorbPointer(
                      child: AppInputTextField(
                        label: 'application_deadline'.tr,
                        isRequired: true,
                        hintText: 'deadline_hint'.tr,
                        controller: controller.deadlineCtrl,
                        validator: (v) => v!.isEmpty ? 'deadline_required'.tr : null,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => controller.selectDate(context, controller.expiryCtrl),
                    child: AbsorbPointer(
                      child: AppInputTextField(
                        label: 'job_expiry_date'.tr,
                        isRequired: true,
                        hintText: 'deadline_hint'.tr,
                        controller: controller.expiryCtrl,
                        validator: (v) => v!.isEmpty ? 'expiry_required'.tr : null,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ================ Benefits & Perks Section ================
            SectionTitle('benefits_perks'.tr),

            // Add Custom Benefit
            Row(
              children: [
                Expanded(
                  child: AppInputTextField(
                    controller: controller.benefitsCtrl,
                    label: 'add_benefit'.tr,
                    hintText: 'benefit_hint'.tr,
                    textInputType: TextInputType.text,
                  ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(top: 25.0),
                  child: CustomButton(
                    title: "+",
                    width: 50,
                    height: 50,
                    onPressed: controller.addCustomBenefit,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            
            // Popular Benefits
            Text(
              'quick_add_benefits'.tr,
              style: context.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: context.theme.hintColor,
              ),
            ),
            const SizedBox(height: 8),
            Obx(() => Wrap(
              spacing: 8,
              runSpacing: 0,
              children: controller.getPopularBenefits()
                  .map(
                    (benefit) => FilterChip(
                      label: Text(benefit, style: TextStyle(fontSize: 12)),
                      selected: controller.selectedBenefits.contains(benefit),
                      selectedColor: context.theme.primaryColor.withOpacity(0.2),
                      checkmarkColor: context.theme.primaryColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      onSelected: (selected) {
                        if (selected) {
                          controller.addPopularBenefit(benefit);
                        } else {
                          controller.removeBenefit(benefit);
                        }
                      },
                    ),
                  )
                  .toList(),
            )),

            // Selected Benefits List
            Obx(
              () => controller.selectedBenefits.isEmpty
                  ? const SizedBox()
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),
                        Text(
                          'selected_benefits'.tr,
                          style: context.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: controller.selectedBenefits
                              .map(
                                (benefit) => Chip(
                                  label: Text(benefit),
                                  backgroundColor: context.theme.primaryColor.withOpacity(0.1),
                                  deleteIcon: const Icon(Icons.cancel, size: 18),
                                  onDeleted: () => controller.removeBenefit(benefit),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ),
            ),

            const SizedBox(height: 24),

            // ================ Skills Required Section ================

            SectionTitle('skills_required'.tr),

            // Add Custom Skill
            Row(
              children: [
                Expanded(
                  child: AppInputTextField(
                    controller: controller.skillsCtrl,
                    label: 'add_skill'.tr,
                    hintText: 'skill_hint'.tr,
                    textInputType: TextInputType.text,
                  ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(top: 25.0),
                  child: CustomButton(
                    title: "+",
                    width: 50,
                    height: 50,
                    onPressed: controller.addCustomSkill,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            
            // Popular Skills
            Text(
              'quick_add_skills'.tr,
              style: context.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: context.theme.hintColor,
              ),
            ),
            const SizedBox(height: 8),
            Obx(() => Wrap(
              spacing: 8,
              runSpacing: 0,
              children: controller.getPopularSkills()
                  .map(
                    (skill) => FilterChip(
                  label: Text(skill, style: TextStyle(fontSize: 12)),
                  selected: controller.selectedSkills.contains(skill),
                  selectedColor: context.theme.primaryColor.withOpacity(0.2),
                  checkmarkColor: context.theme.primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  onSelected: (selected) {
                    if (selected) {
                      controller.addPopularSkill(skill);
                    } else {
                      controller.removeSkill(skill);
                    }
                  },
                ),
              )
                  .toList(),
            )),

            // Selected Skills List
            Obx(
                  () => controller.selectedSkills.isEmpty
                  ? const SizedBox()
                  : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  Text(
                    'selected_skills'.tr,
                    style: context.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: controller.selectedSkills
                        .map(
                          (skill) => Chip(
                        label: Text(skill),
                        backgroundColor: context.theme.primaryColor.withOpacity(0.1),
                        deleteIcon: const Icon(Icons.cancel, size: 18),
                        onDeleted: () => controller.removeSkill(skill),
                      ),
                    )
                        .toList(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: BottomAppBar(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Obx(() => CustomButton(
            title: controller.isEditMode.value ? 'update_job'.tr : 'post_job_now'.tr,
            isLoading: controller.isLoading.value,
            onPressed: controller.onRegister,
          )),
        ),
      ),
    );
  }

  void _showCustomCategoryDialog(BuildContext context) {
    final customCategoryCtrl = TextEditingController();
    Get.dialog(
      AlertDialog(
        title: Text('enter_job_category'.tr),
        content: TextField(
          controller: customCategoryCtrl,
          decoration: InputDecoration(
            hintText: 'job_category_hint'.tr,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: Text('cancel'.tr),
          ),
          TextButton(
            onPressed: () {
              if (customCategoryCtrl.text.trim().isNotEmpty) {
                controller.categoryCtrl.text = customCategoryCtrl.text.trim();
                Get.back();
              }
            },
            child: Text('submit'.tr),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: context.textTheme.titleLarge?.copyWith(
            color: context.theme.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        Container(
          height: 2,
          width: 40,
          color: context.theme.primaryColor,
          margin: const EdgeInsets.only(top: 4, bottom: 16),
        ),
      ],
    );
  }
}

class SingleDropdown extends StatelessWidget {
  final TextEditingController controller;
  final String? label;
  final String? hint;
  final List<String> items;
  final bool isRequired;
  final VoidCallback? onOtherSelected;

  const SingleDropdown({
    super.key,
    required this.controller,
    required this.items,
    this.label,
    this.hint,
    this.isRequired = false,
    this.onOtherSelected,
  });

  @override
  Widget build(BuildContext context) {
    return AppInputTextField(
      controller: controller,
      label: label ?? 'no_label'.tr,
      isRequired: isRequired,
      isDropdown: true,
      dropdownItems: items,
      onOtherSelected: onOtherSelected,
      validator: (v) => (v == null || v.isEmpty) ? "${label ?? 'no_label'.tr} ${'field_required'.tr}" : null,
    );
  }
}
