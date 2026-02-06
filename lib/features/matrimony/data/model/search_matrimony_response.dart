/*
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
*/





import '../../../Auth/login/data/model/res_login_model.dart';

class SearchMatrimonyResponse {
  bool? success;
  SearchMatrimonyData? data;

  SearchMatrimonyResponse({this.success, this.data});

  SearchMatrimonyResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'] ?? false;
    data = json['data'] != null ? SearchMatrimonyData.fromJson(json['data']) : null;
  }
}

class MatrimonyProfileDetailResponse {
  bool? success;
  MatrimonyProfileDetailData? data;

  MatrimonyProfileDetailResponse({this.success, this.data});

  MatrimonyProfileDetailResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'] ?? false;
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
  List<MatrimonyProfile> data;
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
    List<MatrimonyProfile>? data,
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
  }) : data = data ?? [];

  SearchMatrimonyData.fromJson(Map<String, dynamic> json)
      : currentPage = json['current_page'],
        data = json['data'] != null
            ? (json['data'] as List)
            .map((v) => MatrimonyProfile.fromJson(v))
            .toList()
            : [],
        firstPageUrl = json['first_page_url'],
        from = json['from'],
        lastPage = json['last_page'],
        lastPageUrl = json['last_page_url'],
        nextPageUrl = json['next_page_url'],
        path = json['path'],
        perPage = json['per_page'],
        prevPageUrl = json['prev_page_url'],
        to = json['to'],
        total = json['total'];
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

  factory MatrimonyProfile.fromJson(Map<String, dynamic> json) {
    return MatrimonyProfile(
      id: json['id'],
      userId: json['user_id'],
      age: json['age'],
      height: json['height']?.toString(),
      weight: json['weight']?.toString(),
      complexion: json['complexion']?.toString(),
      physicalStatus: json['physical_status']?.toString(),
      personalDetails: json['personal_details'] != null
          ? PersonalDetails.fromJson(json['personal_details'])
          : null,
      familyDetails: json['family_details'] != null
          ? FamilyDetails.fromJson(json['family_details'])
          : null,
      educationDetails: json['education_details'] != null
          ? EducationDetails.fromJson(json['education_details'])
          : null,
      professionalDetails: json['professional_details'] != null
          ? ProfessionalDetails.fromJson(json['professional_details'])
          : null,
      lifestyleDetails: json['lifestyle_details'] != null
          ? LifestyleDetails.fromJson(json['lifestyle_details'])
          : null,
      locationDetails: json['location_details'] != null
          ? LocationDetails.fromJson(json['location_details'])
          : null,
      partnerPreferences: json['partner_preferences'] != null
          ? PartnerPreferences.fromJson(json['partner_preferences'])
          : null,
      privacySettings: json['privacy_settings'] != null
          ? PrivacySettings.fromJson(json['privacy_settings'])
          : null,
      approvalStatus: json['approval_status']?.toString(),
      status: json['status']?.toString(),
      createdAt: json['created_at']?.toString(),
      connectionStatus: json['connection_status']?.toString(),
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }
}

class PersonalDetails {
  String? name;
  String? dob;
  String? annualIncome;
  String? occupation;
  String? profileCreatedBy;
  List<String> hobbies;
  String? language;
  String? citizenship;
  String? employmentType;
  String? familyType;
  String? maritalStatus;
  List<String> religion;
  List<String> starDetails;
  String? dosh;
  List<String> photos;

  PersonalDetails({
    this.name,
    this.dob,
    this.annualIncome,
    this.occupation,
    this.profileCreatedBy,
    List<String>? hobbies,
    this.language,
    this.citizenship,
    this.employmentType,
    this.familyType,
    this.maritalStatus,
    List<String>? religion,
    List<String>? starDetails,
    this.dosh,
    List<String>? photos,
  })  : hobbies = hobbies ?? [],
        religion = religion?.where((e) => e != null).map((e) => e.toString()).toList() ?? [],
        starDetails = starDetails?.where((e) => e != null).map((e) => e.toString()).toList() ?? [],
        photos = photos?.where((e) => e != null).map((e) => e.toString()).toList() ?? [];

