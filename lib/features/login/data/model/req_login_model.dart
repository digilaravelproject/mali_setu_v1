class ReqLoginModel {
  final String phoneCode;
  final String mobileNumber;
  final String password;
  final bool isLoginPass;

  ReqLoginModel({
    required this.phoneCode,
    required this.mobileNumber,
    required this.password,
    required this.isLoginPass,
  });

  Map<String, dynamic> toMap() {
    final map = {'phone_country_code': phoneCode, 'phone': mobileNumber};
    if (isLoginPass && password.trim().isNotEmpty) {
      map['password'] = password;
    }
    return map;
  }
}

class ReqOTPModel {
  final String phoneCode;
  final String mobileNumber;
  final String otp;
  final bool isLoginPass;

  ReqOTPModel({
    required this.phoneCode,
    required this.mobileNumber,
    required this.otp,
    required this.isLoginPass,
  });

  Map<String, dynamic> toMap() {
    final map = {
      'phone_country_code': phoneCode,
      'phone': mobileNumber,
      'otp': otp,
    };
    return map;
  }
}
