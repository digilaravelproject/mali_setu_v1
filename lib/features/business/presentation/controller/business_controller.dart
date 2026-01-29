import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../Auth/service/auth_service.dart';
import '../../data/model/res_all_business_model.dart';
import '../../domain/usecase/add_business_service_usecase.dart';
import '../../domain/usecase/all_business_usecase.dart';
import '../../domain/usecase/get_business_details_usecase.dart';
import '../../domain/usecase/get_business_products_usecase.dart';
import '../../domain/usecase/get_business_services_usecase.dart';
import 'dart:io';
import '../../domain/usecase/get_my_businesses_usecase.dart';
import '../../domain/usecase/add_business_product_usecase.dart';
import '../../domain/usecase/update_business_usecase.dart';
import '../../domain/usecase/delete_business_usecase.dart';
import '../../domain/usecase/get_job_details_usecase.dart';
import '../../domain/usecase/update_job_usecase.dart';
import '../../domain/usecase/delete_job_usecase.dart';
import '../../domain/usecase/get_my_jobs_usecase.dart';
import '../../domain/usecase/toggle_job_status_usecase.dart';
import '../../domain/usecase/get_job_analytics_usecase.dart';
import '../../domain/usecase/apply_job_usecase.dart';
import '../../domain/usecase/get_my_applications_usecase.dart';
import '../../domain/usecase/get_job_applications_usecase.dart';
import '../../domain/usecase/update_application_status_usecase.dart';


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

  @override
  void onInit() {
    super.onInit();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      isLoading.value = true;
      await Future.wait([
        fetchAllBusinesses(),
        fetchMyBusinesses(),
      ]);
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchAllBusinesses() async {
    try {
      final list = await getAllBusinessesUseCase();
      businesses.value = list;
    } catch (e) {
      print('Error fetching all businesses: $e');
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
      Get.snackbar("Error", e.toString(), backgroundColor: Get.theme.colorScheme.error, colorText: Get.theme.colorScheme.onError);
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
      Get.snackbar("Error", e.toString(), backgroundColor: Get.theme.colorScheme.error, colorText: Get.theme.colorScheme.onError);
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
      Get.snackbar("Error", e.toString(), backgroundColor: Get.theme.colorScheme.error, colorText: Get.theme.colorScheme.onError);
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
      Get.snackbar("Success", "Business deleted successfully", backgroundColor: Get.theme.colorScheme.primary, colorText: Get.theme.colorScheme.onPrimary);
    } catch (e) {
      Get.back(); // Close dialog
      Get.snackbar("Error", e.toString(), backgroundColor: Get.theme.colorScheme.error, colorText: Get.theme.colorScheme.onError);
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
        Get.snackbar("Success", response.message ?? "Job deleted successfully");
        
        // Refresh business jobs if we have a selected business
        if (selectedBusiness.value != null) {
          fetchBusinessJobs(selectedBusiness.value!.id!);
        }
      } else {
        Get.snackbar("Error", response.message ?? "Failed to delete job");
      }
    } catch (e) {
      Get.back(); // Close dialog
      Get.snackbar("Error", e.toString());
    }
  }

  Future<void> toggleJobStatus(int jobId) async {
    try {
      Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
      final response = await toggleJobStatusUseCase(jobId);
      Get.back(); // Close dialog
      
      if (response.success == true) {
        Get.snackbar("Success", response.message ?? "Job status updated successfully");
        // Refresh job details
        fetchJobDetails(jobId);
        // Refresh business jobs if we have a selected business
        if (selectedBusiness.value != null) {
          fetchBusinessJobs(selectedBusiness.value!.id!);
        }
      } else {
        Get.snackbar("Error", response.message ?? "Failed to update job status");
      }
    } catch (e) {
      Get.back(); // Close dialog
      Get.snackbar("Error", e.toString());
    }
  }

  Future<void> fetchJobAnalytics() async {
    try {
      isLoading.value = true;
      final response = await getJobAnalyticsUseCase();
      if (response.success == true) {
        jobAnalytics.value = response.data;
      } else {
        Get.snackbar("Error", response.message ?? "Failed to fetch analytics");
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> applyJob(Map<String, dynamic> data) async {
    try {
      isLoading.value = true;
      final response = await applyJobUseCase(data);
      if (response.success == true) {
        Get.snackbar("Success", response.message ?? "Applied successfully");
        // Refresh job details to update hasApplied status
        if (data['job_posting_id'] != null) {
          fetchJobDetails(int.parse(data['job_posting_id'].toString()));
        }
        return true;
      } else {
        Get.snackbar("Error", response.message ?? "Failed to apply");
        return false;
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
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
        Get.snackbar("Error", response.message ?? "Failed to fetch applications");
      }
    } catch (e) {
      print('Error fetching job applications: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateApplicationStatus(int applicationId, String status, int jobId, {String? notes}) async {
    try {
      isLoading.value = true;
      final response = await updateApplicationStatusUseCase(applicationId, status, notes: notes);
      if (response.success == true) {
        Get.snackbar("Success", response.message ?? "Status updated to $status");
        fetchJobApplications(jobId); // Refresh list
      } else {
        Get.snackbar("Error", response.message ?? "Failed to update status");
      }
    } catch (e) {
       Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
