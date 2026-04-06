import 'dart:convert';
import 'dart:io';

import 'package:edu_cluezer/core/helper/string_extensions.dart';
import 'package:edu_cluezer/features/business/presentation/controller/business_controller.dart';
import 'package:edu_cluezer/widgets/custom_snack_bar.dart';
import 'package:edu_cluezer/widgets/phone_field_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:edu_cluezer/features/business/data/model/res_all_business_model.dart';
import 'package:edu_cluezer/core/constent/api_constants.dart';
import 'package:edu_cluezer/core/network/api_client.dart';
import 'package:edu_cluezer/core/helper/img_picker_helper.dart';
import 'package:edu_cluezer/features/business/domain/repository/all_business_repository.dart';
import 'package:edu_cluezer/features/business/presentation/page/business_subscription_plan.dart';
import 'package:edu_cluezer/features/razorpay/payment_repository.dart';
import 'package:edu_cluezer/features/razorpay/razorpay_controller.dart';
import 'package:edu_cluezer/features/business/domain/usecase/get_business_categories_usecase.dart';
import 'package:edu_cluezer/features/business/domain/usecase/get_business_details_usecase.dart';
import 'package:edu_cluezer/features/business/data/model/business_plan_model.dart';
import 'package:intl/intl.dart';

import '../../../../core/helper/pincode_helper.dart';
import '../../../../core/helper/location_helper.dart';

class RegBusinessController extends GetxController {
  final ApiClient _apiClient = Get.find<ApiClient>();
  final GetBusinessCategoriesUseCase getBusinessCategoriesUseCase;
  final GetBusinessDetailsUseCase getBusinessDetailsUseCase;
  final BusinessRepository _repository = Get.find<BusinessRepository>();
  final PaymentRepository _paymentRepository = Get.find<PaymentRepository>();
  final RazorpayController _razorpayController = Get.find<RazorpayController>();

  RegBusinessController({
    required this.getBusinessCategoriesUseCase,
    required this.getBusinessDetailsUseCase,
  });

  /// PHONE FIELD COMPONENT KEY
  final GlobalKey<PhoneFieldComponentState> phoneFieldKey = GlobalKey<PhoneFieldComponentState>();

  /// Text Controllers
  final bNameCtrl = TextEditingController();
  final bTypeCtrl = TextEditingController();
  final bCategoryCtrl = TextEditingController();
  final bDescCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  //final websiteCtrl = TextEditingController();
  final websiteCtrl = TextEditingController(text: "https://");
  final pinCodeCtrl = TextEditingController();
  final cityCtrl = TextEditingController();
  final stateCtrl = TextEditingController();
  final districtCtrl = TextEditingController();
  final countryCtrl = TextEditingController(text: "India");
  final talukaCtrl = TextEditingController();
  
  final isFetchingPincode = false.obs;
  final isDetailsLoading = false.obs;

  TextEditingController openingTimeCtrl = TextEditingController();
  TextEditingController closingTimeCtrl = TextEditingController();
  TimeOfDay? openingTime;
  TimeOfDay? closingTime;

  /// Dropdown DataContainer
 // var businessTypes = <String>["Product", "Service"].obs;
  var businessCategories = <String>[].obs;
  
  // Maps to store ID mapping - Initialize with defaults
  // Map<String, String> typeIdMap = {
  //   "Product": "product",
  //   "Service": "service"
  // };

  var businessTypes = <String>[
    "Proprietary /Partnership - LLP",
    "Private Ltd",
    "Public Ltd"
  ].obs;

  Map<String, String> typeIdMap = {
    "Proprietary /Partnership - LLP": "Proprietary /Partnership - LLP",
    "Private Ltd": "Private Ltd",
    "Public Ltd": "Public Ltd"
  };

  Map<String, int> categoryIdMap = {};

  /// Image Selection
  final RxList<File> selectedImages = <File>[].obs;
  final RxList<String> existingImages = <String>[].obs;
  late final ImagePickerHelper _imagePickerHelper;
  
