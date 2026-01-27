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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Start your new journey",
              style: context.textTheme.displaySmall,
            ),
            Text(
              "Fill the form to continue",
              style: context.textTheme.labelMedium,
            ),

            const SizedBox(height: 16),

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
            BirthdayDateField(),

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

            const SizedBox(height: 16),

            /// Physical Status
            const SectionTitle("Your physical status"),
            Obx(
              () => OptionSelector(
                options: const ['Normal', 'Challenged'],
                selectedValue: controller.physicalStatus.value,
                onSelected: controller.physicalStatus.call,
              ),
            ),

            const SizedBox(height: 16),

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
              hint: "Family Type",
              items: controller.familyTypes,
            ),

            const SizedBox(height: 16),

            /// Marital Status
            const SectionTitle("Your Marital status"),
            Obx(
              () => OptionSelector(
                options: controller.maritalStatuses,
                selectedValue: controller.maritalStatus.value,
                onSelected: controller.maritalStatus.call,
              ),
            ),

            const SizedBox(height: 16),

            /// Eating Habits
            const SectionTitle("Special Eating Habits"),
            Obx(
              () => OptionSelector(
                options: controller.eatingHabits,
                selectedValue: controller.eatingHabit.value,
                onSelected: controller.eatingHabit.call,
              ),
            ),

            const SizedBox(height: 12),

            SingleDropdown(
              controller: controller.drinkingCtrl,
              label: "Drinking Habits",
              items: const ["Yes", "No"],
            ),
            SingleDropdown(
              controller: controller.smokingCtrl,
              label: "Smoking Habits",
              items: const ["Yes", "No"],
            ),

            const SizedBox(height: 16),

            /// Religious Details
            const SectionTitle("Add Religious Details"),
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

            const SizedBox(height: 16),

            /// Star Details
            const SectionTitle("Add Star Details"),
            SingleDropdown(
              controller: controller.starCtrl,
              label: "Star",
              items: controller.stars,
            ),
            SingleDropdown(
              controller: controller.rashiCtrl,
              label: "Rashi",
              items: controller.rashis,
            ),
            SingleDropdown(
              controller: controller.manglikCtrl,
              label: "Manglik",
              items: const ["Yes", "No"],
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
          title: "Register",
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
