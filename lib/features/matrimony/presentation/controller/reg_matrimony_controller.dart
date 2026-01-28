import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class RegMatrimonyController extends GetxController {
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

  /// Rx Option Selectors
  final gender = ''.obs;
  final physicalStatus = ''.obs;
  final maritalStatus = ''.obs;
  final eatingHabit = ''.obs;
  final dosh = ''.obs;
  final currentStep = 0.obs;

  void nextStep() {
    if (currentStep.value < 3) {
      currentStep.value++;
    }
  }

  void previousStep() {
    if (currentStep.value > 0) {
      currentStep.value--;
    }
  }

  /// Dropdown Data
  final countries = ["India", "UK", "USA"];
  final states = ["UP", "Delhi", "Bihar"];
  final cities = ["Lucknow", "Kanpur"];
  final educations = ["Graduate", "Post Graduate"];
  final employmentTypes = ["Private", "Government", "Business"];
  final languages = ["Hindi", "English"];
  final familyTypes = ["Joint", "Nuclear"];
  final religions = ["Hindu", "Muslim", "Christian"];
  final castes = ["General", "OBC", "SC", "ST"];
  final stars = ["Ashwini", "Bharani"];
  final rashis = ["Mesh", "Vrishabh"];

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

  @override
  void onClose() {
    for (final c in [
      countryCtrl,
      stateCtrl,
      cityCtrl,
      birthTimeCtrl,
      citizenshipCtrl,
      educationCtrl,
      employmentCtrl,
      motherTongueCtrl,
      familyTypeCtrl,
      drinkingCtrl,
      smokingCtrl,
      religionCtrl,
      casteCtrl,
      starCtrl,
      rashiCtrl,
      manglikCtrl,
    ]) {
      c.dispose();
    }
    super.onClose();
  }
}
