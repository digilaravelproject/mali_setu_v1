import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class CreateJobController extends GetxController {
  /// Text Controllers
  final countryCtrl = TextEditingController();
  final stateCtrl = TextEditingController();
  final cityCtrl = TextEditingController();
  final birthTimeCtrl = TextEditingController();
  final citizenshipCtrl = TextEditingController();
  final educationCtrl = TextEditingController();
  final employmentCtrl = TextEditingController();
  final motherTongueCtrl = TextEditingController();
  final familyTypeCtrl = TextEditingController();
  final drinkingCtrl = TextEditingController();
  final smokingCtrl = TextEditingController();
  final religionCtrl = TextEditingController();
  final casteCtrl = TextEditingController();
  final starCtrl = TextEditingController();
  final rashiCtrl = TextEditingController();
  final manglikCtrl = TextEditingController();
  final jobTypeCtrl = TextEditingController();
  final experienceCtrl = TextEditingController();


  final benefitsCtrl = TextEditingController();
  final RxList<String> selectedBenefits = <String>[].obs;
  final RxList<String> popularBenefits = <String>[
    'Flexible working hours',
    'Paid time off',
    'Remote work options',
    'Professional development',
    'Stock options',
    'Dental insurance',
    'Vision insurance',
    'Life insurance',
  ].obs;

  final skillsCtrl = TextEditingController();
  final RxList<String> selectedSkills = <String>[].obs;
  final RxList<String> popularSkills = <String>[
    'PHP',
    'Laravel',
    'MySQL',
    'REST API',
    'Flutter',
    'Dart',
    'Android',
  ].obs;

  /// Add new benefit
  void addCustomBenefit() {
    final benefit = benefitsCtrl.text.trim();
    if (benefit.isNotEmpty && !selectedBenefits.contains(benefit)) {
      selectedBenefits.add(benefit);
      benefitsCtrl.clear();
    }
  }

  /// Add from popular list
  void addPopularBenefit(String benefit) {
    if (!selectedBenefits.contains(benefit)) {
      selectedBenefits.add(benefit);
    }
  }

  /// Remove benefit
  void removeBenefit(String benefit) {
    selectedBenefits.remove(benefit);
  }

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

  /// Remove benefit
  void removeSkill(String skill) {
    selectedSkills.remove(skill);
  }

  /// Rx Option Selectors
  final gender = ''.obs;
  final physicalStatus = ''.obs;
  final maritalStatus = ''.obs;
  final eatingHabit = ''.obs;
  final dosh = ''.obs;

  /// Dropdown Data
  final countries = ["India", "UK", "USA"];
  final states = ["UP", "Delhi", "Bihar"];
  final cities = ["Lucknow", "Kanpur"];
  final educations = ["Graduate", "Post Graduate"];
 // final employmentTypes = ["Private", "Government", "Business"];
  final languages = ["Hindi", "English"];
  final familyTypes = ["Joint", "Nuclear"];
  final religions = ["Hindu", "Muslim", "Christian"];
  final castes = ["General", "OBC", "SC", "ST"];
  final stars = ["Ashwini", "Bharani"];
  final rashis = ["Mesh", "Vrishabh"];

  final jobTypes = ["On Site", "Remote", "Hybrid"];
  final expLevel = ["Entry Level (0 Years - 2 Years)","Mid Level (3 Years - 5 Years)", "High Level (6 Years - 9 Years)"];
  final employmentTypes = ["Full Time", "Part Time", "InternShip", "FreeLancer"];
  final categories = ["Flutter Developer", "Android Developer", "Laravel Developer"];

  final maritalStatuses = [
    'Never Married',
    'Awaiting Divorce',
    'Divorced',
    'Widowed',
  ];

  final eatingHabits = ['Vegetarian', 'Non-Vegetarian', 'Eggetarian'];

  void onRegister() {
    // Validate & Submit
  }

  // @override
  // void onClose() {
  //   for (final c in [
  //     countryCtrl,
  //     stateCtrl,
  //     cityCtrl,
  //     birthTimeCtrl,
  //     citizenshipCtrl,
  //     educationCtrl,
  //     employmentCtrl,
  //     motherTongueCtrl,
  //     familyTypeCtrl,
  //     drinkingCtrl,
  //     smokingCtrl,
  //     religionCtrl,
  //     casteCtrl,
  //     starCtrl,
  //     rashiCtrl,
  //     manglikCtrl,
  //   ]) {
  //     c.dispose();
  //   }
  //   super.onClose();
  // }
}

