import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:edu_cluezer/features/Auth/service/auth_service.dart';
import 'package:edu_cluezer/core/helper/string_extensions.dart';

class VolunteerProfileController extends GetxController {
  final authService = Get.find<AuthService>();

  // Volunteer Data
  Map<String, String> get volunteerData => {
    'name': authService.currentUser.value?.name.toTitleCase() ?? 'Rahul Sharma',
    'role': authService.currentUser.value?.occupation.toTitleCase() ?? 'Community Volunteer',
    'profileImage': 'https://img.freepik.com/free-photo/young-bearded-man-with-striped-shirt_273609-5677.jpg',
    'joinDate': authService.currentUser.value?.createdAt ?? 'Jan 2024',
    'totalHours': '245',
    'completedProjects': '18',
    'rating': '4.8',
  };

  // About Me
  final aboutMe = '''
Experienced social worker with 5+ years in community service. Passionate about education and environmental conservation. Strong communication skills and team leadership experience. Fluent in Hindi, English, and Punjabi.
''';

  // Skills
  final skills = [
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
  final experiences = [
    {
      'title': 'Education Volunteer',
      'organization': 'Teach India Foundation',
      'duration': 'Jan 2021 - Present',
      'description': 'Teaching underprivileged children in rural areas',
    },
    {
      'title': 'Environmental Activist',
      'organization': 'Green Earth Society',
      'duration': 'Jun 2020 - Dec 2022',
      'description': 'Organized tree plantation drives and awareness campaigns',
    },
    {
      'title': 'Disaster Relief Volunteer',
      'organization': 'National Relief Organization',
      'duration': 'Mar 2020 - May 2020',
      'description': 'Provided aid during flood relief operations',
    },
  ];

  // Availability
  final availability = {
    'weekdays': 'Evenings (6 PM - 9 PM)',
    'weekends': 'Full Day',
    'remote': 'Available',
    'onSite': 'Available',
  };

  // Interests
  final interests = [
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
    return profileStatus['status'] == 'Active'
        ? Get.theme.colorScheme.primary
        : Colors.grey;
  }
}