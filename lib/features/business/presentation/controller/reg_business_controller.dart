import 'dart:convert';
import 'dart:io';

import 'package:edu_cluezer/core/helper/string_extensions.dart';
import 'package:edu_cluezer/features/business/presentation/controller/business_controller.dart';
import 'package:edu_cluezer/widgets/custom_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:edu_cluezer/features/business/data/model/res_all_business_model.dart';
import 'package:edu_cluezer/core/constent/api_constants.dart';
import 'package:edu_cluezer/core/network/api_client.dart';
import 'package:edu_cluezer/core/network/multipart.dart';
import 'package:edu_cluezer/core/helper/img_picker_helper.dart';
import 'package:edu_cluezer/features/business/domain/usecase/get_business_categories_usecase.dart';

class RegBusinessController extends GetxController {
  final ApiClient _apiClient = Get.find<ApiClient>();
  final GetBusinessCategoriesUseCase getBusinessCategoriesUseCase;

  RegBusinessController({required this.getBusinessCategoriesUseCase});

  /// Text Controllers
  final bNameCtrl = TextEditingController();
  final bTypeCtrl = TextEditingController();
  final bCategoryCtrl = TextEditingController();
  final bDescCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final websiteCtrl = TextEditingController();

  TextEditingController openingTimeCtrl = TextEditingController();
  TextEditingController closingTimeCtrl = TextEditingController();
  TimeOfDay? openingTime;
  TimeOfDay? closingTime;

  /// Dropdown DataContainer
  var businessTypes = <String>["Product", "Service"].obs;
  var businessCategories = <String>[].obs;
  
  // Maps to store ID mapping - Initialize with defaults
  Map<String, String> typeIdMap = {
    "Product": "product",
    "Service": "service"
  };

  // Dropdown DataContainer
//   var businessTypes = <String>[
//     "Proprietary / Partnership",
//     "Private Ltd",
//     "Public Ltd"
//   ].obs;
//
// // Map to store type IDs
//   Map<String, String> typeIdMap = {
//     "Proprietary / Partnership": "proprietary",
//     "Private Ltd": "private_ltd",
//     "Public Ltd": "public_ltd"
//   };

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
      
      // Handle Category (Fallback if needed, main logic in fetchCategories)
      if (business.category != null) {
          bCategoryCtrl.text = business.category!.name ?? "";
      }

      // Handle Existing Photo
      if (business.photo != null && business.photo!.isNotEmpty) {
        existingImages.add(business.photo!);
      }
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
    if (bCategoryCtrl.text == "Other") {
      // Show dialog when "Other" is selected
      Future.delayed(const Duration(milliseconds: 100), () {
        Get.dialog(
          AlertDialog(
            title: Text('add_custom_category'.tr),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'enter_category_name'.tr,
                  style: Get.context?.textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: customCategoryCtrl,
                  decoration: InputDecoration(
                    hintText: 'category_name_hint'.tr,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  customCategoryCtrl.clear();
                  bCategoryCtrl.clear();
                  Get.back();
                },
                child: Text('cancel'.tr),
              ),
              Obx(() => TextButton(
                onPressed: isRegisteringCategory.value
                    ? null
                    : () {
                        registerCustomCategory(customCategoryCtrl.text);
                      },
                child: isRegisteringCategory.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text('add_category'.tr),
              )),
            ],
          ),
          barrierDismissible: false,
        );
      });
    }
  }
  
  Future<void> fetchCategories() async {
    try {
      final categories = await getBusinessCategoriesUseCase();
      businessCategories.clear();
      categoryIdMap.clear();
      
      for(var cat in categories) {
        if (cat.name != null && cat.id != null) {
           businessCategories.add(cat.name!);
           categoryIdMap[cat.name!] = cat.id!;
        }
      }
      
      // Add "Other" option at the end
      businessCategories.add("Other");
      
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
        body,
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
          
          Get.back(); // Close dialog
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
      "Proprietary / Partnership",
      "Private Ltd",
      "Public Ltd"
    ]);

    typeIdMap = {
      "Proprietary / Partnership": "proprietary",
      "Private Ltd": "private_ltd",
      "Public Ltd": "public_ltd"
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
      allowMultiple: true,
    );
  }

  void removeImage(int index) {
    selectedImages.removeAt(index);
  }

  void removeExistingImage(int index) {
    existingImages.removeAt(index);
  }

  Future<void> onRegister() async {
    // Basic Validation
    if (bNameCtrl.text.isEmpty || bTypeCtrl.text.isEmpty || phoneCtrl.text.isEmpty) {
      CustomSnackBar.showError(message: "Please fill required fields");
      return;
    }

    try {
      // Get IDs from maps
      final typeId = typeIdMap[bTypeCtrl.text] ?? "product"; 
      final categoryId = categoryIdMap[bCategoryCtrl.text] ?? 1; 
      
      // Prepare Request Body
      final body = {
        "business_name": bNameCtrl.text,
        "business_type": typeId,
        "category_id": categoryId.toString(), 
        "description": bDescCtrl.text,
        "contact_phone": phoneCtrl.text,
        "contact_email": emailCtrl.text,
        "website": websiteCtrl.text,
      };

      if (isEditMode && businessId != null) {
          final success = await Get.find<BusinessController>().updateBusiness(businessId!, body);
          print("updatebusiness : "+success.toString());
          if (success) {
            Get.back(); // Close Screen
            CustomSnackBar.showSuccess(message: "Business updated successfully");
          }
          return;
      }

      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      // Prepare Multipart Body for Photos
      List<MultipartBody> multipartPhotos = [];
      for (var file in selectedImages) {
        multipartPhotos.add(MultipartBody(file: file, key: "photos[]"));
      }

      final response = await _apiClient.postMultipartData(
        ApiConstants.regBusiness,
        body.cast<String, String>(),
        multipartPhotos,
        [], // No other documents
      );

      Get.back(); // Close Loading

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data['success'] == true) {
          Get.back(); // Close screen
          CustomSnackBar.showSuccess(message: data['message'] ?? "Business registered successfully");
          
          // Refresh list if controller exists
          if (Get.isRegistered<BusinessController>()) {
             Get.find<BusinessController>().fetchMyBusinesses();
          }
        } else {
          // Handle server-side validation/business logic errors
          CustomSnackBar.showError(message: data['message'] ?? "Registration failed");
        }
      } else {
         final data = response.data;
         CustomSnackBar.showError(message: data['message'] ?? "Something went wrong");
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back(); // Close Loading if open
      CustomSnackBar.showError(message: "An unexpected error occurred: ${e.toString()}");
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
