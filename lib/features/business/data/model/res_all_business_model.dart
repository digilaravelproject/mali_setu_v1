class BusinessResponse {
  bool? success;
  BusinessData? data;
  String? message;
  Map<String, dynamic>? errors;

  BusinessResponse({this.success, this.data, this.message, this.errors});

  factory BusinessResponse.fromJson(Map<String, dynamic> json) {
    // Check if directly a list response (pagination) or single object
    BusinessData? businessData;
    if (json['data'] != null) {
      if (json['data']['business'] != null) {
         // Handle single business details response
         businessData = BusinessData(
           data: [Business.fromJson(json['data']['business'])]
         );
      } else if (json['data']['products'] != null) {
          // Handle products list response
          businessData = BusinessData(
              data: [],
              products: List<Product>.from(json['data']['products'].map((x) => Product.fromJson(x))),
          );
      } else if (json['data']['services'] != null) {
          // Handle services list response
          businessData = BusinessData(
              data: [],
              services: List<Service>.from(json['data']['services'].map((x) => Service.fromJson(x))),
          );
      } else if (json['data']['jobs'] != null) {
          // Handle jobs list response
          businessData = BusinessData(
              data: [],
              jobs: List<Job>.from(json['data']['jobs'].map((x) => Job.fromJson(x))),
          );
      } else {
        // Standard pagination response
         businessData = BusinessData.fromJson(json['data']);
      }
    }

    return BusinessResponse(
      success: json['success'],
      message: json['message'],
      errors: json['errors'],
      data: businessData,
    );
  }
}

class BusinessData {
  int? currentPage;
  List<Business>? data;
  int? total;
  String? firstPageUrl;
  String? lastPageUrl;
  String? nextPageUrl;
  String? prevPageUrl;
  int? from;
  int? to;
  int? lastPage;

  List<Product>? products;
  List<Service>? services;
  List<Job>? jobs;

  BusinessData({
    this.currentPage,
    this.data,
    this.total,
    this.firstPageUrl,
    this.lastPageUrl,
    this.nextPageUrl,
    this.prevPageUrl,
    this.from,
    this.to,
    this.lastPage,
    this.products,
    this.services,
    this.jobs,
  });

  factory BusinessData.fromJson(Map<String, dynamic> json) {
    var rawData = json['data'] ?? json['businesses'];
    
    List<Business> businesses = [];
    List<Job> jobsList = [];
    List<Product> productsList = [];
    List<Service> servicesList = [];

    if (rawData != null && rawData is List && rawData.isNotEmpty) {
      var item = rawData.first;
      if (item is Map) {
        if (item.containsKey('title')) {
          jobsList = List<Job>.from(rawData.map((x) => Job.fromJson(x)));
        } else if (item.containsKey('business_name')) {
          businesses = List<Business>.from(rawData.map((x) => Business.fromJson(x)));
        } else if (item.containsKey('cost')) {
          // It could be either product or service. 
          // For now, let's treat it as generic data if we can't distinguish.
          // But usually, they are return in specific keys if not paginated.
          // In pagination, we'll try to guess or just use the caller's expectation.
          // For now, let's focus on jobs which we know has 'title'.
        }
      }
    }

    return BusinessData(
      currentPage: _asInt(json['current_page']),
      data: businesses.isNotEmpty ? businesses : [],
      total: _asInt(json['total'] ?? json['count']),
      firstPageUrl: json['first_page_url'],
      lastPageUrl: json['last_page_url'],
      nextPageUrl: json['next_page_url'],
      prevPageUrl: json['prev_page_url'],
      from: _asInt(json['from']),
      to: _asInt(json['to']),
      lastPage: _asInt(json['last_page']),
      products: json['products'] != null
          ? List<Product>.from(json['products'].map((x) => Product.fromJson(x)))
          : null,
      services: json['services'] != null
          ? List<Service>.from(json['services'].map((x) => Service.fromJson(x)))
          : null,
      jobs: jobsList.isNotEmpty 
          ? jobsList 
          : (json['jobs'] != null
              ? List<Job>.from(json['jobs'].map((x) => Job.fromJson(x)))
              : null),
    );
  }
}

