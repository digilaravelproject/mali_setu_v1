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
        title: const Text("Create Job Posting"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Job Details", style: context.textTheme.displaySmall),
            Text(
              "Fill in the details to create your job posting",
              style: context.textTheme.labelMedium,
            ),

            const SizedBox(height: 16),
            const SectionTitle("Basic Information"),

            AppInputTextField(
              label: "Job Title ",
              hintText: "Senior Flutter Developer",
              textInputType: TextInputType.text,
              //controller: controller.mobileController,
              validator: FormValidator.jobTitle,
            ),

            AppInputTextField(
              label: "Job Description",
              hintText: "Describe the role, responsibility",
              textInputType: TextInputType.text,
              //controller: controller.mobileController,
              maxLines: 4,
              // validator: FormValidator.jobDescription(),
              validator: (value) =>
                  FormValidator.jobDescription(value, "Job Description"),
            ),

            AppInputTextField(
              label: "Requirements",
              hintText: "List the required skills, qualifications",
              textInputType: TextInputType.text,
              //controller: controller.mobileController,
              maxLines: 4,
              validator: (value) =>
                  FormValidator.jobDescription(value, "Requirements"),
            ),

            const SizedBox(height: 16),

            const SectionTitle("Job Details"),
            AppInputTextField(
              label: "Salary Range",
              hintText: "₹5,000-₹5,000 per month",
              textInputType: TextInputType.text,
              //controller: controller.mobileController,
              //validator: FormValidator.name,
            ),
            SingleDropdown(
              controller: controller.jobTypeCtrl,
              label: "Job Type",
              items: controller.jobTypes,
            ),
            AppInputTextField(
              label: "Location",
              hintText: "Lucknow",
              textInputType: TextInputType.text,
              //controller: controller.mobileController,
              //validator: FormValidator.name,
            ),
            SingleDropdown(
              controller: controller.experienceCtrl,
              label: "Experience Level",
              items: controller.expLevel,
            ),
            SingleDropdown(
              controller: controller.employmentCtrl,
              label: "Employment Type",
              items: controller.employmentTypes,
            ),
            SingleDropdown(
              controller: controller.smokingCtrl,
              label: "Category",
              items: controller.categories,
            ),

            const SizedBox(height: 16),

            // ================ Benefits & Perks Section ================
            const SectionTitle("Benefits & Perks"),

            // Add Custom Benefit
            AppInputTextField(
              controller: controller.benefitsCtrl,
              label: "Add Benefits *",
              hintText: "Enter a benefit (e.g., Health insurance)",
              textInputType: TextInputType.text,
            ),

            const SizedBox(height: 16),
            CustomButton(
              title: "+ Add",
              height: 40,
              onPressed: controller.addCustomBenefit,
            ),

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
                          style: context.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: controller.selectedBenefits
                              .map(
                                (benefit) => Chip(
                                  label: Text(benefit),
                                  deleteIcon: const Icon(Icons.close, size: 16),
                                  onDeleted: () =>
                                      controller.removeBenefit(benefit),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ),
            ),

            // Popular Benefits
            const SizedBox(height: 16),
            Text(
              "Popular Benefits:",
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: controller.popularBenefits
                  .map(
                    (benefit) => FilterChip(
                      label: Text(benefit),
                      selected: controller.selectedBenefits.contains(benefit),
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
            ),

            const SizedBox(height: 16),

            // ================ Skills Required Section ================

            const SectionTitle("Skills Required"),

            // Add Custom Skill
            AppInputTextField(
              controller: controller.skillsCtrl,
              label: "Add Skills ",
              hintText: "Enter a skill (e.g., PHP, Laravel)",
              textInputType: TextInputType.text,
            ),

            const SizedBox(height: 16),
            CustomButton(
              title: "+ Add",
              height: 40,
              onPressed: controller.addCustomSkill,
            ),

            // Selected Benefits List
            Obx(
                  () => controller.selectedSkills.isEmpty
                  ? const SizedBox()
                  : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  Text(
                    "Selected Skills:",
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: controller.selectedSkills
                        .map(
                          (skill) => Chip(
                        label: Text(skill),
                        deleteIcon: const Icon(Icons.close, size: 16),
                        onDeleted: () =>
                            controller.removeSkill(skill),
                      ),
                    )
                        .toList(),
                  ),
                ],
              ),
            ),

            // Popular Skills
            const SizedBox(height: 16),
            Text(
              "Quick Add Skills:",
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: controller.popularSkills
                  .map(
                    (skill) => FilterChip(
                  label: Text(skill),
                  selected: controller.selectedSkills.contains(skill),
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
            ),

            const SizedBox(height: 16),

            const SectionTitle("Do you have any dosh ?"),
            Obx(
              () => OptionSelector(
                options: const ['YES', 'NO', 'Unknown'],
                selectedValue: controller.dosh.value,
                onSelected: controller.dosh.call,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: CustomButton(
          title: "Post Job Now",
          onPressed: controller.onRegister,
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: context.textTheme.titleLarge?.copyWith(
        color: context.theme.primaryColor,
      ),
    ).marginOnly(bottom: 4);
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
    );
  }
}
