import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../core/routes/app_routes.dart';
import '../../data/model/req_register_model.dart';
import '../../data/model/state_model.dart';
import '../../domain/usecase/register_usecase.dart';

class RegisterController extends GetxController {
  /// FORM KEY
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  /// BASIC DETAILS
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


  final List<StateModel> statesData = [
    StateModel(
      id: '1',
      name: 'Maharashtra',
      districts: [
        DistrictModel(
          id: '11',
          name: 'Pune',
          cities: [
            CityModel(id: '111', name: 'Pune City'),
            CityModel(id: '112', name: 'Pimpri-Chinchwad'),
            CityModel(id: '113', name: 'Hinjewadi'),
            CityModel(id: '114', name: 'Hadapsar'),
            CityModel(id: '115', name: 'Kharadi'),
          ],
        ),
        DistrictModel(
          id: '12',
          name: 'Mumbai',
          cities: [
            CityModel(id: '121', name: 'South Mumbai'),
            CityModel(id: '122', name: 'Western Suburbs'),
            CityModel(id: '123', name: 'Eastern Suburbs'),
            CityModel(id: '124', name: 'Nav Mumbai'),
            CityModel(id: '125', name: 'Thane'),
          ],
        ),
        DistrictModel(
          id: '13',
          name: 'Nagpur',
          cities: [
            CityModel(id: '131', name: 'Nagpur City'),
            CityModel(id: '132', name: 'Katol'),
            CityModel(id: '133', name: 'Kalmeshwar'),
            CityModel(id: '134', name: 'Ramtek'),
          ],
        ),
        DistrictModel(
          id: '14',
          name: 'Nashik',
          cities: [
            CityModel(id: '141', name: 'Nashik City'),
            CityModel(id: '142', name: 'Deolali'),
            CityModel(id: '143', name: 'Satpur'),
            CityModel(id: '144', name: 'Gangapur'),
          ],
        ),
      ],
    ),
    StateModel(
      id: '2',
      name: 'Uttar Pradesh',
      districts: [
        DistrictModel(
          id: '21',
          name: 'Lucknow',
          cities: [
            CityModel(id: '211', name: 'Lucknow City'),
            CityModel(id: '212', name: 'Gomti Nagar'),
            CityModel(id: '213', name: 'Hazratganj'),
            CityModel(id: '214', name: 'Aliganj'),
            CityModel(id: '215', name: 'Chowk'),
          ],
        ),
        DistrictModel(
          id: '22',
          name: 'Kanpur',
          cities: [
            CityModel(id: '221', name: 'Kanpur City'),
            CityModel(id: '222', name: 'Panki'),
            CityModel(id: '223', name: 'Kalyanpur'),
            CityModel(id: '224', name: 'Govind Nagar'),
          ],
        ),
        DistrictModel(
          id: '23',
          name: 'Varanasi',
          cities: [
            CityModel(id: '231', name: 'Varanasi City'),
            CityModel(id: '232', name: 'Assi Ghat'),
            CityModel(id: '233', name: 'Dashashwamedh Ghat'),
            CityModel(id: '234', name: 'Bhelupur'),
          ],
        ),
        DistrictModel(
          id: '24',
          name: 'Ayodhya',
          cities: [
            CityModel(id: '241', name: 'Ayodhya City'),
            CityModel(id: '242', name: 'Faizabad'),
            CityModel(id: '243', name: 'Saket'),
            CityModel(id: '244', name: 'Naya Ghat'),
          ],
        ),
      ],
    ),
    StateModel(
      id: '3',
      name: 'Karnataka',
      districts: [
        DistrictModel(
          id: '31',
          name: 'Bengaluru',
          cities: [
            CityModel(id: '311', name: 'Bengaluru City'),
            CityModel(id: '312', name: 'Whitefield'),
            CityModel(id: '313', name: 'Electronic City'),
            CityModel(id: '314', name: 'Koramangala'),
            CityModel(id: '315', name: 'Indiranagar'),
          ],
        ),
        DistrictModel(
          id: '32',
          name: 'Mysuru',
          cities: [
            CityModel(id: '321', name: 'Mysuru City'),
            CityModel(id: '322', name: 'Vijayanagar'),
            CityModel(id: '323', name: 'Kuvempunagar'),
            CityModel(id: '324', name: 'Gokulam'),
          ],
        ),
        DistrictModel(
          id: '33',
          name: 'Hubballi',
          cities: [
            CityModel(id: '331', name: 'Hubballi City'),
            CityModel(id: '332', name: 'Old Hubballi'),
            CityModel(id: '333', name: 'New Hubballi'),
            CityModel(id: '334', name: 'Gokul Road'),
          ],
        ),
      ],
    ),
    StateModel(
      id: '4',
      name: 'Delhi',
      districts: [
        DistrictModel(
          id: '41',
          name: 'Central Delhi',
          cities: [
            CityModel(id: '411', name: 'Connaught Place'),
            CityModel(id: '412', name: 'Karol Bagh'),
            CityModel(id: '413', name: 'Paharganj'),
            CityModel(id: '414', name: 'Daryaganj'),
          ],
        ),
        DistrictModel(
          id: '42',
          name: 'South Delhi',
          cities: [
            CityModel(id: '421', name: 'Saket'),
            CityModel(id: '422', name: 'Hauz Khas'),
            CityModel(id: '423', name: 'Greater Kailash'),
            CityModel(id: '424', name: 'Vasant Kunj'),
          ],
        ),
        DistrictModel(
          id: '43',
          name: 'East Delhi',
          cities: [
            CityModel(id: '431', name: 'Preet Vihar'),
            CityModel(id: '432', name: 'Mayur Vihar'),
            CityModel(id: '433', name: 'Patparganj'),
            CityModel(id: '434', name: 'Shahdara'),
          ],
        ),
      ],
    ),
    StateModel(
      id: '5',
      name: 'Tamil Nadu',
      districts: [
        DistrictModel(
          id: '51',
          name: 'Chennai',
          cities: [
            CityModel(id: '511', name: 'Chennai City'),
            CityModel(id: '512', name: 'Adyar'),
            CityModel(id: '513', name: 'Anna Nagar'),
            CityModel(id: '514', name: 'T Nagar'),
            CityModel(id: '515', name: 'Velachery'),
          ],
        ),
        DistrictModel(
          id: '52',
          name: 'Coimbatore',
          cities: [
            CityModel(id: '521', name: 'Coimbatore City'),
            CityModel(id: '522', name: 'Peelamedu'),
            CityModel(id: '523', name: 'Saibaba Colony'),
            CityModel(id: '524', name: 'Ramanathapuram'),
          ],
        ),
        DistrictModel(
          id: '53',
          name: 'Madurai',
          cities: [
            CityModel(id: '531', name: 'Madurai City'),
            CityModel(id: '532', name: 'Koodal Nagar'),
            CityModel(id: '533', name: 'Simmakkal'),
            CityModel(id: '534', name: 'Villapuram'),
          ],
        ),
      ],
    ),
  ];


