import 'package:edu_cluezer/features/matrimony/presentation/controller/reg_matrimony_controller.dart';
import 'package:edu_cluezer/widgets/basic_text_field.dart';
import 'package:edu_cluezer/widgets/custom_buttons.dart';
import 'package:edu_cluezer/widgets/custom_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../common/widgets/option_selector.dart';
import '../../../../core/helper/form_validator.dart';
import '../../../../core/utils/app_assets.dart';
import '../controller/volunteerUpdateProfileController.dart';

class CreateVolunteerScreen extends GetWidget<VoluntProfileUpdateController> {
  const CreateVolunteerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: Get.back,
          child: Icon(Icons.arrow_back_ios_rounded, color: context.iconColor),
        ),
        title: Text("Update Your Profile", style: context.textTheme.headlineLarge),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Update your volunteer information",
              style: context.textTheme.titleMedium,
            ),

            const SizedBox(height: 16),

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

            SingleDropdown(
              controller: controller.experienceCtrl,
              label: "Experience Level",
              items: controller.expLevel,
            ),

            SingleDropdown(
              controller: controller.experienceCtrl,
              label: "Availability",
              items: controller.availabilities,
            ),

            AppInputTextField(
              label: "Location ",
              hintText: "Lucknow",
              textInputType: TextInputType.text,
              //controller: controller.mobileController,
              validator: FormValidator.jobTitle,
            ),

            // ================ Benefits & Perks Section ================
            const SectionTitle("Interests"),

            // Add Custom Benefit
            AppInputTextField(
              controller: controller.benefitsCtrl,
              label: "Add Interests ",
              hintText: "Enter a Interests (e.g., Gaming, Coding)",
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
                    "Selected Interests:",
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
              "Popular Interests:",
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