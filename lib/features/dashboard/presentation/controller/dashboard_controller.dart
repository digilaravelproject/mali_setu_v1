import 'package:edu_cluezer/features/dashboard/data/model/btm_nav_model.dart';
import 'package:edu_cluezer/features/dashboard/presentation/page/more_page.dart';
import 'package:edu_cluezer/features/matrimony/presentation/page/matrimony_page.dart';
import 'package:edu_cluezer/features/volunteer/pages/volunteer_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../business/data/model/res_all_business_model.dart';
import '../../../business/presentation/page/business_page.dart';
import '../../../settings/page/settings_screen.dart';
import '../../../business/presentation/controller/business_controller.dart';
import '../../../Auth/service/auth_service.dart';
import '../../../../core/routes/app_routes.dart';
import '../page/home_page.dart';

class DashboardController extends GetxController {
  var currentPage = 0.obs;
  var hasShownBusinessDialog = false.obs;

  var pageController = PageController();

  var screenList = <Widget>[
    HomePage(),
    //BusinessPage(),
    BusinessScreen(),
    MatrimonyPage(),
    VolunteerPage(),
    SettingsScreen()
 //   MorePage(),
  ];

  @override
  void onInit() {
    super.onInit();
    // Check and show business dialog after a short delay
    Future.delayed(Duration(milliseconds: 800), () {
      _checkAndShowBusinessDialog();
    });
  }

  void _checkAndShowBusinessDialog() {
    try {
      // Get current user
      final authService = Get.find<AuthService>();
      final user = authService.currentUser.value;
      
      print("DEBUG_DASHBOARD: ========================================");
      print("DEBUG_DASHBOARD: Checking business dialog conditions");
      print("DEBUG_DASHBOARD: User: ${user?.name}");
      print("DEBUG_DASHBOARD: User type: '${user?.userType}'");
      print("DEBUG_DASHBOARD: Has shown dialog: ${hasShownBusinessDialog.value}");
      
      // Check if dialog already shown in this session
      if (hasShownBusinessDialog.value) {
        print("DEBUG_DASHBOARD: ❌ Dialog already shown in this session");
        return;
      }
      
      // Check if user exists
      if (user == null) {
        print("DEBUG_DASHBOARD: ❌ User is null, skipping dialog");
        return;
      }
      
      // IMPORTANT: Only check for "general" user type
      final userType = user.userType?.toLowerCase()?.trim() ?? '';
      print("DEBUG_DASHBOARD: User type (normalized): '$userType'");
      
      // Only show dialog if user type is exactly "general"
      if (userType != 'general') {
        print("DEBUG_DASHBOARD: ❌ User type is '$userType', not 'general'. Skipping dialog.");
        print("DEBUG_DASHBOARD: ========================================");
        return;
      }
      
      print("DEBUG_DASHBOARD: ✅ User type is 'general', checking business status...");
      
      // Get business controller to check if user has business
      try {
        final businessController = Get.find<BusinessController>();

        print("DEBUG_DASHBOARD: My business: ${businessController.myBusiness.value?.businessName}");
        print("DEBUG_DASHBOARD: My businesses count: ${businessController.myBusinesses.length}");

        ever(businessController.myBusiness, (Business? business) {
          if (business == null && businessController.myBusinesses.isEmpty) {
            print("DEBUG_DASHBOARD: ✅✅✅ User has no business. SHOWING REGISTRATION DIALOG.");
            hasShownBusinessDialog.value = true;
            _showBusinessRegistrationDialog();
          } else {
            print("DEBUG_DASHBOARD: ❌ User already has a business: ${business?.businessName}");
          }
        });


        // If user doesn't have a business, show dialog
        // if (businessController.myBusiness.value == null &&
        //     businessController.myBusinesses.isEmpty) {
        //   print("DEBUG_DASHBOARD: ✅✅✅ User has no business. SHOWING REGISTRATION DIALOG.");
        //   print("DEBUG_DASHBOARD: ========================================");
        //   hasShownBusinessDialog.value = true;
        //   _showBusinessRegistrationDialog();
        // } else {
        //   print("DEBUG_DASHBOARD: ❌ User already has a business. No dialog needed.");
        //   print("DEBUG_DASHBOARD: ========================================");
        // }
      } catch (e) {
        print("DEBUG_DASHBOARD: ⚠️ Error getting business controller: $e");
        // If business controller not found, assume no business and show dialog
        print("DEBUG_DASHBOARD: ✅✅✅ Business controller not found. SHOWING REGISTRATION DIALOG.");
        print("DEBUG_DASHBOARD: ========================================");
        hasShownBusinessDialog.value = true;
        _showBusinessRegistrationDialog();
      }
    } catch (e) {
      print("DEBUG_DASHBOARD: ❌ Error checking business dialog: $e");
      print("DEBUG_DASHBOARD: ========================================");
    }
  }

  void _showBusinessRegistrationDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.purple.shade50,
                Colors.blue.shade50,
              ],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.business_center,
                  size: 48,
                  color: Colors.purple.shade700,
                ),
              ),
              const SizedBox(height: 20),
              
              // Title
              Text(
                "Create Your Own Business",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple.shade900,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              
              // Description
              Text(
                "Start your digital journey today! Register your business and reach thousands of potential customers.",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              
              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        print("DEBUG_DASHBOARD: User clicked 'Later' button");
                        Get.back();
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(color: Colors.grey.shade400),
                      ),
                      child: Text(
                        "Later",
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () {
                        print("DEBUG_DASHBOARD: User clicked 'Register Now' button");
                        print("DEBUG_DASHBOARD: Navigating to: ${AppRoutes.regBusiness}");
                        Get.back();
                        Get.toNamed(AppRoutes.regBusiness);
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: Colors.purple.shade700,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: const Text(
                        "Register Now",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  changePage(int index) {
    pageController.jumpToPage(index);
  }

  // Method to manually trigger business dialog check
  void checkBusinessRegistration() {
    hasShownBusinessDialog.value = false;
    _checkAndShowBusinessDialog();
  }

  List<BtmNavModel> navList(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    return [
      BtmNavModel(
        title: "home".tr,
        icon: CupertinoIcons.home,
        selectedIcon: CupertinoIcons.house_fill,
        selectedColor: theme.primary,
        unselectedColor: theme.onSurfaceVariant,
      ),
      BtmNavModel(
        title: "business".tr,
        icon: Icons.business,
        selectedIcon: Icons.shop,
        selectedColor: theme.primary,
        unselectedColor: theme.onSurfaceVariant,
      ),
      BtmNavModel(
        title: "matrimony".tr,
        icon: CupertinoIcons.heart,
        selectedIcon: CupertinoIcons.heart_fill,
        selectedColor: theme.primary,
        unselectedColor: theme.onSurfaceVariant,
      ),
      BtmNavModel(
        title: "volunteer".tr,
        icon: CupertinoIcons.person_2,
        selectedIcon: CupertinoIcons.person_2_fill,
        selectedColor: theme.primary,
        unselectedColor: theme.onSurfaceVariant,
      ),
      BtmNavModel(
        title: "more".tr,
        icon: Icons.more_vert,
        selectedColor: theme.primary,
        unselectedColor: theme.onSurfaceVariant,
      ),
    ];
  }
}
