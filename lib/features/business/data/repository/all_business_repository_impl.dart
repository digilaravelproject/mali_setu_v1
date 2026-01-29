import 'dart:io';
import '../../domain/repository/all_business_repository.dart';
import '../../data/data_source/all_business_data_source.dart';
import '../../data/model/res_all_business_model.dart';


class BusinessRepositoryImpl implements BusinessRepository {
  final BusinessDataSource dataSource;

  BusinessRepositoryImpl({required this.dataSource});

  @override
  Future<BusinessResponse> getAllBusinesses() {
    return dataSource.getAllBusinesses();
  }

  @override
  Future<BusinessResponse> getMyBusinesses() {
    return dataSource.getMyBusinesses();
  }

  @override
  Future<BusinessResponse> getBusinessDetails(int id) {
    return dataSource.getBusinessDetails(id);
  }

  @override
  Future<BusinessResponse> getBusinessProducts(int businessId) {
    return dataSource.getBusinessProducts(businessId);
  }

  @override
  Future<BusinessResponse> getBusinessServices(int businessId) {
    return dataSource.getBusinessServices(businessId);
  }

  @override
  Future<BusinessResponse> addProduct(Map<String, dynamic> data, List<File> images) {
    return dataSource.addProduct(data, images);
  }

  @override
  Future<BusinessResponse> addService(Map<String, dynamic> data, List<File> images) {
    return dataSource.addService(data, images);
  }

  @override
  Future<BusinessResponse> updateBusiness(int id, Map<String, dynamic> data) {
    return dataSource.updateBusiness(id, data);
  }

  @override
  Future<void> deleteBusiness(int id) {
    return dataSource.deleteBusiness(id);
  }

  @override
  Future<List<Category>> getBusinessCategories() async {
    final response = await dataSource.getBusinessCategories();
    if (response.success == true && response.data != null && response.data!.data != null) {
      return response.data!.data!;
    }
    return [];
  }

  @override
  Future<Category?> getCategoryDetails(int id) async {
    final response = await dataSource.getCategoryDetails(id);
    if (response.success == true && response.data != null) {
      return response.data!.singleCategory; // Assuming singleCategory is populated
    }
    return null;
  }

  @override
  Future<BusinessResponse> createJob(Map<String, dynamic> data) {
    return dataSource.createJob(data);
  }

  @override
  Future<BusinessResponse> updateJob(int id, Map<String, dynamic> data) {
    return dataSource.updateJob(id, data);
  }

  @override
  Future<BusinessResponse> deleteJob(int id) {
    return dataSource.deleteJob(id);
  }

  @override
  Future<BusinessResponse> getMyJobs(int businessId) {
    return dataSource.getMyJobs(businessId);
  }

  @override
  Future<JobDetailResponse> getJobDetails(int jobId) {
    return dataSource.getJobDetails(jobId);
  }

  @override
  Future<BusinessResponse> toggleJobStatus(int id) {
    return dataSource.toggleJobStatus(id);
  }

  @override
  Future<JobAnalyticsResponse> getJobAnalytics() {
    return dataSource.getJobAnalytics();
  }

  @override
  Future<BusinessResponse> applyJob(Map<String, dynamic> data) {
    return dataSource.applyJob(data);
  }

  @override
  Future<MyApplicationsResponse> getMyApplications() {
    return dataSource.getMyApplications();
  }

  @override
  Future<JobApplicationsResponse> getJobApplications(int jobId) {
    return dataSource.getJobApplications(jobId);
  }

  @override
  Future<BusinessResponse> updateApplicationStatus(int applicationId, String status, {String? notes}) {
    return dataSource.updateApplicationStatus(applicationId, status, notes: notes);
  }
}