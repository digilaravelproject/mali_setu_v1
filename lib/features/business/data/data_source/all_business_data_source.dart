import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:edu_cluezer/core/network/api_client.dart';
import 'package:edu_cluezer/core/constent/api_constants.dart';
import 'package:edu_cluezer/features/business/data/model/res_all_business_model.dart';




abstract class BusinessDataSource {
  Future<BusinessResponse> getAllBusinesses({int page = 1});
  Future<BusinessResponse> getMyBusinesses();
  Future<BusinessResponse> getBusinessDetails(int id);
  Future<BusinessResponse> getBusinessProducts(int businessId);
  Future<BusinessResponse> getBusinessServices(int businessId);
  Future<BusinessResponse> addProduct(Map<String, dynamic> data, List<File> images);
  Future<BusinessResponse> addService(Map<String, dynamic> data, List<File> images);
  Future<BusinessResponse> updateBusiness(int id, Map<String, dynamic> data);
  Future<void> deleteBusiness(int id);
  Future<CategoryResponse> getBusinessCategories({int page = 1});
  Future<CategoryResponse> getCategoryDetails(int id);
  
  // Job Methods
  Future<BusinessResponse> createJob(Map<String, dynamic> data);
  Future<BusinessResponse> updateJob(int id, Map<String, dynamic> data);
  Future<BusinessResponse> deleteJob(int id);
  Future<BusinessResponse> getMyJobs(int businessId);
  Future<JobDetailResponse> getJobDetails(int jobId);
  Future<BusinessResponse> toggleJobStatus(int id);
  Future<JobAnalyticsResponse> getJobAnalytics();
  Future<BusinessResponse> applyJob(Map<String, dynamic> data);
  Future<MyApplicationsResponse> getMyApplications();
  Future<JobApplicationsResponse> getJobApplications(int jobId);
  Future<BusinessResponse> updateApplicationStatus(int applicationId, String status, {String? notes});
}

class BusinessDataSourceImpl implements BusinessDataSource {
  final ApiClient apiClient;

  BusinessDataSourceImpl({required this.apiClient});

  @override
  Future<BusinessResponse> getAllBusinesses({int page = 1}) async {
    final response = await apiClient.get(
      ApiConstants.allBusiness,
      queryParameters: {'page': page},
    );
    return BusinessResponse.fromJson(response.data);
  }

  @override
  Future<BusinessResponse> getMyBusinesses() async {
    final response = await apiClient.post(ApiConstants.myBusinesses);
    return BusinessResponse.fromJson(response.data);
  }

  @override
  Future<BusinessResponse> getBusinessDetails(int id) async {
    final response = await apiClient.get('${ApiConstants.getSingleBusiness}/$id');
    return BusinessResponse.fromJson(response.data);
  }

  @override
  Future<BusinessResponse> getBusinessProducts(int businessId) async {
    final response = await apiClient.get('${ApiConstants.getBusinessProducts}/$businessId/products');
    return BusinessResponse.fromJson(response.data);
  }

  @override
  Future<BusinessResponse> getBusinessServices(int businessId) async {
    final response = await apiClient.get('${ApiConstants.getBusinessServices}/$businessId/services');
    return BusinessResponse.fromJson(response.data);
  }

  @override
  Future<BusinessResponse> addProduct(Map<String, dynamic> data, List<File> images) async {
    List<String> base64Images = [];
    for (var image in images) {
      List<int> imageBytes = await image.readAsBytes();
      String base64Image = base64Encode(imageBytes);
      base64Images.add(base64Image);
    }
    
    // Create a mutable copy of data
    final Map<String, dynamic> requestData = Map<String, dynamic>.from(data);
    requestData['image'] = base64Images; // Sending array of strings

    final response = await apiClient.post(ApiConstants.addBusinessProduct, data: requestData);
    return BusinessResponse.fromJson(response.data);
  }

  @override
  Future<BusinessResponse> addService(Map<String, dynamic> data, List<File> images) async {
    List<String> base64Images = [];
    for (var image in images) {
      List<int> imageBytes = await image.readAsBytes();
      String base64Image = base64Encode(imageBytes);
      base64Images.add(base64Image);
    }

    // Create a mutable copy of data
    final Map<String, dynamic> requestData = Map<String, dynamic>.from(data);
    requestData['image'] = base64Images; // Sending array of strings

    final response = await apiClient.post(ApiConstants.addBusinessService, data: requestData);
    return BusinessResponse.fromJson(response.data);
  }

