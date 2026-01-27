class ReqResetPasswordModel {
  final String email;

  ReqResetPasswordModel({
    required this.email
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
    };
  }
}
