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
      extendBody: false,
      body: PageView.builder(
        physics: const NeverScrollableScrollPhysics(),
        controller: controller.pageController,
        onPageChanged: (p) => controller.currentPage.value = p,
        itemCount: controller.screenList.length,
        itemBuilder: (context, index) => controller.screenList.elementAt(index),
      ),
      bottomNavigationBar: BottomAppBar(
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
    );
  }

  Widget _buildNavItems(BtmNavModel e, int index) {
    return Obx(() {
      final isSelected = controller.currentPage.value == index;

      return GestureDetector(
        onTap: () => controller.changePage(index),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 400),
          curve: Curves.easeInOutCubic,
          padding: EdgeInsets.symmetric(
            horizontal: isSelected ? 6 : 12,
            vertical: 6,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 4,
            children: [
              TweenAnimationBuilder<double>(
                duration: Duration(milliseconds: 400),
                curve: isSelected ? Curves.elasticOut : Curves.easeInOut,
                tween: Tween(begin: 0.0, end: isSelected ? 1.0 : 0.0),
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: 1.0 + (value * 0.15),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? e.selectedColor
                            : e.unselectedColor.withAlpha(20),
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

              AnimatedSize(
                duration: Duration(milliseconds: 400),
                curve: Curves.easeInOutCubic,
                child: Builder(
                  builder: (_) {
                    if (isSelected) {
                      return Padding(
                        padding: EdgeInsets.only(left: 10, right: 4),
                        child: TweenAnimationBuilder<double>(
                          duration: Duration(milliseconds: 400),
                          curve: Curves.easeOutCubic,
                          tween: Tween(begin: 0.0, end: 1.0),
                          builder: (context, value, child) {
                            return Opacity(
                              opacity: value,
                              child: Transform.translate(
                                offset: Offset((1 - value) * 20, 0),
                                child: child,
                              ),
                            );
                          },
                          child: Text(
                            e.title,
                            style: TextStyle(
                              color: e.selectedColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      );
                    } else {
                      return SizedBox.shrink();
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
