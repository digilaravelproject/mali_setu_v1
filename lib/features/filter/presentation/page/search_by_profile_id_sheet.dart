import 'package:edu_cluezer/widgets/basic_text_field.dart';
import 'package:edu_cluezer/widgets/custom_buttons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/styles/app_decoration.dart';

class SearchByProfileIdSheet extends StatelessWidget {
  const SearchByProfileIdSheet({super.key});

  static void show() {
    Get.bottomSheet(
      const SearchByProfileIdSheet(),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppDecorations.bottomSheetDecoration(context),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
            'search_by_profile_id'.tr,
            style: context.textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          AppInputTextField(
            hintText: "Eg. MMS939290",
            label: 'matrimony_id'.tr,
            iconData: CupertinoIcons.search,
          ),
          const SizedBox(height: 16),
          CustomButton(title: 'view_profile'.tr, onPressed: () {}),
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 20),
        ],
      ),
    );
  }
}