class Business {
  int? id;
  int? userId;
  String? businessName;
  String? businessType;
  int? categoryId;
  String? description;
  String? contactPhone;
  String? contactEmail;
  String? website;
  String? opening_time;
  String? closing_time;
  String? verificationStatus;
  String? verifiedAt;
  String? photo;
  String? subscriptionStatus;
  String? subscriptionExpiresAt;
  int? jobPostingLimit;
  int? KMfromuser;
  String? createdAt;
  String? updatedAt;
  String? status;
  String? state;
  String? district;
  String? taluka;
  String? village;
  String? city;
  String? pincode;
  String? country;
  String? address;
  User? user;
  Category? category;
  List<Product>? products;
  List<Service>? services;

  Business({
    this.id,
    this.userId,
    this.businessName,
    this.businessType,
    this.categoryId,
    this.description,
    this.contactPhone,
    this.contactEmail,
    this.website,
    this.opening_time,
    this.closing_time,
    this.verificationStatus,
    this.verifiedAt,
    this.photo,
    this.subscriptionStatus,
    this.subscriptionExpiresAt,
    this.jobPostingLimit,
    this.KMfromuser,
    this.createdAt,
    this.updatedAt,
    this.status,
    this.state,
    this.district,
    this.taluka,
    this.village,
    this.city,
    this.pincode,
    this.country,
    this.address,
    this.user,
    this.category,
    this.products,
    this.services,
  });

  factory Business.fromJson(Map<String, dynamic> json) {
    return Business(
      id: _asInt(json['id']),
      userId: _asInt(json['user_id']),
      businessName: json['business_name'],
      businessType: json['business_type'],
      categoryId: _asInt(json['category_id']),
      description: json['description'],
      contactPhone: json['contact_phone'],
      contactEmail: json['contact_email'],
      website: json['website'],
      opening_time: json['opening_time'],
      closing_time: json['closing_time'],
      verificationStatus: json['verification_status'],
      verifiedAt: json['verified_at'],
      photo: json['photo'],
      subscriptionStatus: json['subscription_status'],
      subscriptionExpiresAt: json['subscription_expires_at'],
      jobPostingLimit: _asInt(json['job_posting_limit']),
      KMfromuser: _asInt(json['KMfromuser']),
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      status: json['status'],
      state: json['state'],
      district: json['district'],
      address: json['address'],
      taluka: json['taluka'],
      village: json['village'],
      city: json['city'],
      pincode: json['pincode'],
      country: json['country'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      category: json['category'] != null ? Category.fromJson(json['category']) : null,
      products: json['products'] != null
          ? List<Product>.from(json['products'].map((x) => Product.fromJson(x)))
          : [],
      services: json['services'] != null
          ? List<Service>.from(json['services'].map((x) => Service.fromJson(x)))
          : [],
    );
  }
}

class User {
  int? id;
  String? name;
  String? email;
  String? phone;
  int? age;
  String? address;
  String? nearbyLocation;
  String? pincode;
  String? state;
  String? city;
  String? district;
  String? destination;
  String? userType;

  User({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.age,
    this.address,
    this.nearbyLocation,
    this.pincode,
    this.state,
    this.city,
    this.district,
    this.destination,
    this.userType,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: _asInt(json['id']),
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      age: _asInt(json['age']),
      address: json['address'],
      nearbyLocation: json['nearby_location'],
      pincode: json['pincode'],
      state: json['state'],
      city: json['city'],
      district: json['district'],
      destination: json['destination'],
      userType: json['user_type'],
    );
  }
}

class Category {
  int? id;
  String? name;
  String? description;
  String? photo;
  bool? isActive;

