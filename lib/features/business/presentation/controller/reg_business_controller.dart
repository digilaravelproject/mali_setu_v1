import 'dart:convert';
import 'dart:io';

import 'package:edu_cluezer/core/helper/string_extensions.dart';
import 'package:edu_cluezer/features/business/presentation/controller/business_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../data/model/res_all_business_model.dart';
import '../../../../core/constent/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/multipart.dart';
import '../../../../core/helper/img_picker_helper.dart';
import '../../domain/usecase/get_business_categories_usecase.dart';

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

  /// Dropdown DataContainer
  var businessTypes = <String>["Product", "Service"].obs;
  var businessCategories = <String>[].obs;
  
  // Maps to store ID mapping - Initialize with defaults
  Map<String, String> typeIdMap = {
    "Product": "product", 
    "Service": "service"
  };
  Map<String, int> categoryIdMap = {};

  /// Image Selection
  final RxList<File> selectedImages = <File>[].obs;
  final RxList<String> existingImages = <String>[].obs;
  late final ImagePickerHelper _imagePickerHelper;
  
  bool isEditMode = false;
  int? businessId;
  int? editingCategoryId;

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

  Future<void> loadBusinessTypes() async {
    try {
      // Just load types from JSON or hardcode
      final String response = await rootBundle.loadString('assets/json/business_data.json');
      final data = await json.decode(response);
      
      if (data['business_types'] != null) {
        businessTypes.clear();
        typeIdMap.clear();
        for (var item in data['business_types']) {
          businessTypes.add(item['name']);
          typeIdMap[item['name']] = item['id'].toString();
        }
      }
    } catch (e) {
      print("Error loading types: $e");
      // Fallback
      businessTypes.assignAll(["Product", "Service"]);
      typeIdMap.assignAll({"Product": "product", "Service": "service"});
    }
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
      Get.snackbar("Error", "Please fill required fields", backgroundColor: Colors.red, colorText: Colors.white);
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
            Get.snackbar("Success", "Business updated successfully", backgroundColor: Colors.green, colorText: Colors.white);
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
          Get.snackbar("Success", data['message'] ?? "Business registered successfully", backgroundColor: Colors.green, colorText: Colors.white);
          
          // Refresh list if controller exists
          if (Get.isRegistered<BusinessController>()) {
             Get.find<BusinessController>().fetchMyBusinesses();
          }
        } else {
          // Handle server-side validation/business logic errors
          Get.snackbar("Error", data['message'] ?? "Registration failed", backgroundColor: Colors.red, colorText: Colors.white);
        }
      } else {
         final data = response.data;
         Get.snackbar("Error", data['message'] ?? "Something went wrong", backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back(); // Close Loading if open
      Get.snackbar("Error", "An unexpected error occurred: ${e.toString()}", backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  @override
  void onClose() {
    bNameCtrl.dispose();
    bTypeCtrl.dispose();
    bCategoryCtrl.dispose();
    bDescCtrl.dispose();
    phoneCtrl.dispose();
    emailCtrl.dispose();
    websiteCtrl.dispose();
    super.onClose();
  }
}
