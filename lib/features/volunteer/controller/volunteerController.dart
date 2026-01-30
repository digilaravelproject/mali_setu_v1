import 'dart:ui';
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
    'profileImage': 'https://img.freepik.com/free-photo/young-bearded-man-with-striped-shirt_273609-5677.jpg',
    'joinDate': authService.currentUser.value?.createdAt ?? 'Jan 2024',
    'totalHours': '245',
    'completedProjects': '18',
    'rating': '4.8',
  };

  // About Me
  String get aboutMe => profileData.value?.bio ?? '''
Experienced social worker with 5+ years in community service. Passionate about education and environmental conservation. Strong communication skills and team leadership experience. Fluent in Hindi, English, and Punjabi.
''';

  // Skills
  List<String> get skillList => profileData.value?.skills?.split(',').map((e) => e.trim()).toList() ?? [
    'Community Outreach',
    'Event Management',
    'Teaching/Tutoring',
    'First Aid Certified',
    'Fundraising',
    'Public Speaking',
    'Social Media Management',
    'Data Collection',
  ];

  // Experience
  List<Map<String, String>> get experiences => [
    {
      'title': profileData.value?.skills?.split(',').first ?? 'Education Volunteer',
      'organization': 'Teach India Foundation',
      'duration': profileData.value?.experience ?? 'Jan 2021 - Present',
      'description': profileData.value?.bio ?? 'Teaching underprivileged children in rural areas',
    },
  ];

  // Availability
  Map<String, String> get availability => {
    'weekdays': 'Evenings (6 PM - 9 PM)',
    'weekends': 'Full Day',
    'remote': 'Available',
    'onSite': 'Available',
    'availability': profileData.value?.availability ?? 'Not specified',
    'location': profileData.value?.location ?? 'Not specified',
  };

  // Interests
  List<String> get interestList => profileData.value?.interests ?? [
    'Education',
    'Environment',
    'Healthcare',
    'Child Welfare',
    'Animal Welfare',
    'Women Empowerment',
    'Digital Literacy',
    'Senior Citizen Care',
  ];

  // Profile Status
  final profileStatus = {
    'status': 'Active',
    'lastActive': '2 hours ago',
    'verified': true,
    'badges': ['Gold Volunteer', 'Top Performer', 'Mentor'],
  };

  // Method to toggle status
  void toggleStatus() {
    if (profileStatus['status'] == 'Active') {
      profileStatus['status'] = 'Inactive';
      Get.snackbar(
        'Status Updated',
        'Profile marked as Inactive',
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      profileStatus['status'] = 'Active';
      Get.snackbar(
        'Status Updated',
        'Profile marked as Active',
        snackPosition: SnackPosition.BOTTOM,
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