  Category({this.id, this.name, this.description, this.photo, this.isActive});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: _asInt(json['id']),
      name: json['name'],
      description: json['description'],
      photo: json['photo'],
      isActive: _asBool(json['is_active']),
    );
  }
}

class Product {
  int? id;
  int? businessId;
  String? name;
  String? description;
  String? cost;
  String? imagePath;
  String? status;

  Product({
    this.id,
    this.businessId,
    this.name,
    this.description,
    this.cost,
    this.imagePath,
    this.status,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: _asInt(json['id']),
      businessId: _asInt(json['business_id']),
      name: json['name'],
      description: json['description'],
      cost: json['cost'],
      imagePath: json['image_path'],
      status: json['status'],
    );
  }
}

class Service {
  int? id;
  int? businessId;
  String? name;
  String? description;
  String? cost;
  String? imagePath;
  String? status;

  Service({
    this.id,
    this.businessId,
    this.name,
    this.description,
    this.cost,
    this.imagePath,
    this.status,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: _asInt(json['id']),
      businessId: _asInt(json['business_id']),
      name: json['name'],
      description: json['description'],
      cost: json['cost'],
      imagePath: json['image_path'],
      status: json['status'],
    );
  }
}

class CategoryResponse {
  bool? success;
  CategoryData? data;
  String? message;

  CategoryResponse({this.success, this.data, this.message});

  factory CategoryResponse.fromJson(Map<String, dynamic> json) {
    return CategoryResponse(
      success: json['success'],
      data: json['data'] != null ? CategoryData.fromJson(json['data']) : null,
      message: json['message'],
    );
  }
}

class CategoryData {
  int? currentPage;
  List<Category>? data;
  Category? singleCategory;
  int? total;
  String? firstPageUrl;
  String? lastPageUrl;
  int? lastPage;
  String? nextPageUrl;
  
  CategoryData({
    this.currentPage,
    this.data,
    this.singleCategory,
    this.total,
    this.firstPageUrl,
    this.lastPageUrl,
    this.lastPage,
    this.nextPageUrl,
  });

  factory CategoryData.fromJson(Map<String, dynamic> json) {
    // Check if it's a list response or single object response
    List<Category>? listData;
    Category? singleData;

    if (json['data'] != null && json['data'] is List) {
       listData = List<Category>.from(json['data'].map((x) => Category.fromJson(x)));
    } else if (json['business_category'] != null) {
       singleData = Category.fromJson(json['business_category']);
    }

    return CategoryData(
      currentPage: json['current_page'],
      data: listData ?? [],
      singleCategory: singleData,
      total: json['total'],
      firstPageUrl: json['first_page_url'],
      lastPageUrl: json['last_page_url'],
      lastPage: json['last_page'],
      nextPageUrl: json['next_page_url'],
    );
  }
}

class Job {
  int? id;
  int? businessId;
  String? title;
  String? description;
  String? requirements;
  String? salaryRange;
  String? jobType;
  String? location;
  String? experienceLevel;
  String? employmentType;
  String? category;
  List<String>? skillsRequired;
  List<String>? benefits;
  String? applicationDeadline;
  String? expiresAt;
  bool? isActive;
  String? status;
  String? updatedAt;
  String? createdAt;
  Business? business;

