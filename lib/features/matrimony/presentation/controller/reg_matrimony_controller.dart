import 'package:dio/dio.dart' as dio;
import 'package:file_picker/file_picker.dart';
import 'package:edu_cluezer/features/matrimony/domain/repository/matrimony_repository.dart';
import 'package:edu_cluezer/features/razorpay/payment_repository.dart';
import 'package:edu_cluezer/features/razorpay/razorpay_controller.dart';
import 'package:edu_cluezer/widgets/custom_snack_bar.dart';
import 'package:edu_cluezer/widgets/name_field_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../payment/presentation/page/ccavenue_payment_screen.dart';

import '../../../../utils/name_parser.dart';
import '../../data/model/matrimony_cast_model.dart';
import '../../data/model/matrimony_plan_model.dart';
import '../../../../core/helper/pincode_helper.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io';
import '../../../../core/constent/app_constants.dart';
import '../../../../core/storage/shared_prefs.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../features/Auth/service/auth_service.dart';
import '../page/matrimony_subscription_plan.dart';
import 'matrimony_details_controller.dart';
import 'matrimony_controller.dart';

class RegMatrimonyController extends GetxController {
  final MatrimonyRepository _repository = Get.find<MatrimonyRepository>();
  final PaymentRepository _paymentRepository = Get.find<PaymentRepository>();
  final RazorpayController _razorpayController = Get.find<RazorpayController>();

  final ScrollController scrollController = ScrollController();

  /// Edit mode flag — set to true when opening from "Edit Profile"
  final isEditMode = false.obs;
  final isPreFilling = false.obs;

  /// NAME FIELD COMPONENT KEY
  final GlobalKey<NameFieldComponentState> nameFieldKey =
      GlobalKey<NameFieldComponentState>();

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
  final villageCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final bloodGroupCtrl = TextEditingController();
  final ref_nameCtrl = TextEditingController();
  final countryCtrl = TextEditingController(text: 'India');
  final stateCtrl = TextEditingController();

  // Keep some old ones if needed or reuse
  final casteCtrl = TextEditingController();
  final subCasteCtrl = TextEditingController();
  final rxSubCaste = ''.obs;

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
  final RxList<String> existingPhotos = <String>[].obs;

  // Caste Certificate (Optional)
  final casteCertificatePath = ''.obs;
  final casteCertificateFileName = ''.obs;
  final casteCertificateError = ''.obs;
  File? casteCertificateFile;
  final existingCasteCertificateUrl = ''.obs;

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

  /// For Double Back Exit
  DateTime? lastPressedTime;
  final canExit = false.obs;

  void handleBack() {
    final now = DateTime.now();
    if (lastPressedTime == null ||
        now.difference(lastPressedTime!) > const Duration(seconds: 2)) {
      lastPressedTime = now;
      canExit.value = true;
      CustomSnackBar.showInfo(message: "back_message".tr);
      // Reset canExit after 2 seconds
      Future.delayed(const Duration(seconds: 2), () {
        canExit.value = false;
      });
      return;
    }
    Get.back();
  }

  /// --- Static Data Lists ---
  final List<String> profileCreatedByList = [
    'Self',
    'Parent',
    'Sibling',
    'Relative',
    'Friend',
  ];
  final List<String> genderList = ['Male', 'Female'];
  final List<String> complexionList = ['Fair', 'Wheatish', 'Dark'];
  final List<String> physicalStatusList = ['Normal', 'Physically Challenged'];
  final List<String> maritalStatusList = [
    'Never Married',
    'Divorced',
    'Widowed',
    'Awaiting Divorce',
  ];
  final List<String> languageList = [
    'Hindi',
    'English',
    'Marathi',
    'Gujarati',
    'Punjabi',
    'Bengali',
    'Tamil',
    'Telugu',
    'Kannada',
    'Malayalam',
    'Urdu',
    'Other',
  ];
  final List<String> citizenshipList = ['Indian', 'NRI', 'Other'];

