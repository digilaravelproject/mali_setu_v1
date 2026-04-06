import 'package:edu_cluezer/features/business/data/model/res_all_business_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import '../../data/model/res_category_business_model.dart' hide Category;
import '../../domain/usecase/category_business_usecase.dart';
import '../../../../core/helper/location_helper.dart';

class CatBusinessController extends GetxController {
  final GetBusinessByCategoryUseCase useCase;

  CatBusinessController({required this.useCase});

  var isLoading = false.obs;
  var errorMessage = ''.obs;

  // ✅ Store all businesses here
  var allBusinesses = <CatBusiness>[].obs;
  var filteredBusinesses = <CatBusiness>[].obs;
  var searchQuery = ''.obs;
  final searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    final dynamic args = Get.arguments;
    if (args != null && args is Category) {
      if (args.id != null) {
        fetchBusinesses(args.id!);
      }
    }
  }

  // Fetch and store data
  Future<void> fetchBusinesses(int categoryId) async {

    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final location = await LocationHelper.getCurrentLocation();
      if (location != null) {
        print("DEBUG_CAT_BIZ: Lat: ${location['latitude']}, Long: ${location['longitude']}");
      } else {
        print("DEBUG_CAT_BIZ: Location is null");
      }

      final res = await useCase(
        categoryId,
        lat: location?['latitude'],
        long: location?['longitude'],
      );

      if (res.success == true && res.businesses != null) {
        // Clear previous data
        allBusinesses.clear();
        filteredBusinesses.clear();
        // Add new data
        allBusinesses.addAll(res.businesses!);
        filteredBusinesses.addAll(res.businesses!);
      } else {
        errorMessage.value = res.message ?? 'Failed to fetch businesses';
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void searchBusinesses(String query) {
    searchQuery.value = query;
    
    if (query.isEmpty) {
      filteredBusinesses.assignAll(allBusinesses);
    } else {
      final filtered = allBusinesses.where((business) {
        final businessName = business.businessName?.toLowerCase() ?? '';
        final businessType = business.businessType?.toLowerCase() ?? '';
        final description = business.description?.toLowerCase() ?? '';
        final city = business.user?.city?.toLowerCase() ?? '';
        final address = business.user?.address?.toLowerCase() ?? '';
        final phone = business.contactPhone?.toLowerCase() ?? '';
        final email = business.contactEmail?.toLowerCase() ?? '';
        final website = business.website?.toLowerCase() ?? '';
        
        final searchTerm = query.toLowerCase();
        
        return businessName.contains(searchTerm) ||
               businessType.contains(searchTerm) ||
               description.contains(searchTerm) ||
               city.contains(searchTerm) ||
               address.contains(searchTerm) ||
               phone.contains(searchTerm) ||
               email.contains(searchTerm) ||
               website.contains(searchTerm);
      }).toList();
      
      filteredBusinesses.assignAll(filtered);
    }
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
    filteredBusinesses.assignAll(allBusinesses);
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