  Job({
    this.id,
    this.businessId,
    this.title,
    this.description,
    this.requirements,
    this.salaryRange,
    this.jobType,
    this.location,
    this.experienceLevel,
    this.employmentType,
    this.category,
    this.skillsRequired,
    this.benefits,
    this.applicationDeadline,
    this.expiresAt,
    this.isActive,
    this.status,
    this.updatedAt,
    this.createdAt,
    this.business,
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: _asInt(json['id']),
      businessId: _asInt(json['business_id']),
      title: json['title'],
      description: json['description'],
      requirements: json['requirements'],
      salaryRange: json['salary_range'],
      jobType: json['job_type'],
      location: json['location'],
      experienceLevel: json['experience_level'],
      employmentType: json['employment_type'],
      category: json['category'],
      skillsRequired: json['skills_required'] != null
          ? List<String>.from(json['skills_required'])
          : [],
      benefits: json['benefits'] != null
          ? List<String>.from(json['benefits'])
          : [],
      applicationDeadline: json['application_deadline'],
      expiresAt: json['expires_at'],
      isActive: json['is_active'] == 1 || json['is_active'] == true,
      status: json['status'],
      updatedAt: json['updated_at'],
      createdAt: json['created_at'],
      business: json['business'] != null
          ? Business.fromJson(json['business'])
          : null,
    );
  }
}

class JobDetailResponse {
  bool? success;
  JobDetailData? data;
  String? message;

  JobDetailResponse({this.success, this.data, this.message});

  factory JobDetailResponse.fromJson(Map<String, dynamic> json) {
    return JobDetailResponse(
      success: json['success'],
      data: json['data'] != null ? JobDetailData.fromJson(json['data']) : null,
      message: json['message'],
    );
  }
}

class JobDetailData {
  Job? job;
  bool? hasApplied;
  List<Job>? similarJobs;

  JobDetailData({this.job, this.hasApplied, this.similarJobs});

  factory JobDetailData.fromJson(Map<String, dynamic> json) {
    return JobDetailData(
      job: json['job'] != null ? Job.fromJson(json['job']) : null,
      hasApplied: _asBool(json['has_applied']),
      similarJobs: json['similar_jobs'] != null
          ? List<Job>.from(json['similar_jobs'].map((x) => Job.fromJson(x)))
          : [],
    );
  }
}

class JobAnalyticsResponse {
  bool? success;
  JobAnalyticsData? data;
  String? message;

  JobAnalyticsResponse({this.success, this.data, this.message});

  factory JobAnalyticsResponse.fromJson(Map<String, dynamic> json) {
    return JobAnalyticsResponse(
      success: json['success'],
      data: json['data'] != null ? JobAnalyticsData.fromJson(json['data']) : null,
      message: json['message'],
    );
  }
}

class JobAnalyticsData {
  int? totalJobs;
  int? activeJobs;
  int? pendingJobs;
  int? totalApplications;
  int? pendingApplications;
  int? acceptedApplications;
  List<dynamic>? recentApplications;

  JobAnalyticsData({
    this.totalJobs,
    this.activeJobs,
    this.pendingJobs,
    this.totalApplications,
    this.pendingApplications,
    this.acceptedApplications,
    this.recentApplications,
  });

  factory JobAnalyticsData.fromJson(Map<String, dynamic> json) {
    return JobAnalyticsData(
      totalJobs: _asInt(json['total_jobs']),
      activeJobs: _asInt(json['active_jobs']),
      pendingJobs: _asInt(json['pending_jobs']),
      totalApplications: _asInt(json['total_applications']),
      pendingApplications: _asInt(json['pending_applications']),
      acceptedApplications: _asInt(json['accepted_applications']),
      recentApplications: json['recent_applications'],
    );
  }
}

class MyApplicationsResponse {
  bool? success;
  MyApplicationsData? data;
  String? message;

  MyApplicationsResponse({this.success, this.data, this.message});

  factory MyApplicationsResponse.fromJson(Map<String, dynamic> json) {
    return MyApplicationsResponse(
      success: json['success'],
      data: json['data'] != null ? MyApplicationsData.fromJson(json['data']) : null,
      message: json['message'],
    );
  }
}

class MyApplicationsData {
  int? currentPage;
  List<JobApplication>? data;
  int? total;
  String? firstPageUrl;
  String? lastPageUrl;
  String? nextPageUrl;
  String? prevPageUrl;
  int? from;
  int? to;
  int? lastPage;

