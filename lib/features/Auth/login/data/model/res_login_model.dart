// class ResLoginModel {
//   bool? success;
//   String? message;
//   LoginData? data;
//
//   ResLoginModel({this.success, this.message, this.data});
//
//   ResLoginModel.fromJson(Map<String, dynamic> json) {
//     success = json['success'];
//     message = json['message'];
//     data = json['data'] != null ? LoginData.fromJson(json['data']) : null;
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['success'] = success;
//     data['message'] = message;
//     if (this.data != null) {
//       data['data'] = this.data!.toJson();
//     }
//     return data;
//   }
// }

class ResLoginModel {
  bool? success;
  String? message;
  LoginData? data;

  ResLoginModel({this.success, this.message, this.data});

  ResLoginModel.fromJson(Map<String, dynamic> json) {
    // Handle both: success OR status
    if (json.containsKey('success')) {
      success = _parseBool(json['success']);
    } else if (json.containsKey('status')) {
      success = _parseBool(json['status']);
    }

    message = json['message'];
    data = json['data'] != null ? LoginData.fromJson(json['data']) : null;
  }

  bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) {
      return value.toLowerCase() == 'true' ||
          value.toLowerCase() == 'success';
    }
    return false;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class LoginData {
  User? user;
  String? token;
  String? tokenType;

  LoginData({this.user, this.token, this.tokenType});

  LoginData.fromJson(Map<String, dynamic> json) {
    user = json['user'] != null ? User.fromJson(json['user']) : null;
    token = json['token'];
    tokenType = json['token_type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (user != null) {
      data['user'] = user!.toJson();
    }
    data['token'] = token;
    data['token_type'] = tokenType;
    return data;
  }
}

class User {
  int? id;

  String? googleId; // 🆕 ADDED

  String? name;
  String? email;

  String? companyName; // 🆕 ADDED
  String? deptName; // 🆕 ADDED
  String? designation; // 🆕 ADDED

  String? otp;
  String? otpExpiresAt;
  String? phone;
  int? age;

  String? dob; // 🆕 ADDED (yyyy-MM-dd HH:mm:ss)

  String? castCertificate;
  String? occupation;
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
  String? profileImage;
  bool? hasPayment;
  bool? isMatrimony;
  String? paymentPurpose;

  User({
    this.id,

    this.googleId,

    this.name,
    this.email,

    this.companyName,
    this.deptName,
    this.designation,

    this.otp,
    this.otpExpiresAt,
    this.phone,
    this.age,

    this.dob,

    this.castCertificate,
    this.occupation,
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
    this.profileImage,
    this.hasPayment,
    this.isMatrimony,
    this.paymentPurpose,
  });

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];

    googleId = json['google_id']; // 🆕

    name = json['name'];
    email = json['email'];

    companyName = json['company_name']; // 🆕
    deptName = json['dept_name']; // 🆕
    designation = json['designation']; // 🆕

    otp = json['otp'];
    otpExpiresAt = json['otp_expires_at'];
    phone = json['phone'];
    age = json['age'];

    dob = json['dob']; // 🆕

    castCertificate = json['cast_certificate'];
    occupation = json['occupation'];
    reffralCode = json['reffral_code'];
    address = json['address'];
    nearbyLocation = json['nearby_location'];
    pincode = json['pincode'];
    roadNumber = json['road_number'];
    state = json['state'];
    city = json['city'];
    sector = json['sector'];
    district = json['district'];
    destination = json['destination'];
    userType = json['user_type'];
    casteVerificationStatus = json['caste_verification_status'];
    status = json['status'];
    blogAccess = json['blog_access'];
    adminNotes = json['admin_notes'];
    emailVerifiedAt = json['email_verified_at'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    // Handle both 'profile_image' and 'photo' fields
    profileImage = json['profile_image'] ?? json['photo'];
    hasPayment = json['has_payment'];
    isMatrimony = json['is_matrimony'];
    paymentPurpose = json['payment_purpose'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;

    data['google_id'] = googleId;

    data['name'] = name;
    data['email'] = email;

    data['company_name'] = companyName;
    data['dept_name'] = deptName;
    data['designation'] = designation;

    data['otp'] = otp;
    data['otp_expires_at'] = otpExpiresAt;
    data['phone'] = phone;
    data['age'] = age;

    data['dob'] = dob;

    data['cast_certificate'] = castCertificate;
    data['occupation'] = occupation;
    data['reffral_code'] = reffralCode;
    data['address'] = address;
    data['nearby_location'] = nearbyLocation;
    data['pincode'] = pincode;
    data['road_number'] = roadNumber;
    data['state'] = state;
    data['city'] = city;
    data['sector'] = sector;
    data['district'] = district;
    data['destination'] = destination;
    data['user_type'] = userType;
    data['caste_verification_status'] = casteVerificationStatus;
    data['status'] = status;
    data['blog_access'] = blogAccess;
    data['admin_notes'] = adminNotes;
    data['email_verified_at'] = emailVerifiedAt;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['profile_image'] = profileImage;
    data['has_payment'] = hasPayment;
    data['is_matrimony'] = isMatrimony;
    data['payment_purpose'] = paymentPurpose;
    return data;
  }
}