  bool isEditMode = false;
  int? businessId;
  int? editingCategoryId;
  
  // For custom category registration
  final isRegisteringCategory = false.obs;
  final customCategoryCtrl = TextEditingController();
  
  // Flag to prevent auto-fetch on init
  bool _ignorePincodeChange = false;

  /// Validation Errors
  final errors = <String, String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    
    // Check for arguments (Edit Mode)
    if (Get.arguments != null) {
      if (Get.arguments is Business) {
        final Business business = Get.arguments;
        _populateForm(business); // Initial fast population
        if (business.id != null) {
          fetchBusinessDetails(business.id!); // Refresh with full details
        }
      } else if (Get.arguments is int) {
        fetchBusinessDetails(Get.arguments);
      }
    } else {
      // Auto-fill website with https:// for new registrations
      websiteCtrl.text = "https://";
    }

    pinCodeCtrl.addListener(_onPincodeChanged);

    _imagePickerHelper = ImagePickerHelper(
      onImagePicked: (files, flags) async {
        if (files != null && files.isNotEmpty) {
          List<File> validFiles = [];
          List<String> failedFiles = [];

          for (var file in files) {
            final int sizeInBytes = await file.length();
            final double sizeInMb = sizeInBytes / (1024 * 1024);
            
            final String extension = file.path.split('.').last.toLowerCase();
            final List<String> allowedExtensions = ['jpg', 'jpeg', 'png'];

            if (sizeInMb <= 2 && allowedExtensions.contains(extension)) {
              validFiles.add(file);
            } else {
              failedFiles.add(file.path.split('/').last);
            }
          }

          if (validFiles.isNotEmpty) {
            selectedImages.addAll(validFiles);
            errors.remove('photos');
          }

          if (failedFiles.isNotEmpty) {
            CustomSnackBar.showError(
              message: "Some files were skipped. Max size 2MB, Formats: JPG, PNG",
            );
          }
        }
      },
    );
    
    // Init lists
    if (businessTypes.isEmpty) {
        loadBusinessTypes();
    }
    fetchCategories();
    
    // Listen to category changes
    bCategoryCtrl.addListener(_onCategoryChanged);

    // Reactive error clearing
    ever(errors, (_) {}); // Force refresh
    bNameCtrl.addListener(() => errors.remove('businessName'));
    bTypeCtrl.addListener(() => errors.remove('businessType'));
    bCategoryCtrl.addListener(() => errors.remove('businessCategory'));
    bDescCtrl.addListener(() => errors.remove('description'));
    openingTimeCtrl.addListener(() => errors.remove('openingTime'));
    closingTimeCtrl.addListener(() => errors.remove('closingTime'));
    pinCodeCtrl.addListener(() => errors.remove('pincode'));
    cityCtrl.addListener(() => errors.remove('city'));
    districtCtrl.addListener(() => errors.remove('district'));
    stateCtrl.addListener(() => errors.remove('state'));
    countryCtrl.addListener(() => errors.remove('country'));
    phoneCtrl.addListener(() => errors.remove('phone'));
    emailCtrl.addListener(() => errors.remove('email'));
    selectedImages.listen((_) => errors.remove('photos'));
    
