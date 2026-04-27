import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:edu_cluezer/widgets/custom_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dio/dio.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:edu_cluezer/core/helper/local_notification_helper.dart';
import 'package:open_filex/open_filex.dart';
import 'package:edu_cluezer/core/helper/location_helper.dart';

import 'package:edu_cluezer/features/Auth/service/auth_service.dart';
import 'package:edu_cluezer/features/business/data/model/res_all_business_model.dart';
import 'package:edu_cluezer/features/business/domain/usecase/add_business_service_usecase.dart';
import 'package:edu_cluezer/features/business/domain/usecase/all_business_usecase.dart';
import 'package:edu_cluezer/features/business/domain/usecase/get_business_details_usecase.dart';
import 'package:edu_cluezer/features/business/domain/usecase/get_business_products_usecase.dart';
import 'package:edu_cluezer/features/business/domain/usecase/get_business_services_usecase.dart';
import 'dart:io';
import 'package:edu_cluezer/features/business/domain/usecase/get_my_businesses_usecase.dart';
import 'package:edu_cluezer/features/business/domain/usecase/add_business_product_usecase.dart';
import 'package:edu_cluezer/features/business/domain/usecase/update_business_usecase.dart';
import 'package:edu_cluezer/features/business/domain/usecase/delete_business_usecase.dart';
import 'package:edu_cluezer/features/business/domain/usecase/get_job_details_usecase.dart';
import 'package:edu_cluezer/features/business/domain/usecase/update_job_usecase.dart';
import 'package:edu_cluezer/features/business/domain/usecase/delete_job_usecase.dart';
import 'package:edu_cluezer/features/business/domain/usecase/get_my_jobs_usecase.dart';
import 'package:edu_cluezer/features/business/domain/usecase/toggle_job_status_usecase.dart';
import 'package:edu_cluezer/features/business/domain/usecase/get_job_analytics_usecase.dart';
import 'package:edu_cluezer/features/business/domain/usecase/apply_job_usecase.dart';
import 'package:edu_cluezer/features/business/domain/usecase/get_my_applications_usecase.dart';
import 'package:edu_cluezer/features/business/domain/usecase/get_job_applications_usecase.dart';
import 'package:edu_cluezer/features/business/domain/usecase/update_application_status_usecase.dart';
import 'package:edu_cluezer/features/business/domain/usecase/search_business_usecase.dart';
import 'package:edu_cluezer/features/business/presentation/controller/reg_business_controller.dart';

import '../../../../core/routes/app_routes.dart';



class BusinessController extends GetxController with WidgetsBindingObserver {
  final GetAllBusinessesUseCase getAllBusinessesUseCase;
  final GetMyBusinessesUseCase getMyBusinessesUseCase;
  final GetBusinessDetailsUseCase getBusinessDetailsUseCase;
  final GetBusinessProductsUseCase getBusinessProductsUseCase;
  final GetBusinessServicesUseCase getBusinessServicesUseCase;
  final AddBusinessProductUseCase addBusinessProductUseCase;
  final AddBusinessServiceUseCase addBusinessServiceUseCase;
  final UpdateBusinessUseCase updateBusinessUseCase;
  final DeleteBusinessUseCase deleteBusinessUseCase;
  final GetMyJobsUseCase getMyJobsUseCase;
  final GetJobDetailsUseCase getJobDetailsUseCase;
  final UpdateJobUseCase updateJobUseCase;
  final DeleteJobUseCase deleteJobUseCase;
  final ToggleJobStatusUseCase toggleJobStatusUseCase;
  final GetJobAnalyticsUseCase getJobAnalyticsUseCase;
  final ApplyJobUseCase applyJobUseCase;
  final GetMyApplicationsUseCase getMyApplicationsUseCase;
  final GetJobApplicationsUseCase getJobApplicationsUseCase;
  final UpdateApplicationStatusUseCase updateApplicationStatusUseCase;
  final SearchBusinessUseCase searchBusinessUseCase;
  final AuthService _authService = Get.find<AuthService>();

