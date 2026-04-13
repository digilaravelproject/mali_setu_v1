import 'package:edu_cluezer/features/matrimony/domain/repository/matrimony_repository.dart';
import 'package:edu_cluezer/features/razorpay/payment_repository.dart';
import 'package:edu_cluezer/features/razorpay/razorpay_controller.dart';
import 'package:edu_cluezer/widgets/custom_snack_bar.dart';
import 'package:edu_cluezer/widgets/name_field_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../models/name_components.dart';
import '../../../../utils/name_parser.dart';
import '../../data/model/matrimony_cast_model.dart';
import '../../data/model/matrimony_plan_model.dart';
import '../../../../core/helper/pincode_helper.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io';
import '../../../../features/Auth/service/auth_service.dart';
import '../page/matrimony_subscription_plan.dart';

class RegMatrimonyController extends GetxController {
  final MatrimonyRepository _repository = Get.find<MatrimonyRepository>();
  final PaymentRepository _paymentRepository = Get.find<PaymentRepository>();
  final RazorpayController _razorpayController = Get.find<RazorpayController>();

  final ScrollController scrollController = ScrollController();

  /// Edit mode flag — set to true when opening from "Edit Profile"
  final isEditMode = false.obs;
  final isPreFilling = false.obs;

  /// NAME FIELD COMPONENT KEY
  final GlobalKey<NameFieldComponentState> nameFieldKey = GlobalKey<NameFieldComponentState>();

  /// Incremented to force NameFieldComponent rebuild when prefill data arrives
  final nameWidgetKey = 0.obs;

  /// --- Name sub-controllers (mirrored from NameFieldComponent for reliable API access) ---
  final titleCtrl = TextEditingController();
  final firstNameCtrl = TextEditingController();
  final middleNameCtrl = TextEditingController();
  final lastNameCtrl = TextEditingController();

  /// --- Text Controllers ---
  final nameCtrl = TextEditingController();
  final dobCtrl = TextEditingController(); // Used for display
  final heightCtrl = TextEditingController();
  final weightCtrl = TextEditingController();
  final collegeCtrl = TextEditingController();
  final jobTitleCtrl = TextEditingController();
  final companyCtrl = TextEditingController();
  final annualIncomeCtrl = TextEditingController();
  final fatherOccupationCtrl = TextEditingController();
  final motherOccupationCtrl = TextEditingController();
  final cityCtrl = TextEditingController();
  final pinCodeCtrl = TextEditingController();
  final talukaCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final bloodGroupCtrl = TextEditingController();
  final ref_nameCtrl = TextEditingController();

  // Keep some old ones if needed or reuse
  final casteCtrl = TextEditingController();
  final subCasteCtrl = TextEditingController();

  /// --- Rx Selection Variables ---
  // Personal
  final profileCreatedBy = ''.obs;
  final gender = ''.obs;
  final complexion = ''.obs;
  final physicalStatus = ''.obs;
  final maritalStatus = ''.obs;
  final language = ''.obs;
  final citizenship = ''.obs;

  // Religious
  final religion = ''.obs;
  final star = ''.obs;
  final raasi = ''.obs;
  final manglik = ''.obs;
  final dosh = ''.obs;
  final bloodGroup = ''.obs;

  // Education & Career
  final education = ''.obs;
  final employmentType = ''.obs;

  // Family & Lifestyle
  final familyType = ''.obs;
  final familyClass = ''.obs;
  final familyValue = ''.obs;
  final diet = ''.obs;
  final smoking = ''.obs;
  final drinking = ''.obs;

  // Location
  final country = 'India'.obs;
  final state = ''.obs;
  
  // Pincode
  final isFetchingPincode = false.obs;

  // Photos
  final RxList<File> selectedPhotos = <File>[].obs;

  // Pincode
  // final isFetchingPincode = false.obs;
  //
  // // Photos
  // final RxList<File> selectedPhotos = <File>[].obs;

  // Formatting variables
  DateTime? selectedDate;
  final rxDob = ''.obs;

  // Steps
  final currentStep = 0.obs;
  final errors = <String, String>{}.obs;
  final approvalStatus = ''.obs; // 🆕 ADDED

  /// --- Static Data Lists ---
  final List<String> profileCreatedByList = ['Self', 'Parent', 'Sibling', 'Relative', 'Friend'];
  final List<String> genderList = ['Male', 'Female'];
  final List<String> complexionList = ['Fair', 'Wheatish', 'Dark'];
  final List<String> physicalStatusList = ['Normal', 'Physically Challenged'];
  final List<String> maritalStatusList = ['Never Married', 'Divorced', 'Widowed', 'Awaiting Divorce'];
  final List<String> languageList = ['Hindi', 'English', 'Marathi', 'Gujarati', 'Punjabi', 'Bengali', 'Tamil', 'Telugu', 'Kannada', 'Malayalam', 'Urdu', 'Other'];
  final List<String> citizenshipList = ['Indian', 'NRI', 'Other'];

