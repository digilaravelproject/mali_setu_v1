import 'package:edu_cluezer/features/Auth/service/auth_service.dart';
import 'package:edu_cluezer/features/Auth/login/data/model/res_login_model.dart';
import 'package:edu_cluezer/core/routes/app_routes.dart';
import 'package:edu_cluezer/features/settings/controller/settings_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:edu_cluezer/core/helper/string_extensions.dart';
import 'package:share_plus/share_plus.dart';
import '../../../widgets/custom_buttons.dart';
import '../../../widgets/custom_image_view.dart';
import '../../../core/utils/app_assets.dart';

class SettingsScreen extends GetWidget<SettingsController> {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Get.find<AuthService>();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // User Profile Header
            _buildUserHeader(context, authService),

            // Settings List
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // User Information Section
                      _buildSectionHeader(context, 'USER INFORMATION'),
                      _buildInfoCard(
                        context: context,
                        infoItems: [
                          {
                            'title': 'My Profile',
                            'icon': Icons.person_outline,
                            'onTap': () {
                              Get.toNamed(AppRoutes.profileScreen);
                            },
                          },
                          {'title': 'App Language', 'icon': Icons.language},
                          {'title': 'User Approval', 'icon': Icons.verified},
                          {'title': 'Active User', 'icon': CupertinoIcons.person_2_fill},
                        ],
                      ),

                      // Business Section
                      _buildSectionHeader(context, 'BUSINESS'),
                      _buildInfoCard(
                        context: context,
                        infoItems: [
                          {'title': 'Active Business', 'icon': Icons.business},
                          {'title': 'Business Approval', 'icon': Icons.verified},
                          {'title': 'Business Type', 'icon': Icons.list},
                          {'title': 'Saved Business', 'icon': Icons.bookmark},
                        ],
                      ),

                      // Volunteer Section
                      _buildSectionHeader(context, 'VOLUNTEER'),
                      _buildInfoCard(
                        context: context,
                        infoItems: [
                          {'title': 'Active Volunteer', 'icon': Icons.favorite},
                          {'title': 'Volunteer Approval', 'icon': Icons.verified},
                          {
                            'title': 'Volunteer Excel Download',
                            'icon': Icons.download_for_offline_sharp,
                          },
                        ],
                      ),

                      // Legal Section
                      _buildSectionHeader(context, 'LEGAL'),
                      _buildInfoCard(
                        context: context,
                        infoItems: [
                          {'title': 'Privacy Policy', 'icon': Icons.policy},
                          {'title': 'Terms & Conditions', 'icon': Icons.file_open},
                          {'title': 'Contact Supports', 'icon': Icons.contact_support},
                        ],
                      ),

                      // App Settings Section
                      _buildSectionHeader(context, 'APP SETTINGS'),
                      _buildInfoCard(
                        context: context,
                        infoItems: [
                          {
                            'title': 'Share App',
                            'icon': CupertinoIcons.arrowshape_turn_up_right_fill,
                            'onTap': () async {
                              try {
                                await Share.share(
                                  'Check out this amazing app!\n\nDownload link: https://yourapp.com',
                                  subject: 'Awesome App Recommendation',
                                );
                              } catch (e) {
                                debugPrint('Share failed: $e');
                              }
                            },
                          },
                          {
                            'title': 'Logout',
                            'icon': Icons.logout,
                            'onTap': () async {
                              final confirm = await LogoutDialog.show(
                                context: context,
                                title: 'Confirm Logout',
                                message: 'You will be redirected to login screen',
                              );
                              if (confirm == true) {
                                authService.logout();
                              }
                            },
                          },
                        ],
                      ),

                      // Add Business Button
                      const SizedBox(height: 20),
                      _buildSectionHeader(context, 'Do you want to register your own business ?'),
                      const SizedBox(height: 8),
                      CustomButton(
                        height: 40,
                        borderRadius: 14,
                        title: "Register Your Own Business",
                        onPressed: () {},
                      ),

                      const SizedBox(height: 40),
                      Align(
                        alignment: Alignment.center,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Initiative By",
                              style: context.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              " Anushka Foundation",
                              style: context.textTheme.titleLarge?.copyWith(
                                color: context.theme.primaryColor,
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserHeader(BuildContext context, AuthService authService) {
    return Obx(() {
      final user = authService.currentUser.value;
      final name = user?.name ?? 'Guest User';
      final email = user?.email ?? 'Sign in to access more features';

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: context.theme.primaryColorLight,
          borderRadius: const BorderRadius.only(
            bottomRight: Radius.circular(40),
            bottomLeft: Radius.circular(40),
          ),
        ),
        child: Row(
          children: [
            InkWell(
              onTap: () {
                Get.toNamed(AppRoutes.profileScreen);
              },
              child: CustomImageView(
                url: user?.profileImage,
                height: 55,
                width: 55,
                radius: BorderRadius.circular(25),
                imagePath: AppAssets.imgAppLogo,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name.toTitleCase(),
                    style: context.textTheme.titleLarge?.copyWith(fontSize: 20),
                  ),
                  Text(
                    email,
                    style: context.textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, top: 16, bottom: 8),
      child: Text(
        title,
        style: context.textTheme.titleMedium?.copyWith(
          color: context.theme.primaryColor,
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required BuildContext context,
    required List<Map<String, dynamic>> infoItems,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: context.theme.dividerColor, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: infoItems
              .map((item) => _buildInfoRow(
                    context: context,
                    onTap: item['onTap'],
                    title: item['title'],
                    icon: item['icon'],
                  ))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required BuildContext context,
    required String title,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: context.theme.primaryColorLight,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(icon, size: 18, color: context.theme.primaryColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: context.textTheme.bodyMedium,
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right, size: 20, color: context.iconColor),
          ],
        ),
      ),
    );
  }
}

class LogoutDialog {
  static Future<bool?> show({
    required BuildContext context,
    String title = 'Log Out',
    String message = 'Are you sure you want to log out?',
    String confirmText = 'Log Out',
    String cancelText = 'Cancel',
    Color confirmColor = Colors.red,
    Color cancelColor = Colors.grey,
    bool showIcon = true,
    bool barrierDismissible = true,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 8,
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (showIcon)
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.red.withOpacity(0.1),
                    ),
                    child: const Icon(
                      Icons.logout,
                      size: 30,
                      color: Colors.red,
                    ),
                  ),
                if (showIcon) const SizedBox(height: 20),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context, false);
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: BorderSide(color: cancelColor),
                        ),
                        child: Text(
                          cancelText,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: cancelColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context, true);
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: confirmColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          confirmText,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
