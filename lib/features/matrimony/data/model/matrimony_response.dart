class MatrimonyResponse {
  bool? success;
  String? message;
  Map<String, dynamic>? data;

  MatrimonyResponse({this.success, this.message, this.data});

  factory MatrimonyResponse.fromJson(Map<String, dynamic> json) {
    return MatrimonyResponse(
      success: json['success'],
      message: json['message'],
      data: json['data'],
    );
  }
}
