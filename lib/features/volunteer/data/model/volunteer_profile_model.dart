class VolunteerProfileResponse {
  bool? success;
  VolunteerProfileData? data;
  String? message;

  VolunteerProfileResponse({this.success, this.data, this.message});

  factory VolunteerProfileResponse.fromJson(Map<String, dynamic> json) {
    return VolunteerProfileResponse(
      success: json['success'],
      data: json['data'] != null ? VolunteerProfileData.fromJson(json['data']) : null,
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['message'] = message;
    return data;
  }
}

// Search response model for volunteer profiles
class VolunteerSearchResponse {
  bool? success;
  VolunteerSearchData? data;

  VolunteerSearchResponse({this.success, this.data});

  factory VolunteerSearchResponse.fromJson(Map<String, dynamic> json) {
    return VolunteerSearchResponse(
      success: json['success'],
      data: json['data'] != null ? VolunteerSearchData.fromJson(json['data']) : null,
    );
  }
}

class VolunteerSearchData {
  int? currentPage;
  List<VolunteerSearchProfile>? data;
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

  VolunteerSearchData({
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

  factory VolunteerSearchData.fromJson(Map<String, dynamic> json) {
    return VolunteerSearchData(
      currentPage: json['current_page'],
      data: json['data'] != null
          ? List<VolunteerSearchProfile>.from(json['data'].map((x) => VolunteerSearchProfile.fromJson(x)))
          : [],
      firstPageUrl: json['first_page_url'],
      from: json['from'],
      lastPage: json['last_page'],
      lastPageUrl: json['last_page_url'],
      nextPageUrl: json['next_page_url'],
      path: json['path'],
      perPage: json['per_page'],
      prevPageUrl: json['prev_page_url'],
      to: json['to'],
      total: json['total'],
    );
  }
}

class VolunteerSearchProfile {
  int? id;
  int? userId;
  String? skills;
  String? experience;
  String? availability;
  String? location;
  String? bio;
  List<String>? interests;
  String? status;
  String? createdAt;
  String? updatedAt;
  VolunteerUser? user;

  VolunteerSearchProfile({
    this.id,
    this.userId,
    this.skills,
    this.experience,
    this.availability,
    this.location,
    this.bio,
    this.interests,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.user,
  });

  factory VolunteerSearchProfile.fromJson(Map<String, dynamic> json) {
    return VolunteerSearchProfile(
      id: _asInt(json['id']),
      userId: _asInt(json['user_id']),
      skills: json['skills'],
      experience: json['experience'],
      availability: json['availability'],
      location: json['location'],
      bio: json['bio'],
      interests: json['interests'] != null ? List<String>.from(json['interests']) : [],
      status: json['status'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      user: json['user'] != null ? VolunteerUser.fromJson(json['user']) : null,
    );
  }
}

class VolunteerUser {
  int? id;
  String? googleId;
  String? name;
  String? email;
  String? photo;
  String? companyName;
  String? deptName;
  String? designation;
  String? otp;
  String? otpExpiresAt;
  String? phone;
  int? age;
  String? castCertificate;
  String? occupation;
  String? dob;
  String? reffralCode;
  String? address;
  String? nearbyLocation;
  String? pincode;
  String? roadNumber;
  String? state;
  String? city;
  String? sector;
  String? district;
  String? destination;
  String? userType;
  String? casteVerificationStatus;
  String? status;
  bool? blogAccess;
  String? adminNotes;
  String? emailVerifiedAt;
  String? createdAt;
  String? updatedAt;

  VolunteerUser({
    this.id,
    this.googleId,
    this.name,
    this.email,
    this.photo,
    this.companyName,
    this.deptName,
    this.designation,
    this.otp,
    this.otpExpiresAt,
    this.phone,
    this.age,
    this.castCertificate,
    this.occupation,
    this.dob,
    this.reffralCode,
    this.address,
    this.nearbyLocation,
    this.pincode,
    this.roadNumber,
    this.state,
    this.city,
    this.sector,
    this.district,
    this.destination,
    this.userType,
    this.casteVerificationStatus,
    this.status,
    this.blogAccess,
    this.adminNotes,
    this.emailVerifiedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory VolunteerUser.fromJson(Map<String, dynamic> json) {
    return VolunteerUser(
      id: _asInt(json['id']),
      googleId: json['google_id'],
      name: json['name'],
      email: json['email'],
      photo: json['photo'],
      companyName: json['company_name'],
      deptName: json['dept_name'],
      designation: json['designation'],
      otp: json['otp'],
      otpExpiresAt: json['otp_expires_at'],
      phone: json['phone'],
      age: _asInt(json['age']),
      castCertificate: json['cast_certificate'],
      occupation: json['occupation'],
      dob: json['dob'],
      reffralCode: json['reffral_code'],
      address: json['address'],
      nearbyLocation: json['nearby_location'],
      pincode: json['pincode'],
      roadNumber: json['road_number'],
      state: json['state'],
      city: json['city'],
      sector: json['sector'],
      district: json['district'],
      destination: json['destination'],
      userType: json['user_type'],
      casteVerificationStatus: json['caste_verification_status'],
      status: json['status'],
      blogAccess: json['blog_access'],
      adminNotes: json['admin_notes'],
      emailVerifiedAt: json['email_verified_at'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}

class VolunteerProfileData {
  int? id;
  int? userId;
  String? skills;
  String? experience;
  String? availability;
  String? location;
  String? bio;
  List<String>? interests;
  String? status;
  String? createdAt;
  String? updatedAt;

  VolunteerProfileData({
    this.id,
    this.userId,
    this.skills,
    this.experience,
    this.availability,
    this.location,
    this.bio,
    this.interests,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory VolunteerProfileData.fromJson(Map<String, dynamic> json) {
    return VolunteerProfileData(
      id: _asInt(json['id']),
      userId: _asInt(json['user_id']),
      skills: json['skills'],
      experience: json['experience'],
      availability: json['availability'],
      location: json['location'],
      bio: json['bio'],
      interests: json['interests'] != null ? List<String>.from(json['interests']) : [],
      status: json['status'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['user_id'] = userId;
    data['skills'] = skills;
    data['experience'] = experience;
    data['availability'] = availability;
    data['location'] = location;
    data['bio'] = bio;
    data['interests'] = interests;
    data['status'] = status;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}

int? _asInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}
