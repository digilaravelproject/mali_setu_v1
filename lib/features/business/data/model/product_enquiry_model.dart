class ProductEnquiryRequest {
  final int? productId;
  final int? serviceId;
  final double price;
  final String description;

  ProductEnquiryRequest({
    this.productId,
    this.serviceId,
    required this.price,
    required this.description,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'price': price,
      'description': description,
    };
    if (productId != null) {
      map['product_id'] = productId;
    }
    if (serviceId != null) {
      map['service_id'] = serviceId;
    }
    return map;
  }
}

class ProductEnquiryResponse {
  final bool success;
  final String? message;
  final dynamic data;

  ProductEnquiryResponse({
    required this.success,
    this.message,
    this.data,
  });

  factory ProductEnquiryResponse.fromJson(Map<String, dynamic> json) {
    return ProductEnquiryResponse(
      success: json['success'] == true ||
          json['success'] == 1 ||
          json['status'] == true ||
          json['status'] == 'success',
      message: json['message']?.toString(),
      data: json['data'],
    );
  }
}
