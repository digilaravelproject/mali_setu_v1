import 'res_all_business_model.dart';

class SingleProductResponse {
  final bool? success;
  final String? message;
  final Product? product;

  SingleProductResponse({this.success, this.message, this.product});

  factory SingleProductResponse.fromJson(Map<String, dynamic> json) {
    return SingleProductResponse(
      success: json['success'],
      message: json['message'],
      product: json['data'] != null && json['data']['product'] != null
          ? Product.fromJson(json['data']['product'])
          : null,
    );
  }
}