  final List<String> religionList = ['Hindu', 'Muslim', 'Christian', 'Sikh', 'Jain', 'Buddhist', 'Parsi', 'Jewish', 'Other'];
  final List<String> starList = ['Ashwini', 'Bharani', 'Krittika', 'Rohini', 'Mrigashirsha', 'Ardra', 'Punarvasu', 'Pushya', 'Ashlesha', 'Magha', 'Purva Phalguni', 'Uttara Phalguni', 'Hasta', 'Chitra', 'Swati', 'Vishakha', 'Anuradha', 'Jyeshtha', 'Mula', 'Purva Ashadha', 'Uttara Ashadha', 'Shravana', 'Dhanishta', 'Shatabhisha', 'Purva Bhadrapada', 'Uttara Bhadrapada', 'Revati'];
  final List<String> raasiList = ['Mesha (Aries)', 'Vrishabha (Taurus)', 'Mithuna (Gemini)', 'Karka (Cancer)', 'Simha (Leo)', 'Kanya (Virgo)', 'Tula (Libra)', 'Vrishchika (Scorpio)', 'Dhanu (Sagittarius)', 'Makara (Capricorn)', 'Kumbha (Aquarius)', 'Meena (Pisces)'];
  final List<String> manglikList = ['Yes', 'No', 'Anshik (Partial)', 'Don\'t Know'];
  final List<String> doshList = ['No', 'Yes', 'Don\'t Know'];
  final List<String> bloodGroupList = ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'];

  final List<String> educationList = ['High School', 'Diploma', 'Bachelor', 'Master', 'Doctorate', 'Other'];
  final List<String> employmentTypeList = ['Private Sector', 'Government/Public Sector', 'Civil Service', 'Defense', 'Owner', 'Self Employed', 'Not Working'];

  final List<String> familyTypeList = ['Nuclear', 'Joint'];
  final List<String> familyClassList = ['Rich', 'Upper Middle Class', 'Middle Class', 'Lower Middle Class', 'Lower Class'];
  final List<String> familyValueList = ['Orthodox', 'Traditional', 'Moderate', 'Liberal'];

  final List<String> dietList = ['Vegetarian', 'Non-Vegetarian', 'Eggetarian', 'Vegan'];
  final List<String> smokingList = ['No', 'Yes', 'Occasionally'];
  final List<String> drinkingList = ['No', 'Yes', 'Occasionally'];

  final Map<String, List<String>> countryStateMap = {
    'India': ['Maharashtra', 'Gujarat', 'Karnataka', 'Punjab', 'Delhi'],
    'USA': ['California', 'Texas', 'Florida', 'New York', 'Washington'],
    'Canada': ['Ontario', 'Quebec', 'British Columbia', 'Alberta', 'Manitoba'],
    'UK': ['England', 'Scotland', 'Wales', 'Northern Ireland'],
    'Australia': ['New South Wales', 'Victoria', 'Queensland', 'Western Australia'],
  };

  final List<String> countryList = ['India', 'USA', 'UK', 'Canada', 'Australia', 'Other'];
  final RxList<String> stateList = <String>[].obs;



  /// --- Methods ---
  
  /// Pick Multiple Photos
  Future<void> pickPhotos() async {
    try {
      final ImagePicker picker = ImagePicker();
      final List<XFile> images = await picker.pickMultiImage(
        imageQuality: 80,
        maxWidth: 1080,
      );

      if (images.isNotEmpty) {
        int remainingSlots = 5 - selectedPhotos.length;
        int addedCount = 0;
        List<String> failedFiles = [];

        for (var i = 0; i < images.length && addedCount < remainingSlots; i++) {
          final file = File(images[i].path);
          final int sizeInBytes = await file.length();
          final double sizeInMb = sizeInBytes / (1024 * 1024);
          
          // Check format
          final String extension = images[i].path.split('.').last.toLowerCase();
          final List<String> allowedExtensions = ['jpg', 'jpeg', 'png'];

          if (sizeInMb <= 2 && allowedExtensions.contains(extension)) {
            selectedPhotos.add(file);
            addedCount++;
          } else {
            failedFiles.add(images[i].name);
          }
        }
        
        if (failedFiles.isNotEmpty) {
          CustomSnackBar.showError(
            message: "Some files were skipped. Max size 2MB, Formats: JPG, PNG",
          );
        } else if (images.length > remainingSlots) {
          CustomSnackBar.showError(message: "You can only select up to 5 photos.");
        }
      }
    } catch (e) {
      debugPrint("Error picking photos: $e");
    }
  }

