import 'package:edu_cluezer/features/matrimony/presentation/controller/reg_matrimony_controller.dart';
import 'package:edu_cluezer/widgets/basic_text_field.dart';
import 'package:edu_cluezer/widgets/custom_buttons.dart';
import 'package:edu_cluezer/widgets/custom_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../common/widgets/option_selector.dart';
import '../../../../core/helper/form_validator.dart';
import '../../../../core/utils/app_assets.dart';
import '../controller/create_job_controller.dart';

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
        title: Obx(() => Text(controller.isEditMode.value ? "Update Job Posting" : "Create Job Posting")),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(controller.isEditMode.value ? "Edit Job Details" : "Job Details", style: context.textTheme.displaySmall),
            Text(
              controller.isEditMode.value 
                  ? "Update the information for your job posting" 
                  : "Fill in the details to create your job posting",
              style: context.textTheme.labelMedium,
            ),

            const SizedBox(height: 16),
            const SectionTitle("Basic Information"),

            AppInputTextField(
              label: "Job Title ",
              hintText: "Job title",
              textInputType: TextInputType.text,
              controller: controller.titleCtrl,
              validator: FormValidator.jobTitle,
            ),

            AppInputTextField(
              label: "Job Description",
              hintText: "Describe the role, responsibility",
              textInputType: TextInputType.text,
              controller: controller.descriptionCtrl,
              maxLines: 4,
              // validator: FormValidator.jobDescription(),
              validator: (value) =>
                  FormValidator.jobDescription(value, "Job Description"),
            ),

            AppInputTextField(
              label: "Requirements",
              hintText: "List the required skills, qualifications",
              textInputType: TextInputType.text,
              controller: controller.requirementsCtrl,
              maxLines: 4,
              validator: (value) =>
                  FormValidator.jobDescription(value, "Requirements"),
            ),

            const SizedBox(height: 16),

            const SectionTitle("Job Details"),
            AppInputTextField(
              label: "Salary Range",
              hintText: "₹5,000 - ₹50,000 per month",
              textInputType: TextInputType.text,
              controller: controller.salaryRangeCtrl,
              validator: (v) => v!.isEmpty ? "Salary range is required" : null,
            ),
            SingleDropdown(
              controller: controller.jobTypeCtrl,
              label: "Job Type",
              items: CreateJobController.JOB_TYPES,
            ),
            AppInputTextField(
              label: "Location",
              hintText: "City name (e.g., Lucknow)",
              textInputType: TextInputType.text,
              controller: controller.locationCtrl,
              validator: (v) => v!.isEmpty ? "Location is required" : null,
            ),
            SingleDropdown(
              controller: controller.experienceCtrl,
              label: "Experience Level",
              items: CreateJobController.EXP_LEVELS,
            ),
            SingleDropdown(
              controller: controller.employmentCtrl,
              label: "Employment Type",
              items: CreateJobController.EMPLOYMENT_TYPES,
            ),
            SingleDropdown(
              controller: controller.categoryCtrl,
              label: "Job Category",
              items: CreateJobController.CATEGORIES,
            ),

            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => controller.selectDate(context, controller.deadlineCtrl),
                    child: AbsorbPointer(
                      child: AppInputTextField(
                        label: "Application Deadline",
                        hintText: "YYYY-MM-DD",
                        controller: controller.deadlineCtrl,
                        validator: (v) => v!.isEmpty ? "Deadline is required" : null,
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
                        label: "Job Expiry Date",
                        hintText: "YYYY-MM-DD",
                        controller: controller.expiryCtrl,
                        validator: (v) => v!.isEmpty ? "Expiry date is required" : null,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ================ Benefits & Perks Section ================
            const SectionTitle("Benefits & Perks"),

            // Add Custom Benefit
            Row(
              children: [
                Expanded(
                  child: AppInputTextField(
                    controller: controller.benefitsCtrl,
                    label: "Add Benefit",
                    hintText: "e.g., Health insurance",
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
              "Quick Add Benefits:",
              style: context.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: context.theme.hintColor,
              ),
            ),
            const SizedBox(height: 8),
            Obx(() => Wrap(
              spacing: 8,
              runSpacing: 0,
              children: CreateJobController.POPULAR_BENEFITS
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
                          "Selected Benefits:",
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

            const SectionTitle("Skills Required"),

            // Add Custom Skill
            Row(
              children: [
                Expanded(
                  child: AppInputTextField(
                    controller: controller.skillsCtrl,
                    label: "Add Skill",
                    hintText: "e.g., Flutter, Laravel",
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
              "Quick Add Skills:",
              style: context.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: context.theme.hintColor,
              ),
            ),
            const SizedBox(height: 8),
            Obx(() => Wrap(
              spacing: 8,
              runSpacing: 0,
              children: CreateJobController.POPULAR_SKILLS
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
                    "Selected Skills:",
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
      bottomNavigationBar: BottomAppBar(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Obx(() => CustomButton(
          title: controller.isEditMode.value ? "Update Job" : "Post Job Now",
          isLoading: controller.isLoading.value,
          onPressed: controller.onRegister,
        )),
      ),
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

  const SingleDropdown({
    super.key,
    required this.controller,
    required this.items,
    this.label,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return AppInputTextField(
      controller: controller,
      label: label ?? "No Label",
      isDropdown: true,
      dropdownItems: items,
      validator: (v) => (v == null || v.isEmpty) ? "${label ?? 'Field'} is required" : null,
    );
  }
}
