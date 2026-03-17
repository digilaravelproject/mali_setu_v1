import 'dart:convert';
import 'dart:io';

import 'package:edu_cluezer/widgets/custom_snack_bar.dart';
import 'package:edu_cluezer/widgets/name_field_component.dart';
import 'package:edu_cluezer/widgets/phone_field_component.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../core/routes/app_routes.dart';
import '../../../../../core/helper/pincode_helper.dart';
import '../../data/model/req_register_model.dart';
import '../../domain/usecase/register_usecase.dart';

class RegisterController extends GetxController {
  /// FORM KEY
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  
  /// NAME FIELD COMPONENT KEY
  final GlobalKey<NameFieldComponentState> nameFieldKey = GlobalKey<NameFieldComponentState>();
  
  /// PHONE FIELD COMPONENT KEY
  final GlobalKey<PhoneFieldComponentState> phoneFieldKey = GlobalKey<PhoneFieldComponentState>();

  /// BASIC DETAILS
  var selectedBirthDate = Rxn<DateTime>();
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController ageCtrl = TextEditingController();
  final TextEditingController mobileCtrl = TextEditingController();
  final TextEditingController userTypeCtrl = TextEditingController();

  /// ADDRESS DETAILS
  final TextEditingController addressCtrl = TextEditingController();
  final TextEditingController nearbyLocationCtrl = TextEditingController();
  final TextEditingController roadNumberCtrl = TextEditingController();
  final TextEditingController cityCtrl = TextEditingController();
  final TextEditingController stateCtrl = TextEditingController();
  final TextEditingController pinCodeCtrl = TextEditingController();
  final TextEditingController districtCtrl = TextEditingController();
  final TextEditingController sectorCtrl = TextEditingController();
  final TextEditingController destinationCtrl = TextEditingController();

  /// PROFESSIONAL DETAILS
  final TextEditingController occupationCtrl = TextEditingController();
  final TextEditingController referralCtrl = TextEditingController();
  final TextEditingController companynameCtrl = TextEditingController();
  final TextEditingController deptCtrl = TextEditingController();
  final TextEditingController designationCtrl = TextEditingController();

  /// SECURITY
  final TextEditingController passwordCtrl = TextEditingController();
  final TextEditingController confirmPasswordCtrl = TextEditingController();

  /// CASTE CERTIFICATE
  final casteCertificatePath = ''.obs;
  final casteCertificateFileName = ''.obs;
  final casteCertificateError = ''.obs;
  File? casteCertificateFile;
  final isLoading = false.obs;
  String? casteCertificateBase64;

  /// PINCODE AUTO-FILL
  final isFetchingPincode = false.obs;

  final usertypeList = [
    'General(Member Mali Setu)',
    'Business',
    'Matrimony',
    'Volunteer'
  ];

  String _getApiUserType(String displayType) {
    switch (displayType) {
      case 'General(Member Mali Setu)':
        return 'general';
      case 'Business':
        return 'business';
      case 'Matrimony':
        return 'matrimony';
      case 'Volunteer':
        return 'volunteer';
      default:
        return displayType.toLowerCase();
    }
  }

