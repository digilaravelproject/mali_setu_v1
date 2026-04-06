class ReqRegisterModel {
  String? name;
  String? email;
  String? dob;
  String? phone;
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
  String? password;
  String? passwordConfirmation;
  String? userType;
  String? castCertificate;
  bool? termCondition;
  String? company_name;
  String? dept_name;
  String? designation;
  double? latitude;
  double? longitude;

  ReqRegisterModel(
      {this.name,
      this.email,
      this.dob,
      this.phone,
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
      this.password,
      this.passwordConfirmation,
      this.userType,
      this.castCertificate,
      this.termCondition,
      this.company_name,
      this.dept_name,
      this.designation,
      this.latitude,
      this.longitude,
      });

  ReqRegisterModel.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    email = json['email'];
    dob = json['dob'];
    phone = json['phone'];
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
    password = json['password'];
    passwordConfirmation = json['password_confirmation'];
    userType = json['user_type'];
    castCertificate = json['cast_certificate'];
    termCondition = json['term_condition'];
    company_name = json['company_name'];
    dept_name = json['dept_name'];
    designation = json['designation'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['email'] = email;
    data['dob'] = dob;
    data['phone'] = phone;
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
    data['password'] = password;
    data['password_confirmation'] = passwordConfirmation;
    data['user_type'] = userType;
    data['cast_certificate'] = castCertificate;
    data['term_condition'] = termCondition;
    data['company_name'] = company_name;
    data['dept_name'] = dept_name;
    data['designation'] = designation;
    if (latitude != null) data['latitude'] = latitude;
    if (longitude != null) data['longitude'] = longitude;
    return data;
  }
}
