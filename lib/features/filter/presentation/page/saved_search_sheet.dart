import 'package:edu_cluezer/common/widgets/bg_gradient_border.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/styles/app_decoration.dart';

class SavedSearchSheet extends StatelessWidget {
  const SavedSearchSheet({super.key});

  static void show() {
    Get.bottomSheet(
      const SavedSearchSheet(),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppDecorations.bottomSheetDecoration(context),
      height: Get.height * 0.8,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              height: 4,
              width: 60,
              decoration: BoxDecoration(
                color: context.theme.dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ).marginOnly(bottom: 16),
          ),
          Text(
            "Saved Searches",
            style: context.textTheme.headlineSmall,
          ),
           Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Your Saved Search...",
                  style: context.textTheme.titleMedium,
                ),
                Text(
                  "Total (75)",
                  style: context.textTheme.titleMedium?.copyWith(
                    color: context.theme.primaryColor,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: 8,
              separatorBuilder: (context, index) {
                return const SizedBox(height: 14);
              },
              itemBuilder: (context, index) {
                return Container(
                  decoration: AppDecorations.cardDecoration(context),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Search Title",
                            style: context.textTheme.labelMedium,
                          ),
                          Icon(
                            Icons.delete,
                            size: 20,
                            color: context.theme.primaryColor,
                          ),
                        ],
                      ),
                      Text(
                        "${index * 7} Matches",
                        style: context.textTheme.titleLarge,
                      ),
                      Center(
                        child: BgGradientBorder(
                          child: Text(
                            "Show Matches",
                            style: context.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: context.theme.primaryColor,
                            ),
                          ).marginSymmetric(
                            horizontal: Get.width * 0.1,
                            vertical: 8,
                          ),
                        ),
                      ).marginOnly(top: 12),
                    ],
                  ),
                ).marginSymmetric(horizontal: 4);
              },
            ),
          ),
        ],
      ),
    );
  }
}
