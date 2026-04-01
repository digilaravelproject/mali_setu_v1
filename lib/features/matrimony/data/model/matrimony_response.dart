class MatrimonyResponse {
  bool? success;
  String? message;
  Map<String, dynamic>? data;
  Map<String, dynamic>? errors;

  MatrimonyResponse({this.success, this.message, this.data,this.errors});

  factory MatrimonyResponse.fromJson(Map<String, dynamic> json) {
    return MatrimonyResponse(
      success: json['success'],
      message: json['message'],
      data: json['data'],
      errors: json['errors'],
    );
  }
}
