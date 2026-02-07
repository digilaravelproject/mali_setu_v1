import 'package:edu_cluezer/common/widgets/bg_gradient_border.dart';
import 'package:edu_cluezer/core/routes/app_routes.dart';
import 'package:edu_cluezer/core/styles/app_decoration.dart';
import 'package:edu_cluezer/widgets/app_image_slider.dart';
import 'package:edu_cluezer/widgets/custom_image_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:edu_cluezer/features/Auth/service/auth_service.dart';
import 'package:edu_cluezer/core/utils/app_assets.dart';
import 'package:edu_cluezer/core/helper/string_extensions.dart';
import 'package:edu_cluezer/core/constent/api_constants.dart';
import '../../../business/presentation/page/business_page.dart';
import '../../../notification/presentation/controller/notification_controller.dart';
import '../controller/home_controller.dart';

import 'package:edu_cluezer/common/widgets/bg_gradient_border.dart';
import 'package:edu_cluezer/core/routes/app_routes.dart';
import 'package:edu_cluezer/core/styles/app_decoration.dart';
import 'package:edu_cluezer/widgets/app_image_slider.dart';
import 'package:edu_cluezer/widgets/custom_image_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:edu_cluezer/features/Auth/service/auth_service.dart';
import 'package:edu_cluezer/core/utils/app_assets.dart';
import 'package:edu_cluezer/core/helper/string_extensions.dart';
import 'package:edu_cluezer/core/constent/api_constants.dart';
import '../../../notification/presentation/controller/notification_controller.dart';
import '../controller/home_controller.dart';

