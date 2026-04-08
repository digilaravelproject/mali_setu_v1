class ResBusinessCategoryModel {
  bool? success;
  String? message;
  List<CatBusiness>? businesses;

  ResBusinessCategoryModel({this.success, this.message, this.businesses});

  ResBusinessCategoryModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    if (json['data'] != null && json['data']['businesses'] != null) {
      businesses = List<CatBusiness>.from(
          json['data']['businesses'].map((x) => CatBusiness.fromJson(x)));
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['success'] = success;
    data['message'] = message;
    if (businesses != null) {
      data['data'] = {
        'businesses': businesses!.map((e) => e.toJson()).toList()
      };
    }
    return data;
  }
}

class CatBusiness {
  int? id;
  int? userId;
  int? KMfromuser;
  String? businessName;
  String? businessType;
  int? categoryId;
  String? description;
  String? contactPhone;
  String? contactEmail;
  String? website;
  String? verificationStatus;
  String? status;
  User? user;
  Category? category;
  List<Product>? products;
  List<Service>? services;
  List<Review>? reviews;

  CatBusiness({
    this.id,
    this.userId,
    this.KMfromuser,
    this.businessName,
    this.businessType,
    this.categoryId,
    this.description,
    this.contactPhone,
    this.contactEmail,
    this.website,
    this.verificationStatus,
    this.status,
    this.user,
    this.category,
    this.products,
    this.services,
    this.reviews,
  });

  CatBusiness.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    KMfromuser = json['KMfromuser'];
    businessName = json['business_name'];
    businessType = json['business_type'];
    categoryId = json['category_id'];
    description = json['description'];
    contactPhone = json['contact_phone'];
    contactEmail = json['contact_email'];
    website = json['website'];
    verificationStatus = json['verification_status'];
    status = json['status'];
    user = json['user'] != null ? User.fromJson(json['user']) : null;
    category = json['category'] != null ? Category.fromJson(json['category']) : null;
    if (json['products'] != null) {
      products = List<Product>.from(
          json['products'].map((x) => Product.fromJson(x)));
    }
    if (json['services'] != null) {
      services = List<Service>.from(
          json['services'].map((x) => Service.fromJson(x)));
    }
    if (json['reviews'] != null) {
      reviews = List<Review>.from(
          json['reviews'].map((x) => Review.fromJson(x)));
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['user_id'] = userId;
    data['KMfromuser'] = KMfromuser;
    data['business_name'] = businessName;
    data['business_type'] = businessType;
    data['category_id'] = categoryId;
    data['description'] = description;
    data['contact_phone'] = contactPhone;
    data['contact_email'] = contactEmail;
    data['website'] = website;
    data['verification_status'] = verificationStatus;
    data['status'] = status;
    if (user != null) data['user'] = user!.toJson();
    if (category != null) data['category'] = category!.toJson();
    if (products != null) data['products'] = products!.map((e) => e.toJson()).toList();
    if (services != null) data['services'] = services!.map((e) => e.toJson()).toList();
    if (reviews != null) data['reviews'] = reviews!.map((e) => e.toJson()).toList();
    return data;
  }
}

class User {
  int? id;
  String? name;
  String? email;
  String? phone;
  int? age;
  String? occupation;
  String? address;
  String? state;
  String? city;

  User({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.age,
    this.occupation,
    this.address,
    this.state,
    this.city,
  });

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    phone = json['phone'];
    age = json['age'];
    occupation = json['occupation'];
    address = json['address'];
    state = json['state'];
    city = json['city'];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'age': age,
      'occupation': occupation,
      'address': address,
      'state': state,
      'city': city,
    };
  }
}

class Category {
  int? id;
  String? name;
  String? description;
  String? photo;

  Category({this.id, this.name, this.description, this.photo});

  Category.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    description = json['description'];
    photo = json['photo'];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'photo': photo,
    };
  }
}

class Product {
  int? id;
  int? businessId;
  String? name;
  String? description;
  String? cost;
  String? status;

  Product({
    this.id,
    this.businessId,
    this.name,
    this.description,
    this.cost,
    this.status,
  });

  Product.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    businessId = json['business_id'];
    name = json['name'];
    description = json['description'];
    cost = json['cost'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'business_id': businessId,
      'name': name,
      'description': description,
      'cost': cost,
      'status': status,
    };
  }
}

class Service {
  int? id;
  int? businessId;
  String? name;
  String? description;
  String? cost;
  String? status;

  Service({
    this.id,
    this.businessId,
    this.name,
    this.description,
    this.cost,
    this.status,
  });

  Service.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    businessId = json['business_id'];
    name = json['name'];
    description = json['description'];
    cost = json['cost'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'business_id': businessId,
      'name': name,
      'description': description,
      'cost': cost,
      'status': status,
    };
  }
}

class Review {
  int? id;
  int? businessId;
  String? comment;
  int? rating;

  Review({this.id, this.businessId, this.comment, this.rating});

  Review.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    businessId = json['business_id'];
    comment = json['comment'];
    rating = json['rating'];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'business_id': businessId,
      'comment': comment,
      'rating': rating,
    };
  }
}
