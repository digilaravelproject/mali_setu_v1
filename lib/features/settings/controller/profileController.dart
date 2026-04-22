import 'dart:convert';
import 'dart:io';

import 'package:edu_cluezer/features/Auth/service/auth_service.dart';
import 'package:edu_cluezer/widgets/custom_snack_bar.dart';
import 'package:edu_cluezer/widgets/name_field_component.dart';
import 'package:edu_cluezer/widgets/phone_field_component.dart';
import 'package:edu_cluezer/core/helper/location_helper.dart';
import 'package:edu_cluezer/core/helper/pincode_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class UpProfileController extends GetxController {
  // NAME FIELD COMPONENT KEY
  final GlobalKey<NameFieldComponentState> nameFieldKey = GlobalKey<NameFieldComponentState>();
  
  // PHONE FIELD COMPONENT KEY
  final GlobalKey<PhoneFieldComponentState> phoneFieldKey = GlobalKey<PhoneFieldComponentState>();
  
  // Form Key for UI validation
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Personal Information Controllers
  final fullNameCtrl = TextEditingController();
  final ageCtrl = TextEditingController();
  final phoneNumberCtrl = TextEditingController();
  final occupationCtrl = TextEditingController();
  final emailCtrl = TextEditingController();

  // Address Information Controllers
  final streetAddressCtrl = TextEditingController();
  final nearbyLocationCtrl = TextEditingController();
  final roadNumberCtrl = TextEditingController();
  final cityCtrl = TextEditingController();
  final stateCtrl = TextEditingController();
  final districtCtrl = TextEditingController();
  final pincodeCtrl = TextEditingController();
  final sectorCtrl = TextEditingController();
  final destinationCtrl = TextEditingController();
  final villageCtrl = TextEditingController();

  // Profile Image
  final profileImage = Rxn<File>();
  final isUploadingImage = false.obs;
  
  // Loading state
  final isLoading = false.obs;
  final isFetchingPincode = false.obs;

  // Dropdown Data
  final cities = ["Lucknow", "Kanpur", "Delhi", "Mumbai", "Bangalore"];
  final states = ["Uttar Pradesh", "Delhi", "Bihar", "Maharashtra", "Karnataka"];
  final districts = ["Lucknow", "Kanpur Nagar", "New Delhi", "Mumbai Suburban"];

  // Load initial data from AuthService
  void loadUserData() {
    final user = Get.find<AuthService>().currentUser.value;
    if (user != null) {
      fullNameCtrl.text = user.name ?? "";
      ageCtrl.text = user.age?.toString() ?? "";
      phoneNumberCtrl.text = user.phone ?? "";
      occupationCtrl.text = user.occupation ?? "";
      emailCtrl.text = user.email ?? "";

      streetAddressCtrl.text = user.address ?? "";
      nearbyLocationCtrl.text = user.nearbyLocation ?? "";
      roadNumberCtrl.text = user.roadNumber ?? "";
      cityCtrl.text = user.city ?? "";
      stateCtrl.text = user.state ?? "";
      districtCtrl.text = user.district ?? "";
      pincodeCtrl.text = user.pincode ?? "";
      sectorCtrl.text = user.sector ?? "";
      destinationCtrl.text = user.destination ?? "";
      villageCtrl.text = user.village ?? "villagewkdnsa";
    }
  }

  // Profile Image Methods
  Future<void> pickImageFromCamera() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (image != null) {
        profileImage.value = File(image.path);
      }
    } catch (e) {
        CustomSnackBar.showError(
          message: 'Failed to capture image: ${e.toString()}',
        );
    }
  }

  Future<void> pickImageFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (image != null) {
        profileImage.value = File(image.path);
      }
    } catch (e) {
        CustomSnackBar.showError(
          message: 'Failed to pick image: ${e.toString()}',
        );
    }
  }

  void showImagePickerOptions() {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Choose Profile Photo',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.blue),
              title: const Text('Take Photo'),
              onTap: () {
                Get.back();
                pickImageFromCamera();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.green),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Get.back();
                pickImageFromGallery();
              },
            ),
            ListTile(
              leading: const Icon(Icons.cancel, color: Colors.red),
              title: const Text('Cancel'),
              onTap: () => Get.back(),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Update Profile
  Future<void> updateProfile() async {
    // 1. Form Key Validation (Asterisk fields)
    if (!(formKey.currentState?.validate() ?? false)) {
        return;
    }

    // 2. Validate name field component
    final nameValidation = nameFieldKey.currentState?.validate();
    if (nameValidation != null) {
      CustomSnackBar.showError(message: nameValidation);
      return;
    }
    
    // 3. Validate phone field component
    final phoneValidation = phoneFieldKey.currentState?.validate();
    if (phoneValidation != null) {
      CustomSnackBar.showError(message: phoneValidation);
      return;
    }
    
    if (emailCtrl.text.isEmpty || !GetUtils.isEmail(emailCtrl.text)) {
      CustomSnackBar.showError(message: 'Please enter valid email');
      return;
    }

    try {
      isLoading.value = true;

      // Get combined name from NameFieldComponent
      final combinedName = nameFieldKey.currentState?.getCombinedName() ?? '';
      
      // Get combined phone from PhoneFieldComponent
      final combinedPhone = phoneFieldKey.currentState?.getCombinedPhone() ?? '';

      // Fetch current location
      final location = await LocationHelper.getCurrentLocation();

      // Prepare data
      final Map<String, dynamic> updateData = {
        'name': combinedName,
        'email': emailCtrl.text,
        'phone': combinedPhone,
        'age': int.tryParse(ageCtrl.text),
        'occupation': occupationCtrl.text,
        'reffral_code': Get.find<AuthService>().currentUser.value?.reffralCode,
        'address': streetAddressCtrl.text,
        'nearby_location': nearbyLocationCtrl.text,
        'road_number': roadNumberCtrl.text,
        'city': cityCtrl.text,
        'state': stateCtrl.text,
        'district': districtCtrl.text,
        'pincode': pincodeCtrl.text,
        'sector': sectorCtrl.text,
        'destination': destinationCtrl.text,
        'village': villageCtrl.text,
        if (location != null) 'latitude': location['latitude'],
        if (location != null) 'longitude': location['longitude'],
      };

      // Add profile image as base64 if selected
      if (profileImage.value != null) {
        final bytes = await profileImage.value!.readAsBytes();
        final base64String = base64Encode(bytes);
        updateData['photos'] = [base64String];
      }

      // Call API via AuthService
      final response = await Get.find<AuthService>().updateProfile(updateData);

      if (response.success) {
        debugPrint("✅ Profile updated successfully");
        
        // Refresh user data from AuthService to get updated profile image
        await Get.find<AuthService>().refreshProfile();
        
        // Clear the local selected image so it shows server image
        profileImage.value = null;
        
        Get.back(); // Close update screen
        CustomSnackBar.showSuccess(
          message: 'Profile updated successfully',
        );
      } else {
        CustomSnackBar.showError(
          message: response.message ?? 'Failed to update profile',
        );
      }
    } catch (e) {
      CustomSnackBar.showError(
        message: 'An unexpected error occurred: ${e.toString()}',
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onInit() {
    loadUserData();
    pincodeCtrl.addListener(_onPincodeChanged);
    super.onInit();
  }

  void _onPincodeChanged() {
    final pincode = pincodeCtrl.text.trim();
    if (pincode.length == 6 && int.tryParse(pincode) != null) {
      _fetchAddressFromPincode(pincode);
    }
  }

  Future<void> _fetchAddressFromPincode(String pincode) async {
    try {
      isFetchingPincode.value = true;
      final response = await PincodeHelper.fetchAddressFromPincode(pincode);

      if (response != null) {
        cityCtrl.text = response.division;
        stateCtrl.text = response.state;
        districtCtrl.text = response.district;
        destinationCtrl.text = response.block; // Taluka
        villageCtrl.text = response.name; // Taluka
        CustomSnackBar.showSuccess(message: "Address auto-filled successfully!");
      } else {
        CustomSnackBar.showError(message: "Invalid pincode or no data found");
      }
    } catch (e) {
      print("Error fetching pincode info: $e");
    } finally {
      isFetchingPincode.value = false;
    }
  }

  @override
  void onClose() {
    // Remove pincode listener
    pincodeCtrl.removeListener(_onPincodeChanged);
    
    // Dispose all controllers
    final controllers = [
      fullNameCtrl, ageCtrl, phoneNumberCtrl, occupationCtrl, emailCtrl,
      streetAddressCtrl, nearbyLocationCtrl, roadNumberCtrl, cityCtrl,
      stateCtrl, districtCtrl, pincodeCtrl, sectorCtrl, destinationCtrl,villageCtrl
    ];

    for (final controller in controllers) {
      controller.dispose();
    }
    super.onClose();
  }
}