  factory PersonalDetails.fromJson(Map<String, dynamic> json) {
    return PersonalDetails(
      name: json['name']?.toString(),
      dob: json['dob']?.toString(),
      annualIncome: json['annual_income']?.toString(),
      occupation: json['occupation']?.toString(),
      profileCreatedBy: json['profile_created_by']?.toString(),
      hobbies: json['hobbies'] != null
          ? List<String>.from(json['hobbies'].where((e) => e != null).map((e) => e.toString()))
          : [],
      language: json['language']?.toString(),
      citizenship: json['citizenship']?.toString(),
      employmentType: json['employment_type']?.toString(),
      familyType: json['family_type']?.toString(),
      maritalStatus: json['marital_status']?.toString(),
      religion: json['religion'] != null
          ? List<String>.from(json['religion'].where((e) => e != null).map((e) => e.toString()))
          : [],
      starDetails: json['star_details'] != null
          ? List<String>.from(json['star_details'].where((e) => e != null).map((e) => e.toString()))
          : [],
      dosh: json['dosh']?.toString(),
      photos: json['photos'] != null
          ? List<String>.from(json['photos'].where((e) => e != null).map((e) => e.toString()))
          : [],
    );
  }
}

// Same pattern apply karo baki classes ke liye:

class FamilyDetails {
  String? father;
  String? mother;
  String? familyClass;
  String? familyValue;

  FamilyDetails({this.father, this.mother, this.familyClass, this.familyValue});

  factory FamilyDetails.fromJson(Map<String, dynamic> json) => FamilyDetails(
    father: json['father']?.toString(),
    mother: json['mother']?.toString(),
    familyClass: json['family_class']?.toString(),
    familyValue: json['family_value']?.toString(),
  );
}

class EducationDetails {
  String? highestQualification;
  String? college;

  EducationDetails({this.highestQualification, this.college});

  factory EducationDetails.fromJson(Map<String, dynamic> json) => EducationDetails(
    highestQualification: json['highest_qualification']?.toString(),
    college: json['college']?.toString(),
  );
}

class ProfessionalDetails {
  String? jobTitle;
  String? company;

  ProfessionalDetails({this.jobTitle, this.company});

  factory ProfessionalDetails.fromJson(Map<String, dynamic> json) => ProfessionalDetails(
    jobTitle: json['job_title']?.toString(),
    company: json['company']?.toString(),
  );
}

class LifestyleDetails {
  String? diet;
  String? smoking;
  String? drinking;

  LifestyleDetails({this.diet, this.smoking, this.drinking});

  factory LifestyleDetails.fromJson(Map<String, dynamic> json) => LifestyleDetails(
    diet: json['diet']?.toString(),
    smoking: json['smoking']?.toString(),
    drinking: json['drinking']?.toString(),
  );
}

class LocationDetails {
  String? city;
  String? state;
  String? country;

  LocationDetails({this.city, this.state, this.country});

  factory LocationDetails.fromJson(Map<String, dynamic> json) => LocationDetails(
    city: json['city']?.toString(),
    state: json['state']?.toString(),
    country: json['country']?.toString(),
  );
}

class PartnerPreferences {
  String? ageRange;
  String? education;
  String? location;

  PartnerPreferences({this.ageRange, this.education, this.location});

  factory PartnerPreferences.fromJson(Map<String, dynamic> json) => PartnerPreferences(
    ageRange: json['age_range']?.toString(),
    education: json['education']?.toString(),
    location: json['location']?.toString(),
  );
}

class PrivacySettings {
  String? showPhotos;
  String? showContact;

  PrivacySettings({this.showPhotos, this.showContact});

  factory PrivacySettings.fromJson(Map<String, dynamic> json) => PrivacySettings(
    showPhotos: json['show_photos']?.toString(),
    showContact: json['show_contact']?.toString(),
  );
}
