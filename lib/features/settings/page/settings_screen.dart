import 'package:edu_cluezer/features/Auth/service/auth_service.dart';
import 'package:edu_cluezer/features/blogs/presentation/screens/blogs_screen.dart';
import 'package:edu_cluezer/features/Auth/login/data/model/res_login_model.dart';
import 'package:edu_cluezer/core/routes/app_routes.dart';
import 'package:edu_cluezer/features/business/presentation/page/business_page.dart';
import 'package:edu_cluezer/features/settings/controller/settings_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:edu_cluezer/core/helper/string_extensions.dart';
import 'package:share_plus/share_plus.dart';
import '../../../widgets/custom_buttons.dart';
import '../../../widgets/custom_image_view.dart';
import '../../../core/utils/app_assets.dart';
import '../../../core/constent/api_constants.dart';
import '../../../widgets/webview_page.dart';
import '../../volunteer/pages/volunteer_page.dart';
import 'change_language_page.dart';
import 'contact_support.dart';

class SettingsScreen extends GetWidget<SettingsController> {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Get.find<AuthService>();
    final topPadding = MediaQuery.of(context).padding.top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.grey[50],
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: topPadding + 16),
              
              // Custom Header instead of AppBar for full-screen feel
              Text(
                "profile & settings".tr,
                style: context.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                ),
              ),
              
              const SizedBox(height: 20),
              // User Profile Header
              _buildUserHeader(context, authService),
              const SizedBox(height: 30),

              // Settings List
              // User Information Section
              _buildSectionHeader(context, 'user_information'.tr),
              _buildSettingsGroup(
                context,
                [
                  _SettingsItem(
                    title: 'my_profile'.tr,
                    icon: Icons.person_outline_rounded,
                    onTap: () => Get.toNamed(AppRoutes.profileScreen),
                  ),
                  _SettingsItem(
                    title: 'app_language'.tr,
                    icon: Icons.language_rounded,
                    onTap: () => Get.to(() => const ChangeLanguagePage()),
                  ),
                  _SettingsItem(
                    title: 'transaction_history'.tr,
                    icon: CupertinoIcons.list_bullet_indent,
                    onTap: () => Get.toNamed(AppRoutes.transactionHistory),
                  ),
                ],
              ),

              // Business Section
              _buildSectionHeader(context, 'business'.tr),
              _buildSettingsGroup(
                context,
                [
                  _SettingsItem(
                    title: 'saved_business'.tr,
                    icon: Icons.bookmark_border_rounded,
                    onTap: () {
                      Get.to(AllBusinessesScreen());
                    }
                  ),
                ],
              ),

              // Volunteer Section
              _buildSectionHeader(context, 'volunteer'.tr),
              _buildSettingsGroup(
                context,
                [
                  _SettingsItem(
                    title: 'active_volunteer'.tr,
                    icon: Icons.favorite_border_rounded,
                    onTap: () {
                      Get.toNamed(AppRoutes.volunteer);
                    },
                  ),
                ],
              ),

              // Legal Section
              _buildSectionHeader(context, 'legal'.tr),
              _buildSettingsGroup(
                context,
                [
                  _SettingsItem(
                    title: 'privacy_policy'.tr,
                    icon: Icons.privacy_tip_outlined,
                    onTap: () => Get.to(() => const WebViewPage(
                          title: 'Privacy Policy',
                          url: ApiConstants.privacyPolicyUrl,
                        )),
                  ),
                  _SettingsItem(
                    title: 'terms & conditions'.tr,
                    icon: Icons.description_outlined,
                    onTap: () => Get.to(() => const WebViewPage(
                          title: 'Terms & Conditions',
                          url: ApiConstants.termsConditionsUrl,
                        )),
                  ),
                  _SettingsItem(
                    title: 'contact_support'.tr,
                    icon: Icons.support_agent_rounded,
                    onTap: () => Get.to(ContactSupportPage())
                  ),
                ],
              ),

              // App Settings Section
              _buildSectionHeader(context, 'app_settings'.tr),
              _buildSettingsGroup(
                context,
                [
                  _SettingsItem(
                    title: 'share_app'.tr,
                    icon: CupertinoIcons.share,
                    onTap: () async {
                      try {
                        await Share.share(
                          'Check out this amazing app!\n\nDownload link: https://yourapp.com',
                          subject: 'Awesome App Recommendation',
                        );
                      } catch (e) {
                        debugPrint('Share failed: $e');
                      }
                    },
                  ),
                  _SettingsItem(
                    title: 'logout'.tr,
                    icon: Icons.logout_rounded,
                    isDestructive: true,
                    onTap: () async {
                      final confirm = await LogoutDialog.show(
                        context: context,
                        title: 'logout'.tr,
                        message: 'are_you_sure_for_logout'.tr,
                      );
                      if (confirm == true) {
                        authService.logout();
                      }
                    },
                  ),
                ],
              ),

              // Add Business Button
              const SizedBox(height: 32),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: context.theme.primaryColor.withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      "want_to_grow_your_business".tr,
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    CustomButton(
                      height: 48,
                      borderRadius: 14,
                      title: "register_your_business".tr,
                      onPressed: () {
                        Get.toNamed(AppRoutes.regBusiness);
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),
              Align(
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Text(
                      "initiative_by".tr,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "anushka_foundation".tr,
                      style: context.textTheme.titleLarge?.copyWith(
                        color: context.theme.primaryColor,
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Version 1.0.0",
                      style: context.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            InkWell(
              onTap: () => Get.toNamed(AppRoutes.profileScreen),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: context.theme.primaryColor.withOpacity(0.2), width: 2),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: CustomImageView(
                  url: user?.profileImage,
                  height: 60,
                  width: 60,
                  radius: BorderRadius.circular(30),
                  imagePath: AppAssets.getAppLogo(),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name.toTitleCase(),
                    style: context.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: () => Get.toNamed(AppRoutes.updateProfile),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: context.theme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.edit_outlined, color: context.theme.primaryColor, size: 20),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12, top: 20),
      child: Text(
        title.toUpperCase(),
        style: context.textTheme.labelLarge?.copyWith(
          color: Colors.grey[600],
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildSettingsGroup(BuildContext context, List<_SettingsItem> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: List.generate(items.length, (index) {
          final item = items[index];
          final isLast = index == items.length - 1;
          
          return Column(
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: item.onTap,
                  borderRadius: isLast 
                      ? const BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20))
                      : index == 0 
                          ? const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))
                          : BorderRadius.zero,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: item.isDestructive 
                                ? Colors.red.withOpacity(0.1) 
                                : context.theme.primaryColor.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            item.icon,
                            size: 20,
                            color: item.isDestructive ? Colors.red : context.theme.primaryColor,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            item.title,
                            style: context.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: item.isDestructive ? Colors.red : Colors.grey[800],
                            ),
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          size: 22,
                          color: Colors.grey[400],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (!isLast)
                Divider(
                  height: 1,
                  thickness: 0.5,
                  indent: 60,
                  color: Colors.grey[200],
                ),
            ],
          );
        }),
      ),
    );
  }

  void _showComingSoonDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.theme.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.rocket_launch_rounded,
                  size: 32,
                  color: context.theme.primaryColor,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "coming_soon".tr,
                style: context.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "coming_soon_msg".tr,
                textAlign: TextAlign.center,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.theme.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                  ),
                  child:  Text(
                    "got_it".tr,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsItem {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final bool isDestructive;

  _SettingsItem({
    required this.title,
    required this.icon,
    required this.onTap,
    this.isDestructive = false,
  });
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
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
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
                      Icons.logout_rounded,
                      size: 28,
                      color: Colors.red,
                    ),
                  ),
                if (showIcon) const SizedBox(height: 20),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
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
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(context, false);
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          cancelText,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
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
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
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