  void removePhoto(int index) {
    selectedPhotos.removeAt(index);
  }

  /// Handle pincode changes for auto-fill
  void _onPincodeChanged() {
    final pincode = pinCodeCtrl.text.trim();

    // Only fetch if pincode is exactly 6 digits
    if (pincode.length == 6 && int.tryParse(pincode) != null) {
      _fetchAddressFromPincode(pincode);
    } 
    errors.remove('pincode');
  }

  Future<void> _fetchAddressFromPincode(String pincode) async {
    try {
      isFetchingPincode.value = true;
      Get.showSnackbar(
        const GetSnackBar(
          message: "Fetching address details...",
          duration: Duration(seconds: 2),
          backgroundColor: Colors.blue,
          icon: Icon(Icons.location_searching, color: Colors.white),
        ),
      );

      final response = await PincodeHelper.fetchAddressFromPincode(pincode);

      if (response != null) {
        // Find existing state or add it
        final fetchedState = response.state;
        if (!stateList.contains(fetchedState)) {
           stateList.add(fetchedState);
        }
        
        state.value = fetchedState;
        cityCtrl.text = "${response.district} , ${response.division}, ${response.name}"; // Using district as major city
        talukaCtrl.text = response.name; // Taluka from pincode API
        country.value = response.country; // Assumed Indian via API

        CustomSnackBar.showSuccess(message: "Address auto-filled successfully!");
      } else {
        CustomSnackBar.showError(message: "Invalid pincode or no data found");
      }
    } catch (e) {
      CustomSnackBar.showError(message: "Failed to fetch address details");
    } finally {
      isFetchingPincode.value = false;
    }
  }

  /// Pick Multiple Photos
/*  Future<void> pickPhotos() async {
    try {
      final ImagePicker picker = ImagePicker();
      final List<XFile> images = await picker.pickMultiImage(
        imageQuality: 80,
        maxWidth: 1080,
      );

      if (images.isNotEmpty) {
        // Limit to max 5 photos for example
        int remainingSlots = 5 - selectedPhotos.length;
        for (var i = 0; i < images.length && i < remainingSlots; i++) {
          selectedPhotos.add(File(images[i].path));
        }

        if (images.length > remainingSlots) {
          CustomSnackBar.showError(message: "You can only select up to 5 photos.");
        }
      }
    } catch (e) {
      debugPrint("Error picking photos: $e");
    }
  }

  void removePhoto(int index) {
    selectedPhotos.removeAt(index);
  }

  /// Handle pincode changes for auto-fill
  void _onPincodeChanged() {
    final pincode = pinCodeCtrl.text.trim();

    // Only fetch if pincode is exactly 6 digits
    if (pincode.length == 6 && int.tryParse(pincode) != null) {
      _fetchAddressFromPincode(pincode);
    } else {
      if (pincode.length < 6) {
        state.value = '';
        cityCtrl.clear();
      }
    }
  }

  Future<void> _fetchAddressFromPincode(String pincode) async {
    try {
      isFetchingPincode.value = true;
      Get.showSnackbar(
        const GetSnackBar(
          message: "Fetching address details...",
          duration: Duration(seconds: 2),
          backgroundColor: Colors.blue,
          icon: Icon(Icons.location_searching, color: Colors.white),
        ),
      );

      final response = await PincodeHelper.fetchAddressFromPincode(pincode);

      if (response != null) {
        // Find existing state or add it
        final fetchedState = response.state;
        if (!stateList.contains(fetchedState)) {
          stateList.add(fetchedState);
        }

        state.value = fetchedState;
        cityCtrl.text = response.district; // Using district as major city
        country.value = 'India'; // Assumed Indian via API

        CustomSnackBar.showSuccess(message: "Address auto-filled successfully!");
      } else {
        CustomSnackBar.showError(message: "Invalid pincode or no data found");
      }
    } catch (e) {
      CustomSnackBar.showError(message: "Failed to fetch address details");
    } finally {
      isFetchingPincode.value = false;
    }
  }*/


