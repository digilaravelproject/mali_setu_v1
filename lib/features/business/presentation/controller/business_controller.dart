import 'dart:async';
import 'package:edu_cluezer/widgets/custom_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dio/dio.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

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


class BusinessController extends GetxController {
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
  
  var isLoading = false.obs;
  var isDetailsLoading = false.obs;
  var applicationLoadingStates = <int, String?>{}.obs;

  // Search logic
  var searchText = "".obs;
  Timer? _searchDebounce;
  
  // Getter for filtered businesses - now returns all loaded businesses
  // Backend handles the filtering
  List<Business> get filteredBusinesses => businesses;
  
  // Search with debounce
  void onSearchChanged(String value) {
    searchText.value = value;
    
    // Cancel previous timer
    _searchDebounce?.cancel();
    
    // Start new timer - wait 500ms after user stops typing
    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      fetchAllBusinesses(isRefresh: true);
    });
  }

  @override
  void onInit() {
    super.onInit();
    fetchData();
  }
  
  @override
  void onClose() {
    _searchDebounce?.cancel();
    super.onClose();
  }

  Future<void> fetchData() async {
    try {
      isLoading.value = true;
      await Future.wait([
        fetchAllBusinesses(isRefresh: true),
        fetchMyBusinesses(),
      ]);
    } catch (e) {
      CustomSnackBar.showError(message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchAllBusinesses({bool isRefresh = false}) async {
    try {
      if (isRefresh) {
        currentPage.value = 1;
        businesses.clear();
      }
      
      // Pass search text to API
      final searchQuery = searchText.value.trim().isEmpty ? null : searchText.value.trim();
      final response = await getAllBusinessesUseCase(page: currentPage.value, search: searchQuery);

      if (isRefresh) {
        businesses.value = response.businesses;
      } else {
        businesses.addAll(response.businesses);
      }
      
      // Update pagination info
      currentPage.value = response.currentPage;
      totalPages.value = response.lastPage;
      hasNextPage.value = response.hasNextPage;
      
      print("DEBUG_PAGINATION: Current page: ${currentPage.value}, Total pages: ${totalPages.value}, Has next: ${hasNextPage.value}");
      print("DEBUG_PAGINATION: Loaded ${response.businesses.length} businesses, Total in list: ${businesses.length}");
      
    } catch (e) {
      print('Error fetching all businesses: $e');
    }
  }

  Future<void> loadMoreBusinesses() async {
    if (isLoadingMore.value || !hasNextPage.value) return;
    
    try {
      isLoadingMore.value = true;
      currentPage.value++;
      
      print("DEBUG_PAGINATION: Loading page ${currentPage.value}");
      
      // Pass search text to API
      final searchQuery = searchText.value.trim().isEmpty ? null : searchText.value.trim();
      final response = await getAllBusinessesUseCase(page: currentPage.value, search: searchQuery);
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

  Future<void> fetchBusinessDetails(int id) async {
    try {
      isDetailsLoading.value = true;
      selectedBusiness.value = null;
      businessProducts.clear();
      businessServices.clear();
      businessJobs.clear();

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

  Future<void> fetchJobAnalytics() async {
    try {
      isLoading.value = true;
      final response = await getJobAnalyticsUseCase();
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
      CustomSnackBar.showError(message: e.toString());
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

  Future<void> launchResume(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
       CustomSnackBar.showError(message: "Could not launch resume");
    }
  }

  Future<void> downloadResume(String url, String fileName) async {
    try {
      // Basic permission check - for Android 10+ scoped storage/mediastore is different, 
      // but for simple downloads folder standard dio write is often used with permission.
      // Or use path_provider to get app docs dir.
      // Since user wants "download", they likely expect it in Downloads folder.
      
      // Checking permission
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        status = await Permission.storage.request();
      }

      // If denied, we might still be able to write to app specific dirs, but for public download:
      if (status.isDenied) {
        // Try anyway or show error? On newer Android, explicit storage perm might not be needed for some paths.
        // Proceeding with attempt or showing error.
        // CustomSnackBar.showError(message: "Storage permission denied");
        // return;
      }

      Directory? downloadsDir;
      if (Platform.isAndroid) {
        downloadsDir = Directory('/storage/emulated/0/Download');
      } else if (Platform.isIOS) {
        downloadsDir = await getApplicationDocumentsDirectory(); // iOS doesn't have public downloads easily accessible
      } else {
        downloadsDir = await getDownloadsDirectory();
      }

      if (downloadsDir == null) {
         CustomSnackBar.showError(message: "Could not find downloads directory");
         return;
      }

      String savePath = "${downloadsDir.path}/$fileName";
      
      // Ensure unique name
      int count = 1;
      while (File(savePath).existsSync()) {
        final nameWithoutExt = fileName.split('.').first;
        final ext = fileName.split('.').last;
        savePath = "${downloadsDir.path}/${nameWithoutExt}_$count.$ext";
        count++;
      }

      CustomSnackBar.showInfo(message: "Downloading...");
      
      await Dio().download(url, savePath);
      
      CustomSnackBar.showSuccess(message: "Downloaded to $savePath");
      
    } catch (e) {
      CustomSnackBar.showError(message: "Download failed: $e");
    }
  }
}

