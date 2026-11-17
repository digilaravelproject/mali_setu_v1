
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FilterController extends GetxController {
  // Age range
  final RxDouble minAge = 18.0.obs;
  final RxDouble maxAge = 50.0.obs;

  // Distance range (in km)
  final RxDouble maxDistance = 50.0.obs;

  // Text Controllers
  final educationCtrl = TextEditingController();
  final familyStatusCtrl = TextEditingController();
  final countryCtrl = TextEditingController();
  final smokingCtrl = TextEditingController();
  final profileCreatedByCtrl = TextEditingController();
  final mothertangueCtrl = TextEditingController();
  final stateCtrl = TextEditingController();
  final cityCtrl = TextEditingController();

  RxBool isProfileWithPhoto = false.obs;

  // For radio-style selection
  RxString selectedDontShowOption = "".obs; // "ignored", "shortlisted", etc.
  final RxString recentlyCreated = 'all'.obs;

  // Initialize if needed
  void init() {
    selectedDontShowOption.value = "ignored";
  }

  // Basic Details
  RangeValues ageRange = RangeValues(18, 60);
  RangeValues salaryRange = RangeValues(0, 5000000); // Default wider range
  RangeValues heightRange = const RangeValues(0.0, 20.0); // Default full range in feet
  List<String> maritalStatus = [];
  List<String> physicalStatus = [];
  List<String> motherTongue = [];

  // Professional Details
  List<String> education = [];
  List<String> profession = [];
  String annualIncome = 'Any';
  List<String> workingWith = [];

  // Religion Details
  List<String> religion = [];
  List<String> caste = [];
  String gothra = '';
  String manglik = "Doesn't Matter";

  RxBool isPrivate = false.obs;
  RxBool isNearbyChecked = false.obs;
  // Family Details
  String familyStatus = 'Any';
  List<String> familyType = [];
  List<String> familyValues = [];
  String fatherOccupation = '';

  // Location Details
  String country = '';
  String state = '';
  String city = '';
  List<String> citizenship = [];

  // State and City lists
  final stateList = [
    'Andhra Pradesh',
    'Arunachal Pradesh',
    'Assam',
    'Bihar',
    'Chhattisgarh',
    'Goa',
    'Gujarat',
    'Haryana',
    'Himachal Pradesh',
    'Jharkhand',
    'Karnataka',
    'Kerala',
    'Madhya Pradesh',
    'Maharashtra',
    'Manipur',
    'Meghalaya',
    'Mizoram',
    'Nagaland',
    'Odisha',
    'Punjab',
    'Rajasthan',
    'Sikkim',
    'Tamil Nadu',
    'Telangana',
    'Tripura',
    'Uttar Pradesh',
    'Uttarakhand',
    'West Bengal',
  ];

  final cityList = [
    'Mumbai',
    'Delhi',
    'Bangalore',
    'Hyderabad',
    'Chennai',
    'Kolkata',
    'Pune',
    'Ahmedabad',
    'Jaipur',
    'Lucknow',
    'Chandigarh',
    'Indore',
    'Kochi',
    'Visakhapatnam',
    'Surat',
    'Nagpur',
    'Bhopal',
    'Coimbatore',
    'Vadodara',
    'Ghaziabad',
    'Ludhiana',
    'Agra',
    'Nashik',
    'Faridabad',
    'Meerut',
    'Rajkot',
    'Kalyan-Dombivali',
    'Vasai-Virar',
    'Varanasi',
    'Srinagar',
  ];

  // Lifestyle
  List<String> diet = [];
  String smoking = 'Any';
  String drinking = 'Any';
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
  List<String> profileCreatedBy = [];
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
    "Marathi",
    "Hindi",
    "English",
    "Bengali",
    "Tamil",
    "Telugu",
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


    ageRange = RangeValues(18, 60);
    heightRange = const RangeValues(0.0, 20.0);
    salaryRange = RangeValues(0, 5000000);
    maritalStatus = [];
    physicalStatus = [];
    motherTongue = [];
    education = [];
    profession = [];
    annualIncome = 'Any';
    workingWith = [];
    religion = [];
    caste = [];
    gothra = '';
    manglik = "Doesn't Matter";
    familyStatus = 'Any';
    familyType = [];
    familyValues = [];
    fatherOccupation = '';
    country = '';
    state = '';
    city = '';
    citizenship = [];
    diet = [];
    smoking = 'Any';
    drinking = 'Any';
    hobbies = [];
    profileCreatedBy = [];
    profileFor = 'Self';
    withPhoto = "Doesn't Matter";
    verifiedProfiles = "Doesn't Matter";
    createdInLast = ['Any'];
    lastActive = ['Any'];
    updatedProfiles = 'Any';
    recentlyCreated.value = 'all';
    isProfileWithPhoto.value = false;
    isPrivate.value = false;
    isNearbyChecked.value = false;
    selectedDontShowOption.value = "";

    // Clear text controllers
    educationCtrl.clear();
    familyStatusCtrl.clear();
    countryCtrl.clear();
    smokingCtrl.clear();
    profileCreatedByCtrl.clear();
    mothertangueCtrl.clear();
    stateCtrl.clear();
    cityCtrl.clear();

    update();
  }

  Map<String, dynamic> getFilters() {
    final Map<String, dynamic> filters = {};

    // Basic Details
    // Only send age if range is customized (not 18-60 default)
    if (ageRange.start > 18 || ageRange.end < 60) {
      filters['age_min'] = ageRange.start.round();
      filters['age_max'] = ageRange.end.round();
    }

    if (profileCreatedByCtrl.text.isNotEmpty && profileCreatedByCtrl.text != 'Any') {
      filters['profile_created_by'] = profileCreatedByCtrl.text;
    } else if (profileCreatedBy.isNotEmpty && profileCreatedBy.first != 'Any') {
      filters['profile_created_by'] = profileCreatedBy.first;
    }

    if (maritalStatus.isNotEmpty && maritalStatus.first != 'Any' && maritalStatus.first != 'any'.tr) {
      filters['marital_status'] = maritalStatus.first;
    }

    if (mothertangueCtrl.text.isNotEmpty && mothertangueCtrl.text != 'Any') {
      filters['language'] = mothertangueCtrl.text;
      filters['mother_tongue'] = mothertangueCtrl.text;
    }

    if (heightRange.start > 0.0 || heightRange.end < 20.0) {
      filters['height'] = heightRange.start.toStringAsFixed(1);
      filters['height_min'] = heightRange.start.toStringAsFixed(1);
      filters['height_max'] = heightRange.end.toStringAsFixed(1);
    }

    if (physicalStatus.isNotEmpty &&
        physicalStatus.first != 'doesnt_matter'.tr &&
        physicalStatus.first != "Doesn't Matter" &&
        physicalStatus.first != 'any'.tr &&
        physicalStatus.first != 'Any') {
      filters['physical_status'] = physicalStatus.first;
    }

    // Professional Details
    if (salaryRange.start > 0 || salaryRange.end < 5000000) {
      filters['annual_income'] = "${salaryRange.start.round()}-${salaryRange.end.round()}";
    }
    if (educationCtrl.text.isNotEmpty && educationCtrl.text != 'Any') {
      filters['education'] = educationCtrl.text;
    }
    if (workingWith.isNotEmpty && workingWith.first != 'any'.tr && workingWith.first != 'Any') {
      filters['employment_type'] = workingWith.first;
    }
    if (profession.isNotEmpty && profession.first != 'any'.tr && profession.first != 'Any') {
      filters['occupation'] = profession.first;
    }

    // Religion Details
    if (manglik.isNotEmpty && manglik != 'doesnt_matter'.tr && manglik != "Doesn't Matter") {
      filters['manglik'] = manglik;
    }

    // Family Details
    if (familyStatusCtrl.text.isNotEmpty && familyStatusCtrl.text != 'Any') {
      filters['family_status'] = familyStatusCtrl.text;
      filters['family_class'] = familyStatusCtrl.text;
    }
    if (familyType.isNotEmpty &&
        familyType.first != 'any'.tr &&
        familyType.first != 'Any' &&
        familyType.first != 'doesnt_matter'.tr &&
        familyType.first != "Doesn't Matter") {
      filters['family_type'] = familyType.first;
    }
    if (familyValues.isNotEmpty &&
        familyValues.first != 'any'.tr &&
        familyValues.first != 'Any' &&
        familyValues.first != 'doesnt_matter'.tr &&
        familyValues.first != "Doesn't Matter") {
      filters['family_value'] = familyValues.first;
    }

    // Location Details
    if (countryCtrl.text.isNotEmpty && countryCtrl.text != 'Any') filters['country'] = countryCtrl.text;
    if (stateCtrl.text.isNotEmpty && stateCtrl.text != 'Any') filters['state'] = stateCtrl.text;
    if (cityCtrl.text.isNotEmpty && cityCtrl.text != 'Any') filters['city'] = cityCtrl.text;
    if (citizenship.isNotEmpty && citizenship.first != 'any'.tr && citizenship.first != 'Any') {
      filters['citizenship'] = citizenship.first;
    }

    // Lifestyle Details
    if (diet.isNotEmpty && diet.first != 'any'.tr && diet.first != 'Any') {
      filters['diet'] = diet.first;
    }
    if (smokingCtrl.text.isNotEmpty && smokingCtrl.text != 'Any') {
      filters['smoking'] = smokingCtrl.text;
    }
    if (drinking.isNotEmpty && drinking != 'Any' && drinking != 'doesnt_matter'.tr && drinking != "Doesn't Matter") {
      filters['drinking'] = drinking;
    }

    // Profile Type & Others
    if (isProfileWithPhoto.value) filters['photo'] = true;

    if (recentlyCreated.value != 'all') {
      filters['created_at'] = recentlyCreated.value;
    }

    return filters;
  }

  void applyFilters() {
    update(); // Notify listeners (MatrimonyPage badge)
    Get.back(result: getFilters());
  }

  int get activeFilterCount {
    int count = 0;
    if (ageRange.start > 18 || ageRange.end < 60) count++;
    if (maritalStatus.isNotEmpty && maritalStatus.first != 'Any' && maritalStatus.first != 'any'.tr) count++;
    if ((profileCreatedByCtrl.text.isNotEmpty && profileCreatedByCtrl.text != 'Any') ||
        (profileCreatedBy.isNotEmpty && profileCreatedBy.first != 'Any')) count++;
    if (mothertangueCtrl.text.isNotEmpty && mothertangueCtrl.text != 'Any') count++;
    if (heightRange.start > 0.0 || heightRange.end < 20.0) count++;
    if (physicalStatus.isNotEmpty &&
        physicalStatus.first != 'doesnt_matter'.tr &&
        physicalStatus.first != "Doesn't Matter" &&
        physicalStatus.first != 'any'.tr &&
        physicalStatus.first != 'Any') count++;
    if (salaryRange.start > 0 || salaryRange.end < 5000000) count++;
    if (educationCtrl.text.isNotEmpty && educationCtrl.text != 'Any') count++;
    if (workingWith.isNotEmpty && workingWith.first != 'any'.tr && workingWith.first != 'Any') count++;
    if (profession.isNotEmpty && profession.first != 'any'.tr && profession.first != 'Any') count++;
    if (manglik.isNotEmpty && manglik != 'doesnt_matter'.tr && manglik != "Doesn't Matter") count++;
    if (familyStatusCtrl.text.isNotEmpty && familyStatusCtrl.text != 'Any') count++;
    if (familyType.isNotEmpty &&
        familyType.first != 'any'.tr &&
        familyType.first != 'Any' &&
        familyType.first != 'doesnt_matter'.tr &&
        familyType.first != "Doesn't Matter") count++;
    if (familyValues.isNotEmpty &&
        familyValues.first != 'any'.tr &&
        familyValues.first != 'Any' &&
        familyValues.first != 'doesnt_matter'.tr &&
        familyValues.first != "Doesn't Matter") count++;
    if (countryCtrl.text.isNotEmpty && countryCtrl.text != 'Any') count++;
    if (stateCtrl.text.isNotEmpty && stateCtrl.text != 'Any') count++;
    if (cityCtrl.text.isNotEmpty && cityCtrl.text != 'Any') count++;
    if (citizenship.isNotEmpty && citizenship.first != 'any'.tr && citizenship.first != 'Any') count++;
    if (diet.isNotEmpty && diet.first != 'any'.tr && diet.first != 'Any') count++;
    if (smokingCtrl.text.isNotEmpty && smokingCtrl.text != 'Any') count++;
    if (drinking.isNotEmpty && drinking != 'Any' && drinking != 'doesnt_matter'.tr && drinking != "Doesn't Matter") count++;
    if (isProfileWithPhoto.value) count++;
    if (recentlyCreated.value != 'all') count++;
    return count;
  }
}