  /// OBSERVABLE LISTS FOR DROPDOWNS
  final stateList = <String>[].obs;
  final districtList = <String>[].obs;
  final cityList = <String>[].obs;



  final RxString selectedState = ''.obs;
  final RxString selectedDistrict = ''.obs;
  final RxString selectedCity = ''.obs;

  // final selectedStateName = stateCtrl.text.trim();
  // final selectedDistrictName = districtCtrl.text.trim();



  /// OBSERVABLE FOR VALIDATION ERRORS
  final stateError = ''.obs;
  final districtError = ''.obs;
  final cityError = ''.obs;

  final usertypeList = ['general',
    'individual',
    'business',
    'matrimony',
    'volunteer'];


  /// PASSWORD VISIBILITY
  final isCnfPasswordValue = false.obs;
  final isPasswordValue = false.obs;


  @override
  void onInit() {
    super.onInit();
    // Initialize state list
    _initializeStateList();

    ever(selectedState, (_) => _onStateChanged());
    ever(selectedDistrict, (_) => _onDistrictChanged());

    // Listen to state changes
    // ever(stateCtrl as RxInterface<Object?>, (_) => _onStateChanged());
    //
    // // Listen to district changes
    // ever(districtCtrl as RxInterface<Object?>, (_) => _onDistrictChanged());
  }

  /// Initialize state list from data
  void _initializeStateList() {
    stateList.value = statesData.map((state) => state.name).toList();
  }

  /// When state changes, update district list

  void _onStateChanged() {
    final selectedStateName = selectedState.value.trim();

    stateError.value = '';
    districtError.value = '';
    cityError.value = '';

    if (selectedStateName.isEmpty) {
      districtCtrl.clear();
      cityCtrl.clear();
      districtList.clear();
      cityList.clear();
      return;
    }

    final state = statesData.firstWhere(
          (s) => s.name == selectedStateName,
      orElse: () => StateModel(id: '', name: '', districts: []),
    );

    if (state.name.isNotEmpty) {
      districtList.value =
          state.districts.map((d) => d.name).toList();

      districtCtrl.clear();
      cityCtrl.clear();
      cityList.clear();
    }
  }


