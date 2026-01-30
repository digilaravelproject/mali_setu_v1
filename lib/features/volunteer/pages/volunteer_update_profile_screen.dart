import 'package:edu_cluezer/widgets/basic_text_field.dart';
import 'package:edu_cluezer/widgets/custom_buttons.dart';
import 'package:edu_cluezer/widgets/custom_scaffold.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/helper/form_validator.dart';
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
        title: Text(controller.isEdit.value ? "Update Your Profile" : "Create Your Profile", style: context.textTheme.headlineLarge),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                controller.isEdit.value ? "Update your volunteer information" : "Fill in your volunteer information",
                style: context.textTheme.titleMedium,
              ),

              const SizedBox(height: 16),

              // Bio Section
              AppInputTextField(
                controller: controller.bioCtrl,
                label: "Bio",
                hintText: "Enter your bio...",
                maxLines: 4,
                textInputType: TextInputType.multiline,
              ),

              const SizedBox(height: 16),

              // Add Custom Skill
              AppInputTextField(
                controller: controller.skillsCtrl,
                label: "Add Skills",
                hintText: "Enter a skill (e.g., PHP, Laravel)",
                textInputType: TextInputType.text,
              ),

              const SizedBox(height: 12),
              CustomButton(
                title: "+ Add Skill",
                height: 40,
                onPressed: controller.addCustomSkill,
              ),

              // Selected Skills List
              Obx(() => controller.selectedSkills.isEmpty
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
                                  onDeleted: () => controller.removeSkill(skill),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    )),

              // Popular Skills
              const SizedBox(height: 16),
              Text(
                "Quick Add Skills:",
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Obx(() => Wrap(
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
                  )),

              const SizedBox(height: 16),

              SingleDropdown(
                controller: controller.experienceCtrl,
                label: "Experience Level",
                items: controller.expLevels,
              ),

              const SizedBox(height: 16),

              SingleDropdown(
                controller: controller.availabilityCtrl,
                label: "Availability",
                items: controller.availabilities,
              ),

              const SizedBox(height: 16),

              AppInputTextField(
                controller: controller.locationCtrl,
                label: "Location",
                hintText: "e.g., Pune, Maharashtra",
                textInputType: TextInputType.text,
                //validator: FormValidator.required,
              ),

              const SizedBox(height: 24),

              // Interests Section
              const SectionTitle("Interests"),

              // Add Custom Interest
              AppInputTextField(
                controller: controller.interestsCtrl,
                label: "Add Interests",
                hintText: "Enter an interest (e.g., Gaming, Coding)",
                textInputType: TextInputType.text,
              ),

              const SizedBox(height: 12),
              CustomButton(
                title: "+ Add Interest",
                height: 40,
                onPressed: controller.addCustomInterest,
              ),

              // Selected Interests List
              Obx(() => controller.selectedInterests.isEmpty
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
                          children: controller.selectedInterests
                              .map(
                                (interest) => Chip(
                                  label: Text(interest),
                                  deleteIcon: const Icon(Icons.close, size: 16),
                                  onDeleted: () => controller.removeInterest(interest),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    )),

              // Popular Interests
              const SizedBox(height: 16),
              Text(
                "Popular Interests:",
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Obx(() => Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: controller.popularInterests
                        .map(
                          (interest) => FilterChip(
                            label: Text(interest),
                            selected: controller.selectedInterests.contains(interest),
                            onSelected: (selected) {
                              if (selected) {
                                controller.addPopularInterest(interest);
                              } else {
                                controller.removeInterest(interest);
                              }
                            },
                          ),
                        )
                        .toList(),
                  )),

              const SizedBox(height: 80),
            ],
          ),
        );
      }),
      bottomNavigationBar: BottomAppBar(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: Obx(() => CustomButton(
              isLoading: controller.isLoading.value,
              title: controller.isEdit.value ? "Update Profile" : "Create Profile",
              onPressed: controller.onSaveProfile,
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