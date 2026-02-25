class ResRegisterModel {
  bool? success;
  dynamic message;
  Map<String, dynamic>? errors;
  Data? data;

  ResRegisterModel({this.success, this.message, this.errors, this.data});

  ResRegisterModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    errors = json['errors'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  String? get messageString {
    if (errors != null && errors!.isNotEmpty) {
      // Aggregate all errors into a single string
      List<String> allErrors = [];
      errors!.forEach((key, value) {
        if (value is List) {
          allErrors.addAll(value.map((e) => e.toString()));
        } else {
          allErrors.add(value.toString());
        }
      });
      return allErrors.join("\n");
    }
    
    if (message == null) return null;
    if (message is String) return message;
    if (message is Map) {
      final messagesMap = message as Map;
      if (messagesMap.isNotEmpty) {
        final firstValue = messagesMap.values.first;
        if (firstValue is List && firstValue.isNotEmpty) {
          return firstValue.first.toString();
        }
        return firstValue.toString();
      }
    }
    return message.toString();
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

class Data {
  User? user;
  String? token;
  String? tokenType;

  Data({this.user, this.token, this.tokenType});

  Data.fromJson(Map<String, dynamic> json) {
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
  String? name;
  String? email;
  String? phone;
  int? age;
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
  String? castCertificate;
  String? userType;
  String? casteVerificationStatus;
  String? updatedAt;
  String? createdAt;
  int? id;

  User(
      {this.name,
      this.email,
      this.phone,
      this.age,
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
      this.castCertificate,
      this.userType,
      this.casteVerificationStatus,
      this.updatedAt,
      this.createdAt,
      this.id});

  User.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    email = json['email'];
    phone = json['phone'];
    age = json['age'];
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
    castCertificate = json['cast_certificate'];
    userType = json['user_type'];
    casteVerificationStatus = json['caste_verification_status'];
    updatedAt = json['updated_at'];
    createdAt = json['created_at'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['email'] = email;
    data['phone'] = phone;
    data['age'] = age;
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
    data['cast_certificate'] = castCertificate;
    data['user_type'] = userType;
    data['caste_verification_status'] = casteVerificationStatus;
    data['updated_at'] = updatedAt;
    data['created_at'] = createdAt;
    data['id'] = id;
    return data;
  }
}
