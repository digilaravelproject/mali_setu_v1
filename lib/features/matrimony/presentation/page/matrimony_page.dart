import 'package:edu_cluezer/core/routes/app_routes.dart';
import 'package:edu_cluezer/core/utils/app_assets.dart';
import 'package:edu_cluezer/features/filter/presentation/page/filter_page.dart';
import 'package:edu_cluezer/packages/card_swiper/flutter_card_swiper.dart';
import 'package:edu_cluezer/widgets/custom_image_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:ui';

import '../controller/matrimony_controller.dart';
import 'package:edu_cluezer/features/Auth/service/auth_service.dart';
import 'package:edu_cluezer/core/constent/api_constants.dart';
import '../../data/model/search_matrimony_response.dart';
import 'package:edu_cluezer/features/filter/presentation/controller/filter_controller.dart';

class MatrimonyPage extends GetWidget<MatrimonyController> {
  const MatrimonyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          centerTitle: true,
          title: Text(
            "DISCOVER",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: theme.primaryColor,
              letterSpacing: 1.2,
            ),
          ),
          leading: Obx(() {
            final user = Get.find<AuthService>().currentUser.value;
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: () {}, // Maybe profile settings?
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset:const Offset(0, 2)),
                    ],
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: ClipOval(
                    child: CustomImageView(
                      url: user?.profileImage,
                      imagePath: AppAssets.imgAppLogo,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            );
          }),
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: () => Get.toNamed(AppRoutes.matrimonyMembers),
                icon: Icon(Icons.people_alt_rounded, color: Colors.grey[800]),
                tooltip: "Members",
              ),
            ),
            GetBuilder<FilterController>(
              builder: (filterCtrl) => Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    margin: const EdgeInsets.only(right: 16),
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
                      icon: Icon(Icons.tune_rounded, color: Colors.grey[800]),
                    ),
                  ),
                  if (filterCtrl.activeFilterCount > 0)
                    Positioned(
                      top: 4,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: Text(
                          "${filterCtrl.activeFilterCount}",
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                tabs: const [
                  Tab(text: "ALL MATCHES"),
                  Tab(text: "NEWLY JOINED"),
                ],
              ),
            ),
          ),
        ),
        body: Obx(() {
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
                    "No matches found",
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
        }),
      ),
    );
  }

  Widget _buildCardList(BuildContext context, List<UserProfile> list) {
    return Column(
      children: [
        Expanded(
          child: CardSwiper(
            controller: controller.swiperController,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            duration: const Duration(milliseconds: 400),
            onSwipe: (previousIndex, currentIndex, direction) {
              if (currentIndex != null) {
                controller.currentIndex.value = currentIndex;
              }
              return true;
            },
            cardBuilder: (context, index, dx, dy) {
              return _buildUserCard(context, list[index]);
            },
            cardsCount: list.length,
          ),
        ),
        const SizedBox(height: 20),
        
        // ACTION BUTTONS
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Reject Button
              _buildActionButton(
                onTap: () {
                    final currentProfileId = controller.profiles[controller.currentIndex.value].id;
                    controller.rejectRequest(currentProfileId);
                    controller.swiperController.swipe(CardSwiperDirection.left);
                },
                icon: Icons.close_rounded,
                color: Colors.redAccent,
                size: 30,
                elevation: 5,
              ),

              // Super Like / Chat (Middle)
              Obx(() {
                 if (controller.profiles.isEmpty) return const SizedBox();
                 final currentProfile = controller.profiles[controller.currentIndex.value];
                 // If already connected, show chat
                 final status = currentProfile.connectionStatus?.toLowerCase();
                 final isAccepted = status == "accepted";

                 return _buildActionButton(
                    onTap: isAccepted ? () => Get.toNamed(AppRoutes.matrimonyChat, arguments: {
                      'conversation_id': null,
                      'other_user_id': currentProfile.user?.id,
                    }) : () {
                      // Maybe super like functionality or just info
                      Get.toNamed(AppRoutes.matrimonyProfileScreen, arguments: {'id': currentProfile.id});
                    },
                    icon: isAccepted ? Icons.chat_bubble_rounded : Icons.info_rounded,
                    color: Colors.blueAccent,
                    size: 24,
                    elevation: 3,
                    isSmall: true,
                 );
              }),

              // Connect/Like Button
               Obx(() {
                  if (controller.profiles.isEmpty) return const SizedBox();
                  final currentProfile = controller.profiles[controller.currentIndex.value];
                  final status = currentProfile.connectionStatus?.toLowerCase();
                  final isConnected = status != "not_connected";
                  
                  return _buildActionButton(
                    onTap: isConnected ? null : () {
                      controller.sendConnectionRequest(currentProfile.id);
                      controller.swiperController.swipe(CardSwiperDirection.right);
                    },
                    icon: isConnected ? Icons.check : Icons.favorite_rounded,
                    color: isConnected ? Colors.green : Colors.purpleAccent,
                    size: 32,
                    elevation: 5,
                  );
               }),
            ],
          ),
        ),
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
        Get.toNamed(AppRoutes.matrimonyProfileScreen, arguments: {'id': user.id});
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
              // BACKGROUND IMAGE
              CustomImageView(
                url: user.imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),

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
                            child: const Text(
                              "NEW",
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

  UserProfile _mapToUserProfile(dynamic data) {
    // If it's already a UserProfile (e.g. from local tests), return it
    if (data is UserProfile) return data;
    
    if (data is MatrimonyProfile) {
       return UserProfile(
          id: data.id,
          name: data.personalDetails?.name ?? 'No Name',
          age: data.age ?? 0,
          location: "${data.locationDetails?.city ?? 'Unknown'}, ${data.locationDetails?.state ?? ''}",
          occupation: data.professionalDetails?.jobTitle ?? data.personalDetails?.occupation ?? "Professional",
          imageUrl: (data.personalDetails?.photos != null && data.personalDetails!.photos!.isNotEmpty) 
              ? "${ApiConstants.imageBaseUrl}${data.personalDetails!.photos![0]}" 
              : "https://images.unsplash.com/photo-1494790108377-be9c29b29330",
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
    
    return UserProfile(
      id: data['id'],
      name: personal['name'] ?? data['name'] ?? 'No Name',
      age: int.tryParse(personal['age']?.toString() ?? data['age']?.toString() ?? "0") ?? 0,
      location: "${location['city'] ?? ''}, ${location['state'] ?? ''}",
      occupation: personal['occupation'] ?? "Professional",
      imageUrl: data['image'] ?? data['imageUrl'] ?? "https://images.unsplash.com/photo-1494790108377-be9c29b29330",
      distance: double.tryParse(data['distance']?.toString() ?? "0") ?? 0.0,
      isNew: data['is_new'] == true,
      isOnline: data['is_online'] == true,
      interests: List<String>.from(personal['hobbies'] ?? []),
    );
  }
}

class UserProfile {
  final int? id;
  final String name;
  final int age;
  final String location;
  final String imageUrl;
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
    required this.distance,
    required this.isNew,
    this.isOnline = false,
    this.occupation,
    this.interests = const [],
    this.connectionStatus,
    this.user,
  });
}

