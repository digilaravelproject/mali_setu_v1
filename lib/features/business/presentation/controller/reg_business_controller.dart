import 'dart:convert';
import 'dart:io';

import 'package:edu_cluezer/core/helper/string_extensions.dart';
import 'package:edu_cluezer/features/business/presentation/controller/business_controller.dart';
import 'package:edu_cluezer/widgets/custom_snack_bar.dart';
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
import 'package:edu_cluezer/features/business/data/model/business_plan_model.dart';
import 'package:intl/intl.dart';

class RegBusinessController extends GetxController {
  final ApiClient _apiClient = Get.find<ApiClient>();
  final GetBusinessCategoriesUseCase getBusinessCategoriesUseCase;
  final BusinessRepository _repository = Get.find<BusinessRepository>();
  final PaymentRepository _paymentRepository = Get.find<PaymentRepository>();
  final RazorpayController _razorpayController = Get.find<RazorpayController>();

  RegBusinessController({required this.getBusinessCategoriesUseCase});

  /// Text Controllers
  final bNameCtrl = TextEditingController();
  final bTypeCtrl = TextEditingController();
  final bCategoryCtrl = TextEditingController();
  final bDescCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  //final websiteCtrl = TextEditingController();
  final websiteCtrl = TextEditingController(text: "https://");

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

