import 'package:edu_cluezer/core/routes/app_routes.dart';
import 'package:edu_cluezer/core/utils/app_assets.dart';
import 'package:edu_cluezer/features/filter/presentation/page/filter_page.dart';
import 'package:edu_cluezer/packages/card_swiper/flutter_card_swiper.dart';
import 'package:edu_cluezer/widgets/custom_image_view.dart';
import 'package:edu_cluezer/widgets/custom_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'dart:ui';

import '../../../blogs/presentation/screens/full_image_screen.dart';
import '../controller/matrimony_controller.dart';
import 'package:edu_cluezer/features/matrimony/presentation/controller/reg_matrimony_controller.dart';
import 'package:edu_cluezer/features/Auth/service/auth_service.dart';
import 'package:edu_cluezer/core/constent/api_constants.dart';
import '../../data/model/search_matrimony_response.dart';
import 'package:edu_cluezer/features/filter/presentation/controller/filter_controller.dart';

class MatrimonyPage extends GetWidget<MatrimonyController> {
  const MatrimonyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final topPadding = MediaQuery.of(context).padding.top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          extendBodyBehindAppBar: true,
          // backgroundColor: Colors.grey[50],
          body: NestedScrollView(
            physics: const NeverScrollableScrollPhysics(),
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                Obx(() {
                  final authService = Get.find<AuthService>();
                  final currentUser = authService.currentUser.value;
                  final hasPayment = authService.hasPaymentForMatrimony();
                  final hasMatrimony = authService.hasMatrimony();
                  final isRestricted = !hasMatrimony || !hasPayment;

                  return SliverAppBar(
                    expandedHeight: (isRestricted ? 60 : 120) + topPadding,
                    toolbarHeight: 60 + topPadding,
                    pinned: false,
                    floating: true,
                    backgroundColor: Colors.white.withOpacity(0.9),
                    elevation: 0,
                    automaticallyImplyLeading: false,
                    flexibleSpace: FlexibleSpaceBar(
                      background: Padding(
                        padding: EdgeInsets.only(top: topPadding),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                              child: Row(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      if (currentUser?.id != null) {
                                        Get.toNamed(AppRoutes.matrimonyProfileScreen, arguments: {'id': currentUser?.id});
                                      }
                                    },
                                    child: Container(
                                      height: 44,
                                      width: 44,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset:const Offset(0, 2)),
                                        ],
                                        border: Border.all(color: Colors.white, width: 2),
                                      ),
                                      child: ClipOval(
                                        child: CustomImageView(
                                          url: currentUser?.profileImage,
                                          imagePath: AppAssets.getAppLogo(),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    'discover'.tr,
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                      color: theme.primaryColor,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                  const Spacer(),
                                  const Spacer(),

                                  if (hasMatrimony && hasPayment) ...[
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey[100],
                                        shape: BoxShape.circle,
                                      ),
                                      child: IconButton(
                                        onPressed: () => Get.toNamed(AppRoutes.matrimonyMembers),
                                        icon: Icon(Icons.people_alt_rounded, color: Colors.grey[800], size: 20),
                                        tooltip: 'members'.tr,
                                      ),
                                    ),
                                    const SizedBox(width: 8),

                                    GetBuilder<FilterController>(
                                      builder: (filterCtrl) => Stack(
                                        clipBehavior: Clip.none,
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              color: Colors.grey[100],
                                              shape: BoxShape.circle,
                                            ),
                                            child: IconButton(
                                              onPressed: () async {
                                                var result = await FilterBottomSheet.show();
                                                if (result != null) {
                                                  controller.fetchProfiles(filters: result);
                                                }
                                              },
                                              icon: Icon(Icons.tune_rounded, color: Colors.grey[800], size: 20),
                                            ),
                                          ),
                                          if (filterCtrl.activeFilterCount > 0)
                                            Positioned(
                                              top: -2,
                                              right: -2,
                                              child: Container(
                                                padding: const EdgeInsets.all(4),
                                                decoration: BoxDecoration(
                                                  color: Colors.redAccent,
                                                  shape: BoxShape.circle,
                                                  border: Border.all(color: Colors.white, width: 1.5),
                                                ),
                                                child: Text(
                                                  "${filterCtrl.activeFilterCount}",
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 8,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ]
                                ],
                              ),
                            ),
                            if (hasMatrimony && hasPayment)
                              Container(
                                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: TabBar(
                                  onTap: (index) {
                                    final filterCtrl = Get.find<FilterController>();
                                    if (index == 0) {
                                      filterCtrl.recentlyCreated.value = 'all';
                                    } else {
                                      filterCtrl.recentlyCreated.value = 'one_week';
                                    }
                                    filterCtrl.update();
                                    controller.currentIndex.value = 0;
                                    controller.fetchProfiles(filters: filterCtrl.getFilters());
                                  },
                                  dividerHeight: 0,
                                  indicator: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(24),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  indicatorSize: TabBarIndicatorSize.tab,
                                  labelColor: theme.primaryColor,
                                  unselectedLabelColor: Colors.grey[600],
                                  labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                  tabs: [
                                    Tab(text: 'all_matches'.tr),
                                    Tab(text: 'newly_joined'.tr),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ];
            },
            body: Obx(() {
              final authService = Get.find<AuthService>();
              final currentUser = authService.currentUser.value;
              final hasPayment = authService.hasPaymentForMatrimony();
              final hasMatrimony = authService.hasMatrimony();

              if (!hasMatrimony) {
                return _buildRestrictedView(context);
              }
              else if(!hasPayment){
                return _buildPymentRestrictedView(context);
              }
              try {
                if (controller.isLoading.value) {
                  return Center(child: CircularProgressIndicator(color: theme.primaryColor));
                }
                if (controller.profiles.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.style_outlined, size: 80, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text(
                          'no_matches_found'.tr,
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return TabBarView(
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildCardList(context, controller.profiles.map((e) => _mapToUserProfile(e)).toList()),
                    _buildCardList(context, controller.profiles.map((e) => _mapToUserProfile(e)).toList()),
                  ],
                );
              } catch (e) {
                print("Error in matrimony page body: $e");
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 80, color: Colors.red[300]),
                      const SizedBox(height: 16),
                      Text(
                        'error_loading_profiles'.tr,
                        style: TextStyle(
                          color: Colors.red[500],
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => controller.fetchProfiles(),
                        child: Text('retry'.tr),
                      ),
                    ],
                  ),
                );
              }
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildCardList(BuildContext context, List<UserProfile> list) {
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children:  [
            Icon(Icons.people_outline, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'no_more_profiles'.tr,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'seen_all_matches'.tr,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }
    return Column(
      children: [
        Expanded(
          flex: 8,
          //child: SafeArea(
            child: CardSwiper(
              controller: controller.swiperController,
              padding: const EdgeInsets.fromLTRB(15, 0, 15, 20),
              duration: const Duration(milliseconds: 400),
              onSwipe: (previousIndex, currentIndex, direction) {
                if (currentIndex != null) {
                  controller.currentIndex.value = currentIndex;
                }
                return true;
              },
              cardBuilder: (context, index, dx, dy) {
                try {
                  return _buildUserCard(context, list[index]);
                } catch (e) {
                  print("Error building card at index $index: $e");
                  return _buildErrorCard(context);
                }
              },
              cardsCount: list.length,
              numberOfCardsDisplayed: list.length > 1 ? 2 : 1,
            ),
          //),
        ),

        // ACTION BUTTONS
        Obx(() {
          if (controller.profiles.isEmpty || controller.currentIndex.value >= controller.profiles.length) {
            return const SizedBox(height: 72);
          }

          final currentProfile = controller.profiles[controller.currentIndex.value];
          final status = currentProfile.connectionStatus?.toLowerCase();
          final isAccepted = status == "accepted";
          final isConnected = status != "not_connected";

          return SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (!isConnected)
                    _buildActionButton(
                      onTap: () {
                        try {
                          final currentProfileId = controller.profiles[controller.currentIndex.value].userId;
                          controller.rejectRequest(currentProfileId);
                          controller.swiperController.swipe(CardSwiperDirection.left);
                        } catch (e) {
                          print("Error rejecting request: $e");
                        }
                      },
                      icon: Icons.close_rounded,
                      color: Colors.redAccent,
                      size: 30,
                      elevation: 5,
                    )
                  else
                    const SizedBox(width: 56),


                  /*if(isAccepted && currentProfile.conversationId!=null)

                  _buildActionButton(
                    onTap: isAccepted
                        ? () {
                      Get.toNamed(AppRoutes.matrimonyChat, arguments: {
                              // 'conversation_id': null,
                              // 'other_user_id': currentProfile.user?.id,

                      'conversation_id': currentProfile.conversationId,
                      'other_user_id': currentProfile.userId,
                      'user_name': currentProfile.personalDetails?.name.toString(),
                            });}
                        : () => Get.toNamed(AppRoutes.matrimonyProfileScreen, arguments: {'id': currentProfile.id}),
                    icon: isAccepted ? Icons.chat_bubble_rounded : Icons.info_rounded,
                    color: Colors.blueAccent,
                    size: 24,
                    elevation: 3,
                    isSmall: true,
                  ),*/



                  _buildActionButton(
                    onTap: (isAccepted && currentProfile.conversationId != null)
                        ? () {
                      Get.toNamed(
                        AppRoutes.matrimonyChat,
                        arguments: {
                          'conversation_id': currentProfile.conversationId,
                          'other_user_id': currentProfile.userId,
                          'user_name': currentProfile.personalDetails?.name.toString(),
                        },
                      );
                    }
                        : () => Get.toNamed(
                      AppRoutes.matrimonyProfileScreen,
                      arguments: {'id': currentProfile.id},
                    ),
                    icon: (isAccepted && currentProfile.conversationId != null)
                        ? Icons.chat_bubble_rounded
                        : Icons.info_rounded,
                    color: Colors.blueAccent,
                    size: 24,
                    elevation: 3,
                    isSmall: true,
                  ),

                  if (!isConnected)
                    _buildActionButton(
                      onTap: () {
                        try {
                          controller.sendConnectionRequest(currentProfile.userId);
                          controller.swiperController.swipe(CardSwiperDirection.right);
                        } catch (e) {
                          print("Error sending connection request: $e");
                        }
                      },
                      icon: Icons.check,
                      color: Colors.green,
                      size: 32,
                      elevation: 5,
                    )
                  else
                    const SizedBox(width: 56),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildActionButton({
    required VoidCallback? onTap,
    required IconData icon,
    required Color color,
    required double size,
    required double elevation,
    bool isSmall = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(isSmall ? 12 : 16),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Icon(icon, color: color, size: size),
      ),
    );
  }

  Widget _buildUserCard(BuildContext context, UserProfile user) {
    return GestureDetector(
      onTap: (){
        try {
          Get.toNamed(AppRoutes.matrimonyProfileScreen, arguments: {'id': user.id});
        } catch (e) {
          print("Error navigating to profile: $e");
          CustomSnackBar.showError(message: 'Error opening profile');
        }
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // BACKGROUND IMAGE with error handling
              _buildCardImage(user),

              // GRADIENT OVERLAY
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.1),
                      Colors.black.withOpacity(0.6),
                      Colors.black.withOpacity(0.9),
                    ],
                    stops: const [0.0, 0.4, 0.75, 1.0],
                  ),
                ),
              ),

              // TOP + BOTTOM CONTENT
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // TOP BADGES
                    Row(
                      children: [
                        if (user.isNew)
                          _buildGlassChip(
                            context,
                            child: Text(
                              'new'.tr,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                                color: Colors.white,
                              ),
                            ),
                            color: Theme.of(context).primaryColor,
                          ),
                        const Spacer(),
                        if (user.distance > 0)
                          _buildGlassChip(
                            context,
                            icon: Icons.near_me_rounded,
                            text: "${user.distance.toStringAsFixed(1)} KM",
                          ),
                      ],
                    ),

                    const Spacer(),

                    // NAME + AGE
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            "${user.name}, ${user.age}",
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 28,
                              color: Colors.white,
                              height: 1.1,
                            ),
                          ),
                        ),
                        if (user.isOnline)
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Colors.greenAccent,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // OCCUPATION / DESIGNATION
                    if (user.occupation != null && user.occupation!.isNotEmpty)
                      Row(
                        children: [
                          const Icon(Icons.work_outline_rounded, color: Colors.white70, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              user.occupation!,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ).marginOnly(bottom: 6),

                    // LOCATION
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, color: Colors.white70, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            user.location,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardImage(UserProfile user) {
    if (user.images.isEmpty && (user.imageUrl == null || user.imageUrl!.isEmpty)) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(Get.context!).primaryColor.withOpacity(0.8),
              Theme.of(Get.context!).primaryColor,
            ],
          ),
        ),
        child: Stack(
          children: [
            // Decorative circles
            Positioned(
              top: -30,
              right: -30,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.15),
                ),
              ),
            ),
            Positioned(
              bottom: -20,
              left: -20,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.15),
                ),
              ),
            ),
            // Center icon
            Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.person_rounded,
                  size: 80,
                  color: Theme.of(Get.context!).primaryColor,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (user.images.length > 1) {
      final PageController pageController = PageController();
      final RxInt currentIdx = 0.obs;

      return Stack(
        children: [
          PageView.builder(
            controller: pageController,
            itemCount: user.images.length,
            onPageChanged: (index) => currentIdx.value = index,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => Get.to(() => FullImageScreen(imageUrl: user.images[index])),
                child: CustomImageView(
                  url: user.images[index],
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              );
            },
          ),
          // Dot Indicators
          Positioned(
            top: 40,
            left: 0,
            right: 0,
            child: Obx(() => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(user.images.length, (index) {
                return Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: currentIdx.value == index
                        ? Colors.white
                        : Colors.white.withOpacity(0.4),
                  ),
                );
              }),
            )),
          ),
        ],
      );
    }

    return GestureDetector(
      onTap: () => Get.to(() => FullImageScreen(imageUrl: user.imageUrl!)),
      child: CustomImageView(
        url: user.imageUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorWidget: (context, url, error) {
          print("Image load error for $url: $error");
          return Container(
            color: Colors.grey[300],
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.image_not_supported_rounded, size: 60, color: Colors.grey[600]),
                  const SizedBox(height: 8),
                  Text(
                    'image_load_failed'.tr,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          );
        },
        placeHolder: (context, url) {
          return Container(
            color: Colors.grey[200],
            child: Center(
              child: CircularProgressIndicator(
                color: Theme.of(Get.context!).primaryColor,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.grey[200],
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 60, color: Colors.grey[600]),
            const SizedBox(height: 12),
            Text(
              'error_loading_profile'.tr,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassChip(BuildContext context, {Widget? child, String? text, IconData? icon, Color? color}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: (color ?? Colors.black).withOpacity(0.25),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
            borderRadius: BorderRadius.circular(20),
          ),
          child: child ?? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, color: Colors.white, size: 12),
                const SizedBox(width: 4),
              ],
              if (text != null)
                Text(
                  text,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: Colors.white,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }



  Widget _buildRestrictedView(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 40), // More compact spacing from top bar
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.lock_person_rounded,
                size: 80,
                color: theme.primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Access Restricted",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Register yourself on matrimony and payment also",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Get.toNamed(AppRoutes.regMatrimony),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Register Now",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }



  Widget _buildPymentRestrictedView(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 40), // More compact spacing from top bar
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.lock_person_rounded,
                size: 80,
                color: theme.primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Access Restricted",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "First Purchase membership for matrimony",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final regCtrl = Get.isRegistered<RegMatrimonyController>()
                      ? Get.find<RegMatrimonyController>()
                      : Get.put(RegMatrimonyController());
                  regCtrl.fetchAndShowPlans();
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Purchase Now",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }



  UserProfile _mapToUserProfile(dynamic data) {
    try {
      // If it's already a UserProfile (e.g. from local tests), return it
      if (data is UserProfile) return data;

      if (data is MatrimonyProfile) {
        return UserProfile(
          id: data.id,
          name: data.personalDetails?.name ?? 'no_name'.tr,
          age: data.age ?? 0,
          location: "${data.locationDetails?.city ?? 'unknown_city'.tr}, ${data.locationDetails?.state ?? ''}",
          occupation: data.professionalDetails?.jobTitle ?? data.personalDetails?.occupation ?? 'professional'.tr,
          images: (data.personalDetails?.photos != null)
              ? data.personalDetails!.photos!.map((e) => "${ApiConstants.imageBaseUrl}$e").toList()
              : [],
          imageUrl: (data.personalDetails?.photos != null && data.personalDetails!.photos!.isNotEmpty)
              ? "${ApiConstants.imageBaseUrl}${data.personalDetails!.photos![0]}"
              : null,
          distance: 0.0, // Backend might need to provide this
          isNew: data.createdAt != null && DateTime.now().difference(DateTime.parse(data.createdAt!)).inDays < 7,
          isOnline: false,
          interests: data.personalDetails?.hobbies ?? [],
          connectionStatus: data.connectionStatus,
        );
      }

      // Fallback/Legacy Mapping
      final personal = data['personal_details'] ?? {};
      final location = data['location_details'] ?? {};
      final List<String> legacyPhotos = personal['photos'] != null
          ? List<String>.from(personal['photos']).map((e) => "${ApiConstants.imageBaseUrl}$e").toList()
          : (data['image'] != null ? ["${ApiConstants.imageBaseUrl}${data['image']}"] : []);

      return UserProfile(
        id: data['id'],
      //  name: personal[''] ?? data['name'] ?? 'no_name'.tr,
        name: [
          personal['title'],
          personal['first_name'],
          personal['last_name']
        ]
            .where((e) => e != null && e.toString().trim().isNotEmpty)
            .join(' ')
            .isNotEmpty
            ? [
          personal['title'],
          personal['first_name'],
          personal['last_name']
        ]
            .where((e) => e != null && e.toString().trim().isNotEmpty)
            .join(' ')
            : 'no_name'.tr,

        age: int.tryParse(personal['age']?.toString() ?? data['age']?.toString() ?? "0") ?? 0,
        location: "${location['city'] ?? ''}, ${location['state'] ?? ''}",
        occupation: personal['occupation'] ?? 'professional'.tr,
        images: legacyPhotos,
        imageUrl: legacyPhotos.isNotEmpty ? legacyPhotos[0] : null,
        distance: double.tryParse(data['distance']?.toString() ?? "0") ?? 0.0,
        isNew: data['is_new'] == true,
        isOnline: data['is_online'] == true,
        interests: List<String>.from(personal['hobbies'] ?? []),
      );
    } catch (e) {
      print("Error mapping user profile: $e");
      // Return a safe fallback profile
      return UserProfile(
        id: null,
        name: 'error_loading'.tr,
        age: 0,
        location: 'unknown_location'.tr,
        imageUrl: null,
        distance: 0.0,
        isNew: false,
        isOnline: false,
        interests: [],
      );
    }
  }
}

class UserProfile {
  final int? id;
  final String name;
  final int age;
  final String location;
  final String? imageUrl;
  final List<String> images;
  final double distance;
  final bool isNew;
  final bool isOnline;
  final String? occupation;
  final List<String> interests;
  final String? connectionStatus;
  final dynamic user; // For extra mapping if needed

  UserProfile({
    required this.id,
    required this.name,
    required this.age,
    required this.location,
    required this.imageUrl,
    this.images = const [],
    required this.distance,
    required this.isNew,
    this.isOnline = false,
    this.occupation,
    this.interests = const [],
    this.connectionStatus,
    this.user,
  });
}