  /// PASSWORD VISIBILITY
  final isCnfPasswordValue = false.obs;
  final isPasswordValue = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Listen to pincode changes for auto-fill
    pinCodeCtrl.addListener(_onPincodeChanged);
  }

  /// Handle pincode changes for auto-fill
  void _onPincodeChanged() {
    final pincode = pinCodeCtrl.text.trim();

    // Only fetch if pincode is exactly 6 digits
    if (pincode.length == 6 && int.tryParse(pincode) != null) {
      _fetchAddressFromPincode(pincode);
    } else {
      // Clear fields if pincode is invalid or incomplete
      if (pincode.length < 6) {
        stateCtrl.clear();
        districtCtrl.clear();
        cityCtrl.clear();
      }
    }
  }

  /// Fetch address details from pincode API
  Future<void> _fetchAddressFromPincode(String pincode) async {
    try {
      isFetchingPincode.value = true;

      // Show loading message
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
        print("DEBUG_PINCODE: ========================================");
        print("DEBUG_PINCODE: Pincode API Response: $response");
        print("DEBUG_PINCODE: State: ${response.state}");
        print("DEBUG_PINCODE: District: ${response.district}");
        print("DEBUG_PINCODE: City: ${response.country}");
        print("DEBUG_PINCODE: Country: ${response.country}");
        print("DEBUG_PINCODE: ========================================");

        // Auto-fill state, district, and city from first PostOffice object
        stateCtrl.text = response.state;
        districtCtrl.text = response.district;
        cityCtrl.text = response.country; // Post office name as city

        CustomSnackBar.showSuccess(
          message: "Address details fetched successfully!",
        );
      } else {
        CustomSnackBar.showError(
          message: "Invalid pincode or no data found",
        );
        // Clear fields on error
        stateCtrl.clear();
        districtCtrl.clear();
        cityCtrl.clear();
      }
    } catch (e) {
      print("DEBUG_PINCODE: ❌ Error fetching pincode: $e");
      CustomSnackBar.showError(
        message: "Failed to fetch address details",
      );
      // Clear fields on error
      stateCtrl.clear();
      districtCtrl.clear();
      cityCtrl.clear();
    } finally {
      isFetchingPincode.value = false;
    }
  }

  /// VALIDATE STATE
  String? validateState(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter pincode to auto-fill state";
    }
    return null;
  }

  /// VALIDATE DISTRICT
  String? validateDistrict(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter pincode to auto-fill district";
    }
    return null;
  }

  /// VALIDATE CITY
  String? validateCity(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter pincode to auto-fill city";
    }
    return null;
  }

  /// PICK CASTE CERTIFICATE
  Future<void> pickCasteCertificate() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1200,
      );

      if (image != null) {
        // Check file size (max 5MB)
        final file = File(image.path);
        final fileSize = await file.length();
        const maxSize = 5 * 1024 * 1024; // 5MB

        if (fileSize > maxSize) {
          casteCertificateError.value = "File size must be less than 5MB";
          return;
        }

        // Check file type
        final extension = image.path.split('.').last.toLowerCase();
        if (!['jpg', 'jpeg', 'png', 'pdf'].contains(extension)) {
          casteCertificateError.value =
              "Only JPG, PNG, and PDF files are allowed";
          return;
        }

        casteCertificateFile = file;
        casteCertificatePath.value = image.path;
        casteCertificateFileName.value = image.name;
        casteCertificateError.value = ''; // Clear any previous error

        CustomSnackBar.showSuccess(
          message: "Caste certificate uploaded successfully",
        );
      }
    } catch (e) {
      casteCertificateError.value = "Failed to upload file: ${e.toString()}";
      debugPrint("Error picking caste certificate: $e");
    }
  }

  /// REMOVE CASTE CERTIFICATE
  void removeCasteCertificate() {
    casteCertificatePath.value = '';
    casteCertificateFileName.value = '';
    casteCertificateError.value = '';
    casteCertificateFile = null;
    casteCertificateBase64 = null;
  }

  /// VALIDATE CASTE CERTIFICATE
  bool _validateCasteCertificate() {
    if (casteCertificatePath.value.isEmpty) {
      casteCertificateError.value = "Please upload caste certificate";
      return false;
    }
    casteCertificateError.value = '';
    return true;
  }

  String _getMimeType(String filePath) {
    final ext = filePath.split('.').last.toLowerCase();
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      default:
        return 'image/jpeg';
    }
  }

  final RegisterUseCase registerUseCase;

  RegisterController({required this.registerUseCase});

  /// Register Action
  Future<void> onRegister() async {
    // Clear all validation errors first
    casteCertificateError.value = '';

    print("call registration function ");

    // Validate form
    if (!formKey.currentState!.validate()) {
      return;
    }
    
    // Validate name field component
    final nameValidation = nameFieldKey.currentState?.validate();
    if (nameValidation != null) {
      CustomSnackBar.showError(message: nameValidation);
      return;
    }
    
    // Validate phone field component
    final phoneValidation = phoneFieldKey.currentState?.validate();
    if (phoneValidation != null) {
      CustomSnackBar.showError(message: phoneValidation);
      return;
    }

    // Validate caste certificate
    if (!_validateCasteCertificate()) {
      return;
    }

    // Validate password confirmation
    if (passwordCtrl.text != confirmPasswordCtrl.text) {
      CustomSnackBar.showError(message: "Passwords do not match");
      return;
    }

    isLoading.value = true;

    try {
      // Prepare caste certificate data URL
      String castCertificateData = '';
      if (casteCertificateFile != null) {
        final bytes = await casteCertificateFile!.readAsBytes();
        casteCertificateBase64 = base64Encode(bytes);
      }

      if (casteCertificateBase64 != null &&
          casteCertificatePath.value.isNotEmpty) {
        final mimeType = _getMimeType(casteCertificatePath.value);
        castCertificateData = 'data:$mimeType;base64,$casteCertificateBase64';
      }

      // Get combined name from NameFieldComponent
      final combinedName = nameFieldKey.currentState?.getCombinedName() ?? '';
      
      // Get combined phone from PhoneFieldComponent
      final combinedPhone = phoneFieldKey.currentState?.getCombinedPhone() ?? '';

      final reqModel = ReqRegisterModel(
        name: combinedName,
        email: emailCtrl.text.trim(),
        dob: ageCtrl.text.trim() ,
        phone: combinedPhone,
        occupation: occupationCtrl.text.trim(),
        reffralCode: referralCtrl.text.trim().isEmpty
            ? null
            : referralCtrl.text.trim(),
        address: addressCtrl.text.trim(),
        nearbyLocation: nearbyLocationCtrl.text.trim(),
        pincode: pinCodeCtrl.text.trim(),
        roadNumber: roadNumberCtrl.text.trim(),
        state: stateCtrl.text.trim(),
        city: cityCtrl.text.trim(),
        sector: sectorCtrl.text.trim(),
        district: districtCtrl.text.trim(),
        destination: destinationCtrl.text.trim(),
        password: passwordCtrl.text.trim(),
        passwordConfirmation: confirmPasswordCtrl.text.trim(),
        userType: _getApiUserType(userTypeCtrl.text.trim()),
        castCertificate: castCertificateData,
        termCondition: true,
        company_name: companynameCtrl.text.trim(),
        dept_name: deptCtrl.text.trim(),
        designation: designationCtrl.text.trim()
      );

      final response = await registerUseCase(reqModel);

      print("registerresponse : " + response.toString());

      if (response.success == true ||
          response.message == "User registered successfully") {
        CustomSnackBar.showSuccess(
          message: response.messageString ?? "Registration completed successfully",
        );

        await Future.delayed(const Duration(seconds: 2));
        Get.offAllNamed(AppRoutes.login);
      } else {
        CustomSnackBar.showError(
            message: response.messageString ?? "Registration failed");
      }
    } catch (e) {
      debugPrint("Registration error: $e");
      CustomSnackBar.showError(
          message: "Registration failed: ${e.toString()}");
    } finally {
      isLoading.value = false;
    }
  }

  /// CLEANUP
  @override
  void onClose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    ageCtrl.dispose();
    mobileCtrl.dispose();

    addressCtrl.dispose();
    nearbyLocationCtrl.dispose();
    cityCtrl.dispose();
    stateCtrl.dispose();
    pinCodeCtrl.dispose();
    districtCtrl.dispose();
    sectorCtrl.dispose();
    destinationCtrl.dispose();
    roadNumberCtrl.dispose();

    occupationCtrl.dispose();
    referralCtrl.dispose();

    passwordCtrl.dispose();
    confirmPasswordCtrl.dispose();


    pinCodeCtrl.removeListener(_onPincodeChanged);

    super.onClose();
  }
}
