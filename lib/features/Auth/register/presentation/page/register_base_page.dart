/*
import 'package:edu_cluezer/core/utils/app_assets.dart';
import 'package:edu_cluezer/core/utils/app_constants.dart';
import 'package:edu_cluezer/widgets/basic_text_field.dart';
import 'package:edu_cluezer/widgets/custom_image_view.dart';
import 'package:edu_cluezer/widgets/custom_scaffold.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../widgets/custom_buttons.dart';
import '../controller/register_controller.dart';

part 'reg_step_2_birthday.dart';
part 'reg_step_3_gender.dart';
part 'reg_step_4_goals.dart';

class RegisterBasePage extends GetWidget<RegisterController> {
  const RegisterBasePage({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      enableDoubleTapExit: true,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            if (controller.currentPage.value > 0) {
              final prevPage = controller.currentPage.value - 1;
              controller.pageController.animateToPage(
                prevPage,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
              controller.currentPage.value = prevPage;
            } else {
              Get.back();
            }
          },
          style: IconButton.styleFrom(side: BorderSide.none),
          icon: Icon(AppAssets.backArrow),
        ),
        title: SizedBox(
          width: Get.width * 0.6,
          child: Obx(
            () => LinearProgressIndicator(
              backgroundColor: context.theme.scaffoldBackgroundColor,
              minHeight: 8,
              value: controller.progressValue.value,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          PageView(
            onPageChanged: (p) => controller.currentPage.value = p,
            controller: controller.pageController,
            children: [
              _buildIdentitySteps(context),
              RegStep2Birthday(),
              RegStep3Gender(),
              RegStep4Goals(),
              _buildAddDistanceSteps(context),
              _buildAddInterest(context),
              _buildAddImages(context),
              _buildAddLocation(context),
            ],
          ),
          Positioned(
            bottom: 0,
            right: 0,
            left: 0,
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: context.theme.dividerColor),
                ),
                color: context.theme.scaffoldBackgroundColor,
              ),
              child: Column(
                children: [
                  CustomButton(title: "Continue", onPressed: controller.next),
                  SizedBox(height: context.mediaQueryPadding.bottom),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIdentitySteps(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            spacing: 8,
            children: [
              Text("Your", style: context.textTheme.headlineMedium),
              CustomImageView(imagePath: AppAssets.imgAppTitle, width: 90),
              Text("Identity", style: context.textTheme.headlineMedium),
            ],
          ),
          Text(
            "Create a unique nick name that represent you\nIts how other will know and remember you always",
            style: context.textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade600,
              height: 1.5,
            ),
          ).marginOnly(top: 8),

          // Custom Themed TextField
          _buildMinimalNameTextField(context).marginOnly(top: 32),
        ],
      ),
    );
  }

  Widget _buildMinimalNameTextField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "USERNAME",
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: context.theme.primaryColor,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: controller.nameController,
          style: context.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
          onTapOutside: (p) => FocusScope.of(context).unfocus(),
          cursorColor: context.theme.primaryColor,
          decoration: InputDecoration(
            hintText: "Your nick name",
            hintStyle: context.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
            prefixIcon: Icon(
              Icons.alternate_email,
              color: context.theme.primaryColor,
            ),
            border: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade300, width: 2),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade300, width: 2),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: context.theme.primaryColor,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddDistanceSteps(BuildContext context) {
    return Obx(() {
      return Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              spacing: 8,
              children: [
                Text(
                  "Let’s get to know you better 💕",
                  style: context.textTheme.headlineMedium,
                ),
              ],
            ),

            Text(
              "Choose your gender so we can match you with the right date. Your selection stays private and helps us personalize your experience.",
              style: context.textTheme.bodyMedium,
            ).marginOnly(top: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Distance Preference",
                  style: context.textTheme.titleMedium,
                ),
                Text(
                  "${controller.range.value} km",
                  style: context.textTheme.bodyLarge,
                ),
              ],
            ).marginOnly(top: 12, bottom: 8),

            Slider(
              value: controller.range.value,
              onChanged: (v) => controller.range.value = v.ceilToDouble(),
              min: controller.minAge.value,
              max: controller.maxAge.value,
              label: controller.range.value.round().toString(),
              activeColor: context.theme.primaryColor,
              inactiveColor: context.theme.dividerColor,
              thumbColor: context.theme.primaryColor,
              padding: EdgeInsets.zero,
            ),
          ],
        ),
      );
    });
  }

  Widget _buildAddInterest(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              spacing: 8,
              children: [
                Text(
                  "What are you into? ✨",
                  style: context.textTheme.headlineMedium,
                ),
              ],
            ),

            Text(
              "Choose a few interests so we can match you with date who vibe like you.",
              style: context.textTheme.bodyMedium,
            ).marginOnly(top: 8, bottom: 16),

            // 🔍 Search Field
            AppInputTextField(
              hintText: "Search your interest",
              iconData: CupertinoIcons.search,
              showLabel: false,
              controller: TextEditingController(),
              onChanged: (v) => controller.searchText.value = v,
            ),

            const SizedBox(height: 16),

            Obx(
              () => Wrap(
                spacing: 10,
                runSpacing: 10,
                children: controller.filteredInterests.map((interest) {
                  final isSelected = controller.selectedInterests.contains(
                    interest.name,
                  );
                  return GestureDetector(
                    onTap: () => controller.toggleInterest(interest.name),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? context.theme.primaryColor.withValues(alpha: 0.2)
                            : context.theme.dividerColor.withValues(
                                alpha: 0.15,
                              ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? context.theme.primaryColor.withValues(
                                  alpha: 0.8,
                                )
                              : context.theme.dividerColor.withValues(
                                  alpha: 0.15,
                                ),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            interest.name,
                            style: context.textTheme.titleSmall?.copyWith(
                              color: isSelected
                                  ? context.theme.primaryColor
                                  : null,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                          if (isSelected) ...[
                            const SizedBox(width: 6),
                            Icon(
                              Icons.check_circle,
                              size: 18,
                              color: context.theme.primaryColor,
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildAddImages(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            spacing: 8,
            children: [
              Text(
                "What are you into? ✨",
                style: context.textTheme.headlineMedium,
              ),
            ],
          ),

          Text(
            "Choose a few interests so we can match you with date who vibe like you.",
            style: context.textTheme.bodyMedium,
          ).marginOnly(top: 8, bottom: 16),

          GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.7,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: controller.fileList.length,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (ctx, index) {
              var item = controller.fileList[index];
              return InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  controller.imagePickerHelper.showImagePickerDialog(
                    context,
                    index.toString(),
                    allowMultiple: true,
                  );
                },
                child: Obx(() {
                  if (item.value != null) {
                    return Badge(
                      offset: Offset(-6, -6),
                      label: Icon(
                        Icons.close,
                        size: 20,
                        color: context.theme.colorScheme.onPrimary,
                      ).marginSymmetric(vertical: 4),
                      child: CustomImageView(
                        file: item.value,
                        height: Get.height,
                        enableFv: true,
                        radius: BorderRadius.circular(12),
                      ),
                    );
                  } else {
                    return Container(
                      decoration: BoxDecoration(
                        color: context.theme.primaryColor.withValues(
                          alpha: 0.15,
                        ),
                        border: Border.all(color: context.theme.dividerColor),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(CupertinoIcons.add),
                    );
                  }
                }),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAddLocation(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 16,
          children: [
            Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: context.theme.dividerColor),
              ),
              child: Icon(Icons.location_on_rounded, size: 40),
            ),
            SizedBox(height: 20),
            Text(
              "Enable Location",
              style: context.theme.textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              "You need to enable location to find date around you on \n${AppConstants.appName}",
              textAlign: TextAlign.center,
              style: context.theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),

            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
*/
