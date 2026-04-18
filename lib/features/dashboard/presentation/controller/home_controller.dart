import 'package:edu_cluezer/widgets/custom_snack_bar.dart';
import '../../../../core/utils/location_helper.dart';
import 'package:edu_cluezer/core/helper/location_helper.dart' as coord_helper;
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:edu_cluezer/core/routes/app_routes.dart';
import 'package:edu_cluezer/packages/card_swiper/src/controller/card_swiper_controller.dart';
import 'package:edu_cluezer/packages/card_swiper/src/direction/card_swiper_direction.dart';
import 'package:edu_cluezer/features/Auth/service/auth_service.dart';
import 'package:edu_cluezer/features/dashboard/data/model/user_profile_data.dart';
import 'package:edu_cluezer/features/business/data/model/res_all_business_model.dart';
import 'package:edu_cluezer/features/business/domain/usecase/get_business_categories_usecase.dart';
import 'package:edu_cluezer/features/business/domain/repository/all_business_repository.dart';
import 'package:edu_cluezer/features/dashboard/domain/usecase/get_banners_usecase.dart';
import 'package:edu_cluezer/features/dashboard/data/model/banner_model.dart';
import 'package:edu_cluezer/features/notification/presentation/controller/notification_controller.dart';

class HomeController extends GetxController with WidgetsBindingObserver {
  final RxInt currentIndex = 0.obs;
  final RxString lastSwipeDirection = ''.obs;
  final RxBool isRefreshSelected = false.obs;
  final RxBool isCloseSelected = false.obs;
  final RxBool isStarSelected = false.obs;
  final RxBool isHeartSelected = false.obs;
  final RxBool isShareSelected = false.obs;
  
  // Banners
  final GetBannersUseCase getBannersUseCase;
  final RxList<BannerData> banners = <BannerData>[].obs;
  final RxBool isLoadingBanners = false.obs;
  
  // Categories
  final GetBusinessCategoriesUseCase getBusinessCategoriesUseCase;
  final RxList<Category> categories = <Category>[].obs;
  final RxBool isLoadingCategories = false.obs;

  // Location
  final RxString currentLocation = "Detecting...".obs;

  HomeController({
    required this.getBusinessCategoriesUseCase,
    required this.getBannersUseCase,
  });
  
  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    if (Get.isRegistered<AuthService>()) {
      Get.find<AuthService>().refreshProfile();
    }

