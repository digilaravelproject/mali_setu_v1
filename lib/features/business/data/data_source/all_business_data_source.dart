import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart'; // Added for MediaType
import 'package:edu_cluezer/core/network/api_client.dart';
import 'package:edu_cluezer/core/constent/api_constants.dart';
import 'package:edu_cluezer/features/business/data/model/res_all_business_model.dart';
import 'package:edu_cluezer/features/business/data/model/res_single_product_model.dart';
import 'package:edu_cluezer/features/business/data/model/res_single_service_model.dart';
import 'package:edu_cluezer/features/business/data/model/business_plan_model.dart';




abstract class BusinessDataSource {
  Future<BusinessResponse> getAllBusinesses({int page = 1, String? search, double? lat, double? long});
  Future<BusinessResponse> getMyBusinesses();
  Future<BusinessResponse> getBusinessDetails(int id);
  Future<SingleProductResponse> getSingleProductDetails(int productId);
  Future<SingleServiceResponse> getSingleServiceDetails(int serviceId);
  Future<BusinessResponse> getBusinessProducts(int businessId);
  Future<BusinessResponse> getBusinessServices(int businessId);
  Future<BusinessResponse> addProduct(Map<String, dynamic> data, List<File> images);
  Future<BusinessResponse> updateProduct(int id, Map<String, dynamic> data, List<File> images);
  Future<BusinessResponse> deleteProduct(int id);
  Future<BusinessResponse> addService(Map<String, dynamic> data, List<File> images);
  Future<BusinessResponse> updateService(int id, Map<String, dynamic> data, List<File> images);
  Future<BusinessResponse> deleteService(int id);
  Future<BusinessResponse> updateBusiness(int id, Map<String, dynamic> data);
  Future<void> deleteBusiness(int id);
  Future<CategoryResponse> getBusinessCategories({int page = 1, String? search});
  Future<CategoryResponse> getCategoryDetails(int id, {double? lat, double? long});
  Future<BusinessResponse> searchBusiness(String query, {double? lat, double? long});
  
  // Job Methods
  Future<BusinessResponse> createJob(Map<String, dynamic> data);
  Future<BusinessResponse> updateJob(int id, Map<String, dynamic> data);
  Future<BusinessResponse> deleteJob(int id);
  Future<BusinessResponse> getMyJobs(int businessId);
  Future<JobDetailResponse> getJobDetails(int jobId);
  Future<BusinessResponse> toggleJobStatus(int id);
  Future<JobAnalyticsResponse> getJobAnalytics(int businessId);
  Future<BusinessResponse> applyJob(Map<String, dynamic> data);
  Future<MyApplicationsResponse> getMyApplications();
  Future<JobApplicationsResponse> getJobApplications(int jobId);
  Future<BusinessPlanResponse> getBusinessPlans();
  Future<BusinessResponse> updateApplicationStatus(int applicationId, String status, {String? notes});
}

class BusinessDataSourceImpl implements BusinessDataSource {
  final ApiClient apiClient;

  BusinessDataSourceImpl({required this.apiClient});

  @override
  Future<BusinessResponse> getAllBusinesses({int page = 1, String? search, double? lat, double? long}) async {
    final Map<String, dynamic> queryParams = {'page': page};
    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }
    if (lat != null) queryParams['latitude'] = lat;
    if (long != null) queryParams['longitude'] = long;
    
