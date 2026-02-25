import 'package:edu_cluezer/features/matrimony/domain/repository/matrimony_repository.dart';
import 'package:edu_cluezer/features/razorpay/payment_repository.dart';
import 'package:edu_cluezer/features/razorpay/razorpay_controller.dart';
import 'package:edu_cluezer/widgets/custom_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/model/matrimony_cast_model.dart';
import '../../data/model/matrimony_plan_model.dart';
import '../page/matrimony_subscription_plan.dart';

class RegMatrimonyController extends GetxController {
  final MatrimonyRepository _repository = Get.find<MatrimonyRepository>();
  final PaymentRepository _paymentRepository = Get.find<PaymentRepository>();
  final RazorpayController _razorpayController = Get.find<RazorpayController>();

  final ScrollController scrollController = ScrollController();


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

  // Formatting variables
  DateTime? selectedDate;
  final rxDob = ''.obs;
  
  // Steps
  final currentStep = 0.obs;

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

  final List<String> educationList = ['High School', 'Diploma', 'Bachelor', 'Master', 'Doctorate', 'Other'];
  final List<String> employmentTypeList = ['Private Sector', 'Government/Public Sector', 'Civil Service', 'Defense', 'Business', 'Self Employed', 'Not Working'];
  
  final List<String> familyTypeList = ['Joint', 'Nuclear'];
  final List<String> familyClassList = ['Rich', 'Upper Middle Class', 'Middle Class', 'Lower Middle Class', 'Lower Class'];
  final List<String> familyValueList = ['Orthodox', 'Traditional', 'Moderate', 'Liberal'];
  
  final List<String> dietList = ['Vegetarian', 'Non-Vegetarian', 'Eggetarian', 'Vegan'];
  final List<String> smokingList = ['No', 'Yes', 'Occasionally'];
  final List<String> drinkingList = ['No', 'Yes', 'Occasionally'];

  final List<String> countryList = ['India', 'USA', 'UK', 'Canada', 'Australia', 'UAE', 'Other'];
  final List<String> stateList = ['Andhra Pradesh', 'Arunachal Pradesh', 'Assam', 'Bihar', 'Chhattisgarh', 'Goa', 'Gujarat', 'Haryana', 'Himachal Pradesh', 'Jharkhand', 'Karnataka', 'Kerala', 'Madhya Pradesh', 'Maharashtra', 'Manipur', 'Meghalaya', 'Mizoram', 'Nagaland', 'Odisha', 'Punjab', 'Rajasthan', 'Sikkim', 'Tamil Nadu', 'Telangana', 'Tripura', 'Uttar Pradesh', 'Uttarakhand', 'West Bengal', 'Delhi', 'Other'];



  /// --- Methods ---


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
      String formatted = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      dobCtrl.text = formatted;
      rxDob.value = formatted;
    }
  }

  int calculateAge() {
    if (selectedDate == null) return 0;
    final now = DateTime.now();
    int age = now.year - selectedDate!.year;
    if (now.month < selectedDate!.month || (now.month == selectedDate!.month && now.day < selectedDate!.day)) {
      age--;
    }
    return age;
  }

  void nextStep() {
    if (currentStep.value < 3) {
      currentStep.value++;
      scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
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


    //await fetchAndShowPlans();
    // Basic Validation
    if (nameCtrl.text.isEmpty || gender.value.isEmpty || dobCtrl.text.isEmpty) {
        CustomSnackBar.showError(message: "Please fill required fields");
        return;
    }
    try {
      Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);

      // Construct Nested JSON
      final Map<String, dynamic> body = {
        "age": calculateAge(), // 28
        "height": heightCtrl.text, // "5.6"
        "weight": weightCtrl.text, // "65"
        "complexion": complexion.value,
        "physical_status": physicalStatus.value,
        "personal_details": {
            "name": nameCtrl.text,
            "dob": dobCtrl.text, // "1997-05-12"
            "annual_income": annualIncomeCtrl.text,
            "occupation": jobTitleCtrl.text,
            "blood_group": bloodGroupCtrl.text,
            "refferal_name": ref_nameCtrl.text,
            "profile_created_by": profileCreatedBy.value,
            "hobbies": ["reading"], // Hardcoded for now
            "language": language.value,
            "citizenship": citizenship.value,
            "employment_type": employmentType.value,
            "family_type": familyType.value,
            "marital_status": maritalStatus.value,
            "religion": [religion.value, casteCtrl.text], // "Hindu", "General"
            "star_details": [star.value, raasi.value, "manglik-${manglik.value}"],
            "dosh": dosh.value
        },
        "family_details": {
            "father": fatherOccupationCtrl.text,
            "mother": motherOccupationCtrl.text,
            "family_class": familyClass.value,
            "family_value": familyValue.value
        },
        "education_details": {
            "highest_qualification": education.value,
            "college": collegeCtrl.text
        },
        "professional_details": {
            "job_title": jobTitleCtrl.text,
            "company": companyCtrl.text
        },
        "lifestyle_details": {
            "diet": diet.value,
            "smoking": smoking.value,
            "drinking": drinking.value
        },
        "location_details": {
            "city": cityCtrl.text,
            "state": state.value,
            "country": country.value
        },
        "partner_preferences": {
            "age_range": "20-30",
            "education": "Any",
            "location": "Any"
        },
        "privacy_settings": {
            "show_photos": "all",
            "show_contact": "premium_only"
        }
      };

      print("Calling API with Body: $body");

      final response = await _repository.createProfile(body);

      Get.back(); // Close Loading

      if (response.success == true) {

          Get.back(); // Close Registration Screen // Removed to show plans first
         CustomSnackBar.showSuccess(message: response.message ?? "Profile Created Successfully");
         
         // Fetch Plans and Show Dialog
         await fetchAndShowPlans();
         
      } else {
         CustomSnackBar.showError(message: response.message ?? "Failed to create profile");
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
    fetchCasts();
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
  }

  @override
  void onClose() {
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
