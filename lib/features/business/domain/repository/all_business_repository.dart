import 'dart:io';
import '../../data/model/res_all_business_model.dart';
import '../../data/model/business_plan_model.dart';


abstract class BusinessRepository {
  Future<BusinessResponse> getAllBusinesses({int page = 1, String? search});
  Future<BusinessResponse> getMyBusinesses();
  Future<BusinessResponse> getBusinessDetails(int id);
  Future<BusinessResponse> getBusinessProducts(int businessId);
  Future<BusinessResponse> getBusinessServices(int businessId);
  Future<BusinessResponse> addProduct(Map<String, dynamic> data, List<File> images);
  Future<BusinessResponse> addService(Map<String, dynamic> data, List<File> images);
  Future<BusinessResponse> updateBusiness(int id, Map<String, dynamic> data);
  Future<void> deleteBusiness(int id);
  Future<List<Category>> getBusinessCategories();
  Future<Category?> getCategoryDetails(int id);

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
  Future<BusinessPlanResponse> getBusinessPlans();
  Future<BusinessResponse> updateApplicationStatus(int applicationId, String status, {String? notes});
}