    final response = await apiClient.get(
      ApiConstants.allBusiness,
      queryParameters: queryParams,
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
  Future<SingleProductResponse> getSingleProductDetails(int productId) async {
    final response = await apiClient.get('${ApiConstants.getSingleProduct}/$productId');
    return SingleProductResponse.fromJson(response.data);
  }

  @override
  Future<SingleServiceResponse> getSingleServiceDetails(int serviceId) async {
    final response = await apiClient.get('${ApiConstants.getSingleService}/$serviceId');
    return SingleServiceResponse.fromJson(response.data);
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
    final formData = FormData();
    data.forEach((k, v) {
      if (v != null) {
        formData.fields.add(MapEntry(k, v.toString()));
      }
    });

    for (final file in images) {
      final fileName = file.path.split('/').last;
      final ext = fileName.split('.').last.toLowerCase();
      MediaType mediaType;
      if (ext == 'png') {
        mediaType = MediaType('image', 'png');
      } else if (ext == 'webp') {
        mediaType = MediaType('image', 'webp');
      } else {
        mediaType = MediaType('image', 'jpeg');
      }

      formData.files.add(
        MapEntry(
          'images[]',
          await MultipartFile.fromFile(
            file.path,
            filename: fileName,
            contentType: mediaType,
          ),
        ),
      );
    }

    final response = await apiClient.post(ApiConstants.addBusinessProduct, data: formData);
    if (response.statusCode != null && (response.statusCode! < 200 || response.statusCode! >= 300)) {
      final msg = response.data is Map ? response.data['message'] ?? 'Failed to add product' : 'Failed to add product';
      throw Exception(msg);
    }
    return BusinessResponse.fromJson(response.data);
  }

  @override
  Future<BusinessResponse> updateProduct(int id, Map<String, dynamic> data, List<File> images) async {
    final formData = FormData();
    formData.fields.add(const MapEntry('_method', 'PUT'));

    data.forEach((k, v) {
      if (k == '_method') return;
      if (k == 'remove_image_paths' || k == 'remove_image_paths[]') {
        if (v is List) {
          for (final path in v) {
            if (path != null && path.toString().isNotEmpty) {
              formData.fields.add(MapEntry('remove_image_paths[]', path.toString()));
            }
          }
        }
      } else if (v != null) {
        formData.fields.add(MapEntry(k, v.toString()));
      }
    });

    for (final file in images) {
      final fileName = file.path.split('/').last;
      final ext = fileName.split('.').last.toLowerCase();
      MediaType mediaType;
      if (ext == 'png') {
        mediaType = MediaType('image', 'png');
      } else if (ext == 'webp') {
        mediaType = MediaType('image', 'webp');
      } else {
        mediaType = MediaType('image', 'jpeg');
      }

      formData.files.add(
        MapEntry(
          'images[]',
          await MultipartFile.fromFile(
            file.path,
            filename: fileName,
            contentType: mediaType,
          ),
        ),
      );
    }

    final response = await apiClient.post('${ApiConstants.addBusinessProduct}/$id', data: formData);
    if (response.statusCode != null && (response.statusCode! < 200 || response.statusCode! >= 300)) {
      final msg = response.data is Map ? response.data['message'] ?? 'Failed to update product' : 'Failed to update product';
      throw Exception(msg);
    }
    return BusinessResponse.fromJson(response.data);
  }

  @override
  Future<BusinessResponse> deleteProduct(int id) async {
    final response = await apiClient.delete('${ApiConstants.addBusinessProduct}/$id');
    if (response.statusCode != null && (response.statusCode! < 200 || response.statusCode! >= 300)) {
      final msg = response.data is Map ? response.data['message'] ?? 'Failed to delete product' : 'Failed to delete product';
      throw Exception(msg);
    }
    return BusinessResponse.fromJson(response.data);
  }

  @override
  Future<BusinessResponse> addService(Map<String, dynamic> data, List<File> images) async {
    final formData = FormData();
    data.forEach((k, v) {
      if (v != null) {
        formData.fields.add(MapEntry(k, v.toString()));
      }
    });

    for (final file in images) {
      final fileName = file.path.split('/').last;
      final ext = fileName.split('.').last.toLowerCase();
      MediaType mediaType;
      if (ext == 'png') {
        mediaType = MediaType('image', 'png');
      } else if (ext == 'webp') {
        mediaType = MediaType('image', 'webp');
      } else {
        mediaType = MediaType('image', 'jpeg');
      }

      formData.files.add(
        MapEntry(
          'images[]',
          await MultipartFile.fromFile(
            file.path,
            filename: fileName,
            contentType: mediaType,
          ),
        ),
      );
    }

    final response = await apiClient.post(ApiConstants.addBusinessService, data: formData);
    if (response.statusCode != null && (response.statusCode! < 200 || response.statusCode! >= 300)) {
      final msg = response.data is Map ? response.data['message'] ?? 'Failed to add service' : 'Failed to add service';
      throw Exception(msg);
    }
    return BusinessResponse.fromJson(response.data);
  }

  @override
  Future<BusinessResponse> updateService(int id, Map<String, dynamic> data, List<File> images) async {
    final formData = FormData();
    formData.fields.add(const MapEntry('_method', 'PUT'));

    data.forEach((k, v) {
      if (k == '_method') return;
      if (k == 'remove_image_paths' || k == 'remove_image_paths[]') {
        if (v is List) {
          for (final path in v) {
            if (path != null && path.toString().isNotEmpty) {
              formData.fields.add(MapEntry('remove_image_paths[]', path.toString()));
            }
          }
        }
      } else if (v != null) {
        formData.fields.add(MapEntry(k, v.toString()));
      }
    });

    for (final file in images) {
      final fileName = file.path.split('/').last;
      final ext = fileName.split('.').last.toLowerCase();
      MediaType mediaType;
      if (ext == 'png') {
        mediaType = MediaType('image', 'png');
      } else if (ext == 'webp') {
        mediaType = MediaType('image', 'webp');
      } else {
        mediaType = MediaType('image', 'jpeg');
      }

      formData.files.add(
        MapEntry(
          'images[]',
          await MultipartFile.fromFile(
            file.path,
            filename: fileName,
            contentType: mediaType,
          ),
        ),
      );
    }

    final response = await apiClient.post('${ApiConstants.addBusinessService}/$id', data: formData);
    if (response.statusCode != null && (response.statusCode! < 200 || response.statusCode! >= 300)) {
      final msg = response.data is Map ? response.data['message'] ?? 'Failed to update service' : 'Failed to update service';
      throw Exception(msg);
    }
    return BusinessResponse.fromJson(response.data);
  }

  @override
  Future<BusinessResponse> deleteService(int id) async {
    final response = await apiClient.delete('${ApiConstants.addBusinessService}/$id');
    if (response.statusCode != null && (response.statusCode! < 200 || response.statusCode! >= 300)) {
      final msg = response.data is Map ? response.data['message'] ?? 'Failed to delete service' : 'Failed to delete service';
      throw Exception(msg);
    }
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
  Future<CategoryResponse> getBusinessCategories({int page = 1, String? search}) async {
    final Map<String, dynamic> queryParams = {'page': page};
    if (search != null && search.trim().isNotEmpty) {
      queryParams['q'] = search.trim();
      queryParams['search'] = search.trim();
    }
    final response = await apiClient.get(
      ApiConstants.getCategory,
      queryParameters: queryParams,
    );
    return CategoryResponse.fromJson(response.data);
  }

  @override
  Future<CategoryResponse> getCategoryDetails(int id, {double? lat, double? long}) async {
    final Map<String, dynamic> queryParams = {};
    if (lat != null) queryParams['latitude'] = lat;
    if (long != null) queryParams['longitude'] = long;

    final response = await apiClient.get(
      '${ApiConstants.getCategoryDetails}/$id',
      queryParameters: queryParams,
    );
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
  Future<JobAnalyticsResponse> getJobAnalytics(int businessId) async {
    final response = await apiClient.post(ApiConstants.jobAnalytics,
      data: {
        "business_id": businessId,
      },);
    return JobAnalyticsResponse.fromJson(response.data);
  }

  @override
  Future<BusinessResponse> applyJob(Map<String, dynamic> data) async {
    if (data['resume'] is File) {
      final File file = data['resume'];
      String fileName = file.path.split('/').last;
      String extension = fileName.split('.').last.toLowerCase();
      MediaType? contentType;
      
      if (extension == 'pdf') {
        contentType = MediaType('application', 'pdf');
      } else if (['jpg', 'jpeg', 'png'].contains(extension)) {
        contentType = MediaType('image', extension == 'jpg' ? 'jpeg' : extension);
      } else if (extension == 'doc' || extension == 'docx') {
        contentType = MediaType('application', 'msword');
      }

      // Create a copy of the data and remove the resume File object
      final Map<String, dynamic> body = Map<String, dynamic>.from(data);
      body.remove('resume');

      // Create FormData
      FormData formData = FormData.fromMap({
        ...body,
        'resume': await MultipartFile.fromFile(
          file.path, 
          filename: fileName,
          contentType: contentType,
        ),
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

  @override
  Future<BusinessPlanResponse> getBusinessPlans() async {
    final response = await apiClient.get(ApiConstants.businessSubscriptionPlans);
    return BusinessPlanResponse.fromJson(response.data);
  }

  @override
  Future<BusinessResponse> searchBusiness(String query, {double? lat, double? long}) async {
    final response = await apiClient.post(
      ApiConstants.searchBusiness,
      data: {
        'search': query,
        if (lat != null) 'latitude': lat,
        if (long != null) 'longitude': long,
      },
    );
    return BusinessResponse.fromJson(response.data);
  }
}