  final List<String> religionList = [
    'Hindu',
    'Muslim',
    'Christian',
    'Sikh',
    'Jain',
    'Buddhist',
    'Parsi',
    'Jewish',
    'Other',
  ];
  final List<String> starList = [
    'Ashwini',
    'Bharani',
    'Krittika',
    'Rohini',
    'Mrigashirsha',
    'Ardra',
    'Punarvasu',
    'Pushya',
    'Ashlesha',
    'Magha',
    'Purva Phalguni',
    'Uttara Phalguni',
    'Hasta',
    'Chitra',
    'Swati',
    'Vishakha',
    'Anuradha',
    'Jyeshtha',
    'Mula',
    'Purva Ashadha',
    'Uttara Ashadha',
    'Shravana',
    'Dhanishta',
    'Shatabhisha',
    'Purva Bhadrapada',
    'Uttara Bhadrapada',
    'Revati',
  ];
  final List<String> raasiList = [
    'Mesha (Aries)',
    'Vrishabha (Taurus)',
    'Mithuna (Gemini)',
    'Karka (Cancer)',
    'Simha (Leo)',
    'Kanya (Virgo)',
    'Tula (Libra)',
    'Vrishchika (Scorpio)',
    'Dhanu (Sagittarius)',
    'Makara (Capricorn)',
    'Kumbha (Aquarius)',
    'Meena (Pisces)',
  ];
  final List<String> manglikList = [
    'Yes',
    'No',
    'Anshik (Partial)',
    'Don\'t Know',
  ];
  final List<String> doshList = ['No', 'Yes', 'Don\'t Know'];
  final List<String> bloodGroupList = [
    'A+',
    'A-',
    'B+',
    'B-',
    'O+',
    'O-',
    'AB+',
    'AB-',
  ];

  final RxList<String> educationList = <String>[].obs;
  final List<String> employmentTypeList = [
    'Private Sector',
    'Government/Public Sector',
    'Civil Service',
    'Defense',
    'Owner',
    'Self Employed',
    'Not Working',
  ];

  final List<String> familyTypeList = ['Nuclear', 'Joint'];
  final List<String> familyClassList = [
    'Rich',
    'Upper Middle Class',
    'Middle Class',
    'Lower Middle Class',
    'Lower Class',
  ];
  final List<String> familyValueList = [
    'Orthodox',
    'Traditional',
    'Moderate',
    'Liberal',
  ];

  final List<String> dietList = [
    'Vegetarian',
    'Non-Vegetarian',
    'Eggetarian',
    'Vegan',
  ];
  final List<String> smokingList = ['No', 'Yes', 'Occasionally'];
  final List<String> drinkingList = ['No', 'Yes', 'Occasionally'];

  final Map<String, List<String>> countryStateMap = {
    'India': ['Maharashtra', 'Gujarat', 'Karnataka', 'Punjab', 'Delhi'],
    'USA': ['California', 'Texas', 'Florida', 'New York', 'Washington'],
    'Canada': ['Ontario', 'Quebec', 'British Columbia', 'Alberta', 'Manitoba'],
    'UK': ['England', 'Scotland', 'Wales', 'Northern Ireland'],
    'Australia': [
      'New South Wales',
      'Victoria',
      'Queensland',
      'Western Australia',
    ],
  };

  final List<String> countryList = [
    'India',
    'USA',
    'UK',
    'Canada',
    'Australia',
    'Other',
  ];
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
        int remainingSlots =
            5 - (selectedPhotos.length + existingPhotos.length);
        int addedCount = 0;
        List<String> failedFiles = [];

        for (var i = 0; i < images.length && addedCount < remainingSlots; i++) {
          final file = File(images[i].path);
          final int sizeInBytes = await file.length();
          final double sizeInMb = sizeInBytes / (1024 * 1024);

          // Check format
          final String extension = images[i].path.split('.').last.toLowerCase();
          final List<String> allowedExtensions = ['jpg', 'jpeg', 'png', 'heic', 'heif', 'webp'];

          if (sizeInMb <= 10 && (allowedExtensions.contains(extension) || extension.isEmpty)) {
            final appDir = await getApplicationDocumentsDirectory();
            final fileName = '${DateTime.now().millisecondsSinceEpoch}_${images[i].name}';
            final savedFile = await file.copy('${appDir.path}/$fileName');
            selectedPhotos.add(savedFile);
            addedCount++;
          } else {
            failedFiles.add(images[i].name);
          }
        }