  @override
  Future<BusinessResponse> updateBusiness(int id, Map<String, dynamic> data) async {
    final response = await apiClient.put('${ApiConstants.updateBusinessServices}/$id', data: data);
    return BusinessResponse.fromJson(response.data);
  }

  @override
  Future<void> deleteBusiness(int id) async {
    await apiClient.delete('${ApiConstants.deleteBusinessServices}/$id');
  }

  @override
  Future<CategoryResponse> getBusinessCategories({int page = 1}) async {
    final response = await apiClient.get(
      ApiConstants.getCategory,
      queryParameters: {'page': page},
    );
    return CategoryResponse.fromJson(response.data);
  }

  @override
  Future<CategoryResponse> getCategoryDetails(int id) async {
    final response = await apiClient.get('${ApiConstants.getCategoryDetails}/$id');
    return CategoryResponse.fromJson(response.data);
  }

  @override
  Future<BusinessResponse> createJob(Map<String, dynamic> data) async {
    final response = await apiClient.post(ApiConstants.createJobs, data: data);
    return BusinessResponse.fromJson(response.data);
  }

  @override
  Future<BusinessResponse> updateJob(int id, Map<String, dynamic> data) async {
    final response = await apiClient.put('${ApiConstants.jobsUpdate}/$id', data: data);
    return BusinessResponse.fromJson(response.data);
  }

  @override
  Future<BusinessResponse> deleteJob(int id) async {
    final response = await apiClient.delete('${ApiConstants.jobsDelete}/$id');
    return BusinessResponse.fromJson(response.data);
  }

  @override
  Future<BusinessResponse> getMyJobs(int businessId) async {
    final response = await apiClient.get('${ApiConstants.jobsByBusinessId}?business_id=$businessId');
    return BusinessResponse.fromJson(response.data);
  }

  @override
  Future<JobDetailResponse> getJobDetails(int jobId) async {
    final response = await apiClient.get('${ApiConstants.jobsById}/$jobId');
    return JobDetailResponse.fromJson(response.data);
  }

  @override
  Future<BusinessResponse> toggleJobStatus(int id) async {
    final response = await apiClient.post('${ApiConstants.toggleJobStatus}/$id/toggle-status');
    return BusinessResponse.fromJson(response.data);
  }

  @override
  Future<JobAnalyticsResponse> getJobAnalytics() async {
    final response = await apiClient.post(ApiConstants.jobAnalytics);
    return JobAnalyticsResponse.fromJson(response.data);
  }

  @override
  Future<BusinessResponse> applyJob(Map<String, dynamic> data) async {
    if (data['resume'] is File) {
      final File file = data['resume'];
      String fileName = file.path.split('/').last;

      // Create FormData
      FormData formData = FormData.fromMap({
        ...data,
        'resume': await MultipartFile.fromFile(file.path, filename: fileName),
      });
      
      final response = await apiClient.post(ApiConstants.applyJob, data: formData);
      return BusinessResponse.fromJson(response.data);
    } else {
      final response = await apiClient.post(ApiConstants.applyJob, data: data);
      return BusinessResponse.fromJson(response.data);
    }
  }

  @override
  Future<MyApplicationsResponse> getMyApplications() async {
    final response = await apiClient.post(ApiConstants.myApplications);
    return MyApplicationsResponse.fromJson(response.data);
  }

  @override
  Future<JobApplicationsResponse> getJobApplications(int jobId) async {
    final response = await apiClient.get('${ApiConstants.getJobApplications}/$jobId/applications');
    return JobApplicationsResponse.fromJson(response.data);
  }

  @override
  Future<BusinessResponse> updateApplicationStatus(int applicationId, String status, {String? notes}) async {
    final response = await apiClient.put(
      '${ApiConstants.updateApplicationStatus}/$applicationId/status',
      data: {
        'status': status,
        if (notes != null) 'employer_notes': notes,
      },
    );
    return BusinessResponse.fromJson(response.data);
  }
}

