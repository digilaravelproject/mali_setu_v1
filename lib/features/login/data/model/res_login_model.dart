//
//
// // login_response_model.dart
//
// class LoginResponse {
//   final bool success;
//   final String message;
//   final LoginData? data;
//
//   LoginResponse({
//     required this.success,
//     required this.message,
//     this.data,
//   });
//
//   factory LoginResponse.fromJson(Map<String, dynamic> json) {
//     return LoginResponse(
//       success: json['success'] ?? false,
//       message: json['message'] ?? '',
//       data: json['data'] != null ? LoginData.fromJson(json['data']) : null,
//     );
//   }
// }
//
//
// class LoginData {
//   final User? user;
//   final String token;
//   final String tokenType;
//
//   LoginData({
//     this.user,
//     required this.token,
//     required this.tokenType,
//   });
//
//   factory LoginData.fromJson(Map<String, dynamic> json) {
//     return LoginData(
//       user: json['user'] != null ? User.fromJson(json['user']) : null,
//       token: json['token'] ?? '',
//       tokenType: json['token_type'] ?? '',
//     );
//   }
// }
//
//
// class User {
//   final int id;
//   final String name;
//   final String email;
//   final String phone;
//   final int age;
//
//   final String otp;
//   final String otpExpiresAt;
//   final String castCertificate;
//   final String occupation;
//   final String reffralCode;
//   final String address;
//   final String nearbyLocation;
//   final String pincode;
//   final String roadNumber;
//   final String state;
//   final String city;
//   final String sector;
//   final String district;
//   final String destination;
//   final String userType;
//   final String casteVerificationStatus;
//   final String status;
//
//   final String? adminNotes;
//   final String? emailVerifiedAt;
//
//   final String createdAt;
//   final String updatedAt;
//
//   User({
//     required this.id,
//     required this.name,
//     required this.email,
//     required this.phone,
//     required this.age,
//     required this.otp,
//     required this.otpExpiresAt,
//     required this.castCertificate,
//     required this.occupation,
//     required this.reffralCode,
//     required this.address,
//     required this.nearbyLocation,
//     required this.pincode,
//     required this.roadNumber,
//     required this.state,
//     required this.city,
//     required this.sector,
//     required this.district,
//     required this.destination,
//     required this.userType,
//     required this.casteVerificationStatus,
//     required this.status,
//     this.adminNotes,
//     this.emailVerifiedAt,
//     required this.createdAt,
//     required this.updatedAt,
//   });
//
//   factory User.fromJson(Map<String, dynamic> json) {
//     return User(
//       id: json['id'] ?? 0,
//       name: json['name'] ?? '',
//       email: json['email'] ?? '',
//       phone: json['phone'] ?? '',
//       age: json['age'] ?? 0,
//       otp: json['otp'] ?? '',
//       otpExpiresAt: json['otp_expires_at'] ?? '',
//       castCertificate: json['cast_certificate'] ?? '',
//       occupation: json['occupation'] ?? '',
//       reffralCode: json['reffral_code'] ?? '',
//       address: json['address'] ?? '',
//       nearbyLocation: json['nearby_location'] ?? '',
//       pincode: json['pincode'] ?? '',
//       roadNumber: json['road_number'] ?? '',
//       state: json['state'] ?? '',
//       city: json['city'] ?? '',
//       sector: json['sector'] ?? '',
//       district: json['district'] ?? '',
//       destination: json['destination'] ?? '',
//       userType: json['user_type'] ?? '',
//       casteVerificationStatus: json['caste_verification_status'] ?? '',
//       status: json['status'] ?? '',
//       adminNotes: json['admin_notes'],
//       emailVerifiedAt: json['email_verified_at'],
//       createdAt: json['created_at'] ?? '',
//       updatedAt: json['updated_at'] ?? '',
//     );
//   }
// }
//





class LoginResponse {
  final bool success;
  final String message;
  final LoginData data; // 👈 nullable hata diya

  LoginResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: LoginData.fromJson(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
    'success': success,
    'message': message,
    'data': data.toJson(),
  };
}



class LoginData {
  final User user;
  final String token;
  final String tokenType;

  LoginData({
    required this.user,
    required this.token,
    required this.tokenType,
  });

  factory LoginData.fromJson(Map<String, dynamic> json) {
    return LoginData(
      user: User.fromJson(json['user'] ?? {}),
      token: json['token'] ?? '',
      tokenType: json['token_type'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'user': user.toJson(),
    'token': token,
    'token_type': tokenType,
  };
}


class User {
  final int id;
  final String name;
  final String email;
  final String phone;
  final int age;
  final String otp;
  final String otpExpiresAt;
  final String castCertificate;
  final String occupation;
  final String reffralCode;
  final String address;
  final String nearbyLocation;
  final String pincode;
  final String roadNumber;
  final String state;
  final String city;
  final String sector;
  final String district;
  final String destination;
  final String userType;
  final String casteVerificationStatus;
  final String status;
  final String? adminNotes;
  final String? emailVerifiedAt;
  final String createdAt;
  final String updatedAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.age,
    required this.otp,
    required this.otpExpiresAt,
    required this.castCertificate,
    required this.occupation,
    required this.reffralCode,
    required this.address,
    required this.nearbyLocation,
    required this.pincode,
    required this.roadNumber,
    required this.state,
    required this.city,
    required this.sector,
    required this.district,
    required this.destination,
    required this.userType,
    required this.casteVerificationStatus,
    required this.status,
    this.adminNotes,
    this.emailVerifiedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      age: json['age'] ?? 0,
      otp: json['otp'] ?? '',
      otpExpiresAt: json['otp_expires_at'] ?? '',
      castCertificate: json['cast_certificate'] ?? '',
      occupation: json['occupation'] ?? '',
      reffralCode: json['reffral_code'] ?? '',
      address: json['address'] ?? '',
      nearbyLocation: json['nearby_location'] ?? '',
      pincode: json['pincode'] ?? '',
      roadNumber: json['road_number'] ?? '',
      state: json['state'] ?? '',
      city: json['city'] ?? '',
      sector: json['sector'] ?? '',
      district: json['district'] ?? '',
      destination: json['destination'] ?? '',
      userType: json['user_type'] ?? '',
      casteVerificationStatus: json['caste_verification_status'] ?? '',
      status: json['status'] ?? '',
      adminNotes: json['admin_notes'],
      emailVerifiedAt: json['email_verified_at'],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'phone': phone,
    'age': age,
    'otp': otp,
    'otp_expires_at': otpExpiresAt,
    'cast_certificate': castCertificate,
    'occupation': occupation,
    'reffral_code': reffralCode,
    'address': address,
    'nearby_location': nearbyLocation,
    'pincode': pincode,
    'road_number': roadNumber,
    'state': state,
    'city': city,
    'sector': sector,
    'district': district,
    'destination': destination,
    'user_type': userType,
    'caste_verification_status': casteVerificationStatus,
    'status': status,
    'admin_notes': adminNotes,
    'email_verified_at': emailVerifiedAt,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };
}
