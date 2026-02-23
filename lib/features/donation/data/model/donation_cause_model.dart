class DonationCauseResponse {
  bool? success;
  DonationCauseData? data;

  DonationCauseResponse({this.success, this.data});

  DonationCauseResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null ? DonationCauseData.fromJson(json['data']) : null;
  }
}

class DonationCauseData {
  int? currentPage;
  List<DonationCauseItem>? data;
  String? firstPageUrl;
  int? from;
  int? lastPage;
  String? lastPageUrl;
  List<dynamic>? links;
  String? nextPageUrl;
  String? path;
  int? perPage;
  String? prevPageUrl;
  int? to;
  int? total;

  DonationCauseData({
    this.currentPage,
    this.data,
    this.firstPageUrl,
    this.from,
    this.lastPage,
    this.lastPageUrl,
    this.links,
    this.nextPageUrl,
    this.path,
    this.perPage,
    this.prevPageUrl,
    this.to,
    this.total,
  });

  DonationCauseData.fromJson(Map<String, dynamic> json) {
    currentPage = json['current_page'];
    if (json['data'] != null) {
      data = <DonationCauseItem>[];
      json['data'].forEach((v) {
        data!.add(DonationCauseItem.fromJson(v));
      });
    }
    firstPageUrl = json['first_page_url'];
    from = json['from'];
    lastPage = json['last_page'];
    lastPageUrl = json['last_page_url'];
    links = json['links'];
    nextPageUrl = json['next_page_url'];
    path = json['path'];
    perPage = json['per_page'];
    prevPageUrl = json['prev_page_url'];
    to = json['to'];
    total = json['total'];
  }
}

class DonationCauseItem {
  int? id;
  String? title;
  String? description;
  String? category;
  String? targetAmount;
  String? raisedAmount;
  String? urgency;
  String? location;
  String? organization;
  String? contactInfo;
  String? imageUrl;
  String? startDate;
  String? endDate;
  String? status;
  String? createdAt;
  String? updatedAt;
  int? donationsCount;
  List<DonationDetail>? donations;

  DonationCauseItem({
    this.id,
    this.title,
    this.description,
    this.category,
    this.targetAmount,
    this.raisedAmount,
    this.urgency,
    this.location,
    this.organization,
    this.contactInfo,
    this.imageUrl,
    this.startDate,
    this.endDate,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.donationsCount,
    this.donations,
  });

  DonationCauseItem.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title']?.toString();
    description = json['description']?.toString();
    category = json['category']?.toString();
    targetAmount = json['target_amount']?.toString();
    raisedAmount = json['raised_amount']?.toString();
    urgency = json['urgency']?.toString();
    location = json['location']?.toString();
    organization = json['organization']?.toString();
    contactInfo = json['contact_info']?.toString();
    imageUrl = json['image_url']?.toString();
    startDate = json['start_date']?.toString();
    endDate = json['end_date']?.toString();
    status = json['status']?.toString();
    createdAt = json['created_at']?.toString();
    updatedAt = json['updated_at']?.toString();
    donationsCount = json['donations_count'];
    if (json['donations'] != null) {
      donations = <DonationDetail>[];
      json['donations'].forEach((v) {
        donations!.add(DonationDetail.fromJson(v));
      });
    }
  }
}

class DonationDetail {
  int? id;
  int? userId;
  int? causeId;
  String? amount;
  String? currency;
  String? paymentMethod;
  String? razorpayPaymentId;
  String? razorpayOrderId;
  String? status;
  String? receiptUrl;
  String? message;
  bool? anonymous;
  String? createdAt;
  String? updatedAt;

  DonationDetail({
    this.id,
    this.userId,
    this.causeId,
    this.amount,
    this.currency,
    this.paymentMethod,
    this.razorpayPaymentId,
    this.razorpayOrderId,
    this.status,
    this.receiptUrl,
    this.message,
    this.anonymous,
    this.createdAt,
    this.updatedAt,
  });

  DonationDetail.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    causeId = json['cause_id'];
    amount = json['amount']?.toString();
    currency = json['currency']?.toString();
    paymentMethod = json['payment_method']?.toString();
    razorpayPaymentId = json['razorpay_payment_id']?.toString();
    razorpayOrderId = json['razorpay_order_id']?.toString();
    status = json['status']?.toString();
    receiptUrl = json['receipt_url']?.toString();
    message = json['message']?.toString();
    anonymous = json['anonymous'];
    createdAt = json['created_at']?.toString();
    updatedAt = json['updated_at']?.toString();
  }
}
