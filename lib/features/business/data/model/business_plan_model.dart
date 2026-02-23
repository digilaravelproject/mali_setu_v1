class BusinessPlanResponse {
  bool? success;
  BusinessPlanData? data;

  BusinessPlanResponse({this.success, this.data});

  BusinessPlanResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null ? BusinessPlanData.fromJson(json['data']) : null;
  }
}

class BusinessPlanData {
  List<BusinessPlan>? plans;

  BusinessPlanData({this.plans});

  BusinessPlanData.fromJson(Map<String, dynamic> json) {
    if (json['plans'] != null) {
      plans = <BusinessPlan>[];
      json['plans'].forEach((v) {
        plans!.add(BusinessPlan.fromJson(v));
      });
    }
  }
}

class BusinessPlan {
  int? id;
  String? companyType;
  int? durationYears;
  String? price;
  bool? active;
  String? createdAt;
  String? updatedAt;

  BusinessPlan(
      {this.id,
      this.companyType,
      this.durationYears,
      this.price,
      this.active,
      this.createdAt,
      this.updatedAt});

  BusinessPlan.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    companyType = json['company_type'];
    durationYears = json['duration_years'];
    price = json['price'];
    active = json['active'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }
}
