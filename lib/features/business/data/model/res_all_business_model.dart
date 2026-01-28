class BusinessResponse {
  bool? success;
  BusinessData? data;

  BusinessResponse({this.success, this.data});

  factory BusinessResponse.fromJson(Map<String, dynamic> json) {
    return BusinessResponse(
      success: json['success'],
      data: json['data'] != null ? BusinessData.fromJson(json['data']) : null,
    );
  }
}

class BusinessData {
  int? currentPage;
  List<Business>? data;
  int? total;

  BusinessData({this.currentPage, this.data, this.total});

  factory BusinessData.fromJson(Map<String, dynamic> json) {
    return BusinessData(
      currentPage: json['current_page'],
      data: json['data'] != null
          ? List<Business>.from(
          json['data'].map((x) => Business.fromJson(x)))
          : [],
      total: json['total'],
    );
  }
}

class Business {
  int? id;
  String? businessName;
  String? businessType;
  String? description;
  String? contactPhone;
  String? contactEmail;
  String? website;
  String? verificationStatus;
  String? subscriptionStatus;
  String? status;
  User? user;
  Category? category;

  Business({
    this.id,
    this.businessName,
    this.businessType,
    this.description,
    this.contactPhone,
    this.contactEmail,
    this.website,
    this.verificationStatus,
    this.subscriptionStatus,
    this.status,
    this.user,
    this.category,
  });

  factory Business.fromJson(Map<String, dynamic> json) {
    return Business(
      id: json['id'],
      businessName: json['business_name'],
      businessType: json['business_type'],
      description: json['description'],
      contactPhone: json['contact_phone'],
      contactEmail: json['contact_email'],
      website: json['website'],
      verificationStatus: json['verification_status'],
      subscriptionStatus: json['subscription_status'],
      status: json['status'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      category:
      json['category'] != null ? Category.fromJson(json['category']) : null,
    );
  }
}

class User {
  int? id;
  String? name;
  String? email;
  String? phone;

  User({this.id, this.name, this.email, this.phone});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
    );
  }
}

class Category {
  int? id;
  String? name;

  Category({this.id, this.name});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
    );
  }
}