    // Add small delay to end of setup to ensure all listeners have settled
    Future.delayed(const Duration(milliseconds: 500), () {
      _ignorePincodeChange = false;
    });
  }

  void _onPincodeChanged() {
    if (_ignorePincodeChange) return;
    final pincode = pinCodeCtrl.text.trim();
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
        _ignorePincodeChange = true;
        countryCtrl.text = response.country;
        _ignorePincodeChange = false;
        talukaCtrl.text = response.name;
        CustomSnackBar.showSuccess(message: "Address auto-filled successfully!");
      }
    } catch (e) {
      print("Error fetching pincode info: $e");
    } finally {
      isFetchingPincode.value = false;
    }
  }
  
  void _onCategoryChanged() {
    // if (bCategoryCtrl.text == "Other") {
    //   // Show dialog when "Other" is selected
    //   Future.delayed(const Duration(milliseconds: 100), () {
    //     Get.dialog(
    //       AlertDialog(
    //         title: Text('add_custom_category'.tr),
    //         content: Column(
    //           mainAxisSize: MainAxisSize.min,
    //           children: [
    //             Text(
    //               'enter_category_name'.tr,
    //               style: Get.context?.textTheme.bodyMedium,
    //             ),
    //             const SizedBox(height: 16),
    //             TextField(
    //               controller: customCategoryCtrl,
    //               decoration: InputDecoration(
    //                 hintText: 'category_name_hint'.tr,
    //                 border: OutlineInputBorder(
    //                   borderRadius: BorderRadius.circular(8),
    //                 ),
    //                 contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    //               ),
    //             ),
    //           ],
    //         ),
    //         actions: [
    //           TextButton(
    //             onPressed: () {
    //               customCategoryCtrl.clear();
    //               bCategoryCtrl.clear();
    //               Get.back();
    //             },
    //             child: Text('cancel'.tr),
    //           ),
    //           Obx(() => TextButton(
    //             onPressed: isRegisteringCategory.value
    //                 ? null
    //                 : () {
    //                     registerCustomCategory(customCategoryCtrl.text);
    //                   },
    //             child: isRegisteringCategory.value
    //                 ? const SizedBox(
    //                     width: 20,
    //                     height: 20,
    //                     child: CircularProgressIndicator(strokeWidth: 2),
    //                   )
    //                 : Text('add_category'.tr),
    //           )),
    //         ],
    //       ),
    //       barrierDismissible: false,
    //     );
    //   });
    // }
  }
  
  Future<void> fetchCategories() async {
    try {
      final categories = await getBusinessCategoriesUseCase();
      
      final tempCategories = <String>[];
      final tempIdMap = <String, int>{};
      
      for(var cat in categories) {
        if (cat.name != null && cat.id != null) {
           tempCategories.add(cat.name!);
           tempIdMap[cat.name!] = cat.id!;
        }
      }
      
      // Add "Other" option at the end
      tempCategories.add("Other");
      
      // Atomic updates
      categoryIdMap = tempIdMap;
      businessCategories.assignAll(tempCategories);
      
      // If in edit mode, re-trigger category name set after fetch
      if(isEditMode && editingCategoryId != null) {
          String? catName;
           for(var entry in categoryIdMap.entries) {
               if (entry.value == editingCategoryId) {
                   catName = entry.key;
                   break;
               }
           }
           if (catName != null) {
               bCategoryCtrl.text = catName;
               print("DEBUG: Async set category to $catName");
           }
      }
      
    } catch (e) {
      print("Error fetching categories: $e");
    } finally {
       print("Categories loaded: ${businessCategories.length}");
    }
  }
  
  Future<void> registerCustomCategory(String categoryName) async {
    if (categoryName.trim().isEmpty) {
      CustomSnackBar.showError(message: "Please enter a category name");
      return;
    }

    try {
      isRegisteringCategory.value = true;
      
      final body = {
        "name": categoryName.trim(),
        "description": "",
        "photo": ""
      };

      final response = await _apiClient.post(
        ApiConstants.registerCategory,
        data: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data['success'] == true) {
          final categoryData = data['data']['business_category'];
          final newCategoryId = categoryData['id'];
          final newCategoryName = categoryData['name'];
          
          // Add to local lists
          businessCategories.remove("Other");
          businessCategories.add(newCategoryName);
          businessCategories.add("Other");
          categoryIdMap[newCategoryName] = newCategoryId;
          
          // Set the newly created category as selected
          bCategoryCtrl.text = newCategoryName;
          customCategoryCtrl.clear();
          
          // Refresh categories from server as requested
          await fetchCategories();
          
          // Ensure the selected value remains valid after fetch
          // (fetchCategories clears and rebuilds the list, so we might need to ensure the name logic in UI holds)
          // Since bCategoryCtrl.text is just a string, it should be fine.
          
          CustomSnackBar.showSuccess(message: "Category added successfully");
        } else {
          CustomSnackBar.showError(message: data['message'] ?? "Failed to add category");
        }
      } else {
        final data = response.data;
        CustomSnackBar.showError(message: data['message'] ?? "Something went wrong");
      }
    } catch (e) {
      CustomSnackBar.showError(message: "Error: ${e.toString()}");
    } finally {
      isRegisteringCategory.value = false;
    }
  }

  // Future<void> loadBusinessTypes() async {
  //   try {
  //     // Just load types from JSON or hardcode
  //     final String response = await rootBundle.loadString('assets/json/business_data.json');
  //     final data = await json.decode(response);
  //
  //     if (data['business_types'] != null) {
  //       businessTypes.clear();
  //       typeIdMap.clear();
  //       for (var item in data['business_types']) {
  //         businessTypes.add(item['name']);
  //         typeIdMap[item['name']] = item['id'].toString();
  //       }
  //     }
  //   } catch (e) {
  //     print("Error loading types: $e");
  //     // Fallback
  //     businessTypes.assignAll(["Product", "Service"]);
  //     typeIdMap.assignAll({"Product": "product", "Service": "service"});
  //   }
  // }

  Future<void> loadBusinessTypes() async {
    businessTypes.assignAll([
      "Proprietary /Partnership - LLP",
      "Private Ltd",
      "Public Ltd"
    ]);

    typeIdMap = {
      "Proprietary /Partnership - LLP": "Proprietary /Partnership - LLP",
      "Private Ltd": "Private Ltd",
      "Public Ltd": "Public Ltd"
    };
  }

  String _toTitleCase(String text) {
      if (text.isEmpty) return text;
      return text[0].toUpperCase() + text.substring(1);
  }

  void pickImages(BuildContext context) {
    _imagePickerHelper.showImagePickerDialog(
      context,
      "business_photos",
      allowMultiple: false,  // Changed to false for single image
    );
  }

  void removeImage(int index) {
    selectedImages.removeAt(index);
  }

  void removeExistingImage(int index) {
    existingImages.removeAt(index);
  }

  bool validateBusinessFields() {
    errors.clear();

    if (bNameCtrl.text.trim().isEmpty) errors['businessName'] = "Please enter business name";
    if (bTypeCtrl.text.trim().isEmpty) errors['businessType'] = "Please select business type";
    if (bCategoryCtrl.text.trim().isEmpty || bCategoryCtrl.text == "Select Category") {
      errors['businessCategory'] = "Please select business category";
    }
    if (bDescCtrl.text.trim().isEmpty) errors['description'] = "Please enter business description";
    if (openingTimeCtrl.text.trim().isEmpty) errors['openingTime'] = "Please select opening time";
    if (closingTimeCtrl.text.trim().isEmpty) errors['closingTime'] = "Please select closing time";
    
    // Location
    if (pinCodeCtrl.text.trim().isEmpty) errors['pincode'] = "Please enter pincode";
    else if (pinCodeCtrl.text.trim().length < 5 || pinCodeCtrl.text.trim().length > 10) errors['pincode'] = "No Match";
    
    if (cityCtrl.text.trim().isEmpty) errors['city'] = "Please enter city";
    if (districtCtrl.text.trim().isEmpty) errors['district'] = "Please enter district";
    if (stateCtrl.text.trim().isEmpty) errors['state'] = "Please enter state";
    if (countryCtrl.text.trim().isEmpty) errors['country'] = "Please enter country";

    // Contact - Use component validation for consistency
    final phoneValidationError = phoneFieldKey.currentState?.validate();
    if (phoneValidationError != null) {
      errors['phone'] = phoneValidationError;
    } else {
      errors.remove('phone');
    }
    
    if (emailCtrl.text.trim().isEmpty) {
      errors['email'] = "Please enter email address";
    } else if (!GetUtils.isEmail(emailCtrl.text.trim())) {
      errors['email'] = "Please enter a valid email";
    }

    // Photos
    if (!isEditMode && selectedImages.isEmpty) {
      errors['photos'] = "Please add at least one business photo";
    } else if (isEditMode && existingImages.isEmpty && selectedImages.isEmpty) {
      errors['photos'] = "Please add at least one business photo";
    }

    if (errors.isNotEmpty) {
      return false;
    }
    return true;
  }

  Future<void> onRegister() async {
    if (!validateBusinessFields()) return;

    try {
      // Get IDs from maps
      final typeId = typeIdMap[bTypeCtrl.text] ?? "product";
      final categoryId = categoryIdMap[bCategoryCtrl.text] ?? 1;

      // Get combined phone from PhoneFieldComponent
      final combinedPhone = phoneFieldKey.currentState?.getCombinedPhone() ?? '';

      // Prepare Request Body
      final body = <String, dynamic>{
        "business_name": bNameCtrl.text,
        "business_type": typeId,
        "category_id": categoryId.toString(),
        "description": bDescCtrl.text,
        "contact_phone": combinedPhone,
        "contact_email": emailCtrl.text,
        "website": (websiteCtrl.text.trim() == "https://" || websiteCtrl.text.trim().isEmpty) ? "" : websiteCtrl.text.trim(),
        "country": countryCtrl.text,
        "state": stateCtrl.text,
        "district": districtCtrl.text,
        "taluka": talukaCtrl.text,
        "city": cityCtrl.text,
        "pincode": pinCodeCtrl.text,
        "opening_time": openingTime == null ? "" : "${openingTime!.hour.toString().padLeft(2, '0')}:${openingTime!.minute.toString().padLeft(2, '0')}",
        "closing_time": closingTime == null ? "" : "${closingTime!.hour.toString().padLeft(2, '0')}:${closingTime!.minute.toString().padLeft(2, '0')}",
        // Adding nested location details as a fallback for Laravel/Matrimony-style endpoints
        "location_details": {
          "state": stateCtrl.text,
          "district": districtCtrl.text,
          "taluka": talukaCtrl.text,
          "city": cityCtrl.text,
          "pincode": pinCodeCtrl.text,
          "country": countryCtrl.text,
        }
      };
      print("registerbusiness : " + body.toString());

      // Fetch current location
      final location = await LocationHelper.getCurrentLocation();
      if (location != null) {
        body['latitude'] = location['latitude'];
        body['longitude'] = location['longitude'];
      }

      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      if (isEditMode && businessId != null) {
        // Convert images to base64
        List<String> base64Images = [];
        
        // Add newly selected images as base64
        for (var file in selectedImages) {
          final bytes = await file.readAsBytes();
          final base64String = base64Encode(bytes);
          base64Images.add(base64String);
        }

        // Always add photos array (even if empty, to clear old images if user removed them)
        body['photos'] = base64Images;

        final response = await _apiClient.put(
          "${ApiConstants.updateBusinessServices}/$businessId",
          data: body,
        );

        Get.back(); // Close Loading

        if (response.statusCode == 200 || response.statusCode == 201) {
          final data = response.data;
          debugPrint("[RegBusinessController] Update Response: ${jsonEncode(data)}");
          if (data['success'] == true) {
            // Refresh list if controller exists
            if (Get.isRegistered<BusinessController>()) {
              Get.find<BusinessController>().fetchMyBusinesses();
            }
            Get.back(); // Close Screen
            CustomSnackBar.showSuccess(
                message: "Business updated successfully");
          } else {
            CustomSnackBar.showError(
                message: data['message'] ?? "Update failed");
          }
        } else {
          final data = response.data;
          CustomSnackBar.showError(
              message: data['message'] ?? "Something went wrong");
        }
        return;
      }

      // Convert images to base64 for new registration
      List<String> base64Images = [];
      
      // Add newly selected images as base64
      for (var file in selectedImages) {
        final bytes = await file.readAsBytes();
        final base64String = base64Encode(bytes);
        base64Images.add(base64String);
      }

      // Add photos array to body
      body['photos'] = base64Images;

      final response = await _apiClient.post(
        ApiConstants.regBusiness,
        data: body,
      );

      Get.back(); // Close Loading

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data['success'] == true) {
          // Refresh list if controller exists
          if (Get.isRegistered<BusinessController>()) {
            Get.find<BusinessController>().fetchMyBusinesses();
          }

          // Fetch and Show Plans
          await fetchAndShowBusinessPlans();
        } else {
          // Handle server-side validation/business logic errors
          CustomSnackBar.showError(
              message: data['message'] ?? "Registration failed");
        }
      } else {
        final data = response.data;
        CustomSnackBar.showError(
            message: data['message'] ?? "Something went wrong");
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back(); // Close Loading if open
      CustomSnackBar.showError(
          message: "An unexpected error occurred: ${e.toString()}");
    }
  }

  Future<void> fetchAndShowBusinessPlans() async {
    await fetchAndShowBusinessPlansForType(bTypeCtrl.text);
  }

  Future<void> fetchAndShowBusinessPlansForType(String businessType) async {
    try {
      Get.dialog(const Center(child: CircularProgressIndicator()),
          barrierDismissible: false);
      final response = await _repository.getBusinessPlans();
      Get.back(); // Close Loading

      if (response.success == true && response.data?.plans != null) {
        final targetType = businessType.toLowerCase();
        
        final filteredPlans = response.data!.plans!.where((plan) {
          final planType = plan.companyType?.toLowerCase() ?? "";
          return planType.contains(targetType) || targetType.contains(planType);
        }).toList();

        if (filteredPlans.isEmpty) {
          CustomSnackBar.showInfo(message: "No specific plans found for your business type. Showing all plans.");
          filteredPlans.addAll(response.data!.plans!);
        }

        final selectedPlan = await showBusinessSubscriptionBottomSheet(filteredPlans);
        
        if (selectedPlan != null) {
          await initiateBusinessPayment(selectedPlan);
        }
        
        // Only close registration screen if called from registration flow
        if (bTypeCtrl.text.isNotEmpty) {
          Get.back();
        }

      } else {
        Get.back();
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      print("Error fetching business plans: $e");
    }
  }

  Future<void> initiateBusinessPayment(BusinessPlan plan) async {
    try {
      Get.dialog(const Center(child: CircularProgressIndicator()),
          barrierDismissible: false);
      
      final response = await _paymentRepository.createBusinessPaymentOrder(
        planId: plan.id!,
        //type: "business" // Ensure type is business
      );

      Get.back(); // Close Loading

      if (response.success && response.data != null) {
        final orderData = response.data!;

        _razorpayController.openCheckout(
          amount: ((double.tryParse(plan.price?.toString() ?? "0") ?? 0)).toInt(),
          name: bNameCtrl.text,
          description: "Business Subscription Plan",
          mobile: phoneCtrl.text,
          email: emailCtrl.text,
          orderId: orderData['order_id'],
          transaction_id: int.tryParse(orderData['transaction_id']?.toString() ?? "0") ?? 0,
          key: orderData['key_id'],
          type: 'business',
        );
      } else {
        CustomSnackBar.showError(
            message: response.message ?? "Failed to create payment order");
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      print("Error initiating payment: $e");
      CustomSnackBar.showError(message: "Payment initialization failed: $e");
    }
  }

  void _populateForm(Business business) {
    debugPrint("[RegBusinessController] Populating form for: ${business.businessName}");
    isEditMode = true;
    businessId = business.id;
    editingCategoryId = business.categoryId; // Store for async lookup in fetchCategories
    
    _ignorePincodeChange = true;
    bNameCtrl.text = business.businessName ?? "";

    // Handle Business Type
    // The API might return the display name or the ID.
    // Try to match the display name from the map if it's there
    String? type = business.businessType;
    if (type != null) {
      if (type.toLowerCase() == "product") {
        bTypeCtrl.text = "Product";
      } else if (type.toLowerCase() == "service") {
        bTypeCtrl.text = "Service";
      } else {
        // Direct set if it matches our list (e.g. "Proprietary /Partnership - LLP")
        bTypeCtrl.text = type;
      }
    }

    bDescCtrl.text = business.description ?? "";
    phoneCtrl.text = business.contactPhone ?? "";
    emailCtrl.text = business.contactEmail ?? "";
    websiteCtrl.text = business.website ?? "";

    // Pre-fill location fields
    pinCodeCtrl.text = business.pincode ?? "";
    cityCtrl.text = business.city ?? "";
    districtCtrl.text = business.district ?? "";
    talukaCtrl.text = business.taluka ?? "";
    stateCtrl.text = business.state ?? "";
    countryCtrl.text = business.country ?? "India";

    // Handle Time (Supports HH:mm:ss from API)
    if (business.opening_time != null && business.opening_time!.isNotEmpty) {
      try {
        // Use HH:mm:ss to match your provided JSON "09:00:00"
        String timeStr = business.opening_time!;
        DateTime openTime;
        if (timeStr.split(':').length == 3) {
          openTime = DateFormat("HH:mm:ss").parse(timeStr);
        } else {
          openTime = DateFormat("HH:mm").parse(timeStr);
        }
        openingTime = TimeOfDay.fromDateTime(openTime);
        openingTimeCtrl.text = DateFormat.jm().format(openTime);
      } catch (e) {
        debugPrint("Error parsing opening time ($business.opening_time): $e");
      }
    }

    if (business.closing_time != null && business.closing_time!.isNotEmpty) {
      try {
        String timeStr = business.closing_time!;
        DateTime closeTime;
        if (timeStr.split(':').length == 3) {
          closeTime = DateFormat("HH:mm:ss").parse(timeStr);
        } else {
          closeTime = DateFormat("HH:mm").parse(timeStr);
        }
        closingTime = TimeOfDay.fromDateTime(closeTime);
        closingTimeCtrl.text = DateFormat.jm().format(closeTime);
      } catch (e) {
        debugPrint("Error parsing closing time ($business.closing_time): $e");
      }
    }

    // Handle Category
    if (business.category != null) {
      bCategoryCtrl.text = business.category!.name ?? "";
    }

    // Handle Existing Photo
    if (business.photo != null && business.photo!.isNotEmpty) {
      final photoUrl = business.photo!.startsWith('http') 
          ? business.photo! 
          : ApiConstants.imageBaseUrl + business.photo!;
      existingImages.clear();
      existingImages.add(photoUrl);
    }

    // Reset ignore flag after UI has updated
    Future.delayed(const Duration(milliseconds: 500), () {
      _ignorePincodeChange = false;
    });
  }

  Future<void> fetchBusinessDetails(int id) async {
    try {
      isDetailsLoading.value = true;
      final business = await getBusinessDetailsUseCase(id);
      if (business != null) {
        _populateForm(business);
      }
    } catch (e) {
      CustomSnackBar.showError(message: "Failed to load business details: $e");
    } finally {
      isDetailsLoading.value = false;
    }
  }

  @override
  void onClose() {
    bCategoryCtrl.removeListener(_onCategoryChanged);
    bNameCtrl.dispose();
    bTypeCtrl.dispose();
    bCategoryCtrl.dispose();
    bDescCtrl.dispose();
    phoneCtrl.dispose();
    emailCtrl.dispose();
    websiteCtrl.dispose();
    pinCodeCtrl.dispose();
    cityCtrl.dispose();
    stateCtrl.dispose();
    districtCtrl.dispose();
    countryCtrl.dispose();
    talukaCtrl.dispose();
    customCategoryCtrl.dispose();
    super.onClose();
  }
}