  void selectDate(BuildContext context) async {
    final now = DateTime.now();
    final lastAllowedDate = DateTime(now.year - 18, now.month, now.day);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: lastAllowedDate,
      firstDate: DateTime(1960),
      lastDate: lastAllowedDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      selectedDate = picked;
      String formatted = "${picked.day.toString().padLeft(2, '0')}/"
          "${picked.month.toString().padLeft(2, '0')}/"
          "${picked.year}";
      dobCtrl.text = formatted;
      rxDob.value = formatted;
      errors.remove('dob');
    }
  }

  int calculateAge() {
    DateTime? birthDate = selectedDate;
    
    // If selectedDate is null, try parsing from the text controller
    if (birthDate == null && dobCtrl.text.isNotEmpty) {
      try {
        birthDate = DateFormat('dd/MM/yyyy').parse(dobCtrl.text);
      } catch (e) {
        // Fallback for different format or error
        try {
          birthDate = DateTime.parse(dobCtrl.text);
        } catch (_) {
          return 0;
        }
      }
    }

    if (birthDate == null) return 0;
    
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month || (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  void nextStep() {
    if (validateCurrentStep()) {
      if (currentStep.value < 3) {
        currentStep.value++;
        scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  bool validateCurrentStep() {
    errors.clear();
    bool isValid = true;

    if (currentStep.value == 0) {
      // Step 1: Personal
      final nameValidation = nameFieldKey.currentState?.validate();
      if (nameValidation != null) {
        errors['name'] = nameValidation;
        isValid = false;
      }
      if (profileCreatedBy.value.isEmpty) {
        errors['profileCreatedBy'] = "Please select profile creator";
        isValid = false;
      }
      if (gender.value.isEmpty) {
        errors['gender'] = "Please select gender";
        isValid = false;
      }
      if (rxDob.value.isEmpty) {
        errors['dob'] = "Please select date of birth";
        isValid = false;
      } else if (calculateAge() < 18) {
        errors['dob'] = "Age must be at least 18 years";
        isValid = false;
      }
    } else if (currentStep.value == 1) {
      // Step 2: Religious
      if (religion.value.isEmpty) {
        errors['religion'] = "Please select caste";
        isValid = false;
      }
      if (casteCtrl.text.isEmpty) {
        errors['caste'] = "Please select sub-caste";
        isValid = false;
      }
    } else if (currentStep.value == 2) {
      // Step 3: Education & Career
      if (education.value.isEmpty) {
        errors['education'] = "Please select education";
        isValid = false;
      }
      if (employmentType.value.isEmpty) {
        errors['employmentType'] = "Please select employment type";
        isValid = false;
      }
    } else if (currentStep.value == 3) {
      // Step 4: Family & Location
      if (familyType.value.isEmpty) {
        errors['familyType'] = "Please select family type";
        isValid = false;
      }
      if (pinCodeCtrl.text.isEmpty) {
        errors['pincode'] = "Please enter pincode";
        isValid = false;
      } else if (pinCodeCtrl.text.trim().length < 5 || pinCodeCtrl.text.trim().length > 10) {
        errors['pincode'] = "No Match";
        isValid = false;
      }
      if (country.value.isEmpty) {
        errors['country'] = "Please select country";
        isValid = false;
      }
      if (state.value.isEmpty) {
        errors['state'] = "Please select state";
        isValid = false;
      }
      if (cityCtrl.text.isEmpty) {
        errors['city'] = "Please enter city";
        isValid = false;
      }
    }

    return isValid;
  }

  void previousStep() {
    if (currentStep.value > 0) {
      currentStep.value--;
      scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> onRegister() async {
    if (!validateCurrentStep()) {
      return;
    }
    try {
      Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);

      // Sync name from widget state if available (user may have typed after prefill)
      final widgetState = nameFieldKey.currentState;
      if (widgetState != null) {
        titleCtrl.text = widgetState.titleCtrl.text;
        firstNameCtrl.text = widgetState.firstNameCtrl.text;
        middleNameCtrl.text = widgetState.middleNameCtrl.text;
        lastNameCtrl.text = widgetState.lastNameCtrl.text;
      }

      // Get name parts directly from controller's own TextEditingControllers
      final titleText = titleCtrl.text.trim();
      final firstNameText = firstNameCtrl.text.trim();
      final middleNameText = middleNameCtrl.text.trim();
      final lastNameText = lastNameCtrl.text.trim();
      final combinedName = [titleText, firstNameText, middleNameText, lastNameText]
          .where((s) => s.isNotEmpty).join(' ');
      
      // Convert images to base64
      List<String> base64Photos = [];
      for (var file in selectedPhotos) {
        final bytes = await file.readAsBytes();
        final base64String = base64Encode(bytes);
        final ext = file.path.split('.').last.toLowerCase();
        final mimeType = (ext == 'png') ? 'image/png' : 'image/jpeg';
        base64Photos.add('data:$mimeType;base64,$base64String');
      }

      // Convert images to base64
      // List<String> base64Photos = [];
      // for (var file in selectedPhotos) {
      //   final bytes = await file.readAsBytes();
      //   final base64String = base64Encode(bytes);
      //   final ext = file.path.split('.').last.toLowerCase();
      //   final mimeType = (ext == 'png') ? 'image/png' : 'image/jpeg';
      //   base64Photos.add('data:$mimeType;base64,$base64String');
      // }

      // Construct Nested JSON
      final Map<String, dynamic> body = {
        "age": calculateAge(),
        "height": heightCtrl.text.isEmpty ? "0" : heightCtrl.text,
        "weight": weightCtrl.text.isEmpty ? "0" : weightCtrl.text,
        "complexion": complexion.value,
        "physical_status": physicalStatus.value,
        "personal_details": {
          "title": titleText,
          "first_name": firstNameText,
          "middle_name": middleNameText,
          "last_name": lastNameText,
          "gender": gender.value,
          "dob": dobCtrl.text,
          "annual_income": annualIncomeCtrl.text,
          "occupation": jobTitleCtrl.text,
          "profile_created_by": profileCreatedBy.value,
          "hobbies": ["reading"],
          "language": language.value,
          "citizenship": citizenship.value,
          "employment_type": employmentType.value,
          "family_type": familyType.value,
          "marital_status": maritalStatus.value,
          "religion": [religion.value, casteCtrl.text],
          "star_details": [star.value, raasi.value, "manglik-${manglik.value.toLowerCase()}"],
          "dosh": dosh.value,
          "photos": base64Photos,
          "blood_group": bloodGroup.value,
          "refferal_name": ref_nameCtrl.text,
        },
        "family_details": {
          "father": fatherOccupationCtrl.text,
          "mother": motherOccupationCtrl.text,
          "family_class": familyClass.value,
          "family_value": familyValue.value,
        },
        "education_details": {
          "highest_qualification": education.value,
          "college": collegeCtrl.text,
        },
        "professional_details": {
          "job_title": jobTitleCtrl.text,
          "company": companyCtrl.text,
        },
        "lifestyle_details": {
          "diet": diet.value,
          "smoking": smoking.value,
          "drinking": drinking.value,
        },
        "location_details": {
          "city": cityCtrl.text,
          "state": state.value,
          "country": country.value,
          "pincode": pinCodeCtrl.text,
          "taluka": talukaCtrl.text,
          "address": addressCtrl.text,
        },
        "partner_preferences": {
          "age_range": "20-30",
          "education": "Any",
          "location": "Any",
        },
        "privacy_settings": {
          "show_photos": "all",
          "show_contact": "premium_only",
        },
      };

      print("Calling API with Body: $body");

      final response = isEditMode.value
          ? await _repository.updateProfile(body)
          : await _repository.createProfile(body);

      Get.back(); // Close Loading

      if (response.success == true) {
        // Refresh User Profile to ensure Home/Matrimony tabs reflect registration status
        try {
          await Get.find<AuthService>().refreshProfile();
        } catch (e) {
          debugPrint("Note: Post-registration profile refresh failed: $e");
        }

        Get.back(); // Close Registration Screen
        CustomSnackBar.showSuccess(message: response.message ?? (isEditMode.value ? "Profile Updated Successfully" : "Profile Created Successfully"));

        if (!isEditMode.value) {
          // Only show plans for new registration
          await fetchAndShowPlans();
        }
      } else {
        String errorMsg = response.message ?? "Failed to create profile";
        if (response.errors != null && response.errors!.isNotEmpty) {
          // Extract first error message from the nested errors object
          var firstErrorKey = response.errors!.keys.first;
          var firstErrorValue = response.errors![firstErrorKey];
          if (firstErrorValue is List && firstErrorValue.isNotEmpty) {
            errorMsg = firstErrorValue.first.toString();
          } else {
            errorMsg = firstErrorValue.toString();
          }
        }
        CustomSnackBar.showError(message: errorMsg);
      }

    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      print("API Error: $e");
      CustomSnackBar.showError(message: "Something went wrong. Please try again.");
    }
  }

  // Dynamic Lists
  final RxList<Cast> casteList = <Cast>[].obs;
  final RxList<SubCast> subCasteList = <SubCast>[].obs;

  @override
  void onInit() {
    super.onInit();
    print("DEBUG_MATRIMONY: onInit with arguments: ${Get.arguments}");
    fetchCasts();
    // Initialize stateList for default country (India)
    onCountryChanged(country.value);
    pinCodeCtrl.addListener(_onPincodeChanged);

    // Register watchers for error clearing (moved from unreachable block)
    ever(profileCreatedBy, (_) => errors.remove('profileCreatedBy'));
    ever(gender, (_) => errors.remove('gender'));
    ever(religion, (_) => errors.remove('religion'));
    ever(education, (_) => errors.remove('education'));
    ever(employmentType, (_) => errors.remove('employmentType'));
    ever(familyType, (_) => errors.remove('familyType'));
    ever(country, (_) => errors.remove('country'));
    ever(state, (_) => errors.remove('state'));

    cityCtrl.addListener(() => errors.remove('city'));

    // DOB controller listener to sync with rxDob and clear error
    dobCtrl.addListener(() {
      rxDob.value = dobCtrl.text;
      if (dobCtrl.text.isNotEmpty) {
        errors.remove('dob');
      }
    });

    // If edit mode passed as argument, prefill
    if (Get.arguments == true) {
      isEditMode.value = true;
      prefillFromApi();
    } else {
      isEditMode.value = false;
    }
  }

  /// Fetch existing profile and prefill all fields
  Future<void> prefillFromApi() async {
    try {
      isPreFilling.value = true;
      print("DEBUG_MATRIMONY: Starting prefillFromApi");
      final raw = await _repository.getProfiles();
      print("DEBUG_MATRIMONY: API response received: $raw");
      
      if (raw == null) {
        print("DEBUG_MATRIMONY: API returned null");
        return;
      }

      final data = raw is Map<String, dynamic> ? raw : null;
      if (data == null || data['success'] != true) {
        print("DEBUG_MATRIMONY: API success false or bad data structure");
        return;
      }

      final profile = data['data']?['profile'] as Map<String, dynamic>?;
      if (profile == null) {
        print("DEBUG_MATRIMONY: No profile data found in response");
        return;
      }

      // Top-level fields
      heightCtrl.text = profile['height']?.toString() ?? '';
      weightCtrl.text = profile['weight']?.toString() ?? '';
      complexion.value = _safeValue(profile['complexion'], complexionList);
      physicalStatus.value = _safeValue(profile['physical_status'], physicalStatusList);
      approvalStatus.value = profile['approval_status']?.toString() ?? ''; // 🆕 ADDED

      // Personal details
      final personal = profile['personal_details'] as Map<String, dynamic>? ?? {};
      
      // Name: set controller's own fields + sync to NameFieldComponent
      final apiTitle = personal['title']?.toString() ?? '';
      final apiFirstName = personal['first_name']?.toString() ?? '';
      final apiLastName = personal['last_name']?.toString() ?? '';
      final fullName = personal['name']?.toString() ?? '';

      // Set controller's own controllers (used in API body)
      if (personal['first_name'] != null || personal['middle_name'] != null) {
        titleCtrl.text = personal['title']?.toString() ?? '';
        firstNameCtrl.text = personal['first_name']?.toString() ?? '';
        middleNameCtrl.text = personal['middle_name']?.toString() ?? '';
        lastNameCtrl.text = personal['last_name']?.toString() ?? '';
      } else if (fullName.isNotEmpty) {
        final components = NameParser.parse(fullName);
        titleCtrl.text = components.title;
        firstNameCtrl.text = components.firstName;
        middleNameCtrl.text = components.middleName;
        lastNameCtrl.text = components.lastName;
      }
      nameCtrl.text = fullName;
      // nameWidgetKey increment not needed — external controllers are shared directly

      dobCtrl.text = personal['dob']?.toString() ?? '';
      if (dobCtrl.text.isNotEmpty) {
        try {
          final dobStr = dobCtrl.text.trim();
          // Handle both DD/MM/YYYY and YYYY-MM-DD formats
          if (dobStr.contains('/')) {
            // DD/MM/YYYY format
            final parts = dobStr.split('/');
            if (parts.length == 3) {
              final day = int.tryParse(parts[0]) ?? 1;
              final month = int.tryParse(parts[1]) ?? 1;
              final year = int.tryParse(parts[2]) ?? 2000;
              selectedDate = DateTime(year, month, day);
            }
          } else {
            // YYYY-MM-DD format
            selectedDate = DateTime.parse(dobStr);
            // Reformat to DD/MM/YYYY for display
            final d = selectedDate!;
            dobCtrl.text = "${d.day.toString().padLeft(2, '0')}/"
                "${d.month.toString().padLeft(2, '0')}/"
                "${d.year}";
          }
          // Always set rxDob so validation passes
          rxDob.value = dobCtrl.text;
        } catch (_) {
          // If parsing still fails, at least set rxDob from raw text so it's not empty
          rxDob.value = dobCtrl.text;
        }
      }
      annualIncomeCtrl.text = personal['annual_income']?.toString() ?? '';
      jobTitleCtrl.text = personal['occupation']?.toString() ?? '';
      gender.value = _safeValue(
        (personal['gender']?.toString() ?? '').capitalizeFirst ?? '',
        genderList,
      );
      profileCreatedBy.value = _safeValue(personal['profile_created_by'], profileCreatedByList);
      language.value = _safeValue(personal['language'], languageList);
      citizenship.value = _safeValue(personal['citizenship'], citizenshipList);
      // employment_type: do case-insensitive match
      final rawEmpType = personal['employment_type']?.toString() ?? '';
      employmentType.value = employmentTypeList.firstWhere(
        (e) => e.toLowerCase() == rawEmpType.toLowerCase(),
        orElse: () => _safeValue(rawEmpType, employmentTypeList),
      );
      familyType.value = _safeValue(personal['family_type'], familyTypeList);
      maritalStatus.value = _safeValue(personal['marital_status'], maritalStatusList);
      // blood_group: API may return "A" but list has "A+","A-" etc — try exact match first, then prefix match
      final rawBloodGroup = personal['blood_group']?.toString() ?? '';
      bloodGroup.value = bloodGroupList.contains(rawBloodGroup)
          ? rawBloodGroup
          : bloodGroupList.firstWhere((b) => b.startsWith(rawBloodGroup), orElse: () => '');
      ref_nameCtrl.text = personal['refferal_name']?.toString() ?? '';
      dosh.value = _safeValue(personal['dosh'], doshList);

      // Religion array: ["Mali","Phulmali"] → Mali = Caste (religion.value), Phulmali = Sub-Caste (casteCtrl.text)
      final religionArr = personal['religion'];
      if (religionArr is List && religionArr.isNotEmpty) {
        religion.value = religionArr[0]?.toString() ?? '';       // Caste
        if (religionArr.length > 1) {
          casteCtrl.text = religionArr[1]?.toString() ?? '';     // Sub-Caste
        }
      }

      // Star details array: [star, raasi, "manglik-yes/no"]
      final starArr = personal['star_details'];
      if (starArr is List) {
        if (starArr.isNotEmpty) star.value = _safeValue(starArr[0]?.toString(), starList);
        if (starArr.length > 1) raasi.value = _safeValue(starArr[1]?.toString(), raasiList);
        if (starArr.length > 2) {
          final manglikStr = starArr[2]?.toString() ?? '';
          final manglikVal = manglikStr.replaceFirst('manglik-', '');
          if (manglikVal.isNotEmpty) {
            manglik.value = _safeValue(
              manglikVal[0].toUpperCase() + manglikVal.substring(1),
              manglikList,
            );
          }
        }
      }

      // Family details
      final family = profile['family_details'] as Map<String, dynamic>? ?? {};
      fatherOccupationCtrl.text = family['father']?.toString() ?? '';
      motherOccupationCtrl.text = family['mother']?.toString() ?? '';
      final rawFamilyClass = family['family_class']?.toString() ?? '';
      familyClass.value = familyClassList.firstWhere(
        (e) => e.toLowerCase() == rawFamilyClass.toLowerCase(),
        orElse: () => '',
      );
      final rawFamilyValue = family['family_value']?.toString() ?? '';
      familyValue.value = familyValueList.firstWhere(
        (e) => e.toLowerCase() == rawFamilyValue.toLowerCase(),
        orElse: () => '',
      );

      // Education details
      final edu = profile['education_details'] as Map<String, dynamic>? ?? {};
      education.value = _safeValue(edu['highest_qualification'], educationList);
      collegeCtrl.text = edu['college']?.toString() ?? '';

      // Professional details
      final prof = profile['professional_details'] as Map<String, dynamic>? ?? {};
      jobTitleCtrl.text = prof['job_title']?.toString() ?? jobTitleCtrl.text;
      companyCtrl.text = prof['company']?.toString() ?? '';

      // Lifestyle details
      final lifestyle = profile['lifestyle_details'] as Map<String, dynamic>? ?? {};
      diet.value = _safeValue(lifestyle['diet'], dietList);
      final rawSmoking = lifestyle['smoking']?.toString() ?? '';
      smoking.value = smokingList.firstWhere(
        (e) => e.toLowerCase() == rawSmoking.toLowerCase(),
        orElse: () => smokingList.firstWhere(
          (e) => rawSmoking.toLowerCase().contains(e.toLowerCase()),
          orElse: () => '',
        ),
      );
      final rawDrinking = lifestyle['drinking']?.toString() ?? '';
      drinking.value = drinkingList.firstWhere(
        (e) => e.toLowerCase() == rawDrinking.toLowerCase(),
        orElse: () => '',
      );

      // Location details
      final location = profile['location_details'] as Map<String, dynamic>? ?? {};
      cityCtrl.text = location['city']?.toString() ?? '';
      pinCodeCtrl.text = location['pincode']?.toString() ?? '';
      talukaCtrl.text = location['taluka']?.toString() ?? '';
      addressCtrl.text = location['address']?.toString() ?? '';
      final fetchedCountry = location['country']?.toString() ?? 'India';
      onCountryChanged(fetchedCountry);
      state.value = _safeValue(location['state']?.toString(), stateList.toList(), fallback: location['state']?.toString() ?? '');
      if (state.value.isNotEmpty && !stateList.contains(state.value)) {
        stateList.add(state.value);
      }

    } catch (e) {
      debugPrint('prefillFromApi error: $e');
    } finally {
      isPreFilling.value = false;
    }
  }

  /// Returns value if it exists in list, else empty string (or fallback)
  String _safeValue(String? value, List<String> list, {String fallback = ''}) {
    if (value == null || value.isEmpty) return fallback;
    return list.contains(value) ? value : fallback;
  }

  void onCountryChanged(String countryName) {
    country.value = countryName;
    state.value = ''; // Reset state when country changes
    if (countryStateMap.containsKey(countryName)) {
      stateList.assignAll(countryStateMap[countryName]!);
    } else {
      stateList.assignAll(['Other']);
    }
  }

  Future<void> fetchCasts() async {
    try {
      final response = await _repository.getCasts();
      if (response.success == true && response.data?.casts != null) {
        casteList.assignAll(response.data!.casts!);
      }
    } catch (e) {
      print("Error fetching casts: $e");
    }
  }

  Future<void> fetchSubCasts(int castId) async {
    try {
      subCasteList.clear();
      final response = await _repository.getSubCasts(castId);
      if (response.success == true && response.data?.subCasts != null) {
        subCasteList.assignAll(response.data!.subCasts!);
      }
    } catch (e) {
      print("Error fetching sub-casts: $e");
    }
  }

  void onCasteSelected(String casteName) {
    religion.value = casteName; // Using religion variable to store Caste Name as per plan

    // Find ID
    final selectedCast = casteList.firstWhereOrNull((c) => c.name == casteName);
    if (selectedCast != null && selectedCast.id != null) {
      fetchSubCasts(selectedCast.id!);
    }

    casteCtrl.clear(); // Clear sub-caste selection
  }

  void onSubCasteSelected(String subCasteName) {
    casteCtrl.text = subCasteName; // Using casteCtrl to store Sub-caste Name
    errors.remove('caste');
  }

  @override
  void onClose() {
    titleCtrl.dispose();
    firstNameCtrl.dispose();
    lastNameCtrl.dispose();
    nameCtrl.dispose();
    dobCtrl.dispose();
    heightCtrl.dispose();
    weightCtrl.dispose();
    collegeCtrl.dispose();
    jobTitleCtrl.dispose();
    companyCtrl.dispose();
    annualIncomeCtrl.dispose();
    fatherOccupationCtrl.dispose();
    motherOccupationCtrl.dispose();
    cityCtrl.dispose();
    pinCodeCtrl.removeListener(_onPincodeChanged);
    pinCodeCtrl.dispose();
    talukaCtrl.dispose();
    addressCtrl.dispose();
    casteCtrl.dispose();
    subCasteCtrl.dispose();
    super.onClose();
  }


  Future<void> fetchAndShowPlans() async {
    try {
      // Get.dialog(const Center(child: CircularProgressIndicator()),
      //     barrierDismissible: false);
      final response = await _repository.getMatrimonyPlans();
      Get.back(); // Close Loading

      if (response.success == true && response.data?.plans != null) {
        final selectedPlan = await showSubscriptionBottomSheet(response.data!.plans!);

        if (selectedPlan != null) {
          await initiateMatrimonyPayment(selectedPlan);
        } else {
          // User closed the bottom sheet without selecting
          Get.back(); // Close Registration Screen
        }
      } else {
        Get.back(); // Close Registration Screen if no plans
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      Get.back(); // Close Registration Screen
      print("Error fetching plans: $e");
    }
  }

  Future<void> initiateMatrimonyPayment(MatrimonyPlan plan) async {
    try {
      if (plan.id == null) return;

      Get.dialog(const Center(child: CircularProgressIndicator()),
          barrierDismissible: false);

      final response = await _paymentRepository.createOrder(planId: plan.id!);

      Get.back(); // Close Loading

      if (response.success && response.data != null) {
        final orderData = response.data!;

        _razorpayController.openCheckout(
          amount: ((double.tryParse(orderData['amount']?.toString() ?? "0") ?? 0) / 100).toInt(),
          name: nameCtrl.text,
          description: "Matrimony Subscription: ${plan.planName}",
          mobile: "", // Optional: fetch from Auth if needed
          email: "", // Optional: fetch from Auth if needed
          orderId: orderData['order_id'],
          transaction_id: int.tryParse(orderData['transaction_id']?.toString() ?? "0") ?? 0,
          key: orderData['key_id'],
          type: 'matrimony',
        );
      } else {
        CustomSnackBar.showError(
            message: response.message ?? "Failed to create payment order");
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      print("Payment Error: $e");
      CustomSnackBar.showError(message: "Payment initialization failed");
    }
  }
}
