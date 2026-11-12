import 'package:edu_cluezer/common/widgets/bg_gradient_border.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:edu_cluezer/core/routes/app_routes.dart';
import 'package:edu_cluezer/core/styles/app_decoration.dart';
import 'package:edu_cluezer/widgets/app_image_slider.dart';
import 'package:edu_cluezer/widgets/custom_image_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:edu_cluezer/features/Auth/service/auth_service.dart';
import 'package:edu_cluezer/core/utils/app_assets.dart';
import 'package:edu_cluezer/core/helper/string_extensions.dart';
import 'package:edu_cluezer/core/constent/api_constants.dart';
import '../../../../widgets/category_paginated_bottom_sheet.dart';
import '../../../../widgets/language_selection_dialog.dart';
import '../../../business/presentation/page/business_page.dart';
import '../../../notification/presentation/controller/notification_controller.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../../../core/widgets/whatsapp_support_fab.dart';
import 'package:edu_cluezer/core/styles/app_colors.dart';
import '../../../webinars/presentation/controllers/webinars_controller.dart';
import '../../../webinars/presentation/pages/webinar_details_screen.dart';
import '../../../webinars/presentation/pages/webinar_live_screen.dart';
import '../../../webinars/presentation/widgets/webinar_registration_sheet.dart';
import '../../../webinars/data/models/webinar_model.dart';
import '../../data/model/banner_model.dart';
import '../../../referral/presentation/binding/referral_binding.dart';
import '../../../referral/presentation/widgets/volunteer_prompt_dialog.dart';
import '../controller/home_controller.dart';

