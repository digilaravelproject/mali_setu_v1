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




class RequestResetPasswordModel {
  final String email;
  final String otp;
  final String password;
  final String passwordConfirmation;

  RequestResetPasswordModel({
    required this.email,
    required this.otp,
    required this.password,
    required this.passwordConfirmation,
  });

  Map<String, dynamic> toJson() {
    return {
      "email": email,
      "otp": otp,
      "password": password,
      "password_confirmation": passwordConfirmation,
    };
  }
}

