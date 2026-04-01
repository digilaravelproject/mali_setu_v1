import 'package:edu_cluezer/widgets/basic_text_field.dart';
import 'package:edu_cluezer/widgets/custom_buttons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/volunteerUpdateProfileController.dart';

class CreateVolunteerScreen extends GetWidget<VoluntProfileUpdateController> {
  const CreateVolunteerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Get.theme;
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: Colors.grey[50], // Match profile view background
      appBar: AppBar(
        leading: GestureDetector(
          onTap: Get.back,
          child: const Icon(Icons.arrow_back_ios_rounded, color: Colors.black, size: 20),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          controller.isEdit.value ? "update_profile".tr : "create_profile".tr,
          style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Text
              Text(
                controller.isEdit.value 
                    ? "update_info_desc".tr
                    : "fill_info_desc".tr,
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
              const SizedBox(height: 20),

              // 1. Basic Information Card
              _buildSectionCard(
                title: "basic_information".tr,
                icon: Icons.person_outline,
                colorScheme: colorScheme,
                children: [
                   AppInputTextField(
                    controller: controller.bioCtrl,
                    label: "bio".tr,
                    hintText: "bio_hint".tr,
                    maxLines: 4,
                    textInputType: TextInputType.multiline,
                    isRequired: true,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Bio is required";
                      }
                      if (value.trim().length < 10) {
                        return "Bio must be at least 10 characters";
                      }
                      if (value.trim().length > 500) {
                        return "Bio cannot exceed 500 characters";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  AppInputTextField(
                    controller: controller.locationCtrl,
                    label: "location".tr,
                    hintText: "location_hint".tr,
                    textInputType: TextInputType.text,
                    isRequired: true,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Location is required";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  SingleDropdown(
                    controller: controller.experienceCtrl,
                    label: "experience_level".tr,
                    items: controller.expLevels,
                    isRequired: true,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Experience level is required";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  SingleDropdown(
                    controller: controller.availabilityCtrl,
                    label: "availability".tr,
                    items: controller.availabilities,
                    isRequired: true,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Availability is required";
                      }
                      return null;
                    },
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // 2. Skills Section
              _buildSectionCard(
                title: "skills".tr,
                icon: Icons.star_outline,
                colorScheme: colorScheme,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: AppInputTextField(
                          controller: controller.skillsCtrl,
                          label: "add_skill".tr,
                          hintText: "skill_hint".tr,
                          textInputType: TextInputType.text,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Padding(
                        padding: const EdgeInsets.only(top: 40.0), // Align with input field
                        child: InkWell(
                          onTap: controller.addCustomSkill,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: colorScheme.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.add, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Selected Skills
                  Obx(() => controller.selectedSkills.isNotEmpty ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("selected_skills".tr, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                          Text("${controller.selectedSkills.length}/10", style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: controller.selectedSkills.map((skill) => 
                          Chip(
                            label: Text(skill, style: TextStyle(color: colorScheme.primary, fontSize: 12)),
                            backgroundColor: colorScheme.primary.withOpacity(0.1),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide(color: colorScheme.primary.withOpacity(0.2))
                              ),
                            deleteIcon: Icon(Icons.close, size: 16, color: colorScheme.primary),
                            onDeleted: () => controller.removeSkill(skill),
                          )
                        ).toList(),
                      ),
                      const Divider(height: 24),
                    ],
                  ) : const SizedBox.shrink()),

                   // Popular Skills
                  Text("popular_skills".tr, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 8),
                  Obx(() => Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: controller.popularSkills.map((skill) => 
                      FilterChip(
                        label: Text(skill),
                        labelStyle: TextStyle(
                          color: controller.selectedSkills.contains(skill) ? Colors.white : Colors.black87,
                          fontSize: 12,
                        ),
                        selected: controller.selectedSkills.contains(skill),
                        selectedColor: colorScheme.primary,
                        checkmarkColor: Colors.white,
                        backgroundColor: Colors.grey[100],
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        side: BorderSide.none,
                        onSelected: (selected) {
                           if (selected) {
                            controller.addPopularSkill(skill);
                          } else {
                            controller.removeSkill(skill);
                          }
                        },
                      )
                    ).toList(),
                  )),
                ],
              ),

              const SizedBox(height: 16),

              // 3. Interests Section
              _buildSectionCard(
                title: "interests".tr,
                icon: Icons.favorite_outline,
                colorScheme: colorScheme,
                children: [
                   Row(
                    children: [
                      Expanded(
                        child: AppInputTextField(
                          controller: controller.interestsCtrl,
                          label: "add_interest".tr,
                          hintText: "interest_hint".tr,
                          textInputType: TextInputType.text,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Padding(
                        padding: const EdgeInsets.only(top: 40.0),
                        child: InkWell(
                          onTap: controller.addCustomInterest,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.add, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Selected Interests
                  Obx(() => controller.selectedInterests.isNotEmpty ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("selected_interests".tr, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                          Text("${controller.selectedInterests.length}/10", style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: controller.selectedInterests.map((interest) => 
                          Chip(
                            label: Text(interest, style: const TextStyle(color: Colors.green, fontSize: 12)),
                            backgroundColor: Colors.green.withOpacity(0.1),
                             shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide(color: Colors.green.withOpacity(0.2))
                              ),
                            deleteIcon: const Icon(Icons.close, size: 16, color: Colors.green),
                            onDeleted: () => controller.removeInterest(interest),
                          )
                        ).toList(),
                      ),
                      const Divider(height: 24),
                    ],
                  ) : const SizedBox.shrink()),

                   // Popular Interests
                  Text("popular_interests".tr, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 8),
                  Obx(() => Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: controller.popularInterests.map((interest) => 
                      FilterChip(
                        label: Text(interest),
                           labelStyle: TextStyle(
                          color: controller.selectedInterests.contains(interest) ? Colors.white : Colors.black87,
                          fontSize: 12,
                        ),
                        selected: controller.selectedInterests.contains(interest),
                        selectedColor: Colors.green,
                        checkmarkColor: Colors.white,
                        backgroundColor: Colors.grey[100],
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        side: BorderSide.none,
                        onSelected: (selected) {
                           if (selected) {
                            controller.addPopularInterest(interest);
                          } else {
                            controller.removeInterest(interest);
                          }
                        },
                      )
                    ).toList(),
                  )),
                ],
              ),
              const SizedBox(height: 30),
            ],
          ),
        );
      }),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5)),
          ],
        ),
        child: Obx(() => CustomButton(
              isLoading: controller.isLoading.value,
              title: controller.isEdit.value ? "update_profile".tr : "create_profile".tr,
              onPressed: controller.onSaveProfile,
            )),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required ColorScheme colorScheme,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: Colors.grey[700]),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const Divider(height: 24),
          ...children,
        ],
      ),
    );
  }
}


class SingleDropdown extends StatelessWidget {
  final TextEditingController controller;
  final String? label;
  final String? hint;
  final List<String> items;
  final bool isRequired;
  final String? Function(String?)? validator;

  const SingleDropdown({
    super.key,
    required this.controller,
    required this.items,
    this.label,
    this.hint,
    this.isRequired = false,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return AppInputTextField(
      controller: controller,
      label: label ?? "No Label",
      isDropdown: true,
      dropdownItems: items,
      isRequired: isRequired,
      validator: validator,
    );
  }
}