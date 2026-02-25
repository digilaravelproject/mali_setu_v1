import 'dart:convert';
import 'dart:io';

import 'package:edu_cluezer/features/Auth/service/auth_service.dart';
import 'package:edu_cluezer/widgets/custom_snack_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

/*class UpProfileController extends GetxController {
  /// Text Controllers
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
}*/




class UpProfileController extends GetxController {
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

  // Profile Image
  final profileImage = Rxn<File>();
  final isUploadingImage = false.obs;

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
        // Here you can upload to server
        // await uploadProfileImage(File(image.path));
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
        // Here you can upload to server
        // await uploadProfileImage(File(image.path));
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
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
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
    // Validate fields
    if (fullNameCtrl.text.isEmpty) {
      CustomSnackBar.showError(message: 'Please enter full name');
      return;
    }
    if (emailCtrl.text.isEmpty || !GetUtils.isEmail(emailCtrl.text)) {
      CustomSnackBar.showError(message: 'Please enter valid email');
      return;
    }
    if (phoneNumberCtrl.text.isEmpty) {
      CustomSnackBar.showError(message: 'Please enter phone number');
      return;
    }

    try {
      // Show loading
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(),
        ),
        barrierDismissible: false,
      );

      // Prepare data
      final Map<String, dynamic> updateData = {
        'name': fullNameCtrl.text,
        'email': emailCtrl.text,
        'phone': phoneNumberCtrl.text,
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
      };

      // Add profile image as base64 if selected
      if (profileImage.value != null) {
        final bytes = await profileImage.value!.readAsBytes();
        final base64String = base64Encode(bytes);
        updateData['photos'] = [base64String];
      }

      // Call API via AuthService
      final response = await Get.find<AuthService>().updateProfile(updateData);

      Get.back(); // Close loading

      if (response.success) {
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
      Get.back(); // Close loading if open
      CustomSnackBar.showError(
        message: 'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  @override
  void onInit() {
    loadUserData();
    super.onInit();
  }

  @override
  void onClose() {
    // Dispose all controllers
    final controllers = [
      fullNameCtrl, ageCtrl, phoneNumberCtrl, occupationCtrl, emailCtrl,
      streetAddressCtrl, nearbyLocationCtrl, roadNumberCtrl, cityCtrl,
      stateCtrl, districtCtrl, pincodeCtrl, sectorCtrl, destinationCtrl,
    ];

    for (final controller in controllers) {
      controller.dispose();
    }
    super.onClose();
  }
}