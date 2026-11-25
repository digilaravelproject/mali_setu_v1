import 'package:edu_cluezer/core/styles/app_colors.dart';
import 'package:edu_cluezer/features/dashboard/data/model/btm_nav_model.dart';
import 'package:edu_cluezer/features/dashboard/presentation/controller/dashboard_controller.dart';
import 'package:edu_cluezer/widgets/custom_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:edu_cluezer/features/donation/presentation/controller/donation_controller.dart';
import 'package:edu_cluezer/features/donation/binding/donation_binding.dart';
import 'package:edu_cluezer/features/donation/presentation/widget/donation_bottom_sheet.dart';
import 'package:edu_cluezer/core/routes/app_routes.dart';
import 'package:edu_cluezer/core/widgets/custom_confirm_dialog.dart';

class DashboardPage extends GetWidget<DashboardController> {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      enableDoubleTapExit: true,
      whatsAppFabBottomPadding: 85.0,
      showWhatsAppFab: true,
      onWillPop: () async {
        if (controller.isBlogger) {
          CustomConfirmDialog.show(
            title: 'exit_app'.tr,
            message: 'want_to_exit_app_message'.tr,
            confirmText: 'yes'.tr,
            cancelText: 'cancel'.tr,
            icon: Icons.exit_to_app,
            confirmColor: AppColors.error,
            onConfirm: () {
              SystemNavigator.pop();
            },
          );
          return false;
        }

        // Show donation prompt on exit
        if (!Get.isRegistered<DonationController>()) {
          final donationBinding = DonationBinding();
          donationBinding.dependencies();
        }

        final donationController = Get.find<DonationController>();
        await donationController.fetchDonationCauses();

        if (donationController.causes.isNotEmpty) {
          showDonationPrompt(donationController.causes, (cause) {
            Get.toNamed(AppRoutes.donationDetails, arguments: cause);
          }, onClose: () {
            // If user clicks "Not right now" on exit, really exit
            SystemNavigator.pop();
          });
          return false; // Don't exit yet, we are showing the sheet
        }
        return true; // No causes? Just let normal exit flow handle it
      },
      extendBody: true,
      body: Obx(() {
        final screens = controller.screenList;
        final index = controller.currentPage.value;
        final safeIndex = (index >= 0 && index < screens.length) ? index : 0;
        return IndexedStack(
          index: safeIndex,
          children: screens,
        );
      }),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
          border: const Border(
            top: BorderSide(
              color: AppColors.lightBorder,
              width: 0.5,
            ),
          ),
        ),
        child: BottomAppBar(
          elevation: 0,
          height: 60,
          padding: EdgeInsets.zero,
          child: Obx(() {
            // Observe auth/screenList dependencies so bottom nav stays synced with IndexedStack
            controller.screenList;
            return Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: controller.navList(context).asMap().entries.map((entry) {
                final index = entry.key;
                final e = entry.value;
                return _buildNavItems(e, index);
              }).toList(),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildNavItems(BtmNavModel e, int index) {
    return Obx(() {
      final isSelected = controller.currentPage.value == index;

      return Expanded(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => controller.changePage(index),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                width: isSelected ? 28 : 26,
                height: isSelected ? 28 : 26,
                decoration: BoxDecoration(
                  color: isSelected
                      ? e.selectedColor
                      : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    isSelected ? (e.selectedIcon ?? e.icon) : e.icon,
                    color: isSelected ? Colors.white : e.unselectedColor,
                    size: isSelected ? 17 : 22,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    e.title,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    style: TextStyle(
                      color: isSelected ? e.selectedColor : e.unselectedColor,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 10,
                      letterSpacing: 0.1,
                      height: 1.1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
