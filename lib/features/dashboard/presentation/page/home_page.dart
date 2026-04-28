import 'package:edu_cluezer/common/widgets/bg_gradient_border.dart';
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
import '../../../business/presentation/page/business_page.dart';
import '../../../notification/presentation/controller/notification_controller.dart';
import '../../../../core/widgets/shimmer_loading.dart';
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
                                       children: [
                                         Icon(Icons.location_on, size: 10, color: Colors.grey[600]),
                                         const SizedBox(width: 2),
                                         Text(
                                           controller.currentLocation.value,
                                           style: TextStyle(
                                             fontSize: 10,
                                             color: Colors.grey[600],
                                             fontWeight: FontWeight.w500,
                                           ),
                                         ),
                                       ],
                                     )),
                                   ],
                                 ),
                              ],
                            ),
                            const Spacer(),
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
                                  label: Text(count.toString()),
                                  isLabelVisible: count > 0,
                                  backgroundColor: Colors.redAccent,
                                  child: const Icon(CupertinoIcons.bell, color: Colors.black87, size: 24),
                                ),
                              );
                            }),
                            const SizedBox(width: 16),
                            // Profile Avatar
                            InkWell(
                              onTap: () => Get.toNamed(AppRoutes.profileScreen),
                              child: Hero(
                                tag: 'profile_avatar',
                                child: CircleAvatar(
                                  radius: 16,
                                  backgroundColor: Colors.grey[200],
                                  backgroundImage: (user?.profileImage != null && user!.profileImage!.isNotEmpty)
                                      ? NetworkImage(
                                      user.profileImage!.startsWith('http')
                                          ? user.profileImage!
                                          : "${ApiConstants.imageBaseUrl}${user.profileImage}"
                                  ) : null,
                                  child: (user?.profileImage == null || user!.profileImage!.isEmpty)
                                      ? const Icon(CupertinoIcons.person_fill, color: Colors.grey, size: 20)
                                      : null,
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
                          return Container(
                            height: 130,
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            child: const ShimmerLoading.rounded(height: 130),
                          );
                        }
                        if (controller.banners.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        return Container(
                          height: 130,
                          margin: const EdgeInsets.only(top: 4, bottom: 8),
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(0), boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
                          ]),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(0),
                            child: ImageSlider(
                              indicatorType: IndicatorType.rectangle,
                              images: controller.banners
                                  .map((banner) => "${ApiConstants.imageBaseUrl}/${banner.imageUrl}")
                                  .toList(),
                              onImageTap: (index) {
                                controller.onBannerTap(index);
                              },
                            ),
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

                              final displayList = controller.categories.length > 12
                                  ? controller.categories.take(11).toList()
                                  : controller.categories.toList();
                              
                              final showViewAll = controller.categories.length > 12;

                              return GridView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                padding: EdgeInsets.zero,
                                itemCount: showViewAll ? 12 : displayList.length,
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 4,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 4,
                                  childAspectRatio: 0.85,
                                ),
                                itemBuilder: (context, index) {
                                  if (showViewAll && index == 11) {
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
          Text(
            _capitalizeText(category.name ?? ""),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 11,
              color: Colors.grey[800],
              height: 1.2,
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
            _buildAllCategoriesSheet(context),
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
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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