import 'package:edu_cluezer/features/matrimony/presentation/controller/reg_matrimony_controller.dart';
import 'package:edu_cluezer/widgets/basic_text_field.dart';
import 'package:edu_cluezer/widgets/custom_buttons.dart';
import 'package:edu_cluezer/widgets/custom_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../common/widgets/option_selector.dart';
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
        title: const Text("Matrimony Registration"),
      ),
      body: Obx(
        () => Column(
          children: [
            /// Progress Indicator
            _buildProgressIndicator(context),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (controller.currentStep.value == 0) _buildPersonalStep(context),
                    if (controller.currentStep.value == 1) _buildBackgroundStep(context),
                    if (controller.currentStep.value == 2) _buildHabitsStep(context),
                    if (controller.currentStep.value == 3) _buildReligiousStep(context),
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
                    title: "Back",
                    onPressed: controller.previousStep,
                  ).marginOnly(right: 8),
                ),
              Expanded(
                child: CustomButton(
                  title: controller.currentStep.value == 3 ? "Register" : "Next",
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
      child: Row(
        children: List.generate(4, (index) {
          final isCompleted = index < controller.currentStep.value;
          final isActive = index == controller.currentStep.value;

          return Expanded(
            child: Row(
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
    );
  }

  Widget _buildPersonalStep(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Personal Identity",
          style: context.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          "Let's start with your basic details",
          style: context.textTheme.bodyMedium?.copyWith(color: Colors.grey),
        ),
        const SizedBox(height: 24),

        /// Gender
        const SectionTitle("Gender"),
        Obx(
          () => OptionSelector(
            options: const ['Male', 'Female'],
            onSelected: controller.gender.call,
            selectedValue: controller.gender.value,
          ),
        ),
        const SizedBox(height: 16),

        /// DOB
        const SectionTitle("Date of birth"),
        const BirthdayDateField(),
        const SizedBox(height: 16),

        /// Place of Birth
        const SectionTitle("Place of birth"),
        TwoColumnDropdownRow(
          left: AppInputTextField(
            controller: controller.countryCtrl,
            label: "Country",
            isDropdown: true,
            dropdownItems: controller.countries,
          ),
          right: AppInputTextField(
            controller: controller.stateCtrl,
            label: "State",
            isDropdown: true,
            dropdownItems: controller.states,
          ),
        ),
        const SizedBox(height: 12),
        TwoColumnDropdownRow(
          left: AppInputTextField(
            controller: controller.cityCtrl,
            label: "City",
            isDropdown: true,
            dropdownItems: controller.cities,
          ),
          right: AppInputTextField(
            controller: controller.birthTimeCtrl,
            label: "Time",
            enable: false,
            endIcon: Icons.watch_later_outlined,
          ),
        ),
      ],
    );
  }

  Widget _buildBackgroundStep(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Background & Lifestyle",
          style: context.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          "Tell us about your education and lifestyle",
          style: context.textTheme.bodyMedium?.copyWith(color: Colors.grey),
        ),
        const SizedBox(height: 24),

        /// Physical Status
        const SectionTitle("Your physical status"),
        Obx(
          () => OptionSelector(
            options: const ['Normal', 'Challenged'],
            selectedValue: controller.physicalStatus.value,
            onSelected: controller.physicalStatus.call,
          ),
        ),
        const SizedBox(height: 24),

        /// Education & Employment
        TwoColumnDropdownRow(
          left: AppInputTextField(
            controller: controller.citizenshipCtrl,
            label: "Citizenship",
            isDropdown: true,
            dropdownItems: controller.countries,
          ),
          right: AppInputTextField(
            controller: controller.educationCtrl,
            label: "Education",
            isDropdown: true,
            dropdownItems: controller.educations,
          ),
        ),
        const SizedBox(height: 12),
        TwoColumnDropdownRow(
          left: AppInputTextField(
            controller: controller.employmentCtrl,
            label: "Employment Type",
            isDropdown: true,
            dropdownItems: controller.employmentTypes,
          ),
          right: AppInputTextField(
            controller: controller.motherTongueCtrl,
            label: "Mother Tongue",
            isDropdown: true,
            dropdownItems: controller.languages,
          ),
        ),
        const SizedBox(height: 12),
        SingleDropdown(
          controller: controller.familyTypeCtrl,
          label: "Family Type",
          items: controller.familyTypes,
        ),
      ],
    );
  }

  Widget _buildHabitsStep(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Habits & Social",
          style: context.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          "More about your personality and habits",
          style: context.textTheme.bodyMedium?.copyWith(color: Colors.grey),
        ),
        const SizedBox(height: 24),

        /// Marital Status
        const SectionTitle("Your Marital status"),
        Obx(
          () => OptionSelector(
            options: controller.maritalStatuses,
            selectedValue: controller.maritalStatus.value,
            onSelected: controller.maritalStatus.call,
          ),
        ),
        const SizedBox(height: 24),

        /// Eating Habits
        const SectionTitle("Special Eating Habits"),
        Obx(
          () => OptionSelector(
            options: controller.eatingHabits,
            selectedValue: controller.eatingHabit.value,
            onSelected: controller.eatingHabit.call,
          ),
        ),
        const SizedBox(height: 16),
        SingleDropdown(
          controller: controller.drinkingCtrl,
          label: "Drinking Habits",
          items: const ["Yes", "No"],
        ),
        const SizedBox(height: 12),
        SingleDropdown(
          controller: controller.smokingCtrl,
          label: "Smoking Habits",
          items: const ["Yes", "No"],
        ),
      ],
    );
  }

  Widget _buildReligiousStep(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Religious & Horoscope",
          style: context.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          "Final step for your religious details",
          style: context.textTheme.bodyMedium?.copyWith(color: Colors.grey),
        ),
        const SizedBox(height: 24),

        /// Religious Details
        const SectionTitle("Religious Details"),
        SingleDropdown(
          controller: controller.religionCtrl,
          label: "Religion",
          items: controller.religions,
        ),
        const SizedBox(height: 12),
        SingleDropdown(
          controller: controller.casteCtrl,
          label: "Caste",
          items: controller.castes,
        ),
        const SizedBox(height: 24),

        /// Star Details
        const SectionTitle("Add Star Details"),
        SingleDropdown(
          controller: controller.starCtrl,
          label: "Star",
          items: controller.stars,
        ),
        const SizedBox(height: 12),
        SingleDropdown(
          controller: controller.rashiCtrl,
          label: "Rashi",
          items: controller.rashis,
        ),
        const SizedBox(height: 12),
        SingleDropdown(
          controller: controller.manglikCtrl,
          label: "Manglik",
          items: const ["Yes", "No"],
        ),
        const SizedBox(height: 24),

        const SectionTitle("Do you have any dosh?"),
        Obx(
          () => OptionSelector(
            options: const ['YES', 'NO', 'Unknown'],
            selectedValue: controller.dosh.value,
            onSelected: controller.dosh.call,
          ),
        ),
      ],
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
      style: context.textTheme.titleLarge,
    ).marginOnly(bottom: 4);
  }
}

class TwoColumnDropdownRow extends StatelessWidget {
  final Widget left;
  final Widget right;

  const TwoColumnDropdownRow({
    super.key,
    required this.left,
    required this.right,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: left),
        const SizedBox(width: 12),
        Expanded(child: right),
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
    );
  }
}
