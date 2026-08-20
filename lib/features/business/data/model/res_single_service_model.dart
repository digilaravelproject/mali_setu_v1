import 'res_all_business_model.dart';

class SingleServiceResponse {
  final bool? success;
  final String? message;
  final Service? service;

  SingleServiceResponse({this.success, this.message, this.service});

  factory SingleServiceResponse.fromJson(Map<String, dynamic> json) {
    return SingleServiceResponse(
      success: json['success'],
      message: json['message'],
      service: json['data'] != null && json['data']['service'] != null
          ? Service.fromJson(json['data']['service'])
          : null,
    );
  }
}