  @override
  void onInit() {
    super.onInit();
    
    // Check for arguments (Edit Mode)
    if (Get.arguments != null && Get.arguments is Business) {
      isEditMode = true;
      final Business business = Get.arguments;
      businessId = business.id;
      editingCategoryId = business.categoryId; // Store for async lookup
      
      bNameCtrl.text = business.businessName ?? "";
      
      // Handle Business Type
      String type = (business.businessType ?? "").toLowerCase();
      if (type == "product") {
         bTypeCtrl.text = "Product";
      } else if (type == "service") {
         bTypeCtrl.text = "Service";
      } else {
         bTypeCtrl.text = (business.businessType ?? "").toTitleCase();
      }

      // Handle Business Type
      // String type = (business.businessType ?? "").toLowerCase();
      // if (type.contains("proprietary")) {
      //   bTypeCtrl.text = "Proprietary / Partnership";
      // } else if (type.contains("private")) {
      //   bTypeCtrl.text = "Private Ltd";
      // } else if (type.contains("public")) {
      //   bTypeCtrl.text = "Public Ltd";
      // } else {
      //   bTypeCtrl.text = (business.businessType ?? "").toTitleCase();
      // }


      bDescCtrl.text = business.description ?? "";
      phoneCtrl.text = business.contactPhone ?? "";
      emailCtrl.text = business.contactEmail ?? "";
      websiteCtrl.text = business.website ?? "";
      // openingTimeCtrl.text = business.opening_time ?? "";
      // closingTimeCtrl.text = business.closing_time ?? "";


      if (business.opening_time != null && business.opening_time!.isNotEmpty) {
        DateTime openTime = DateTime.parse("2000-01-01 ${business.opening_time!}");
        openingTimeCtrl.text = DateFormat.Hm().format(openTime); // HH:mm
      }

      if (business.closing_time != null && business.closing_time!.isNotEmpty) {
        DateTime closeTime = DateTime.parse("2000-01-01 ${business.closing_time!}");
        closingTimeCtrl.text = DateFormat.Hm().format(closeTime); // HH:mm
      }

      // Handle Category (Fallback if needed, main logic in fetchCategories)
      if (business.category != null) {
          bCategoryCtrl.text = business.category!.name ?? "";
      }

      // Handle Existing Photo
      if (business.photo != null && business.photo!.isNotEmpty) {
        // Prepend base URL if it's not already a full URL
        final photoUrl = business.photo!.startsWith('http') 
            ? business.photo! 
            : ApiConstants.imageBaseUrl + business.photo!;
        existingImages.add(photoUrl);
      }
    } else {
      // Auto-fill website with https:// for new registrations
      websiteCtrl.text = "https://";
    }

    _imagePickerHelper = ImagePickerHelper(
      onImagePicked: (files, flags) {
        if (files != null && files.isNotEmpty) {
          selectedImages.addAll(files);
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

  Future<void> onRegister() async {
    // Comprehensive Validation
    if (bNameCtrl.text.trim().isEmpty) {
      CustomSnackBar.showError(message: "Please enter business name");
      return;
    }
    if (bTypeCtrl.text.trim().isEmpty) {
      CustomSnackBar.showError(message: "Please select business type");
      return;
    }
    if (bCategoryCtrl.text.trim().isEmpty || bCategoryCtrl.text == "Select Category") {
      CustomSnackBar.showError(message: "Please select business category");
      return;
    }
    if (bDescCtrl.text.trim().isEmpty) {
      CustomSnackBar.showError(message: "Please enter business description");
      return;
    }
    if (openingTimeCtrl.text.trim().isEmpty) {
      CustomSnackBar.showError(message: "Please select opening time");
      return;
    }
    if (closingTimeCtrl.text.trim().isEmpty) {
      CustomSnackBar.showError(message: "Please select closing time");
      return;
    }
    if (phoneCtrl.text.trim().isEmpty) {
      CustomSnackBar.showError(message: "Please enter contact number");
      return;
    }
    if (emailCtrl.text.trim().isEmpty) {
      CustomSnackBar.showError(message: "Please enter email address");
      return;
    }
    String website = websiteCtrl.text.trim();
    if (website.isEmpty || website == "https://") {
      CustomSnackBar.showError(message: "Please enter website");
      return;
    }

    // Basic URL validation: must contain at least one dot and some characters after https://
    if (!website.contains(".") || website.length < 12) { // https://a.co is 12 chars
      CustomSnackBar.showError(message: "Please enter a valid website URL");
      return;
    }

    // Check for images in new registration
    if (!isEditMode && selectedImages.isEmpty) {
      CustomSnackBar.showError(message: "Please add at least one business photo");
      return;
    }

    // Check for images in edit mode (must have at least one image - either existing or new)
    if (isEditMode && existingImages.isEmpty && selectedImages.isEmpty) {
      CustomSnackBar.showError(message: "Please add at least one business photo");
      return;
    }

    try {
      // Get IDs from maps
      final typeId = typeIdMap[bTypeCtrl.text] ?? "product";
      final categoryId = categoryIdMap[bCategoryCtrl.text] ?? 1;

      // Prepare Request Body
      final body = <String, dynamic>{
        "business_name": bNameCtrl.text,
        "business_type": typeId,
        "category_id": categoryId.toString(),
        "description": bDescCtrl.text,
        "contact_phone": phoneCtrl.text,
        "contact_email": emailCtrl.text,
        "website": websiteCtrl.text,
        "opening_time": openingTimeCtrl.text,
        "closing_time": closingTimeCtrl.text
      };
      print("registerbusiness : " + body.toString());

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
    try {
      Get.dialog(const Center(child: CircularProgressIndicator()),
          barrierDismissible: false);
      final response = await _repository.getBusinessPlans();
      Get.back(); // Close Loading

      if (response.success == true && response.data?.plans != null) {
        // Filter plans by company type
        final selectedType = typeIdMap[bTypeCtrl.text] ?? bTypeCtrl.text;
        
        // Match logic: filter plans where company_type matches selectedType
        final filteredPlans = response.data!.plans!.where((plan) {
          final planType = plan.companyType?.toLowerCase() ?? "";
          final targetType = bTypeCtrl.text.toLowerCase();
          
          // Flexible matching
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
        
        // Close Registration Screen
        Get.back(); 

      } else {
        Get.back(); // Close Registration Screen if no plans
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      Get.back(); // Close Registration Screen
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
    customCategoryCtrl.dispose();
    super.onClose();
  }
}