    updateLocation();
    fetchCategories();
    fetchBanners();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Re-fetch location when app comes to foreground (e.g. back from settings)
      updateLocation();
    }
  }

  Future<void> updateLocation() async {
    try {
      final location = await LocationHelper.getCurrentLocation();
      currentLocation.value = location;
    } catch (e) {
      currentLocation.value = "Location Error";
      print("Location error: $e");
    }
  }


  Future<void> refreshHomeData() async {
    try {
      isLoadingBanners.value = true;
      isLoadingCategories.value = true;

      final List<Future<dynamic>> futures = [
        updateLocation(),
        fetchBanners(),
        fetchCategories(),
      ];

      if (Get.isRegistered<AuthService>()) {
        futures.add(Get.find<AuthService>().refreshProfile());
      }

      if (Get.isRegistered<NotificationController>()) {
        futures.add(Get.find<NotificationController>().loadUnreadCount());
      }

      await Future.wait(futures);
    } catch (e) {
      print("Refresh error: $e");
    } finally {
      isLoadingBanners.value = false;
      isLoadingCategories.value = false;
    }
  }


  Future<void> fetchBanners() async {
    try {
      isLoadingBanners.value = true;
      final response = await getBannersUseCase();
      banners.assignAll(response.data);
    } catch (e) {
      print("Error fetching home banners: $e");
    } finally {
      isLoadingBanners.value = false;
    }
  }
  

  Future<void> fetchCategories() async {
    try {
      isLoadingCategories.value = true;
      final list = await getBusinessCategoriesUseCase();
      categories.assignAll(list);
    } catch (e) {
      print("Error fetching home categories: $e");
    } finally {
      isLoadingCategories.value = false;
    }
  }

  Future<void> onCategoryTap(int categoryId) async {
    try {
      Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
      
      final repository = Get.find<BusinessRepository>();
      final location = await coord_helper.LocationHelper.getCurrentLocation();
      
      if (location == null) {
        print("DEBUG_LOCATION: Location returned null in onCategoryTap");
      } else {
        print("DEBUG_LOCATION: Lat: ${location['latitude']}, Long: ${location['longitude']}");
      }

      final categoryDetails = await repository.getCategoryDetails(
        categoryId,
        lat: location?['latitude'],
        long: location?['longitude'],
      );
      
      Get.back(); // Close loading dialog

      if (categoryDetails != null) {
        print("Category Fetched: ${categoryDetails.name}");
        Get.toNamed(AppRoutes.categoryDetails, arguments: categoryDetails);
      } else {
        print("Category Details is null for ID: $categoryId");
        CustomSnackBar.showError(message: "Category details not found.");
      }
    } catch (e) {
      if (Get.isDialogOpen == true) Get.back();
      print("Error fetching category details: $e");
      CustomSnackBar.showError(message: "Failed to fetch category details: $e");
    }
  }

  Future<void> onBannerTap(int index) async {
    if (index < 0 || index >= banners.length) return;
    
    final banner = banners[index];
    final bizId = banner.businessId;
    
    if (bizId == null) {
      print("No business ID found in banner URL: ${banner.url}");
      return;
    }

    try {
      Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
      
      final repository = Get.find<BusinessRepository>();
      final response = await repository.getBusinessDetails(bizId);
      
      Get.back(); // Close loading dialog

      if (response.success == true && response.data?.data != null && response.data!.data!.isNotEmpty) {
        final business = response.data!.data!.first;
        Get.toNamed(AppRoutes.businessDetails, arguments: business);
      } else {
        print("Business Details not found for ID: $bizId");
        CustomSnackBar.showError(message: "Business details not found.");
      }
    } catch (e) {
      if (Get.isDialogOpen == true) Get.back();
      print("Error fetching business details from banner: $e");
      CustomSnackBar.showError(message: "Failed to fetch business details: $e");
    }
  }

  final List<UserProfile> users = [
    UserProfile(
      id: '1',
      name: 'Emily',
      age: 24,
      imageUrl:
          'https://images.pexels.com/photos/1391498/pexels-photo-1391498.jpeg',
      distanceKm: 5.2,
      bio: 'Love traveling and photography',
      interests: ['Travel', 'Photography', 'Coffee'],
      location: 'New York',
    ),
    UserProfile(
      id: '2',
      name: 'Sarah',
      age: 22,
      imageUrl:
          'https://images.pexels.com/photos/1542085/pexels-photo-1542085.jpeg',
      distanceKm: 8.5,
      bio: 'Yoga enthusiast and foodie',
      interests: ['Yoga', 'Cooking', 'Music'],
      location: 'Los Angeles',
    ),
    UserProfile(
      id: '3',
      name: 'Olivia',
      age: 26,
      imageUrl:
          'https://images.pexels.com/photos/1181686/pexels-photo-1181686.jpeg',
      distanceKm: 3.8,
      bio: 'Artist and nature lover',
      interests: ['Art', 'Hiking', 'Reading'],
      location: 'San Francisco',
    ),
    UserProfile(
      id: '4',
      name: 'Sophia',
      age: 23,
      imageUrl:
          'https://images.pexels.com/photos/1858175/pexels-photo-1858175.jpeg',
      distanceKm: 12.4,
      bio: 'Fitness trainer and runner',
      interests: ['Fitness', 'Running', 'Health'],
      location: 'Chicago',
    ),
    UserProfile(
      id: '5',
      name: 'Mia',
      age: 25,
      imageUrl:
          'https://images.pexels.com/photos/1239291/pexels-photo-1239291.jpeg',
      distanceKm: 6.7,
      bio: 'Dog lover and adventure seeker',
      interests: ['Dogs', 'Adventure', 'Beach'],
      location: 'Miami',
    ),
    UserProfile(
      id: '6',
      name: 'Isabella',
      age: 21,
      imageUrl:
          'https://images.pexels.com/photos/1382731/pexels-photo-1382731.jpeg',
      distanceKm: 15.2,
      bio: 'Fashion designer and coffee addict',
      interests: ['Fashion', 'Design', 'Coffee'],
      location: 'Seattle',
    ),
    UserProfile(
      id: '7',
      name: 'Ava',
      age: 27,
      imageUrl:
          'https://images.pexels.com/photos/1310522/pexels-photo-1310522.jpeg',
      distanceKm: 4.3,
      bio: 'Writer and bookworm',
      interests: ['Writing', 'Books', 'Poetry'],
      location: 'Boston',
    ),
    UserProfile(
      id: '8',
      name: 'Charlotte',
      age: 24,
      imageUrl:
          'https://images.pexels.com/photos/1065084/pexels-photo-1065084.jpeg',
      distanceKm: 9.8,
      bio: 'Music producer and DJ',
      interests: ['Music', 'DJ', 'Concerts'],
      location: 'Austin',
    ),
    UserProfile(
      id: '9',
      name: 'Amelia',
      age: 22,
      imageUrl:
          'https://images.pexels.com/photos/1130626/pexels-photo-1130626.jpeg',
      distanceKm: 7.5,
      bio: 'Dancer and choreographer',
      interests: ['Dance', 'Theater', 'Music'],
      location: 'Denver',
    ),
    UserProfile(
      id: '10',
      name: 'Harper',
      age: 26,
      imageUrl:
          'https://images.pexels.com/photos/1102341/pexels-photo-1102341.jpeg',
      distanceKm: 11.2,
      bio: 'Chef and food blogger',
      interests: ['Cooking', 'Baking', 'Wine'],
      location: 'Portland',
    ),
    UserProfile(
      id: '11',
      name: 'Evelyn',
      age: 23,
      imageUrl:
          'https://images.pexels.com/photos/1197132/pexels-photo-1197132.jpeg',
      distanceKm: 5.9,
      bio: 'Photographer and traveler',
      interests: ['Photography', 'Travel', 'Nature'],
      location: 'San Diego',
    ),
    UserProfile(
      id: '12',
      name: 'Luna',
      age: 25,
      imageUrl:
          'https://images.pexels.com/photos/1024311/pexels-photo-1024311.jpeg',
      distanceKm: 13.6,
      bio: 'Graphic designer and illustrator',
      interests: ['Design', 'Art', 'Digital'],
      location: 'Phoenix',
    ),
  ];

  final cardController = CardSwiperController();

  UserProfile? get currentUser {
    if (currentIndex.value < users.length) {
      return users[currentIndex.value];
    }
    return null;
  }


  void onSwipeComplete(
    int oldIndex,
    int? newIndex,
    CardSwiperDirection direction,
  ) {
    currentIndex.value = newIndex ?? oldIndex;
    _resetAllSelections();

    if (direction == CardSwiperDirection.right) {
      isHeartSelected.value = true;
      _handleLike();
    } else if (direction == CardSwiperDirection.left) {
      isCloseSelected.value = true;
      _handlePass();
    } else if (direction == CardSwiperDirection.top) {
      isStarSelected.value = true;
      _handleSuperLike();
    }

    Future.delayed(Duration(milliseconds: 500), _resetAllSelections);
  }

  void onDragging(CardSwiperDirection? hDir, CardSwiperDirection? vDir) {
    _resetAllSelections();

    if (hDir == CardSwiperDirection.right) {
      isHeartSelected.value = true;
      lastSwipeDirection.value = 'right';
    } else if (hDir == CardSwiperDirection.left) {
      isCloseSelected.value = true;
      lastSwipeDirection.value = 'left';
    } else if (vDir == CardSwiperDirection.top) {
      isStarSelected.value = true;
      lastSwipeDirection.value = 'top';
    } else if (vDir == CardSwiperDirection.bottom) {
      isStarSelected.value = true;
      lastSwipeDirection.value = 'bottom';
    }
  }

  void _resetAllSelections() {
    isRefreshSelected.value = false;
    isCloseSelected.value = false;
    isStarSelected.value = false;
    isHeartSelected.value = false;
    isShareSelected.value = false;
  }

  void onRefreshTap() {
    isRefreshSelected.value = true;
    _handleRefresh();
    Future.delayed(Duration(milliseconds: 300), () {
      isRefreshSelected.value = false;
    });
  }

  void onCloseTap() {
    isCloseSelected.value = true;
    _handlePass();
    Future.delayed(Duration(milliseconds: 300), () {
      isCloseSelected.value = false;
    });
  }

  void onStarTap() {
    isStarSelected.value = true;
    _handleSuperLike();
    Future.delayed(Duration(milliseconds: 300), () {
      isStarSelected.value = false;
    });
  }

  void onHeartTap() {
    isHeartSelected.value = true;
    _handleLike();
    Future.delayed(Duration(milliseconds: 300), () {
      isHeartSelected.value = false;
    });
  }

  void onShareTap() {
    isShareSelected.value = true;
    _handleShare();
    Future.delayed(Duration(milliseconds: 300), () {
      isShareSelected.value = false;
    });
  }

  void _handleRefresh() {
    if (currentIndex.value > 0) {
      currentIndex.value--;
    }
    cardController.undo();
  }

  void _handlePass() {
    cardController.swipe(CardSwiperDirection.left);
  }

  void _handleSuperLike() {
    cardController.swipe(CardSwiperDirection.top);
  }

  void _handleLike() {
    cardController.swipe(CardSwiperDirection.right);
  }

  void _handleShare() {}
}