  MyApplicationsData({
    this.currentPage,
    this.data,
    this.total,
    this.firstPageUrl,
    this.lastPageUrl,
    this.nextPageUrl,
    this.prevPageUrl,
    this.from,
    this.to,
    this.lastPage,
  });

  factory MyApplicationsData.fromJson(Map<String, dynamic> json) {
    return MyApplicationsData(
      currentPage: json['current_page'],
      data: json['data'] != null
          ? List<JobApplication>.from(json['data'].map((x) => JobApplication.fromJson(x)))
          : [],
      total: json['total'],
      firstPageUrl: json['first_page_url'],
      lastPageUrl: json['last_page_url'],
      nextPageUrl: json['next_page_url'],
      prevPageUrl: json['prev_page_url'],
      from: json['from'],
      to: json['to'],
      lastPage: json['last_page'],
    );
  }
}

class JobApplication {
  int? id;
  int? userId;
  int? jobPostingId;
  String? coverLetter;
  String? resumeUrl;
  String? additionalInfo;
  String? status;
  String? employerNotes;
  String? appliedAt;
  String? reviewedAt;
  Job? jobPosting;
  User? user;

  JobApplication({
    this.id,
    this.userId,
    this.jobPostingId,
    this.coverLetter,
    this.resumeUrl,
    this.additionalInfo,
    this.status,
    this.employerNotes,
    this.appliedAt,
    this.reviewedAt,
    this.jobPosting,
    this.user,
  });

  factory JobApplication.fromJson(Map<String, dynamic> json) {
    return JobApplication(
      id: _asInt(json['id']),
      userId: _asInt(json['user_id']),
      jobPostingId: _asInt(json['job_posting_id']),
      coverLetter: json['cover_letter'],
      resumeUrl: json['resume_url'],
      additionalInfo: json['additional_info'],
      status: json['status'],
      employerNotes: json['employer_notes'],
      appliedAt: json['applied_at'],
      reviewedAt: json['reviewed_at'],
      jobPosting: json['job_posting'] != null ? Job.fromJson(json['job_posting']) : null,
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }
}

class JobApplicationsResponse {
  bool? success;
  JobApplicationsData? data;
  String? message;

  JobApplicationsResponse({this.success, this.data, this.message});

  factory JobApplicationsResponse.fromJson(Map<String, dynamic> json) {
    return JobApplicationsResponse(
      success: json['success'],
      data: json['data'] != null ? JobApplicationsData.fromJson(json['data']) : null,
      message: json['message'],
    );
  }
}

class JobApplicationsData {
  Job? job;
  JobApplicationsPagination? applications;

  JobApplicationsData({this.job, this.applications});

  factory JobApplicationsData.fromJson(Map<String, dynamic> json) {
    return JobApplicationsData(
      job: json['job'] != null ? Job.fromJson(json['job']) : null,
      applications: json['applications'] != null ? JobApplicationsPagination.fromJson(json['applications']) : null,
    );
  }
}

class JobApplicationsPagination {
  int? currentPage;
  List<JobApplication>? data;
  int? lastPage;
  int? total;

  JobApplicationsPagination({this.currentPage, this.data, this.lastPage, this.total});

  factory JobApplicationsPagination.fromJson(Map<String, dynamic> json) {
    return JobApplicationsPagination(
      currentPage: _asInt(json['current_page']),
      data: json['data'] != null
          ? List<JobApplication>.from(json['data'].map((x) => JobApplication.fromJson(x)))
          : null,
      lastPage: _asInt(json['last_page']),
      total: _asInt(json['total']),
    );
  }
}

int? _asInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value);
  if (value is List && value.isNotEmpty) return _asInt(value.first);
  return null;
}

bool? _asBool(dynamic value) {
  if (value == null) return null;
  if (value is bool) return value;
  if (value is int) return value == 1;
  if (value is String) {
    String v = value.toLowerCase();
    if (v == 'true' || v == '1') return true;
    if (v == 'false' || v == '0') return false;
  }
  return null;
}
