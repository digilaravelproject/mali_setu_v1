
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
  RangeValues heightRange = RangeValues(140, 200); // Default full range
  List<String> maritalStatus = [];
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


    ageRange = RangeValues(18, 60);
    heightRange = RangeValues(140, 200);
    salaryRange = RangeValues(0, 5000000);
    maritalStatus = [];
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

    if (maritalStatus.isNotEmpty && maritalStatus.first != 'Any') filters['marital_status'] = maritalStatus.first;
    if (profileCreatedBy.isNotEmpty && profileCreatedBy.first != 'Any') filters['profile_created_by'] = profileCreatedBy.first;
    if (mothertangueCtrl.text.isNotEmpty) filters['language'] = mothertangueCtrl.text;

    if (heightRange.start > 140 || heightRange.end < 200) {
      filters['height'] = heightRange.start.toStringAsFixed(1);
    }

    // Professional
    if (salaryRange.start > 0 || salaryRange.end < 5000000) {
      filters['annual_income'] = "${salaryRange.start.round()}-${salaryRange.end.round()}";
    }
    if (educationCtrl.text.isNotEmpty) filters['education'] = educationCtrl.text;

    // Family
    if (familyStatusCtrl.text.isNotEmpty) filters['family_status'] = familyStatusCtrl.text;
    if (familyType.isNotEmpty && familyType.first != 'Any') filters['family_type'] = familyType.first;
    if (familyValues.isNotEmpty && familyValues.first != 'Any') filters['family_value'] = familyValues.first;

    // Location
    if (countryCtrl.text.isNotEmpty) filters['country'] = countryCtrl.text;
    if (stateCtrl.text.isNotEmpty) filters['state'] = stateCtrl.text;
    if (cityCtrl.text.isNotEmpty) filters['city'] = cityCtrl.text;
    if (citizenship.isNotEmpty && citizenship.first != 'Any') filters['citizenship'] = citizenship.first;

    // Lifestyle
    if (diet.isNotEmpty && diet.first != 'Any') filters['diet'] = diet.first;
    if (smokingCtrl.text.isNotEmpty && smokingCtrl.text != 'Any') filters['smoking'] = smokingCtrl.text;

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
    if (maritalStatus.isNotEmpty && maritalStatus.first != 'Any') count++;
    if (profileCreatedBy.isNotEmpty && profileCreatedBy.first != 'Any') count++;
    if (mothertangueCtrl.text.isNotEmpty) count++;
    if (heightRange.start > 140 || heightRange.end < 200) count++;
    if (salaryRange.start > 0 || salaryRange.end < 5000000) count++;
    if (educationCtrl.text.isNotEmpty) count++;
    if (familyStatusCtrl.text.isNotEmpty) count++;
    if (familyType.isNotEmpty && familyType.first != 'Any') count++;
    if (familyValues.isNotEmpty && familyValues.first != 'Any') count++;
    if (countryCtrl.text.isNotEmpty) count++;
    if (stateCtrl.text.isNotEmpty) count++;
    if (cityCtrl.text.isNotEmpty) count++;
    if (citizenship.isNotEmpty && citizenship.first != 'Any') count++;
    if (diet.isNotEmpty && diet.first != 'Any') count++;
    if (smokingCtrl.text.isNotEmpty && smokingCtrl.text != 'Any') count++;
    if (isProfileWithPhoto.value) count++;
    if (recentlyCreated.value != 'all') count++;
    return count;
  }
}





