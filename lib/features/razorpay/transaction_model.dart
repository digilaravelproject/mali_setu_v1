class TransactionResponse {
  bool? success;
  TransactionData? data;

  TransactionResponse({this.success, this.data});

  TransactionResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null ? TransactionData.fromJson(json['data']) : null;
  }
}

class TransactionData {
  int? currentPage;
  List<TransactionItem>? data;
  String? firstPageUrl;
  int? from;
  int? lastPage;
  String? lastPageUrl;
  List<Links>? links;
  String? nextPageUrl;
  String? path;
  int? perPage;
  String? prevPageUrl;
  int? to;
  int? total;

  TransactionData(
      {this.currentPage,
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
      this.total});

  TransactionData.fromJson(Map<String, dynamic> json) {
    currentPage = json['current_page'];
    if (json['data'] != null) {
      data = <TransactionItem>[];
      json['data'].forEach((v) {
        data!.add(TransactionItem.fromJson(v));
      });
    }
    firstPageUrl = json['first_page_url'];
    from = json['from'];
    lastPage = json['last_page'];
    lastPageUrl = json['last_page_url'];
    if (json['links'] != null) {
      links = <Links>[];
      json['links'].forEach((v) {
        links!.add(Links.fromJson(v));
      });
    }
    nextPageUrl = json['next_page_url'];
    path = json['path'];
    perPage = json['per_page'];
    prevPageUrl = json['prev_page_url'];
    to = json['to'];
    total = json['total'];
  }
}

class TransactionItem {
  int? id;
  int? userId;
  String? amount;
  String? currency;
  String? purpose;
  String? razorpayPaymentId;
  String? razorpayOrderId;
  dynamic metadata;
  String? status;
  int? subscriptionPeriod;
  String? receiptUrl;
  String? createdAt;
  String? updatedAt;

  TransactionItem(
      {this.id,
      this.userId,
      this.amount,
      this.currency,
      this.purpose,
      this.razorpayPaymentId,
      this.razorpayOrderId,
      this.metadata,
      this.status,
      this.subscriptionPeriod,
      this.receiptUrl,
      this.createdAt,
      this.updatedAt});

  TransactionItem.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    amount = json['amount'];
    currency = json['currency'];
    purpose = json['purpose'];
    razorpayPaymentId = json['razorpay_payment_id'];
    razorpayOrderId = json['razorpay_order_id'];
    metadata = json['metadata'];
    status = json['status'];
    subscriptionPeriod = json['subscription_period'];
    receiptUrl = json['receipt_url'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }
}

class Links {
  String? url;
  String? label;
  bool? active;

  Links({this.url, this.label, this.active});

  Links.fromJson(Map<String, dynamic> json) {
    url = json['url'];
    label = json['label'];
    active = json['active'];
  }
}