  BusinessController({
    required this.getAllBusinessesUseCase,
    required this.getMyBusinessesUseCase,
    required this.getBusinessDetailsUseCase,
    required this.getBusinessProductsUseCase,
    required this.getBusinessServicesUseCase,
    required this.addBusinessProductUseCase,
    required this.addBusinessServiceUseCase,
    required this.updateBusinessUseCase,
    required this.deleteBusinessUseCase,
    required this.getMyJobsUseCase,
    required this.getJobDetailsUseCase,
    required this.updateJobUseCase,
    required this.deleteJobUseCase,
    required this.toggleJobStatusUseCase,
    required this.getJobAnalyticsUseCase,
    required this.applyJobUseCase,
    required this.getMyApplicationsUseCase,
    required this.getJobApplicationsUseCase,
    required this.updateApplicationStatusUseCase,
    required this.searchBusinessUseCase,
  });

  var businesses = <Business>[].obs;
  var myBusinesses = <Business>[].obs;
  var myBusiness = Rxn<Business>();
  
  // Pagination variables
  var currentPage = 1.obs;
  var totalPages = 1.obs;
  var hasNextPage = false.obs;
  var isLoadingMore = false.obs;
  
  // For Business Detail Screen
  var selectedBusiness = Rxn<Business>();
  var businessProducts = <Product>[].obs;
  var businessServices = <Service>[].obs;
  var businessJobs = <Job>[].obs;
  var selectedJobDetail = Rxn<JobDetailData>();
  var jobAnalytics = Rxn<JobAnalyticsData>();
  var myApplications = <JobApplication>[].obs;
  var selectedJobApplications = <JobApplication>[].obs;
  
  final SpeechToText _speechToText = SpeechToText();
  var isListening = false.obs;
  
  var isSearching = false.obs;
  var isLoading = false.obs;
  var isDetailsLoading = false.obs;
  var voiceSearchError = "".obs;
  var applicationLoadingStates = <int, String?>{}.obs;

  // Search logic
  var searchText = "".obs;
  final searchController = TextEditingController();
  Timer? _searchDebounce;

  // Filter logic
  var isFilterVisible = false.obs;
  final filterCityCtrl = TextEditingController();
  final filterStateCtrl = TextEditingController();
  final filterTalukaCtrl = TextEditingController();
  final filterDistrictCtrl = TextEditingController();
  
  // Getter for filtered businesses - now returns all loaded businesses
  // Backend handles the filtering
  List<Business> get filteredBusinesses => businesses;
  