        if (failedFiles.isNotEmpty) {
          CustomSnackBar.showError(
            message: "Some files were skipped. Max size 5MB, Formats: JPG, PNG",
          );
        } else if (images.length > remainingSlots) {
          CustomSnackBar.showError(
            message: "You can only select up to 5 photos.",
          );
        }
      }
    } catch (e) {
      debugPrint("Error picking photos: $e");
    }
  }

  void removePhoto(int index) {
    selectedPhotos.removeAt(index);
  }

  void removeExistingPhoto(int index) {
    existingPhotos.removeAt(index);
  }

  /// Pick Caste Certificate (Optional, supports JPG, PNG, PDF up to 5MB)
  Future<void> pickCasteCertificate() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
      );

      if (result != null && result.files.single.path != null) {
        final filePath = result.files.single.path!;
        final file = File(filePath);

        final fileSize = await file.length();
        const maxSize = 5 * 1024 * 1024; // 5MB

        if (fileSize > maxSize) {
          casteCertificateError.value = "File size must be less than 5MB";
          CustomSnackBar.showError(message: "File size must be less than 5MB");
          return;
        }

        final extension = result.files.single.extension?.toLowerCase() ?? '';
        if (!['jpg', 'jpeg', 'png', 'pdf'].contains(extension)) {
          casteCertificateError.value = "Only JPG, PNG, and PDF files are allowed";
          CustomSnackBar.showError(message: "Only JPG, PNG, and PDF files are allowed");
          return;
        }

        casteCertificateFile = file;
        casteCertificatePath.value = filePath;
        casteCertificateFileName.value = result.files.single.name;
        casteCertificateError.value = '';

        CustomSnackBar.showSuccess(
          message: "Caste certificate selected successfully",
        );
      }
    } catch (e) {
      casteCertificateError.value = "Failed to select file: $e";
      debugPrint("Error picking caste certificate: $e");
    }
  }

  /// Remove selected Caste Certificate
  void removeCasteCertificate() {
    casteCertificatePath.value = '';
    casteCertificateFileName.value = '';
    casteCertificateError.value = '';
    casteCertificateFile = null;
    existingCasteCertificateUrl.value = '';
  }

  /// Handle pincode changes for auto-fill
  void _onPincodeChanged() {
    if (isPreFilling.value) return;
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
      // Get.showSnackbar(
      //   const GetSnackBar(
      //     message: "Fetching address details...",
      //     duration: Duration(seconds: 2),
      //     backgroundColor: Colors.blue,
      //     icon: Icon(Icons.location_searching, color: Colors.white),
      //   ),
      // );

      final response = await PincodeHelper.fetchAddressFromPincode(pincode);

      if (response != null) {
        // Find existing state or add it
        final fetchedState = response.state;
        if (!stateList.contains(fetchedState)) {
          stateList.add(fetchedState);
        }

        state.value = fetchedState;
        stateCtrl.text = fetchedState;
        cityCtrl.text = "${response.district}"; // Using district as major city
        talukaCtrl.text = response.block; // Taluka from pincode API
        villageCtrl.text = response.name; // Taluka from pincode API
        country.value = response.country; // Assumed Indian via API
        countryCtrl.text = response.country;

        // CustomSnackBar.showSuccess(message: "Address auto-filled successfully!");
      } else {
        // CustomSnackBar.showError(message: "Invalid pincode or no data found");
      }
    } catch (e) {
      // CustomSnackBar.showError(message: "Failed to fetch address details");
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
    if (isPreFilling.value) return;
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
      // Get.showSnackbar(
      //   const GetSnackBar(
      //     message: "Fetching address details...",
      //     duration: Duration(seconds: 2),
      //     backgroundColor: Colors.blue,
      //     icon: Icon(Icons.location_searching, color: Colors.white),
      //   ),
      // );

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

        // CustomSnackBar.showSuccess(message: "Address auto-filled successfully!");
      } else {
        // CustomSnackBar.showError(message: "Invalid pincode or no data found");
      }
    } catch (e) {
      // CustomSnackBar.showError(message: "Failed to fetch address details");
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
      String formatted =
          "${picked.day.toString().padLeft(2, '0')}/"
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
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
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
      // Minimum 2 photos validation
      final totalPhotos = existingPhotos.length + selectedPhotos.length;
      if (totalPhotos < 2) {
        CustomSnackBar.showError(message: "Minimum 2 images are required");
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
      } else if (pinCodeCtrl.text.trim().length < 5 ||
          pinCodeCtrl.text.trim().length > 10) {
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

    // Final check: minimum 2 photos required for registration and update
    final totalPhotos = existingPhotos.length + selectedPhotos.length;
    if (totalPhotos < 2) {
      CustomSnackBar.showError(message: "Minimum 2 images are required");
      return;
    }
    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      // Sync name from widget state if available (user may have typed after prefill)
      final widgetState = nameFieldKey.currentState;
      if (widgetState != null) {
        // titleCtrl.text = widgetState.titleCtrl.text;
        firstNameCtrl.text = widgetState.firstNameCtrl.text;
        middleNameCtrl.text = widgetState.middleNameCtrl.text;
        lastNameCtrl.text = widgetState.lastNameCtrl.text;
      }

      // Get name parts directly from controller's own TextEditingControllers
      // final titleText = titleCtrl.text.trim();
      final firstNameText = firstNameCtrl.text.trim();
      final middleNameText = middleNameCtrl.text.trim();
      final lastNameText = lastNameCtrl.text.trim();
      final combinedName = [
        /*titleText,*/ firstNameText,
        middleNameText,
        lastNameText,
      ].where((s) => s.isNotEmpty).join(' ');

      // Verify photos exist
      for (var file in selectedPhotos) {
        if (!await file.exists()) {
          Get.back(); // close dialog
          CustomSnackBar.showError(message: "Some selected photos are no longer available. Please re-select them.");
          return;
        }
      }

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
        "approval_status": "pending",
        "personal_details": {
          "name": combinedName,
          // "title": titleText,
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
          "star_details": [
            star.value,
            raasi.value,
            "manglik-${manglik.value.toLowerCase()}",
          ],
          "dosh": dosh.value,
          "photos": [...existingPhotos, ...base64Photos],
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
          "village": villageCtrl.text,
          "address": addressCtrl.text,
        },
        "partner_preferences": {
          "age_range": "20-30",
          "education": education.value.isNotEmpty ? education.value : "Any",
          "location": "Any",
        },
        "privacy_settings": {
          "show_photos": "all",
          "show_contact": "premium_only",
        },
      };

      dynamic requestData;
      if (casteCertificateFile != null && await casteCertificateFile!.exists()) {
        final formData = dio.FormData();
        if (isEditMode.value) {
          formData.fields.add(const MapEntry('_method', 'PUT'));
        }

        void addEntry(String prefix, dynamic value) {
          if (value == null) return;
          if (value is Map) {
            value.forEach((k, v) {
              addEntry(prefix.isEmpty ? k.toString() : '$prefix[$k]', v);
            });
          } else if (value is List) {
            for (int i = 0; i < value.length; i++) {
              addEntry('$prefix[$i]', value[i]);
            }
          } else {
            formData.fields.add(MapEntry(prefix, value.toString()));
          }
        }

        body.forEach((k, v) => addEntry(k, v));

        formData.files.add(MapEntry(
          'cast_certificate',
          await dio.MultipartFile.fromFile(
            casteCertificateFile!.path,
            filename: casteCertificateFile!.path.split('/').last,
          ),
        ));
        requestData = formData;
      } else {
        requestData = body;
      }

      print("Calling API with requestData: $requestData");

      final response = isEditMode.value
          ? await _repository.updateProfile(requestData)
          : await _repository.createProfile(requestData);

      Get.back(); // Close Loading

      if (response.success == true) {
        // Refresh User Profile to ensure Home/Matrimony tabs reflect registration status
        try {
          await Get.find<AuthService>().refreshProfile();
        } catch (e) {
          debugPrint("Note: Post-registration profile refresh failed: $e");
        }

        // 🆕 NEW: Refresh Matrimony-specific controllers to show updated data immediately
        try {
          if (Get.isRegistered<MatrimonyDetailsController>()) {
            Get.find<MatrimonyDetailsController>().refreshData();
          }
          if (Get.isRegistered<MatrimonyController>()) {
            Get.find<MatrimonyController>().fetchProfiles(isSilent: true);
          }
        } catch (e) {
          debugPrint("Note: Matrimony controllers refresh failed: $e");
        }

        Get.back(); // Close Registration Screen
        CustomSnackBar.showSuccess(
          message:
              response.message ??
              (isEditMode.value
                  ? "Profile Updated Successfully"
                  : "Profile Created Successfully"),
        );

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
      CustomSnackBar.showError(
        message: "Something went wrong. Please try again.",
      );
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
    fetchEducations();
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
    countryCtrl.addListener(() {
      country.value = countryCtrl.text;
      errors.remove('country');
    });
    stateCtrl.addListener(() {
      state.value = stateCtrl.text;
      errors.remove('state');
    });

    // DOB controller listener to sync with rxDob and clear error
    dobCtrl.addListener(() {
      rxDob.value = dobCtrl.text;
      if (dobCtrl.text.isNotEmpty) {
        errors.remove('dob');
      }
    });

    // If edit mode passed as argument, prefill
    final args = Get.arguments;
    if (args == true ||
        (args is Map &&
            (args['isEdit'] == true ||
                args['edit'] == true ||
                args['userId'] != null))) {
      isEditMode.value = true;
      prefillFromApi();
    } else {
      isEditMode.value = false;
    }
  }

  bool _hasCheckedPrefill = false;

  /// Check and prefill if in edit mode (can be called from page didChangeDependencies or initState)
  void checkAndPrefill() {
    if (_hasCheckedPrefill) return;
    final args = Get.arguments;
    if (args == true ||
        (args is Map &&
            (args['isEdit'] == true ||
                args['edit'] == true ||
                args['userId'] != null))) {
      _hasCheckedPrefill = true;
      isEditMode.value = true;
      if (!isPreFilling.value) {
        prefillFromApi();
      }
    }
  }

  /// Fetch existing profile and prefill all fields
  Future<void> prefillFromApi() async {
    try {
      isPreFilling.value = true;
      print("DEBUG_MATRIMONY: Starting prefillFromApi");

      int? userId;
      final args = Get.arguments;
      if (args is Map && args['userId'] != null) {
        userId = int.tryParse(args['userId'].toString());
      } else if (args is int) {
        userId = args;
      }
      if (userId == null) {
        final user = Get.find<AuthService>().currentUser.value;
        userId = user?.id;
      }
      if (userId == null) {
        final userJson = SharedPrefs.getString(AppConstants.userDataPref);
        if (userJson != null) {
          try {
            final map = jsonDecode(userJson);
            userId = int.tryParse(map['id']?.toString() ?? '');
          } catch (_) {}
        }
      }

      if (userId == null) {
        print("DEBUG_MATRIMONY: No user ID found for prefill");
        return;
      }

      final raw = await _repository.getProfiles(userId);
      print("DEBUG_MATRIMONY: API response received: $raw");

      if (raw == null) {
        print("DEBUG_MATRIMONY: API returned null");
        return;
      }

      final data = raw is Map<String, dynamic> ? raw : null;
      if (data == null) {
        print("DEBUG_MATRIMONY: API returned non-map data");
        return;
      }

      final profile = (data['data']?['profile'] ?? data['data'] ?? data['profile']) as Map<String, dynamic>?;
      if (profile == null) {
        print("DEBUG_MATRIMONY: No profile data found in response");
        return;
      }

      // Top-level fields
      heightCtrl.text = profile['height']?.toString() ?? '';
      weightCtrl.text = profile['weight']?.toString() ?? '';
      complexion.value = _safeValue(profile['complexion']?.toString(), complexionList);
      physicalStatus.value = _safeValue(
        profile['physical_status']?.toString(),
        physicalStatusList,
      );
      approvalStatus.value = profile['approval_status']?.toString() ?? '';

      // Personal details
      final personal =
          profile['personal_details'] as Map<String, dynamic>? ?? {};

      // Name: set controller's own fields + sync to NameFieldComponent
      final apiFirstName = personal['first_name']?.toString() ?? '';
      final apiMiddleName = personal['middle_name']?.toString() ?? '';
      final apiLastName = personal['last_name']?.toString() ?? '';
      final fullName = personal['name']?.toString() ?? '';

      if (apiFirstName.isNotEmpty || apiLastName.isNotEmpty || apiMiddleName.isNotEmpty) {
        firstNameCtrl.text = apiFirstName;
        middleNameCtrl.text = apiMiddleName;
        lastNameCtrl.text = apiLastName;
        nameCtrl.text = [apiFirstName, apiMiddleName, apiLastName].where((s) => s.isNotEmpty).join(' ');
      } else if (fullName.isNotEmpty) {
        final components = NameParser.parse(fullName);
        firstNameCtrl.text = components.firstName;
        middleNameCtrl.text = components.middleName;
        lastNameCtrl.text = components.lastName;
        nameCtrl.text = fullName;
      }
      nameWidgetKey.value++; // Forces NameFieldComponent to rebuild

      dobCtrl.text = personal['dob']?.toString() ?? '';
      if (dobCtrl.text.isNotEmpty) {
        try {
          final dobStr = dobCtrl.text.trim();
          if (dobStr.contains('/')) {
            final parts = dobStr.split('/');
            if (parts.length == 3) {
              final day = int.tryParse(parts[0]) ?? 1;
              final month = int.tryParse(parts[1]) ?? 1;
              final year = int.tryParse(parts[2]) ?? 2000;
              selectedDate = DateTime(year, month, day);
            }
          } else {
            selectedDate = DateTime.parse(dobStr);
            final d = selectedDate!;
            dobCtrl.text =
                "${d.day.toString().padLeft(2, '0')}/"
                "${d.month.toString().padLeft(2, '0')}/"
                "${d.year}";
          }
          rxDob.value = dobCtrl.text;
        } catch (_) {
          rxDob.value = dobCtrl.text;
        }
      }
      annualIncomeCtrl.text = personal['annual_income']?.toString() ?? '';
      final rawOcc = personal['occupation']?.toString() ?? '';
      if (rawOcc.isNotEmpty) {
        jobTitleCtrl.text = rawOcc;
      }
      gender.value = _safeValue(
        (personal['gender']?.toString() ?? '').capitalizeFirst ?? '',
        genderList,
      );
      profileCreatedBy.value = _safeValue(
        personal['profile_created_by']?.toString(),
        profileCreatedByList,
      );
      language.value = _safeValue(personal['language']?.toString(), languageList);
      citizenship.value = _safeValue(personal['citizenship']?.toString(), citizenshipList);
      
      final rawEmpType = personal['employment_type']?.toString() ?? '';
      employmentType.value = _safeValue(rawEmpType, employmentTypeList);

      familyType.value = _safeValue(personal['family_type']?.toString(), familyTypeList);
      maritalStatus.value = _safeValue(
        personal['marital_status']?.toString(),
        maritalStatusList,
      );
      
      final rawBloodGroup = personal['blood_group']?.toString() ?? '';
      bloodGroup.value = bloodGroupList.contains(rawBloodGroup)
          ? rawBloodGroup
          : bloodGroupList.firstWhere(
              (b) => b.startsWith(rawBloodGroup),
              orElse: () => rawBloodGroup,
            );
      ref_nameCtrl.text = personal['refferal_name']?.toString() ?? '';
      dosh.value = _safeValue(personal['dosh']?.toString(), doshList);

      // Religion array: ["Mali","Aheri Mali"] → Mali = Caste (religion.value), Aheri Mali = Sub-Caste (casteCtrl.text & rxSubCaste.value)
      final religionArr = personal['religion'];
      if (religionArr is List && religionArr.isNotEmpty) {
        final casteVal = religionArr[0]?.toString() ?? '';
        religion.value = casteVal;
        if (religionArr.length > 1) {
          final subVal = religionArr[1]?.toString() ?? '';
          casteCtrl.text = subVal;
          rxSubCaste.value = subVal;
        }
        final matchingCaste = casteList.firstWhereOrNull((c) => c.name?.toLowerCase() == casteVal.toLowerCase());
        if (matchingCaste != null && matchingCaste.id != null) {
          fetchSubCasts(matchingCaste.id!);
        }
      }

      // Star details array: [star, raasi, "manglik-yes/no"]
      final starArr = personal['star_details'];
      if (starArr is List) {
        if (starArr.isNotEmpty) {
          star.value = _safeValue(starArr[0]?.toString(), starList);
        }
        if (starArr.length > 1) {
          raasi.value = _safeValue(starArr[1]?.toString(), raasiList);
        }
        if (starArr.length > 2) {
          final manglikStr = starArr[2]?.toString() ?? '';
          final manglikVal = manglikStr.replaceFirst('manglik-', '').trim();
          if (manglikVal.isNotEmpty) {
            final cap = manglikVal[0].toUpperCase() + manglikVal.substring(1).toLowerCase();
            manglik.value = _safeValue(cap, manglikList, fallback: cap);
          } else {
            manglik.value = 'No';
          }
        }
      }

      // Family details
      final family = profile['family_details'] as Map<String, dynamic>? ?? {};
      fatherOccupationCtrl.text = family['father']?.toString() ?? '';
      motherOccupationCtrl.text = family['mother']?.toString() ?? '';
      final rawFamilyClass = family['family_class']?.toString() ?? '';
      familyClass.value = _safeValue(rawFamilyClass, familyClassList);
      final rawFamilyValue = family['family_value']?.toString() ?? '';
      familyValue.value = _safeValue(rawFamilyValue, familyValueList);

      // Education details
      final edu = profile['education_details'] as Map<String, dynamic>? ?? {};
      final qual = edu['highest_qualification']?.toString() ?? '';
      education.value = _safeValue(qual, educationList, fallback: qual);
      collegeCtrl.text = edu['college']?.toString() ?? '';

      // Professional details
      final prof =
          profile['professional_details'] as Map<String, dynamic>? ?? {};
      if (prof['job_title'] != null && prof['job_title'].toString().isNotEmpty) {
        jobTitleCtrl.text = prof['job_title'].toString();
      }
      companyCtrl.text = prof['company']?.toString() ?? '';

      // Lifestyle details
      final lifestyle =
          profile['lifestyle_details'] as Map<String, dynamic>? ?? {};
      diet.value = _safeValue(lifestyle['diet']?.toString(), dietList);
      final rawSmoking = lifestyle['smoking']?.toString() ?? '';
      smoking.value = _safeValue(rawSmoking, smokingList);
      final rawDrinking = lifestyle['drinking']?.toString() ?? '';
      drinking.value = _safeValue(rawDrinking, drinkingList);

      // Location details
      final location =
          profile['location_details'] as Map<String, dynamic>? ?? {};
      cityCtrl.text = location['city']?.toString() ?? '';
      pinCodeCtrl.text = location['pincode']?.toString() ?? '';
      talukaCtrl.text = location['taluka']?.toString() ?? '';
      villageCtrl.text = location['village']?.toString() ?? '';
      addressCtrl.text = location['address']?.toString() ?? '';
      final fetchedCountry = location['country']?.toString() ?? 'India';
      onCountryChanged(fetchedCountry);
      countryCtrl.text = fetchedCountry;

      final fetchedState = location['state']?.toString() ?? '';
      state.value = fetchedState;
      stateCtrl.text = fetchedState;

      // Photos
      final photos = personal['photos'];
      if (photos is List) {
        existingPhotos.assignAll(photos.map((e) => e.toString()).toList());
      }

      // Caste Certificate
      final cert = profile['cast_certificate']?.toString();
      if (cert != null && cert.isNotEmpty) {
        existingCasteCertificateUrl.value = cert;
        casteCertificateFileName.value = cert.split('/').last;
      }
    } catch (e) {
      debugPrint('prefillFromApi error: $e');
    } finally {
      isPreFilling.value = false;
    }
  }

  /// Returns value if it exists in list (case-insensitive), or the trimmed value if list is empty, else fallback
  String _safeValue(String? value, List<String> list, {String fallback = ''}) {
    if (value == null) return fallback;
    final trimmed = value.trim();
    if (trimmed.isEmpty) return fallback;
    if (list.isEmpty) return trimmed;
    final match = list.firstWhereOrNull((e) => e.toLowerCase() == trimmed.toLowerCase());
    return match ?? trimmed;
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

        if (religion.value.isNotEmpty) {
          final matchingCaste = casteList.firstWhereOrNull(
            (c) => c.name?.toLowerCase() == religion.value.toLowerCase(),
          );
          if (matchingCaste != null && matchingCaste.id != null) {
            fetchSubCasts(matchingCaste.id!);
          }
        } else if (!isEditMode.value) {
          // Auto-select 'Mali' by default for new registrations
          final maliCast = casteList.firstWhereOrNull((c) => c.name?.toLowerCase() == 'mali');
          if (maliCast != null && maliCast.name != null) {
            onCasteSelected(maliCast.name!);
          }
        }
      }
    } catch (e) {
      print("Error fetching casts: $e");
    }
  }

  Future<void> fetchEducations() async {
    try {
      final response = await _repository.getEducations();
      if (response.success == true && response.data.isNotEmpty) {
        // Extract unique highest_qualification values
        final qualifications = response.data
            .where(
              (edu) =>
                  edu.highestQualification != null &&
                  edu.highestQualification!.isNotEmpty,
            )
            .map((edu) => edu.highestQualification!)
            .toSet() // Remove duplicates
            .toList();

        educationList.assignAll(qualifications);
        print(
          "DEBUG_EDUCATION: Fetched ${qualifications.length} education qualifications",
        );
      }
    } catch (e) {
      print("Error fetching educations: $e");
      // Fallback to default list if API fails
      educationList.assignAll([
        'High School',
        'Diploma',
        'Bachelor',
        'Master',
        'Doctorate',
        'Other',
      ]);
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
    religion.value =
        casteName; // Using religion variable to store Caste Name as per plan

    // Find ID
    final selectedCast = casteList.firstWhereOrNull((c) => c.name?.toLowerCase() == casteName.toLowerCase());
    if (selectedCast != null && selectedCast.id != null) {
      fetchSubCasts(selectedCast.id!);
    }

    if (!isPreFilling.value) {
      casteCtrl.clear(); // Clear sub-caste selection only when user manually selects
      rxSubCaste.value = '';
    }
  }

  void onSubCasteSelected(String subCasteName) {
    casteCtrl.text = subCasteName; // Using casteCtrl to store Sub-caste Name
    rxSubCaste.value = subCasteName;
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
    villageCtrl.dispose();
    addressCtrl.dispose();
    casteCtrl.dispose();
    subCasteCtrl.dispose();
    super.onClose();
  }

  Future<void> fetchAndShowPlans() async {
    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );
      final response = await _repository.getMatrimonyPlans();
      Get.back(); // Close Loading
      await Future.delayed(const Duration(milliseconds: 300)); // Allow pop animation to finish

      if (response.success == true && response.data?.plans != null) {
        final selectedPlan = await showSubscriptionBottomSheet(
          response.data!.plans!,
        );

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

      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      final response = await _paymentRepository.createOrder(planId: plan.id!);

      Get.back(); // Close Loading
      await Future.delayed(const Duration(milliseconds: 300)); // Allow pop animation to finish

      if (response.success && response.data != null) {
        final orderData = response.data!;
        final paymentWay = orderData['payment_way']?.toString().toLowerCase();

        if (paymentWay == 'ccavenue') {
          final result = await Get.to(
            () => CCAvenuePaymentScreen(
              paymentUrl: orderData['payment_url'] ?? '',
              encRequest: orderData['encRequest'] ?? '',
              accessCode: orderData['access_code'] ?? '',
              type: 'matrimony',
            ),
          );
          if (result == true) {
            // Payment success handling
            print("CCAvenue Matrimony Payment Success");
            PaymentSuccessDialog.show(
              amount: plan.price?.toString() ?? '0',
              paymentId: orderData['order_id']?.toString() ?? 'N/A',
              onOkPressed: () {
                if (Get.isRegistered<AuthService>()) {
                  Get.find<AuthService>().refreshProfile();
                }
                Get.back(); // Go back from payment page
              },
            );
          }
        } else {
          _razorpayController.openCheckout(
            amount:
                ((double.tryParse(orderData['amount']?.toString() ?? "0") ??
                            0) /
                        100)
                    .toInt(),
            name: nameCtrl.text,
            description: "Matrimony Subscription: ${plan.planName}",
            mobile: "", // Optional: fetch from Auth if needed
            email: "", // Optional: fetch from Auth if needed
            orderId: orderData['order_id'],
            transaction_id:
                int.tryParse(orderData['transaction_id']?.toString() ?? "0") ??
                0,
            key: orderData['key_id'],
            type: 'matrimony',
          );
        }
      } else {
        CustomSnackBar.showError(
          message: response.message ?? "Failed to create payment order",
        );
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      print("Payment Error: $e");
      CustomSnackBar.showError(message: "Payment initialization failed");
    }
  }
}