  /// When district changes, update city list

  void _onDistrictChanged() {
    final stateName = selectedState.value.trim();
    final districtName = selectedDistrict.value.trim();

    districtError.value = '';
    cityError.value = '';

    if (stateName.isEmpty || districtName.isEmpty) {
      cityCtrl.clear();
      cityList.clear();
      return;
    }

    final state = statesData.firstWhere(
          (s) => s.name == stateName,
      orElse: () => StateModel(id: '', name: '', districts: []),
    );

    final district = state.districts.firstWhere(
          (d) => d.name == districtName,
      orElse: () => DistrictModel(id: '', name: '', cities: []),
    );

    if (district.name.isNotEmpty) {
      cityList.value =
          district.cities.map((c) => c.name).toList();

      cityCtrl.clear();
    }
  }


  /// VALIDATE STATE
  String? validateState(String? value) {
    if (value == null || value.isEmpty) {
     // stateError.value = "Please select state";
      return "Please select state";
    }
    stateError.value = '';
    return null;
  }



  /// VALIDATE DISTRICT
  String? validateDistrict(String? value) {
    if (selectedState.value.isEmpty) {
      //districtError.value = "Please select state first";
      return "Please select state first";
    }

    if (value == null || value.isEmpty) {
     // districtError.value = "Please select district";
      return "Please select district";
    }
    districtError.value = '';
    return null;
  }

  /// VALIDATE CITY
  String? validateCity(String? value) {
    if (stateCtrl.text.isEmpty) {
      cityError.value = "Please select state first";
      return "Please select state first";
    }

    if (districtCtrl.text.isEmpty) {
      cityError.value = "Please select district first";
      return "Please select district first";
    }

    if (value == null || value.isEmpty) {
      cityError.value = "Please select city";
      return "Please select city";
    }
    cityError.value = '';
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
          casteCertificateError.value = "Only JPG, PNG, and PDF files are allowed";
          return;
        }

        casteCertificateFile = file;
        casteCertificatePath.value = image.path;
        casteCertificateFileName.value = image.name;
        casteCertificateError.value = ''; // Clear any previous error

        Get.snackbar(
          "Success",
          "Caste certificate uploaded successfully",
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
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
    stateError.value = '';
    districtError.value = '';
    cityError.value = '';
    casteCertificateError.value = '';

    // Validate form
    if (!formKey.currentState!.validate()) {
      return;
    }

    // Validate address hierarchy
    final stateValidation = validateState(stateCtrl.text.trim());
    final districtValidation = validateDistrict(districtCtrl.text.trim());
    final cityValidation = validateCity(cityCtrl.text.trim());

    if (stateValidation != null || districtValidation != null || cityValidation != null) {
      Get.snackbar("Error", "Please fill all address fields properly");
      return;
    }

    // Validate caste certificate
    if (!_validateCasteCertificate()) {
      return;
    }

    // Validate password confirmation
    if (passwordCtrl.text != confirmPasswordCtrl.text) {
      Get.snackbar("Error", "Passwords do not match");
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
      
      if (casteCertificateBase64 != null && casteCertificatePath.value.isNotEmpty) {
        final mimeType = _getMimeType(casteCertificatePath.value);
        castCertificateData = 'data:$mimeType;base64,$casteCertificateBase64';
      }

      final reqModel = ReqRegisterModel(
        name: nameCtrl.text.trim(),
        email: emailCtrl.text.trim(),
        age: int.tryParse(ageCtrl.text.trim()) ?? 0,
        phone: mobileCtrl.text.trim(),
        occupation: occupationCtrl.text.trim(),
        reffralCode: referralCtrl.text.trim().isEmpty ? null : referralCtrl.text.trim(),
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
        userType: userTypeCtrl.text.trim(),
        castCertificate: castCertificateData,
        termCondition: true,
      );

      final response = await registerUseCase(reqModel);

      if (response.success == true || response.message == "User registered successfully") {
        Get.snackbar(
          "Success",
          response.message ?? "Registration completed successfully",
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
        );

        await Future.delayed(const Duration(seconds: 2));
        Get.offAllNamed(AppRoutes.login);
      } else {
        Get.snackbar("Error", response.message ?? "Registration failed");
      }
    } catch (e) {
      debugPrint("Registration error: $e");
      Get.snackbar("Error", "Registration failed: ${e.toString()}");
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

    occupationCtrl.dispose();
    referralCtrl.dispose();

    passwordCtrl.dispose();
    confirmPasswordCtrl.dispose();

    super.onClose();
  }
}
