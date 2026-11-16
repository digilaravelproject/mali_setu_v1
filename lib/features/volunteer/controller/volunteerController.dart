import 'package:edu_cluezer/widgets/custom_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:edu_cluezer/features/Auth/service/auth_service.dart';
import 'package:edu_cluezer/core/helper/string_extensions.dart';
import '../domain/repository/volunteer_repository.dart';
import '../data/model/volunteer_profile_model.dart';

class VolunteerProfileController extends GetxController {
  final VolunteerRepository repository;
  final authService = Get.find<AuthService>();

  VolunteerProfileController({required this.repository,});

  final Rxn<VolunteerProfileData> profileData = Rxn<VolunteerProfileData>();
  final RxBool isLoading = false.obs;


  @override
  void onInit() {
    super.onInit();
    fetchVolunteerProfile();
  }

  Future<void> fetchVolunteerProfile() async {
    isLoading.value = true;
    update();
    try {
      final response = await repository.getVolunteerProfile();
      if (response.success == true) {
        profileData.value = response.data;
      }
    } catch (e) {
      debugPrint("Error fetching volunteer profile: $e");
    } finally {
      isLoading.value = false;
      update();
    }
  }

  // Volunteer Data
  Map<String, String> get volunteerData => {
    'name': authService.currentUser.value?.name.toTitleCase() ?? 'Volunteer',
    'role': profileData.value?.skills?.split(',').first ?? authService.currentUser.value?.occupation.toTitleCase() ?? 'Community Volunteer',
    'profileImage': authService.currentUser.value?.profileImage ?? '',
    'joinDate': authService.currentUser.value?.createdAt ?? '',
    'totalHours': '0',
    'completedProjects': '0',
    'rating': '-',
  };

  // About Me
  String get aboutMe => profileData.value?.bio ?? '';

  // Skills
  List<String> get skillList => profileData.value?.skills
      ?.split(',')
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList() ?? [];

  // Experience
  List<Map<String, String>> get experiences => profileData.value != null
      ? [
          {
            'title': profileData.value?.skills?.split(',').first ?? 'Volunteer',
            'organization': '',
            'duration': profileData.value?.experience ?? '',
            'description': profileData.value?.bio ?? '',
          },
        ]
      : [];

  // Availability
  Map<String, String> get availability => {
    'weekdays': profileData.value?.availability ?? 'Not specified',
    'weekends': profileData.value?.availability ?? 'Not specified',
    'remote': 'Available',
    'onSite': 'Available',
    'availability': profileData.value?.availability ?? 'Not specified',
    'location': profileData.value?.location ?? 'Not specified',
  };

  // Interests
  List<String> get interestList => profileData.value?.interests ?? [];

  // Profile Status
  final profileStatus = {
    'status': 'Active',
    'lastActive': '',
    'verified': false,
    'badges': <String>[],
  };

  // Method to toggle status
  void toggleStatus() {
    if (profileStatus['status'] == 'Active') {
      profileStatus['status'] = 'Inactive';
      CustomSnackBar.showInfo(
        message: 'Profile marked as Inactive',
      );
    } else {
      profileStatus['status'] = 'Active';
      CustomSnackBar.showInfo(
        message: 'Profile marked as Active',
      );
    }
    update();
  }

  // Get status color
  Color getStatusColor() {
    String status = profileData.value?.status ?? profileStatus['status'] as String;
    return status.toLowerCase() == 'active'
        ? Get.theme.colorScheme.primary
        : Colors.grey;
  }
}