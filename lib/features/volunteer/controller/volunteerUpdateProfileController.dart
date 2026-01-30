import 'package:edu_cluezer/widgets/custom_snack_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../data/model/volunteer_profile_model.dart';
import '../domain/repository/volunteer_repository.dart';
import 'volunteerController.dart';

class VoluntProfileUpdateController extends GetxController {
  final VolunteerRepository repository;

  VoluntProfileUpdateController({required this.repository});

  /// Text Controllers
  final skillsCtrl = TextEditingController();
  final experienceCtrl = TextEditingController();
  final availabilityCtrl = TextEditingController();
  final locationCtrl = TextEditingController();
  final bioCtrl = TextEditingController();
  final interestsCtrl = TextEditingController();

  final RxList<String> selectedSkills = <String>[].obs;
  final RxList<String> selectedInterests = <String>[].obs;

  final RxBool isLoading = false.obs;
  final RxBool isEdit = false.obs;

  @override
  void onInit() {
    super.onInit();
    
    // Check if we are in edit mode
    if (Get.arguments != null && Get.arguments is Map && Get.arguments['isEdit'] == true) {
      isEdit.value = true;
      _prefillData();
    }
  }

  void _prefillData() {
    final profileController = Get.find<VolunteerProfileController>();
    final profile = profileController.profileData.value;

    if (profile != null) {
      experienceCtrl.text = profile.experience ?? "";
      availabilityCtrl.text = profile.availability ?? "";
      locationCtrl.text = profile.location ?? "";
      bioCtrl.text = profile.bio ?? "";
      
      if (profile.skills != null && profile.skills!.isNotEmpty) {
        selectedSkills.assignAll(profile.skills!.split(',').map((e) => e.trim()));
      }
      
      if (profile.interests != null) {
        selectedInterests.assignAll(profile.interests!);
      }
    }
  }

  final RxList<String> popularSkills = <String>[
    'Communication',
    'Leadership',
    'Problem-solving',
    'Teaching',
    'Management',
    'First Aid',
    'Event Planning',
  ].obs;

  final RxList<String> popularInterests = <String>[
    'Fitness',
    'Technology',
    'Travel',
    'Music',
    'Art',
    'Sports',
    'Reading',
  ].obs;

  /// Add new skill
  void addCustomSkill() {
    final skill = skillsCtrl.text.trim();
    if (skill.isNotEmpty && !selectedSkills.contains(skill)) {
      selectedSkills.add(skill);
      skillsCtrl.clear();
    }
  }

  /// Add from popular list
  void addPopularSkill(String skill) {
    if (!selectedSkills.contains(skill)) {
      selectedSkills.add(skill);
    }
  }

  /// Remove skill
  void removeSkill(String skill) {
    selectedSkills.remove(skill);
  }

  /// Add new interest
  void addCustomInterest() {
    final interest = interestsCtrl.text.trim();
    if (interest.isNotEmpty && !selectedInterests.contains(interest)) {
      selectedInterests.add(interest);
      interestsCtrl.clear();
    }
  }

  /// Add from popular list
  void addPopularInterest(String interest) {
    if (!selectedInterests.contains(interest)) {
      selectedInterests.add(interest);
    }
  }

  /// Remove interest
  void removeInterest(String interest) {
    selectedInterests.remove(interest);
  }

  final expLevels = [
    "Entry Level (0 Years - 2 Years)",
    "Mid Level (3 Years - 5 Years)",
    "High Level (6 Years - 9 Years)"
  ];
  
  final availabilities = [
    "Full-time",
    "Part-time",
    "Weekends Only",
    "Evenings Only"
  ];

  Future<void> onSaveProfile() async {
    isLoading.value = true;
    update();

    final Map<String, dynamic> data = {
      "skills": selectedSkills,
      "experience": experienceCtrl.text.trim(),
      "availability": availabilityCtrl.text.trim(),
      "location": locationCtrl.text.trim(),
      "bio": bioCtrl.text.trim(),
      "interests": selectedInterests,
    };

    try {
      final VolunteerProfileResponse response;
      if (isEdit.value) {
        response = await repository.updateVolunteerProfile(data);
      } else {
        response = await repository.createVolunteerProfile(data);
      }

      if (response.success == true) {
        CustomSnackBar.showSuccess(message: response.message ?? (isEdit.value ? "Profile updated successfully" : "Profile created successfully"));
        // Refresh profile data
        Get.find<VolunteerProfileController>().fetchVolunteerProfile();
        await Future.delayed(const Duration(milliseconds: 500));
        Get.back();
      } else {
        CustomSnackBar.showError(message: response.message ?? "Failed to save profile");
      }
    } catch (e) {
      CustomSnackBar.showError(message: "Something went wrong: $e");
    } finally {
      isLoading.value = false;
      update();
    }
  }

  @override
  void onClose() {
    skillsCtrl.dispose();
    experienceCtrl.dispose();
    availabilityCtrl.dispose();
    locationCtrl.dispose();
    bioCtrl.dispose();
    interestsCtrl.dispose();
    super.onClose();
  }
}
