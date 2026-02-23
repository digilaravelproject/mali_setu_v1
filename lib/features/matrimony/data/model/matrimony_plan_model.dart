class MatrimonyPlanResponse {
  bool? success;
  MatrimonyPlanData? data;

  MatrimonyPlanResponse({this.success, this.data});

  MatrimonyPlanResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null ? MatrimonyPlanData.fromJson(json['data']) : null;
  }
}

class MatrimonyPlanData {
  List<MatrimonyPlan>? plans;

  MatrimonyPlanData({this.plans});

  MatrimonyPlanData.fromJson(Map<String, dynamic> json) {
    if (json['plans'] != null) {
      plans = <MatrimonyPlan>[];
      json['plans'].forEach((v) {
        plans!.add(MatrimonyPlan.fromJson(v));
      });
    }
  }
}

class MatrimonyPlan {
  int? id;
  String? planName;
  int? durationYears;
  String? price;
  bool? active;
  String? createdAt;
  String? updatedAt;

  MatrimonyPlan({
    this.id,
    this.planName,
    this.durationYears,
    this.price,
    this.active,
    this.createdAt,
    this.updatedAt,
  });

  MatrimonyPlan.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    planName = json['plan_name'];
    durationYears = json['duration_years'];
    price = json['price'];
    active = json['active'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }
}
