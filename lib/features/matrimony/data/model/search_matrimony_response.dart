import '../../../Auth/login/data/model/res_login_model.dart';

class SearchMatrimonyResponse {
  bool? success;
  SearchMatrimonyData? data;

  SearchMatrimonyResponse({this.success, this.data});

  SearchMatrimonyResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null ? SearchMatrimonyData.fromJson(json['data']) : null;
  }
}


class MatrimonyProfileDetailResponse {
  bool? success;
  MatrimonyProfileDetailData? data;

  MatrimonyProfileDetailResponse({this.success, this.data});

  MatrimonyProfileDetailResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null ? MatrimonyProfileDetailData.fromJson(json['data']) : null;
  }
}

class MatrimonyProfileDetailData {
  MatrimonyProfile? profile;

  MatrimonyProfileDetailData({this.profile});

  MatrimonyProfileDetailData.fromJson(Map<String, dynamic> json) {
    profile = json['profile'] != null ? MatrimonyProfile.fromJson(json['profile']) : null;
  }
}

class SearchMatrimonyData {
  int? currentPage;
  List<MatrimonyProfile>? data;
  String? firstPageUrl;
  int? from;
  int? lastPage;
  String? lastPageUrl;
  String? nextPageUrl;
  String? path;
  int? perPage;
  String? prevPageUrl;
  int? to;
  int? total;

  SearchMatrimonyData({
    this.currentPage,
    this.data,
    this.firstPageUrl,
    this.from,
    this.lastPage,
    this.lastPageUrl,
    this.nextPageUrl,
    this.path,
    this.perPage,
    this.prevPageUrl,
    this.to,
    this.total,
  });

  SearchMatrimonyData.fromJson(Map<String, dynamic> json) {
    currentPage = json['current_page'];
    if (json['data'] != null) {
      data = <MatrimonyProfile>[];
      json['data'].forEach((v) {
        data!.add(MatrimonyProfile.fromJson(v));
      });
    }
    firstPageUrl = json['first_page_url'];
    from = json['from'];
    lastPage = json['last_page'];
    lastPageUrl = json['last_page_url'];
    nextPageUrl = json['next_page_url'];
    path = json['path'];
    perPage = json['per_page'];
    prevPageUrl = json['prev_page_url'];
    to = json['to'];
    total = json['total'];
  }
}

class MatrimonyProfile {
  int? id;
  int? userId;
  int? age;
  String? height;
  String? weight;
  String? complexion;
  String? physicalStatus;
  PersonalDetails? personalDetails;
  FamilyDetails? familyDetails;
  EducationDetails? educationDetails;
  ProfessionalDetails? professionalDetails;
  LifestyleDetails? lifestyleDetails;
  LocationDetails? locationDetails;
  PartnerPreferences? partnerPreferences;
  PrivacySettings? privacySettings;
  String? approvalStatus;
  String? status;
  String? createdAt;
  String? connectionStatus;
  User? user;

  MatrimonyProfile({
    this.id,
    this.userId,
    this.age,
    this.height,
    this.weight,
    this.complexion,
    this.physicalStatus,
    this.personalDetails,
    this.familyDetails,
    this.educationDetails,
    this.professionalDetails,
    this.lifestyleDetails,
    this.locationDetails,
    this.partnerPreferences,
    this.privacySettings,
    this.approvalStatus,
    this.status,
    this.createdAt,
    this.connectionStatus,
    this.user,
  });

  MatrimonyProfile.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    age = json['age'];
    height = json['height'];
    weight = json['weight'];
    complexion = json['complexion'];
    physicalStatus = json['physical_status'];
    personalDetails = json['personal_details'] != null
        ? PersonalDetails.fromJson(json['personal_details'])
        : null;
    familyDetails = json['family_details'] != null
        ? FamilyDetails.fromJson(json['family_details'])
        : null;
    educationDetails = json['education_details'] != null
        ? EducationDetails.fromJson(json['education_details'])
        : null;
    professionalDetails = json['professional_details'] != null
        ? ProfessionalDetails.fromJson(json['professional_details'])
        : null;
    lifestyleDetails = json['lifestyle_details'] != null
        ? LifestyleDetails.fromJson(json['lifestyle_details'])
        : null;
    locationDetails = json['location_details'] != null
        ? LocationDetails.fromJson(json['location_details'])
        : null;
    partnerPreferences = json['partner_preferences'] != null
        ? PartnerPreferences.fromJson(json['partner_preferences'])
        : null;
    privacySettings = json['privacy_settings'] != null
        ? PrivacySettings.fromJson(json['privacy_settings'])
        : null;
    approvalStatus = json['approval_status'];
    status = json['status'];
    createdAt = json['created_at'];
    connectionStatus = json['connection_status'];
    user = json['user'] != null ? User.fromJson(json['user']) : null;
  }
}

class PersonalDetails {
  String? name;
  String? dob;
  String? annualIncome;
  String? occupation;
  String? profileCreatedBy;
  List<String>? hobbies;
  String? language;
  String? citizenship;
  String? employmentType;
  String? familyType;
  String? maritalStatus;
  List<String>? religion;
  List<String>? starDetails;
  String? dosh;
  List<String>? photos;

  PersonalDetails.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    dob = json['dob'];
    annualIncome = json['annual_income'];
    occupation = json['occupation'];
    profileCreatedBy = json['profile_created_by'];
    hobbies = json['hobbies'] != null ? List<String>.from(json['hobbies']) : null;
    language = json['language'];
    citizenship = json['citizenship'];
    employmentType = json['employment_type'];
    familyType = json['family_type'];
    maritalStatus = json['marital_status'];
    religion = json['religion'] != null ? List<String>.from(json['religion']) : null;
    starDetails = json['star_details'] != null ? List<String>.from(json['star_details']) : null;
    dosh = json['dosh'];
    photos = json['photos'] != null ? List<String>.from(json['photos']) : null;
  }
}

class FamilyDetails {
  String? father;
  String? mother;
  String? familyClass;
  String? familyValue;

  FamilyDetails.fromJson(Map<String, dynamic> json) {
    father = json['father'];
    mother = json['mother'];
    familyClass = json['family_class'];
    familyValue = json['family_value'];
  }
}

class EducationDetails {
  String? highestQualification;
  String? college;

  EducationDetails.fromJson(Map<String, dynamic> json) {
    highestQualification = json['highest_qualification'];
    college = json['college'];
  }
}

class ProfessionalDetails {
  String? jobTitle;
  String? company;

  ProfessionalDetails.fromJson(Map<String, dynamic> json) {
    jobTitle = json['job_title'];
    company = json['company'];
  }
}

class LifestyleDetails {
  String? diet;
  String? smoking;
  String? drinking;

  LifestyleDetails.fromJson(Map<String, dynamic> json) {
    diet = json['diet'];
    smoking = json['smoking'];
    drinking = json['drinking'];
  }
}

class LocationDetails {
  String? city;
  String? state;
  String? country;

  LocationDetails.fromJson(Map<String, dynamic> json) {
    city = json['city'];
    state = json['state'];
    country = json['country'];
  }
}

class PartnerPreferences {
  String? ageRange;
  String? education;
  String? location;

  PartnerPreferences.fromJson(Map<String, dynamic> json) {
    ageRange = json['age_range'];
    education = json['education'];
    location = json['location'];
  }
}

class PrivacySettings {
  String? showPhotos;
  String? showContact;

  PrivacySettings.fromJson(Map<String, dynamic> json) {
    showPhotos = json['show_photos'];
    showContact = json['show_contact'];
  }
}