  // Search with debounce
  void onSearchChanged(String query) {
    // Check registration first, then payment
    // if (!_authService.hasBusiness()) {
    //   _showBusinessRegisterDialog();
    //   return;
    // }
    // if (!_authService.hasPaymentForBusiness()) {
    //   _showBusinessPaymentDialog();
    //   return;
    // }
    searchText.value = query;
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      fetchAllBusinesses(isRefresh: true);
    });
  }

  void onSearchCleared() {
    searchText.value = "";
    searchController.clear();
    fetchAllBusinesses(isRefresh: true);
  }

  void startListening() async {
    // if (!_authService.hasBusiness()) {
    //   _showBusinessRegisterDialog();
    //   return;
    // }
    // if (!_authService.hasPaymentForBusiness()) {
    //   _showBusinessPaymentDialog();
    //   return;
    // }

    voiceSearchError.value = "";
    _showVoiceSearchBottomSheet();

    bool available = await _speechToText.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          isListening.value = false;
          // Fallback: If engine stopped but sheet is still open and we have words, search and close
          if (searchText.value.isNotEmpty && (Get.isBottomSheetOpen ?? false)) {
             Get.back();
             fetchAllBusinesses(isRefresh: true);
          }
        }
      },
      onError: (errorNotification) {
        isListening.value = false;
        if (errorNotification.errorMsg == "error_no_match") {
          voiceSearchError.value = "We didn't catch that. Please try again.";
        } else {
          voiceSearchError.value = errorNotification.errorMsg;
        }
      },
    );

    if (available) {
      isListening.value = true;
      voiceSearchError.value = "";
      _speechToText.listen(
        onResult: (result) {
          searchController.text = result.recognizedWords;
          searchText.value = result.recognizedWords;
          
          if (result.finalResult) {
            isListening.value = false;
            // Only close bottom sheet if it's actually open
            if (Get.isBottomSheetOpen ?? false) {
               Get.back();
            }
            fetchAllBusinesses(isRefresh: true);
          }
        },
      );
    } else {
      voiceSearchError.value = "Speech recognition is not available";
    }
  }

  void stopListening() async {
    await _speechToText.stop();
    isListening.value = false;
    // Don't call Get.back() here - let the bottom sheet's .then() handle it
  }

  void _showVoiceSearchBottomSheet() {
    Get.bottomSheet(
      Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(35),
            topRight: Radius.circular(35),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 20,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 50,
              height: 5,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            
            Obx(() => Text(
              isListening.value ? "listening".tr : (voiceSearchError.isNotEmpty ? "something_went_wrong".tr : "Thinking..."),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Colors.black,
                letterSpacing: -0.5,
              ),
            )),
            const SizedBox(height: 12),
            Obx(() => Text(
              voiceSearchError.isNotEmpty 
                  ? voiceSearchError.value 
                  : "speak_to_search_business".tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: voiceSearchError.isNotEmpty ? Colors.red[400] : Colors.grey[600],
                height: 1.4,
              ),
            )),
            
            const SizedBox(height: 48),
            
            // Pulsing Mic Animation
            Obx(() => Stack(
              alignment: Alignment.center,
              children: [
                if (isListening.value)
                  ...List.generate(3, (index) => TweenAnimationBuilder<double>(
                    duration: Duration(milliseconds: 1000 + (index * 500)),
                    tween: Tween(begin: 1.0, end: 1.8),
                    curve: Curves.easeOutQuart,
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Get.theme.primaryColor.withOpacity(0.25 * (2.0 - value)),
                              width: 2,
                            ),
                          ),
                        ),
                      );
                    },
                  )),
                GestureDetector(
                  onTap: () {
                    if (!isListening.value) startListening();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: isListening.value ? Get.theme.primaryColor : (voiceSearchError.isNotEmpty ? Colors.red[50] : Colors.grey[50]),
                      shape: BoxShape.circle,
                      boxShadow: [
                        if (isListening.value)
                          BoxShadow(
                            color: Get.theme.primaryColor.withOpacity(0.3),
                            blurRadius: 15,
                            spreadRadius: 2,
                          ),
                      ],
                    ),
                    child: Icon(
                      isListening.value ? Icons.mic : (voiceSearchError.isNotEmpty ? Icons.replay_rounded : Icons.mic_none),
                      size: 42,
                      color: isListening.value ? Colors.white : (voiceSearchError.isNotEmpty ? Colors.red : Colors.grey[400]),
                    ),
                  ),
                ),
              ],
            )),
            
            const SizedBox(height: 48),
            
            // Recognized Text or Error Action
            Obx(() {
              if (voiceSearchError.isNotEmpty) {
                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => startListening(),
                    icon: const Icon(Icons.refresh_rounded, size: 20),
                    label:  Text("try_again".tr, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Get.theme.primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                );
              }
              
              if (!isListening.value && searchText.value.isNotEmpty) {
                 return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Only close bottom sheet, don't use Navigator.pop
                      if (Get.isBottomSheetOpen ?? false) {
                         Get.back();
                      }
                      fetchAllBusinesses(isRefresh: true);
                    },
                    icon: const Icon(Icons.search_rounded, size: 20),
                    label:  Text("search_here".tr, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                );
              }

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey[100]!),
                ),
                child: Text(
                  searchText.value.isEmpty ? "..." : searchText.value,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              );
            }),
            
            const SizedBox(height: 32),
            
            // Cancel Button
            TextButton(
              onPressed: () {
                _speechToText.stop();
                isListening.value = false;
                if (Get.isBottomSheetOpen ?? false) {
                  Get.back();
                }
              },
              child: Text(
                "cancel".tr,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[400],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
      isDismissible: true,
      enableDrag: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    ).then((_) {
      // Just stop the speech recognition if still listening
      // Don't call stopListening() as it might trigger another Get.back()
      if (isListening.value) {
        _speechToText.stop();
        isListening.value = false;
      }
    });
  }

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    
    print("DEBUG_BUSINESS: onInit() called");
    
    // Load cached data immediately for instant display
    _loadCachedBusinesses();
    
    // Then fetch fresh data without delay
    fetchData();
  }

  // Cache key constants
  static const String _businessesCacheKey = 'cached_businesses';
  static const String _businessesCacheTimeKey = 'cached_businesses_time';
  static const Duration _cacheValidDuration = Duration(hours: 12);

  /// Load businesses from cache
  Future<void> _loadCachedBusinesses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedJson = prefs.getString(_businessesCacheKey);
      final cachedTime = prefs.getInt(_businessesCacheTimeKey);
      
      if (cachedJson != null && cachedTime != null) {
        final cacheAge = DateTime.now().millisecondsSinceEpoch - cachedTime;
        
        // Load cache regardless of age (fresh data will replace it)
        final List<dynamic> jsonList = json.decode(cachedJson);
        final cachedBusinesses = jsonList.map((json) => Business.fromJson(json)).toList();
        
        if (cachedBusinesses.isNotEmpty) {
          businesses.assignAll(cachedBusinesses);
          print("DEBUG_BUSINESSES: Loaded ${cachedBusinesses.length} businesses from cache (age: ${Duration(milliseconds: cacheAge).inHours}h)");
        }
      }
    } catch (e) {
      print("DEBUG_BUSINESSES: Error loading cache: $e");
    }
  }

  /// Save businesses to cache
  Future<void> _saveBusinessesCache(List<Business> businessesToCache) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = businessesToCache.map((biz) => biz.toJson()).toList();
      await prefs.setString(_businessesCacheKey, json.encode(jsonList));
      await prefs.setInt(_businessesCacheTimeKey, DateTime.now().millisecondsSinceEpoch);
      print("DEBUG_BUSINESSES: Saved ${businessesToCache.length} businesses to cache");
    } catch (e) {
      print("DEBUG_BUSINESSES: Error saving cache: $e");
    }
  }
  
  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchDebounce?.cancel();
    searchController.dispose();
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // If we resumed and have no businesses, try fetching again 
      // (in case location was just turned on or previous fetch failed)
      if (businesses.isEmpty && !isLoading.value && searchText.isEmpty) {
        debugPrint("📍 [BusinessController] App resumed with empty list, auto-refreshing...");
        fetchData();
      }
    }
  }

  Future<void> fetchData() async {
    print("DEBUG_BUSINESS: fetchData() called");
    
    // Load cache first for instant display
    await _loadCachedBusinesses();
    
    // Then fetch fresh data
    try {
      await Future.wait([
        fetchAllBusinesses(isRefresh: true),
        fetchMyBusinesses(),
      ], eagerError: false); // Continue even if one fails
      
      print("DEBUG_BUSINESS: fetchData() completed successfully");
    } catch (e) {
      print("ERROR_BUSINESS: fetchData() failed: $e");
      // Don't show error if we have cached data
      if (businesses.isEmpty && myBusiness.value == null) {
        CustomSnackBar.showError(message: "Failed to load data. Please refresh.");
      }
    }
  }


  Future<void> fetchAllBusinesses({bool isRefresh = false}) async {
    final searchQuery = searchText.value.trim();
    
    // Don't show loading if we already have businesses and not refreshing
    final bool showLoading = businesses.isEmpty || isRefresh;
    
    if (searchQuery.isNotEmpty) {
      isSearching.value = true;
    } else if (showLoading) {
      isLoading.value = true;
    }
    
    try {
      if (isRefresh && searchQuery.isEmpty) {
        currentPage.value = 1;
      }

      final location = await LocationHelper.getCurrentLocation();
      
      final response = await getAllBusinessesUseCase(
        page: currentPage.value,
        search: searchQuery.isNotEmpty ? searchQuery : null,
        lat: location?['latitude'],
        long: location?['longitude'],
      );

      if (isRefresh || searchQuery.isNotEmpty) {
        businesses.value = response.businesses;
        // Save to cache only for non-search results
        if (searchQuery.isEmpty && response.businesses.isNotEmpty) {
          await _saveBusinessesCache(response.businesses);
        }
      } else {
        businesses.addAll(response.businesses);
      }

      // Update pagination info
      currentPage.value = response.currentPage;
      totalPages.value = response.lastPage;
      hasNextPage.value = response.hasNextPage;
      
      print("DEBUG_BUSINESSES: Loaded ${response.businesses.length} businesses, Total: ${businesses.length}");
      print("DEBUG_PAGINATION: Page ${currentPage.value}/${totalPages.value}, Has next: ${hasNextPage.value}");
      
    } catch (e) {
      print('ERROR_BUSINESSES: $e');
      // Don't clear existing businesses on error
      if (businesses.isEmpty) {
        CustomSnackBar.showError(message: "Failed to load businesses");
      } else {
        print("DEBUG_BUSINESSES: Keeping existing ${businesses.length} businesses after error");
      }
    } finally {
      isLoading.value = false;
      isSearching.value = false;
    }
  }

  Future<void> searchBusinessWithFilters() async {
    try {
      isSearching.value = true;
      isLoading.value = true;
      
      // Combine filters into a single search query or handle specifically if API supports it
      // Users requested: "city state taluka distrcit kisi bhi chij ko enter karke search pe click kre"
      // Since API is {"search": "Latur"}, I will use the first non-empty filter or combine them
      
      List<String> activeFilters = [];
      if (filterCityCtrl.text.trim().isNotEmpty) activeFilters.add(filterCityCtrl.text.trim());
      if (filterStateCtrl.text.trim().isNotEmpty) activeFilters.add(filterStateCtrl.text.trim());
      if (filterTalukaCtrl.text.trim().isNotEmpty) activeFilters.add(filterTalukaCtrl.text.trim());
      if (filterDistrictCtrl.text.trim().isNotEmpty) activeFilters.add(filterDistrictCtrl.text.trim());
      
      if (activeFilters.isEmpty) {
        await fetchAllBusinesses(isRefresh: true);
        return;
      }
      
      final query = activeFilters.join(" ");
      final location = await LocationHelper.getCurrentLocation();
      final response = await searchBusinessUseCase(
        query,
        lat: location?['latitude'],
        long: location?['longitude'],
      );
      
      businesses.value = response.businesses;
      currentPage.value = response.currentPage;
      totalPages.value = response.lastPage;
      hasNextPage.value = response.hasNextPage;
      
      isFilterVisible.value = false; // Hide filter after search
      
    } catch (e) {
      print('Error searching businesses with filters: $e');
      CustomSnackBar.showError(message: "Search failed: ${e.toString()}");
    } finally {
      isLoading.value = false;
      isSearching.value = false;
    }
  }

  void clearFilters() {
    filterCityCtrl.clear();
    filterStateCtrl.clear();
    filterTalukaCtrl.clear();
    filterDistrictCtrl.clear();
    fetchAllBusinesses(isRefresh: true);
  }

  Future<void> loadMoreBusinesses() async {
    if (isLoadingMore.value || !hasNextPage.value) return;
    
    try {
      isLoadingMore.value = true;
      currentPage.value++;
      
      print("DEBUG_PAGINATION: Loading page ${currentPage.value}");
      
      final searchQuery = searchText.value.trim();
      final location = await LocationHelper.getCurrentLocation();
      BusinessPaginationResult response;

      if (searchQuery.isNotEmpty) {
        response = await searchBusinessUseCase(
          searchQuery,
          lat: location?['latitude'],
          long: location?['longitude'],
        );
      } else {
        response = await getAllBusinessesUseCase(
          page: currentPage.value,
          lat: location?['latitude'],
          long: location?['longitude'],
        );
      }

      businesses.addAll(response.businesses);
      
      // Update pagination info
      totalPages.value = response.lastPage;
      hasNextPage.value = response.hasNextPage;
      
      print("DEBUG_PAGINATION: Loaded ${response.businesses.length} more businesses, Total: ${businesses.length}");
      
    } catch (e) {
      print('Error loading more businesses: $e');
      currentPage.value--; // Revert page number on error
    } finally {
      isLoadingMore.value = false;
    }
  }

  Future<void> fetchMyBusinesses() async {
    try {
      final list = await getMyBusinessesUseCase();
      myBusinesses.value = list;

      if (list.isNotEmpty) {
        // As per user request: "Business Dashboard ye list ka last data show kro"
        myBusiness.value = list.last;
      } else {
        myBusiness.value = null;
      }
    } catch (e) {
      print('Error fetching my businesses: $e');
      myBusiness.value = null;
    }
  }

  Future<void> fetchBusinessDetails(int id, {bool isRefresh = false}) async {
    try {
      if (!isRefresh) {
        isDetailsLoading.value = true;
        selectedBusiness.value = null;
        businessProducts.clear();
        businessServices.clear();
        businessJobs.clear();
      }

      final business = await getBusinessDetailsUseCase(id);
      selectedBusiness.value = business;
      
      // Fetch related data in parallel if business exists
      if (business != null) {
          await Future.wait([
             fetchBusinessProducts(id),
             fetchBusinessServices(id),
             fetchBusinessJobs(id),
          ]);
      }

    } catch (e) {
      print('Error fetching business details: $e');
    } finally {
      isDetailsLoading.value = false;
    }
  }

  Future<void> fetchBusinessProducts(int businessId) async {
      try {
          final products = await getBusinessProductsUseCase(businessId);
          businessProducts.value = products;
      } catch(e) {
          print('Error fetching products: $e');
      }
  }

  Future<void> fetchBusinessServices(int businessId) async {
      try {
          final services = await getBusinessServicesUseCase(businessId);
          businessServices.value = services;
      } catch(e) {
          print('Error fetching services: $e');
      }
  }

  Future<void> fetchBusinessJobs(int businessId) async {
      try {
          final jobs = await getMyJobsUseCase(businessId);
          businessJobs.value = jobs;
      } catch(e) {
          print('Error fetching jobs: $e');
      }
  }

  Future<bool> addProduct(Map<String, dynamic> data, List<File> images) async {
    try {
      isLoading.value = true;
      await addBusinessProductUseCase(data, images);
      
      // Refresh products if adding for current business
      if (selectedBusiness.value != null && data['business_id'].toString() == selectedBusiness.value!.id.toString()) {
         await fetchBusinessProducts(int.parse(data['business_id'].toString()));
      }
      return true;
    } catch (e) {
      CustomSnackBar.showError(message: e.toString());
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> addService(Map<String, dynamic> data, List<File> images) async {
    try {
      isLoading.value = true;
      await addBusinessServiceUseCase(data, images);
      
      // Refresh services if adding for current business
      if (selectedBusiness.value != null && data['business_id'].toString() == selectedBusiness.value!.id.toString()) {
         await fetchBusinessServices(int.parse(data['business_id'].toString()));
      }
      return true;
    } catch (e) {
      CustomSnackBar.showError(message: e.toString());
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateBusiness(int id, Map<String, dynamic> data) async {
    try {
      isLoading.value = true;
      await updateBusinessUseCase(id, data);
      await fetchMyBusinesses(); // Refresh list
      return true;
    } catch (e) {
      CustomSnackBar.showError(message: e.toString());
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteBusiness(int id) async {
    try {
      Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
      await deleteBusinessUseCase(id);
      await fetchMyBusinesses(); // Refresh list
      Get.back(); // Close dialog
      CustomSnackBar.showSuccess(message: "Business deleted successfully");
    } catch (e) {
      Get.back(); // Close dialog
      CustomSnackBar.showError(message: e.toString());
    }
  }

  Future<void> fetchJobDetails(int jobId) async {
    try {
      isLoading.value = true;
      final detail = await getJobDetailsUseCase(jobId);
      selectedJobDetail.value = detail;
    } catch (e) {
      print('Error fetching job details: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteJob(int jobId) async {
    try {
      Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
      final response = await deleteJobUseCase(jobId);
      Get.back(); // Close dialog
      
      if (response.success == true) {
        Get.back(); // Back from details screen
        CustomSnackBar.showSuccess(message: response.message ?? "Job deleted successfully");
        
        // Refresh business jobs if we have a selected business
        if (selectedBusiness.value != null) {
          fetchBusinessJobs(selectedBusiness.value!.id!);
        }
      } else {
        CustomSnackBar.showError(message: response.message ?? "Failed to delete job");
      }
    } catch (e) {
      Get.back(); // Close dialog
      CustomSnackBar.showError(message: e.toString());
    }
  }

  Future<void> toggleJobStatus(int jobId) async {
    try {
      Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
      final response = await toggleJobStatusUseCase(jobId);
      Get.back(); // Close dialog
      
      if (response.success == true) {
        CustomSnackBar.showSuccess(message: response.message ?? "Job status updated successfully");
        // Refresh job details
        fetchJobDetails(jobId);
        // Refresh business jobs if we have a selected business
        if (selectedBusiness.value != null) {
          fetchBusinessJobs(selectedBusiness.value!.id!);
        }
      } else {
        CustomSnackBar.showError(message: response.message ?? "Failed to update job status");
      }
    } catch (e) {
      Get.back(); // Close dialog
      CustomSnackBar.showError(message: e.toString());
    }
  }

  Future<void> fetchJobAnalytics(int businessId) async {
    try {
      isLoading.value = true;
      final response = await getJobAnalyticsUseCase(businessId);
      if (response.success == true) {
        jobAnalytics.value = response.data;
      } else {
        CustomSnackBar.showError(message: response.message ?? "Failed to fetch analytics");
      }
    } catch (e) {
      CustomSnackBar.showError(message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> applyJob(Map<String, dynamic> data) async {
    try {
      isLoading.value = true;
      final response = await applyJobUseCase(data);
      
      if (Get.isBottomSheetOpen == true) {
        Get.back();
      }

      if (response.success == true) {
        CustomSnackBar.showSuccess(message: response.message ?? "Applied successfully");
        // Refresh job details to update hasApplied status
        if (data['job_posting_id'] != null) {
          fetchJobDetails(int.parse(data['job_posting_id'].toString()));
        }
        return true;
      } else {
        // Handle "already applied" case specifically
        if (response.message != null && response.message!.toLowerCase().contains("already applied")) {
           CustomSnackBar.showInfo(message: "You have already applied for this job");
           if (data['job_posting_id'] != null) {
             fetchJobDetails(int.parse(data['job_posting_id'].toString()));
           }
           return true; // Return true to close the form
        }
        
        // Handle validation errors specifically
        String errorMessage = response.message ?? "Failed to apply";
        if (response.errors != null && response.errors!.isNotEmpty) {
          // Extract the first error message from the errors map
          // e.g., {resume: [The resume failed to upload.]}
          var firstError = response.errors!.values.first;
          if (firstError is List && firstError.isNotEmpty) {
            errorMessage = firstError.first.toString();
          } else {
            errorMessage = firstError.toString();
          }
        }
        
        CustomSnackBar.showError(message: errorMessage);
        return false;
      }
    } catch (e) {
      if (Get.isBottomSheetOpen == true) {
        Get.back();
      }
      
      String errorMessage = "Failed to apply";
      if (e is DioException && e.response?.data != null) {
        final errorData = e.response!.data;
        if (errorData is Map) {
          errorMessage = errorData['message'] ?? errorMessage;
        } else {
          errorMessage = e.response!.data.toString();
        }
      } else {
        errorMessage = e.toString();
      }
      CustomSnackBar.showError(message: errorMessage);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchMyApplications() async {
    try {
      isLoading.value = true;
      final response = await getMyApplicationsUseCase();
      if (response.success == true && response.data != null) {
        myApplications.value = response.data!.data ?? [];
      } else {
        // Handle failure if needed
      }
    } catch (e) {
      print('Error fetching applications: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchJobApplications(int jobId) async {
    try {
      isLoading.value = true;
      selectedJobApplications.clear();
      final response = await getJobApplicationsUseCase(jobId);
      if (response.success == true && response.data != null && response.data!.applications != null) {
        selectedJobApplications.value = response.data!.applications!.data ?? [];
      } else {
        CustomSnackBar.showError(message: response.message ?? "Failed to fetch applications");
      }
    } catch (e) {
      print('Error fetching job applications: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateApplicationStatus(int applicationId, String status, int jobId, {String? notes}) async {
    try {
      applicationLoadingStates[applicationId] = status;
      final response = await updateApplicationStatusUseCase(applicationId, status, notes: notes);
      if (response.success == true) {
        CustomSnackBar.showSuccess(message: response.message ?? "Status updated to $status");
        fetchJobApplications(jobId); // Refresh list
      } else {
        CustomSnackBar.showError(message: response.message ?? "Failed to update status");
      }
    } catch (e) {
       CustomSnackBar.showError(message: e.toString());
    } finally {
      applicationLoadingStates[applicationId] = null;
    }
  }

  Future<void> launchPhone(String phone) async {
    final Uri uri = Uri(scheme: 'tel', path: phone);
    if (!await launchUrl(uri)) {
      throw 'Could not launch phone';
    }
  }

  Future<void> launchEmail(String email) async {
    final Uri uri = Uri(
      scheme: 'mailto',
      path: email,
    );

    if (!await launchUrl(uri)) {
      throw 'Could not launch email';
    }
  }

  // Controller me function
  Future<void> launchWhatsApp(String phone) async {
    final Uri uri = Uri.parse("https://wa.me/$phone");
    if (!await launchUrl(uri)) {
      throw 'Could not launch WhatsApp';
    }
  }

  Future<void> launchResume(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
       CustomSnackBar.showError(message: "Could not launch resume");
    }
  }

  Future<void> downloadResume(String url, String fileName) async {
    try {
      // Permission check
      if (Platform.isAndroid) {
        final status = await Permission.storage.request();
        if (status.isPermanentlyDenied) {
          CustomSnackBar.showError(message: "Storage permission denied. Enable from settings.");
          return;
        }
        
        // Request notification permission for Android 13+
        if (await Permission.notification.isDenied) {
          await Permission.notification.request();
        }
      }

      Directory? downloadsDir;
      if (Platform.isAndroid) {
        downloadsDir = Directory('/storage/emulated/0/Download');
      } else if (Platform.isIOS) {
        downloadsDir = await getApplicationDocumentsDirectory();
      } else {
        downloadsDir = await getDownloadsDirectory();
      }

      if (downloadsDir == null) {
        CustomSnackBar.showError(message: "Could not find downloads directory");
        return;
      }

      // Ensure unique filename
      String savePath = "${downloadsDir.path}/$fileName";
      int count = 1;
      while (File(savePath).existsSync()) {
        final parts = fileName.split('.');
        final ext = parts.last;
        final nameWithoutExt = parts.sublist(0, parts.length - 1).join('.');
        savePath = "${downloadsDir.path}/${nameWithoutExt}_$count.$ext";
        count++;
      }

      // Show downloading snackbar
      Get.snackbar(
        'downloading'.tr,
        fileName,
        icon: const Icon(Icons.download_rounded, color: Colors.white),
        backgroundColor: Colors.blueGrey[700],
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        snackPosition: SnackPosition.BOTTOM,
      );

      int notificationId = fileName.hashCode;
      await Dio().download(
        url, 
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            int progress = ((received / total) * 100).toInt();
            LocalNotificationHelper.showDownloadNotification(
              id: notificationId,
              title: "Downloading $fileName",
              body: "$progress%",
              progress: progress,
            );
          }
        },
      );

      // Show success notification
      await LocalNotificationHelper.showDownloadCompleteNotification(
        id: notificationId,
        title: "Download Complete",
        body: fileName,
        filePath: savePath,
      );

      // Show success snackbar with "Open" action
      Get.snackbar(
        'download_complete'.tr,
        fileName,
        icon: const Icon(Icons.check_circle_rounded, color: Colors.white),
        backgroundColor: Colors.green[700],
        colorText: Colors.white,
        duration: const Duration(seconds: 6),
        snackPosition: SnackPosition.BOTTOM,
        mainButton: TextButton(
          onPressed: () async {
            Get.back(); // close snackbar
            try {
              await OpenFilex.open(savePath);
            } catch (e) {
              launchUrl(Uri.parse('file://$savePath'), mode: LaunchMode.externalApplication);
            }
          },
          child: Text('open'.tr, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      );
    } catch (e) {
      CustomSnackBar.showError(message: "Download failed: $e");
    }
  }


  void _showBusinessRegisterDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Get.theme.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.store_outlined, size: 48, color: Get.theme.primaryColor),
              ),
              const SizedBox(height: 20),
              Text('register_your_business'.tr, style: Get.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800), textAlign: TextAlign.center),
              const SizedBox(height: 10),
              Text('register_business_to_search'.tr, style: Get.textTheme.bodyMedium?.copyWith(color: Colors.grey[600]), textAlign: TextAlign.center),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Get.back(),
                      style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      child: Text('cancel'.tr, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        Get.toNamed(AppRoutes.regBusiness);
                      },
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
                      child: Text('register_now'.tr, style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBusinessPaymentDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Get.theme.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.lock_person_rounded, size: 48, color: Get.theme.primaryColor),
              ),
              const SizedBox(height: 20),
              Text('plan_required'.tr, style: Get.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800), textAlign: TextAlign.center),
              const SizedBox(height: 10),
              Text('purchase_business_plan_to_search'.tr, style: Get.textTheme.bodyMedium?.copyWith(color: Colors.grey[600]), textAlign: TextAlign.center),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Get.back(),
                      style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      child: Text('cancel'.tr, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Get.back();
                        if (Get.isRegistered<RegBusinessController>()) {
                          await Get.find<RegBusinessController>().fetchAndShowBusinessPlans();
                        }
                      },
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
                      child: Text('purchase_now'.tr, style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

