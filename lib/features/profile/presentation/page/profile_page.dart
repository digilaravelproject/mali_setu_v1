import 'package:edu_cluezer/core/routes/app_routes.dart';
import 'package:edu_cluezer/core/styles/app_colors.dart';
import 'package:edu_cluezer/core/styles/app_decoration.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/utils/app_assets.dart';
import '../../../../widgets/custom_image_view.dart';
import '../controller/profile_controller.dart';

class ProfilePage extends GetWidget<ProfileController> {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Profile",
          style: context.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
        leading: SizedBox.square(
          dimension: 40,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: CustomImageView(
              imagePath: AppAssets.imgAppLogo,
              fit: BoxFit.contain,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {},
          ).marginSymmetric(horizontal: 12),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              spacing: 6,
              children: [
                Obx(() {
                  final p = controller.progress.value;
                  return Stack(
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            height: 80,
                            width: 80,
                            child: TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0, end: p),
                              duration: const Duration(milliseconds: 1500),
                              builder: (context, value, _) {
                                return Transform.rotate(
                                  angle: 2.7,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 6,
                                    value: value,
                                    backgroundColor: context.theme.dividerColor,
                                  ),
                                );
                              },
                            ),
                          ),

                          Positioned.fill(
                            child: Align(
                              alignment: Alignment.center,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(40),
                                child: SizedBox(
                                  height: 72,
                                  width: 72,
                                  child: CustomImageView(
                                    fit: BoxFit.cover,
                                    url:
                                        "https://images.unsplash.com/photo-1560250097-0b93528c311a?q=80&w=687&auto=format&fit=crop",
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ).marginOnly(bottom: 8),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        left: 0,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration:
                                AppDecorations.primaryBgDecoration(
                                  context,
                                ).copyWith(
                                  border: Border.all(
                                    width: 3,
                                    color: context.theme.dividerColor,
                                  ),
                                ),
                            child: Obx(
                              () => Text(
                                "${(controller.progress.value * 100).toInt()}%",
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.darkTextPrimary,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          spacing: 6,
                          children: [
                            Text(
                              "Username, 18",
                              style: context.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ).marginOnly(left: 2),
                            Icon(
                              Icons.error_outline_rounded,
                              color: context.theme.primaryColor,
                            ),
                          ],
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 5),
                          decoration: AppDecorations.primaryBgDecoration(
                            context,
                          ).copyWith(borderRadius: BorderRadius.circular(24)),
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          child: InkWell(
                            onTap: () {
                              Get.toNamed(AppRoutes.editProfile);
                            },
                            child: Row(
                              spacing: 8,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.edit,
                                  size: 20,
                                  color: context.theme.colorScheme.onPrimary,
                                ),
                                Text(
                                  "Edit Profile",
                                  style: context.textTheme.bodyMedium?.copyWith(
                                    color: context.theme.colorScheme.onPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            color: context.theme.primaryColorLight.withValues(alpha: 0.7),
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            child: Column(
              spacing: 12,
              children: [
                Row(
                  spacing: 12,
                  children: [
                    _buildItems(
                      context,
                      icon: Icons.star,
                      title: "Super Like",
                      subtitle: "Buy More",
                      gradientBorder: true,
                    ),
                    _buildItems(
                      context,
                      icon: Icons.flash_on,
                      title: "My Boost",
                      subtitle: "Get More",
                      gradientBorder: true,
                    ),
                  ],
                ),
                Row(
                  spacing: 12,
                  children: [
                    _buildItems(
                      context,
                      icon: Icons.card_membership_rounded,
                      title: "Subscription",
                      subtitle: "Select your package",
                    ),
                    _buildItems(
                      context,
                      icon: Icons.verified_rounded,
                      title: "Verification",
                      subtitle: "Get verified today",
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItems(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    bool gradientBorder = false,
  }) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: AppDecorations.cardDecoration(
          context,
        ).copyWith(borderRadius: BorderRadius.circular(30)),
        child: Row(
          spacing: 12,
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: AppDecorations.cardDecoration(
                context,
              ).copyWith(borderRadius: BorderRadius.circular(24)),
              child: Icon(icon, color: AppColors.primary),
            ),

            /// TEXT AREA
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: context.theme.textTheme.titleSmall!.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: context.theme.textTheme.bodySmall!.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
