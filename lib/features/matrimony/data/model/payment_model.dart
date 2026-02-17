class CreateOrderResponse {
  bool? success;
  String? message;
  OrderData? data;

  CreateOrderResponse({this.success, this.message, this.data});

  factory CreateOrderResponse.fromJson(Map<String, dynamic> json) {
    return CreateOrderResponse(
      success: json['success'],
      message: json['message'],
      data: json['data'] != null ? OrderData.fromJson(json['data']) : null,
    );
  }
}

class OrderData {
  String? orderId;
  int? amount;
  String? currency;
  int? transactionId;
  String? keyId;

  OrderData({
    this.orderId,
    this.amount,
    this.currency,
    this.transactionId,
    this.keyId,
  });

  factory OrderData.fromJson(Map<String, dynamic> json) {
    return OrderData(
      orderId: json['order_id'],
      amount: json['amount'],
      currency: json['currency'],
      transactionId: json['transaction_id'],
      keyId: json['key_id'],
    );
  }
}

class VerifyPaymentRequest {
  String? razorpayPaymentId;
  String? razorpayOrderId;
  String? razorpaySignature;
  String? transactionId;

  VerifyPaymentRequest({
    this.razorpayPaymentId,
    this.razorpayOrderId,
    this.razorpaySignature,
    this.transactionId,
  });

  Map<String, dynamic> toJson() {
    return {
      'razorpay_payment_id': razorpayPaymentId,
      'razorpay_order_id': razorpayOrderId,
      'razorpay_signature': razorpaySignature,
      'transaction_id': transactionId,
    };
  }
}

class VerifyPaymentResponse {
  bool? success;
  String? message;
  dynamic data;

  VerifyPaymentResponse({this.success, this.message, this.data});

  factory VerifyPaymentResponse.fromJson(Map<String, dynamic> json) {
    return VerifyPaymentResponse(
      success: json['success'],
      message: json['message'],
      data: json['data'],
    );
  }
}
