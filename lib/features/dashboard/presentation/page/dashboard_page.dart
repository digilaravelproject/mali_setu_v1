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

class DashboardPage extends GetWidget<DashboardController> {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      enableDoubleTapExit: true,
      onWillPop: () async {
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
      body: Obx(() => IndexedStack(
        index: controller.currentPage.value,
        children: controller.screenList,
      )),
      bottomNavigationBar: SafeArea(
        child: BottomAppBar(
          padding: EdgeInsets.zero,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: controller.navList(context).asMap().entries.map((entry) {
              final index = entry.key;
              final e = entry.value;
              return _buildNavItems(e, index);
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItems(BtmNavModel e, int index) {
    return Obx(() {
      final isSelected = controller.currentPage.value == index;

      return GestureDetector(
        onTap: () => controller.changePage(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 4,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TweenAnimationBuilder<double>(
                duration: Duration(milliseconds: 400),
                curve: isSelected ? Curves.elasticOut : Curves.easeInOut,
                tween: Tween(begin: 0.0, end: isSelected ? 1.0 : 0.0),
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: 1.0 + (value * 0.1),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? e.selectedColor
                            : e.unselectedColor.withAlpha(15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isSelected ? (e.selectedIcon ?? e.icon) : e.icon,
                        color: isSelected ? Colors.white : e.unselectedColor,
                        size: 20,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 4),
              Text(
                e.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isSelected ? e.selectedColor : e.unselectedColor,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 11,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
