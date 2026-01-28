class ResResetPasswordModel {
  bool? success;
  String? message;
  User? user; // directly user, no nested data object

  ResResetPasswordModel({this.success, this.message, this.user});

  factory ResResetPasswordModel.fromJson(Map<String, dynamic> json) {
    return ResResetPasswordModel(
      success: json['success'],
      message: json['message'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['success'] = success;
    data['message'] = message;
    if (user != null) {
      data['user'] = user!.toJson();
    }
    return data;
  }
}

class User {
  int? id;
  String? name;
  String? email;
  String? otp;
  String? otpExpiresAt;
  String? phone;
  int? age;
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
  String? adminNotes;
  String? emailVerifiedAt;
  String? createdAt;
  String? updatedAt;

  User({
    this.id,
    this.name,
    this.email,
    this.otp,
    this.otpExpiresAt,
    this.phone,
    this.age,
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
    this.adminNotes,
    this.emailVerifiedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      otp: json['otp'],
      otpExpiresAt: json['otp_expires_at'],
      phone: json['phone'],
      age: json['age'],
      castCertificate: json['cast_certificate'],
      occupation: json['occupation'],
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
      adminNotes: json['admin_notes'],
      emailVerifiedAt: json['email_verified_at'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['id'] = id;
    data['name'] = name;
    data['email'] = email;
    data['otp'] = otp;
    data['otp_expires_at'] = otpExpiresAt;
    data['phone'] = phone;
    data['age'] = age;
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
    data['admin_notes'] = adminNotes;
    data['email_verified_at'] = emailVerifiedAt;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}