class HomePage extends GetWidget<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Get.find<AuthService>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Obx(() {
        final user = authService.currentUser.value;
        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // 1. Modern Header
            SliverAppBar(
              expandedHeight: 70, 
              toolbarHeight: 70,
              pinned: true,
              floating: false,
              backgroundColor: theme.primaryColor,
              elevation: 0,
              automaticallyImplyLeading: false,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        theme.primaryColor,
                        theme.primaryColor.withOpacity(0.9),
                      ],
                    ),
                  ),
                ),
              ),
              title: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                     Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: InkWell(
                          onTap: () => Get.toNamed(AppRoutes.profileScreen),
                        child: CircleAvatar(
                          radius: 22,
                          backgroundColor: Colors.white,
                          backgroundImage: (user?.profileImage != null && user!.profileImage!.isNotEmpty)
                              ? NetworkImage(user.profileImage!)
                              : null,
                          child: (user?.profileImage == null || user!.profileImage!.isEmpty)
                              ? Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Image.asset(AppAssets.imgAppLogo),
                                )
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Welcome Back,",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          Text(
                            user?.name.toTitleCase() ?? "User Name",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                 Container(
                   margin: const EdgeInsets.only(right: 16, top: 8),
                   decoration: BoxDecoration(
                     color: Colors.white.withOpacity(0.2),
                     borderRadius: BorderRadius.circular(12),
                   ),
                   child: IconButton(
                    onPressed: () {
                      Get.toNamed(AppRoutes.notification);
                    },
                    icon: Obx(() {
                      int count = 0;
                      try {
                        final notificationController = Get.find<NotificationController>();
                        count = notificationController.unreadCount.value;
                      } catch (e) {
                        count = 0;
                      }
                  
                      return Badge(
                        label: Text(count.toString()),
                        isLabelVisible: count > 0,
                        backgroundColor: Colors.redAccent,
                        child: const Icon(CupertinoIcons.bell, color: Colors.white, size: 22),
                      );
                    }),
                  ),
                ),
              ],
            ),

            SliverToBoxAdapter(
              child: Column(
                children: [
                  // Search Bar with visual overlap
                  Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      // Header Extension (Purple background to bridge the gap)
                      Container(
                        height: 45, // Deeper curve
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              theme.primaryColor,
                              theme.primaryColor.withOpacity(0.9),
                            ],
                          ),
                          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)), // Smoother curve
                        ),
                      ),
                      // Search Bar


              InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  Get.to(() => const AllBusinessesScreen());
                },
                child: Container(
                  margin: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      )
                    ],
                  ),
                  child: AbsorbPointer( // 🔥 MAIN FIX
                    child: TextField(
                      readOnly: true,
                      decoration: InputDecoration(
                        hintText: "Search here...",
                        hintStyle: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                        ),
                        prefixIcon: Icon(
                          CupertinoIcons.search,
                          color: theme.primaryColor,
                        ),
                        border: InputBorder.none,
                        contentPadding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      ),
                    ),
                  ),
                ),
              ),


              /* InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  Get.to(() => const AllBusinessesScreen());
                },
                child: Container(
                  margin: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      )
                    ],
                  ),
                  child: AbsorbPointer( // 👈 VERY IMPORTANT
                    child: TextField(
                      enabled: false, // extra safety
                      decoration: InputDecoration(
                        hintText: "Search here...",
                        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                        prefixIcon: Icon(
                          CupertinoIcons.search,
                          color: theme.primaryColor,
                        ),
                        border: InputBorder.none,
                        contentPadding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      ),
                    ),
                  ),
                ),
              ),*/

              ],
                  ),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Column(
                      children: [
                        // 2. Banners Slider
                        Obx(() {
                          if (controller.isLoadingBanners.value) {
                            return Container(
                              height: 150,
                              decoration: BoxDecoration(
                                 color: Colors.grey[200],
                                 borderRadius: BorderRadius.circular(16)
                              ),
                              child: const Center(child: CircularProgressIndicator()),
                            );
                          }
                          if (controller.banners.isEmpty) {
                            return const SizedBox.shrink();
                          }
                          return Container(
                            height: 150,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                 BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
                              ]
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: ImageSlider(
                                indicatorType: IndicatorType.rectangle,
                                images: controller.banners
                                    .map((banner) => "${ApiConstants.imageBaseUrl}/${banner.imageUrl}")
                                    .toList(),
                                onImageTap: (index) {
                                  // Handle banner tap
                                  controller.onBannerTap(index);
                                },
                              ),
                            ),
                          );
                        }),
                        
                        const SizedBox(height: 16),

                        // 3. Categories Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Categories",
                              style: context.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                                fontSize: 18,
                                color: Colors.black87,
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                 if (controller.categories.isNotEmpty) {
                                   Get.bottomSheet(
                                     _buildAllCategoriesSheet(context),
                                     isScrollControlled: true,
                                   );
                                 }
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: Text(
                                "View All",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: theme.primaryColor,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      //  const SizedBox(height: 8),

                        // 4. Categories Grid (Home)
                        Obx(() {
                          if (controller.isLoadingCategories.value) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          if (controller.categories.isEmpty) {
                            return const SizedBox.shrink();
                          }
                          
                          final displayList = controller.categories.take(8).toList();
                          
                          return GridView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: displayList.length,
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 12,
                              childAspectRatio: 0.95,
                            ),
                            itemBuilder: (_, index) {
                              return _buildCategoryItem(context, displayList[index]);
                            },
                          );
                        }),

                        const SizedBox(height: 20),

                        // 5. Promotional Banners
                        _buildPromoCard(
                          context,
                          title: "Register your Business",
                          subtitle: "Showcase your ideas and generate leads",
                          image: "https://img.freepik.com/free-vector/modern-business-team-working-open-office-space_74855-5541.jpg",
                          buttonText: "Start Now",
                          onTap: () => Get.toNamed(AppRoutes.regBusiness),
                          color1: const Color(0xFF6B8EFF),
                          color2: const Color(0xFF536DFE),
                        ),

                        const SizedBox(height: 16),

                        _buildPromoCard(
                          context,
                          title: "Register Matrimony",
                          subtitle: "Find your soulmate for a journey of love",
                          image: "https://img.freepik.com/free-vector/wedding-couple-love_23-2148633454.jpg",
                          buttonText: "Join Now",
                          onTap: () => Get.toNamed(AppRoutes.regMatrimony),
                          color1: const Color(0xFFF48FB1),
                          color2: const Color(0xFFE91E63),
                        ),

                         const SizedBox(height: 80), // Bottom padding
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
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
            padding: const EdgeInsets.all(2),
            // decoration: BoxDecoration(
            //   shape: BoxShape.circle,
            //   border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.1), width: 1),
            //    boxShadow: [
            //     BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))
            //   ]
            // ),
               child: CustomImageView(
                height: 28,
                width: 28,
                 url: category.photo != null && category.photo!.isNotEmpty
                    ? category.photo
                    : "https://cdn-icons-png.freepik.com/512/10416/10416308.png",
                fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            category.name ?? "",
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 13,
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
    required String image,
    required String buttonText,
    required VoidCallback onTap,
    required Color color1,
    required Color color2,
  }) {
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
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CustomImageView(
                    url: image,
                    height: 100,
                    width: 100,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAllCategoriesSheet(BuildContext context) {
    return Container(
      height: Get.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Center(
             child: Container(
               width: 40,
               height: 4, 
               margin: const EdgeInsets.only(bottom: 20),
               decoration: BoxDecoration(
                 color: Colors.grey[300],
                 borderRadius: BorderRadius.circular(2)
               ),
             ),
           ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "All Categories",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              IconButton(onPressed: () => Get.back(), icon: const Icon(Icons.close)),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: GridView.builder(
              itemCount: controller.categories.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12, 
                childAspectRatio: 0.85, // Same as Home Screen
              ),
              itemBuilder: (_, index) {
                return _buildCategoryItem(context, controller.categories[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}