class HomePage extends GetWidget<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Get.find<AuthService>();
    final currentUser = authService.currentUser.value;
   // final authService = Get.find<AuthService>();
    final theme = Theme.of(context);
    final topPadding = MediaQuery.of(context).padding.top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark, // Set to dark for white background
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.white,
        body: Obx(() {
          final hasPayment = Get.find<AuthService>().hasPaymentForMatrimony();
          final hasMatrimony = Get.find<AuthService>().hasMatrimony();
          final user = authService.currentUser.value;

          return RefreshIndicator(
            onRefresh: () async {
              await controller.refreshHomeData();
            },
            color: theme.primaryColor,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: ClampingScrollPhysics(),
              ),
              slivers: [
                // 1. Scrollable Header (SliverAppBar with pinned: false)
                SliverAppBar(
                  expandedHeight: 55 + topPadding,
                  toolbarHeight: 55 + topPadding,
                  pinned: false,
                  floating: true,
                  backgroundColor: Colors.white,
                  elevation: 0,
                  automaticallyImplyLeading: false,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      color: Colors.white,
                      padding: EdgeInsets.only(top: topPadding),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Row(
                          children: [
                            // App Logo & Name
                            Row(
                              children: [
                                Image.asset(
                                  AppAssets.getAppLogo(),
                                  height: 28,
                                  fit: BoxFit.contain,
                                ),
                                const SizedBox(width: 8),
                                 Column(
                                   crossAxisAlignment: CrossAxisAlignment.start,
                                   mainAxisSize: MainAxisSize.min,
                                   children: [
                                     Text(
                                       "Mali Setu",
                                       style: TextStyle(
                                         fontSize: 18,
                                         fontWeight: FontWeight.w900,
                                         color: theme.primaryColor,
                                         letterSpacing: -0.5,
                                       ),
                                     ),
                                     Obx(() => Row(
                                       mainAxisSize: MainAxisSize.min,
                                       children: [
                                         Icon(Icons.location_on, size: 10, color: Colors.grey[600]),
                                         const SizedBox(width: 2),
                                         ConstrainedBox(
                                           constraints: BoxConstraints(
                                             maxWidth: MediaQuery.of(context).size.width * 0.35,
                                           ),
                                           child: Text(
                                             controller.currentLocation.value,
                                             style: TextStyle(
                                               fontSize: 10,
                                               color: Colors.grey[600],
                                               fontWeight: FontWeight.w500,
                                             ),
                                             maxLines: 1,
                                             overflow: TextOverflow.ellipsis,
                                           ),
                                         ),
                                       ],
                                     )),
                                   ],
                                 ),
                              ],
                            ),
                            const Spacer(),
                            // Language Change Icon (A ⇄ अ)
                            const LanguageAppBarButton(),
                            const SizedBox(width: 16),
                            // Notification Icon
                            Obx(() {
                              int count = 0;
                              try {
                                final notificationController = Get.find<NotificationController>();
                                count = notificationController.unreadCount.value;
                              } catch (e) { count = 0; }
                              return InkWell(
                                onTap: () => Get.toNamed(AppRoutes.notification),
                                child: Badge(
                                  label: Text(count > 99 ? '99+' : count.toString()),
                                  isLabelVisible: count > 0,
                                  backgroundColor: Colors.redAccent,
                                  child: const Icon(CupertinoIcons.bell, color: Colors.black87, size: 24),
                                ),
                              );
                            }),
                            const SizedBox(width: 24),
                            // Profile Avatar
                            InkWell(
                              onTap: () => Get.toNamed(AppRoutes.settings),
                              child: Hero(
                                tag: 'profile_avatar',
                                child: Container(
                                  width: 34,
                                  height: 34,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.grey[200],
                                    border: Border.all(
                                      color: Colors.grey[300]!,
                                      width: 1,
                                    ),
                                  ),
                                  child: ClipOval(
                                    child: (user?.profileImage != null && user!.profileImage!.isNotEmpty)
                                        ? CachedNetworkImage(
                                            imageUrl: user!.profileImage!.startsWith('http')
                                                ? user!.profileImage!
                                                : "${ApiConstants.imageBaseUrl}${user!.profileImage}",
                                            fit: BoxFit.cover,
                                            width: 34,
                                            height: 34,
                                            placeholder: (context, url) => Container(
                                              color: Colors.grey[200],
                                            ),
                                            errorWidget: (context, url, error) => const Icon(
                                              CupertinoIcons.person_fill,
                                              color: Colors.grey,
                                              size: 20,
                                            ),
                                          )
                                        : const Icon(
                                            CupertinoIcons.person_fill,
                                            color: Colors.grey,
                                            size: 20,
                                          ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      // Search Bar with visual overlap
                      // Modern Search Bar
                      InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => Get.to(() => const AllBusinessesScreen()),
                        child: Container(
                          margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.black.withOpacity(0.8), width: 1),
                            boxShadow: [],
                          ),
                          child: Row(
                            children: [
                              Icon(CupertinoIcons.search, color: Colors.black54, size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'search_your_business'.tr,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                              Container(
                                width: 1,
                                height: 20,
                                margin: const EdgeInsets.symmetric(horizontal: 8),
                                color: Colors.black.withOpacity(0.15),
                              ),
                              Icon(Icons.mic, color: theme.primaryColor, size: 22),
                            ],
                          ),
                        ),
                      ),

                      // Banners Slider
                      Obx(() {
                        if (controller.isLoadingBanners.value) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 4, bottom: 8),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                AspectRatio(
                                  aspectRatio: 2.5,
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 16),
                                    child: ShimmerLoading.withBorderRadius(
                                      height: double.infinity,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(
                                    3,
                                    (index) => Container(
                                      margin: const EdgeInsets.symmetric(horizontal: 3),
                                      width: index == 0 ? 18 : 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: context.isDarkMode
                                            ? Colors.white12
                                            : Colors.grey.shade300,
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        if (controller.banners.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 4, bottom: 8),
                          child: ImageSlider(
                            aspectRatio: 2.5,
                            isIndicatorBelow: true,
                            indicatorSpacing: 8,
                            fit: BoxFit.fill,
                            indicatorType: IndicatorType.dot,
                            autoScrollInterval: const Duration(seconds: 5),
                            scrollAnimationDuration: const Duration(milliseconds: 800),
                            images: controller.banners
                                .map((banner) => "${ApiConstants.imageBaseUrl}/${banner.imageUrl}")
                                .toList(),
                            onImageTap: (index) {
                              controller.onBannerTap(index);
                            },
                          ),
                        );
                      }),

                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Column(
                          children: [
                            const SizedBox(height: 0),
                            // Row(
                            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            //   children: [
                            //     Text(
                            //       'categories'.tr,
                            //       style: context.textTheme.titleLarge?.copyWith(
                            //         fontWeight: FontWeight.w800,
                            //         fontSize: 18,
                            //         color: Colors.black87,
                            //       ),
                            //     ),
                            //   ],
                            // ),
                            const SizedBox(height: 12),
                            Obx(() {
                              if (controller.isLoadingCategories.value) {
                                return _buildCategoryShimmer();
                              }
                              
                              if (controller.categories.isEmpty) {
                                if (controller.isCategoryError.value) {
                                  return _buildCategoryErrorWidget();
                                }
                                return const SizedBox.shrink();
                              }

                              final displayList = controller.categories.take(11).toList();
                              
                              final showViewAll = true; // Always show View All to open bottom sheet

                              return GridView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                padding: EdgeInsets.zero,
                                itemCount: displayList.length + 1, // Add 1 for View All button
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 4,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 4,
                                  childAspectRatio: 0.76,
                                ),
                                itemBuilder: (context, index) {
                                  if (index == displayList.length) {
                                    return _buildViewAllCategoryItem(context);
                                  }
                                  return _buildCategoryItem(context, displayList[index]);
                                },
                              );
                            }),

                            const SizedBox(height: 48),
                            //const SizedBox(height: 20),
                            _buildPromoCard(
                              context,
                              title: 'register_your_business'.tr,
                              subtitle: 'showcase_ideas'.tr,
                              icon: Icons.store_rounded,
                              buttonText: 'start_now'.tr,
                              onTap: () => Get.toNamed(AppRoutes.regBusiness),
                              color1: const Color(0xFF6B8EFF),
                              color2: const Color(0xFF536DFE),
                            ),

                            const SizedBox(height: 16),

                            (!hasMatrimony)
                                ? _buildPromoCard(
                              context,
                              title: 'register_matrimony'.tr,
                              subtitle: 'find_soulmate'.tr,
                              icon: Icons.favorite_rounded,
                              buttonText: 'join_now'.tr,
                              onTap: () => Get.toNamed(AppRoutes.regMatrimony),
                              color1: const Color(0xFFF48FB1),
                              color2: const Color(0xFFE91E63),
                            )
                                : _buildPromoCard(
                              context,
                              title: 'view_profile'.tr,
                              subtitle: 'find_soulmate'.tr,
                              icon: Icons.favorite_rounded,
                              buttonText: "view_profile".tr,
                              onTap: () {
                                if (currentUser?.id != null) {
                                  Get.toNamed(AppRoutes.matrimonyProfileScreen, arguments: {'id': currentUser?.id});
                                }
                              },
                             // onTap: () => Get.toNamed(AppRoutes.regMatrimony, arguments: true),
                              color1: const Color(0xFFF48FB1),
                              color2: const Color(0xFFE91E63),
                              statusText: user?.matrimonyApprovalStatus ?? "Pending",
                            ),

                            const SizedBox(height: 16),

                            // Volunteer Registration or Referral Analytics Card
                            Builder(
                              builder: (context) {
                                final userType = (user?.userType ?? VolunteerPromptDialog.getUserTypeFromPrefs()).toLowerCase().trim();
                                final bool isVolunteer = userType == 'volunteer';

                                if (isVolunteer) {
                                  return _buildPromoCard(
                                    context,
                                    title: 'referral_analytics'.tr,
                                    subtitle: 'volunteer_dialog_desc'.tr,
                                    icon: Icons.insights_rounded,
                                    buttonText: 'check_analytics_btn'.tr,
                                    onTap: () {
                                      ReferralBinding.init();
                                      Get.toNamed(AppRoutes.referralAnalytics);
                                    },
                                    color1: const Color(0xFF10B981),
                                    color2: const Color(0xFF059669),
                                  );
                                } else {
                                  return _buildPromoCard(
                                    context,
                                    title: 'become_volunteer_title'.tr,
                                    subtitle: 'become_volunteer_note'.tr,
                                    icon: Icons.volunteer_activism_rounded,
                                    buttonText: 'register_volunteer_btn'.tr,
                                    onTap: () {
                                      VolunteerPromptDialog.checkAndShow(force: true);
                                    },
                                    color1: const Color(0xFFC62D86),
                                    color2: const Color(0xFF8B185D),
                                    secondaryText: 'view_analytics_btn'.tr,
                                    onSecondaryTap: () {
                                      ReferralBinding.init();
                                      Get.toNamed(AppRoutes.referralAnalytics);
                                    },
                                  );
                                }
                              },
                            ),

                            // Leaderboard Section (Top Champions from banner API)
                            if (controller.leaderboard.isNotEmpty) ...[
                              const SizedBox(height: 22),
                              _buildLeaderboardSection(context, controller.leaderboard),
                            ],

                            // Upcoming Webinars Section (only shown when banner API returns upcoming webinars)
                            if (controller.upcomingWebinars.isNotEmpty) ...[
                              const SizedBox(height: 22),
                              // Section Heading: Upcoming Webinars | See All
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 2.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Text(
                                      "Upcoming Webinars",
                                      style: TextStyle(
                                        fontSize: 16.5,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.lightTextPrimary,
                                        letterSpacing: -0.2,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () => Get.toNamed(AppRoutes.webinars),
                                      behavior: HitTestBehavior.opaque,
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            "See All",
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                          SizedBox(width: 3),
                                          Icon(
                                            Icons.arrow_forward_ios_rounded,
                                            size: 11,
                                            color: AppColors.primary,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                              _buildWebinarPromoCard(context, controller.upcomingWebinars),
                            ],

                            const SizedBox(height: 120),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCategoryItem(BuildContext context, dynamic category) {
    return GestureDetector(
      onTap: () {
        if (category.id != null) {
          controller.onCategoryTap(category.id!);
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            // decoration: BoxDecoration(
            //   shape: BoxShape.circle,
            //   color: Theme.of(context).primaryColor.withOpacity(0.08),
            // ),
            child: CustomImageView(
              height: 32,
              width: 32,
              url: category.photo != null && category.photo!.isNotEmpty
                  ? category.photo
                  : "https://cdn-icons-png.freepik.com/512/10416/10416308.png",
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 2),
          Flexible(
            child: Text(
              _capitalizeText(category.name ?? ""),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 11,
                color: Colors.grey[800],
                height: 1.1,
              ),
            ),
          ),
        ],
      ),
    );
  }
 
  Widget _buildViewAllCategoryItem(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (controller.categories.isNotEmpty) {
          Get.bottomSheet(
            CategoryPaginatedBottomSheet(
              onCategorySelected: (category) {
                if (category.id != null) {
                  controller.onCategoryTap(category.id!);
                }
              },
            ),
            isScrollControlled: true,
          );
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 48,
            width: 48,
            child: Center(
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).primaryColor,
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).primaryColor.withOpacity(0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'view_all'.tr,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 11,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromoCard(
      BuildContext context, {
        required String title,
        required String subtitle,
        required IconData icon,
        required String buttonText,
        required VoidCallback onTap,
        required Color color1,
        required Color color2,
        String? statusText,
        String? secondaryText,
        VoidCallback? onSecondaryTap,
      }) {
    Color getStatusColor(String status) {
      switch (status.toLowerCase().trim()) {
        case 'approved':
        case 'active':
          return Colors.green;
        case 'pending':
          return Colors.orange;
        case 'rejected':
        case 'inactive':
          return Colors.red;
        default:
          return Colors.grey;
      }
    }
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [color1.withOpacity(0.1), color2.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: color1.withOpacity(0.3), width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600],
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 10,
                        runSpacing: 8,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [color1, color2]),
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: color2.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Text(
                              buttonText,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (secondaryText != null && onSecondaryTap != null)
                            GestureDetector(
                              onTap: onSecondaryTap,
                              behavior: HitTestBehavior.opaque,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: color1.withOpacity(0.4), width: 1),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.04),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.insights_rounded,
                                      size: 14,
                                      color: color2,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      secondaryText,
                                      style: TextStyle(
                                        color: color2,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(width: 2),
                                    Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      size: 9,
                                      color: color2,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [color1.withOpacity(0.2), color2.withOpacity(0.1)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        icon,
                        size: 60,
                        color: color1,
                      ),
                    ),
                    if (statusText != null && statusText.isNotEmpty)
                      Positioned(
                        top: -4,
                        right: -4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: getStatusColor(statusText),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white, width: 2.5),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Text(
                            statusText.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
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
      ),
    );
  }

  Widget _buildWebinarPromoCard(BuildContext context, List<Webinar> webinars) {
    if (webinars.isEmpty) return const SizedBox.shrink();

    final featured = webinars.first;
    final isLive = featured.isLive;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          colors: [
            AppColors.primaryLight.withOpacity(0.55),
            Colors.white,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.28),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: () {
            Get.toNamed(AppRoutes.webinarDetails, arguments: featured);
          },
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Row: LIVE/UPCOMING Badge + Category Chip + View All
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                      decoration: BoxDecoration(
                        color: isLive ? const Color(0xFFEF4444) : const Color(0xFFEF4444).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                            radius: 3,
                            backgroundColor: isLive ? Colors.white : const Color(0xFFEF4444),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isLive ? "LIVE NOW" : "UPCOMING WEBINAR",
                            style: TextStyle(
                              color: isLive ? Colors.white : const Color(0xFFEF4444),
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),

                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        featured.category,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),

                    const Spacer(),

                    // Duration chip
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.access_time_rounded,
                            size: 11,
                            color: Color(0xFF64748B),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            featured.duration,
                            style: const TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Middle Row: Dynamic Title & Speaker + Video Badge
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            featured.title,
                            style: const TextStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.lightTextPrimary,
                              letterSpacing: -0.2,
                              height: 1.25,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(
                                CupertinoIcons.person_crop_circle_fill,
                                size: 14,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 5),
                              Expanded(
                                child: Text(
                                  featured.speaker.name,
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF475569),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: AppColors.primary.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.videocam_rounded,
                              color: AppColors.primary,
                              size: 26,
                            ),
                          ),
                        ),
                        Positioned(
                          top: -3,
                          right: -3,
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(
                              color: Color(0xFFEF4444),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.play_arrow_rounded, size: 8, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Divider
                Container(
                  height: 1,
                  color: AppColors.primary.withOpacity(0.12),
                ),

                const SizedBox(height: 10),

                // Bottom Row: Date/Time + Registrations Count + Action Button
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_rounded,
                            size: 13,
                            color: Color(0xFF64748B),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            featured.dateString,
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF334155),
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Icon(
                            Icons.people_alt_outlined,
                            size: 13,
                            color: Color(0xFF64748B),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "${featured.registeredCount} joined",
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF334155),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.primaryDark],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.28),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            isLive ? "Join Now" : "Register Now",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            size: 12,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLeaderboardSection(BuildContext context, List<LeaderboardItem> items) {
    if (items.isEmpty) return const SizedBox.shrink();

    // Sort by rank ascending
    final sorted = List<LeaderboardItem>.from(items)
      ..sort((a, b) => a.rank.compareTo(b.rank));

    LeaderboardItem? getRank(int r) {
      for (final item in sorted) {
        if (item.rank == r) return item;
      }
      return null;
    }

    final top1 = getRank(1) ?? (sorted.isNotEmpty ? sorted[0] : null);
    final top2 = getRank(2) ?? (sorted.length > 1 ? sorted[1] : null);
    final top3 = getRank(3) ?? (sorted.length > 2 ? sorted[2] : null);
    final others = sorted.where((e) => e != top1 && e != top2 && e != top3).toList();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.22),
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header with Primary Gradient Aura & Trophy
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFFFF0F7),
                  Colors.white.withValues(alpha: 0.95),
                  const Color(0xFFFFF5FA),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
            ),
            child: Row(
              children: [
                // Primary Gradient Trophy Badge
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFE0409A), Color(0xFF8B185D)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                      const BoxShadow(
                        color: Colors.white,
                        blurRadius: 4,
                        offset: Offset(-1, -1),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(Icons.emoji_events_rounded, color: Colors.white, size: 24),
                  ),
                ),
                const SizedBox(width: 12),

                // Title & Subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'leaderboard_title'.tr,
                            style: const TextStyle(
                              fontSize: 16.5,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF1E293B),
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFC62D86), Color(0xFF8B185D)],
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              "LIVE",
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'leaderboard_subtitle'.tr,
                        style: TextStyle(
                          fontSize: 11.5,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                // View All Button
                GestureDetector(
                  onTap: () {
                    ReferralBinding.init();
                    Get.toNamed(AppRoutes.referral);
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.35),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'leaderboard_view_all'.tr,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 3),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 10,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, thickness: 1, color: Color(0xFFF8E7F1)),

          // 3D Realistic Podium Stage (Primary Themed)
          Container(
            padding: const EdgeInsets.fromLTRB(10, 16, 10, 0),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFFF9FC), Colors.white],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Rank 2 (Silver - Left)
                    if (top2 != null)
                      Expanded(
                        child: _buildPodiumColumn(
                          item: top2,
                          rank: 2,
                          medalEmoji: "🥈",
                          pedestalHeight: 74,
                          avatarSize: 52,
                          accentColor: const Color(0xFF78909C),
                          gradientColors: const [Color(0xFFECEFF1), Color(0xFFCFD8DC), Color(0xFF90A4AE)],
                        ),
                      )
                    else
                      const Expanded(child: SizedBox()),

                    // Rank 1 (Primary Brand Theme - Center)
                    if (top1 != null)
                      Expanded(
                        child: _buildPodiumColumn(
                          item: top1,
                          rank: 1,
                          medalEmoji: "🥇",
                          pedestalHeight: 102,
                          avatarSize: 66,
                          isFirst: true,
                          accentColor: AppColors.primary,
                          gradientColors: const [Color(0xFFE8439E), Color(0xFFC62D86), Color(0xFF8B185D)],
                        ),
                      ),

                    // Rank 3 (Warm Bronze - Right)
                    if (top3 != null)
                      Expanded(
                        child: _buildPodiumColumn(
                          item: top3,
                          rank: 3,
                          medalEmoji: "🥉",
                          pedestalHeight: 58,
                          avatarSize: 48,
                          accentColor: const Color(0xFF8D6E63),
                          gradientColors: const [Color(0xFFFFE0B2), Color(0xFFD7CCC8), Color(0xFFA1887F)],
                        ),
                      )
                    else
                      const Expanded(child: SizedBox()),
                  ],
                ),

                // Floor Stage Runner (Harmonized with Primary Palette)
                Container(
                  height: 6,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFF3E1EC), Color(0xFFD9B6CB), Color(0xFFF3E1EC)],
                    ),
                    borderRadius: BorderRadius.circular(3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),

          // Additional Ranks (Rank 4, 5...)
          if (others.isNotEmpty) ...[
            const Divider(height: 1, thickness: 0.8, color: Color(0xFFEEEEEE)),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              itemCount: others.length.clamp(0, 3),
              separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFF5F5F5)),
              itemBuilder: (context, index) {
                final item = others[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF5FA),
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.primary.withValues(alpha: 0.25), width: 1),
                        ),
                        child: Center(
                          child: Text(
                            "#${item.rank}",
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: CachedNetworkImage(
                          imageUrl: item.photoUrl ?? '',
                          width: 34,
                          height: 34,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => CircleAvatar(
                            radius: 17,
                            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                            child: Text(
                              item.name.isNotEmpty ? item.name[0].toUpperCase() : '?',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primary),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.black87),
                            ),
                            if (item.referralCode.isNotEmpty)
                              Text(
                                item.referralCode,
                                style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                              ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.stars_rounded, size: 14, color: AppColors.primary),
                              const SizedBox(width: 3),
                              Text(
                                "${item.totalEarnedPoints} ${'points_label'.tr}",
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.primary),
                              ),
                            ],
                          ),
                          Text(
                            "${item.totalReferrals} ${'referrals_label'.tr}",
                            style: TextStyle(fontSize: 10.5, color: Colors.grey.shade500, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ],

          // Footer Call-to-action
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFFFF0F7),
                  Colors.white.withValues(alpha: 0.95),
                  const Color(0xFFFFF5F9),
                ],
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(22),
                bottomRight: Radius.circular(22),
              ),
              border: Border(
                top: BorderSide(color: AppColors.primary.withValues(alpha: 0.12)),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.rocket_launch_rounded, color: AppColors.primary, size: 15),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'refer_and_win'.tr,
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    ReferralBinding.init();
                    Get.toNamed(AppRoutes.referral);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFC62D86), Color(0xFF8B185D)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFC62D86).withValues(alpha: 0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'refer_now'.tr,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 2),
                        const Icon(Icons.arrow_forward_rounded, size: 11, color: Colors.white),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPodiumColumn({
    required LeaderboardItem item,
    required int rank,
    required String medalEmoji,
    required double pedestalHeight,
    required double avatarSize,
    required Color accentColor,
    required List<Color> gradientColors,
    bool isFirst = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Top Crown for Rank 1 or Medal emoji
        if (isFirst)
          const Padding(
            padding: EdgeInsets.only(bottom: 4),
            child: Icon(Icons.workspace_premium_rounded, color: AppColors.primary, size: 24),
          )
        else
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(medalEmoji, style: const TextStyle(fontSize: 18)),
          ),

        // Avatar with Glowing Metal Ring & Medal Ribbon
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            // Outer Glow ring
            Container(
              padding: EdgeInsets.all(isFirst ? 3.5 : 2.5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withValues(alpha: isFirst ? 0.45 : 0.25),
                    blurRadius: isFirst ? 14 : 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: item.photoUrl ?? '',
                    width: avatarSize,
                    height: avatarSize,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => Container(
                      width: avatarSize,
                      height: avatarSize,
                      color: Colors.grey.shade100,
                      child: Center(
                        child: Text(
                          item.name.isNotEmpty ? item.name[0].toUpperCase() : '?',
                          style: TextStyle(
                            fontSize: avatarSize * 0.45,
                            fontWeight: FontWeight.w900,
                            color: accentColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Pinned Medal Badge at bottom of avatar
            Positioned(
              bottom: -6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isFirst
                        ? [const Color(0xFFE8439E), const Color(0xFF8B185D)]
                        : [accentColor, accentColor.withValues(alpha: 0.85)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.18),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  rank == 1 ? "1st" : (rank == 2 ? "2nd" : "3rd"),
                  style: const TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // Member Name
        SizedBox(
          width: isFirst ? 105 : 95,
          child: Text(
            item.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isFirst ? 13 : 11.5,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1E293B),
            ),
          ),
        ),

        // Referral Code Pill
        if (item.referralCode.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 1, bottom: 3),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF5FA),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isFirst
                      ? AppColors.primary.withValues(alpha: 0.3)
                      : Colors.grey.shade200,
                  width: 0.8,
                ),
              ),
              child: Text(
                item.referralCode,
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                  color: isFirst ? AppColors.primary : Colors.blueGrey.shade700,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),

        // Points & Referrals Micro Badges
        Container(
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: isFirst ? const Color(0xFFFFF0F7) : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isFirst
                  ? AppColors.primary.withValues(alpha: 0.25)
                  : Colors.grey.shade200,
              width: 0.8,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.stars_rounded, size: 12, color: isFirst ? AppColors.primary : accentColor),
                  const SizedBox(width: 2),
                  Text(
                    "${item.totalEarnedPoints} ${'points_label'.tr}",
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      color: isFirst ? AppColors.primary : Colors.black87,
                    ),
                  ),
                ],
              ),
              Text(
                "${item.totalReferrals} ${'referrals_label'.tr}",
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),

        // 3D Realistic Pedestal Block
        Container(
          width: double.infinity,
          height: pedestalHeight,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            boxShadow: [
              BoxShadow(
                color: accentColor.withValues(alpha: 0.25),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              // 3D Top Bevel Highlight Cap
              Container(
                height: 5,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.5),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  // Embossed circular medallion for rank number
                  child: Container(
                    width: isFirst ? 42 : 36,
                    height: isFirst ? 42 : 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.28),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.7),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        "$rank",
                        style: TextStyle(
                          fontSize: isFirst ? 24 : 20,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.25),
                              offset: const Offset(0, 1.5),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAllCategoriesSheet(BuildContext context) {
    String searchQuery = '';
    return Container(
      height: Get.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      child: StatefulBuilder(
        builder: (context, setState) {
          final filteredCategories = controller.categories.where((category) {
            final catName = category.name?.toLowerCase() ?? '';
            return catName.contains(searchQuery.toLowerCase());
          }).toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2) ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "all_categories".tr,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  IconButton(onPressed: () => Get.back(), icon: const Icon(Icons.close)),
                ],
              ),
              const SizedBox(height: 10),
              TextField(
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search Category...',
                  prefixIcon: const Icon(CupertinoIcons.search, color: Colors.black54, size: 20),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 1),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: filteredCategories.isEmpty
                    ? Center(
                        child: Text(
                          "No categories found",
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      )
                    : GridView.builder(
                        itemCount: filteredCategories.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 4,
                          childAspectRatio: 0.85,
                        ),
                        itemBuilder: (_, index) {
                          return _buildCategoryItem(context, filteredCategories[index]);
                        },
                      ),
              ),
            ],
          );
        }
      ),
    );
  }

  Widget _buildCategoryShimmer() {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      itemCount: 8,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 16,
        mainAxisSpacing: 4,
        childAspectRatio: 0.85,
      ),
      itemBuilder: (context, index) {
        return Column(
          children: [
            const ShimmerLoading.circular(width: 40, height: 40),
            const SizedBox(height: 8),
            Container(
              alignment: Alignment.center,
              child: const ShimmerLoading.rectangular(height: 10, width: 60),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCategoryErrorWidget() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 32),
          const SizedBox(height: 8),
          Text(
            "Failed to load categories",
            style: TextStyle(color: Colors.red[700], fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () => controller.fetchCategories(),
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text("Retry"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }

  String _capitalizeText(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }
}