
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FilterController extends GetxController {
  // Age range
  final RxDouble minAge = 18.0.obs;
  final RxDouble maxAge = 50.0.obs;

  // Distance range (in km)
  final RxDouble maxDistance = 50.0.obs;

  final educationCtrl = TextEditingController();
  final familyStatusCtrl = TextEditingController();
  final countryCtrl = TextEditingController();
  final smokingCtrl = TextEditingController();
  final profileCreatedByCtrl = TextEditingController();
  final mothertangueCtrl = TextEditingController();

  RxBool isProfileWithPhoto = false.obs;

  // For radio-style selection
  RxString selectedDontShowOption = "".obs; // "ignored", "shortlisted", etc.

  // Initialize if needed
  void init() {
    selectedDontShowOption.value = "ignored";
  }

    // Basic Details
  RangeValues ageRange = RangeValues(25, 35);
  RangeValues salaryRange = RangeValues(25000, 80000);
  RangeValues heightRange = RangeValues(150, 180);
  List<String> maritalStatus = ['Never Married'];
  List<String> motherTongue = ['Hindi'];

  // Professional Details
  List<String> education = ['Bachelor\'s Degree'];
  List<String> profession = [];
  String annualIncome = 'Any';
  List<String> workingWith = [];

  // Religion Details
  List<String> religion = ['Hindu'];
  List<String> caste = [];
  String gothra = '';
  String manglik = "Doesn't Matter";

  RxBool isPrivate = false.obs;
  RxBool isNearbyChecked = false.obs;
  // Family Details
  String familyStatus = 'Middle Class';
  List<String> familyType = ['Nuclear'];
  List<String> familyValues = ['Moderate'];
  String fatherOccupation = '';

  // Location Details
  String country = 'India';
  String state = '';
  String city = '';
  List<String> citizenship = ['Indian'];

  // Lifestyle
  List<String> diet = ['Vegetarian'];
  String smoking = 'No';
  String drinking = 'No';
  List<String> hobbies = [];
  //RxBool isNearbyChecked = false.obs;

  void toggleNearby(bool value) {
    isNearbyChecked.value = value;
    // Additional logic if needed
    if (value) {
      // Do something when checked
    } else {
      // Do something when unchecked
    }
  }
  // Profile Type
  List<String> profileCreatedBy = ['Self'];
  String profileFor = 'Self';
  String withPhoto = "Doesn't Matter";
  String verifiedProfiles = "Doesn't Matter";

  // Recently Created
  List<String> createdInLast = ['Any'];
  List<String> lastActive = ['Any'];
  String updatedProfiles = 'Any';

  final educationList = [ 'High School',
    'Bachelor\'s Degree',
    'Master\'s Degree',
    'PhD',
    'Diploma',
    'CA/CS/ICWA',
    'MBA',
    'Other'];

  final familyList = [
    'Middle Class',
    'Upper Middle Class',
    'Rich',
    'PhD',
    'Affluent',
  ];

  final countryList =[
    "India",
    "UK",
    "USA",
  ];


  final languageList =[
    "Hindi",
    "English",
    "Bengali",
    "Tamil",
    "Telugu",
    "Marathi",
  ];

  final smokingHabits =[
    'No', 'Occasionally', 'Yes', "Doesn't Matter"
  ];
  final profileCreatedByList =[
    'No', 'Occasionally', 'Yes', "Doesn't Matter"
  ];

  // Other methods remain same...


  // Looking for
  final RxString lookingFor = 'Everyone'.obs;
  final List<String> lookingForOptions = [
    'Everyone',
    'Men',
    'Women',
    'Non-binary',
  ];

  // Interests
  final RxList<String> selectedInterests = <String>[].obs;
  final List<String> availableInterests = [
    'Travel',
    'Music',
    'Movies',
    'Sports',
    'Reading',
    'Cooking',
    'Art',
    'Gaming',
    'Fitness',
    'Photography',
    'Dancing',
    'Yoga',
    'Fashion',
    'Technology',
    'Food',
    'Nature',
    'Pets',
    'Coffee',
  ];

  // Relationship type
  final RxString relationshipType = 'Any'.obs;
  final List<String> relationshipTypes = [
    'Any',
    'Long-term',
    'Short-term',
    'Friendship',
    'Casual',
  ];

  // Verification status
  final RxBool verifiedOnly = false.obs;

  // Has bio
  final RxBool hasBio = false.obs;

  // Has photos count
  final RxInt minPhotos = 1.obs;

  void toggleInterest(String interest) {
    if (selectedInterests.contains(interest)) {
      selectedInterests.remove(interest);
    } else {
      selectedInterests.add(interest);
    }
  }


  void resetFilters() {
    minAge.value = 18.0;
    maxAge.value = 50.0;
    maxDistance.value = 50.0;
    lookingFor.value = 'Everyone';
    selectedInterests.clear();
    relationshipType.value = 'Any';
    verifiedOnly.value = false;
    hasBio.value = false;
    minPhotos.value = 1;



    ageRange = RangeValues(25, 35);
    heightRange = RangeValues(150, 180);
    salaryRange = RangeValues(25000, 80000);
    maritalStatus = ['Never Married'];
    motherTongue = ['Hindi'];
    education = ['Bachelor\'s Degree'];
    profession = [];
    annualIncome = 'Any';
    workingWith = [];
    religion = ['Hindu'];
    caste = [];
    gothra = '';
    manglik = "Doesn't Matter";
    familyStatus = 'Middle Class';
    familyType = ['Nuclear'];
    familyValues = ['Moderate'];
    fatherOccupation = '';
    country = 'India';
    state = '';
    city = '';
    citizenship = ['Indian'];
    diet = ['Vegetarian'];
    smoking = 'No';
    drinking = 'No';
    hobbies = [];
    profileCreatedBy = ['Self'];
    profileFor = 'Self';
    withPhoto = "Doesn't Matter";
    verifiedProfiles = "Doesn't Matter";
    createdInLast = ['Any'];
    lastActive = ['Any'];
    updatedProfiles = 'Any';
    update();
  }

  void applyFilters() {
    Get.back();
    Get.snackbar(
      'Filters Applied',
      'Your preferences have been updated',
      snackPosition: SnackPosition.BOTTOM,
      duration: Duration(seconds: 2),
    );
  }
}





