import 'package:edu_cluezer/core/helper/country_list_picker.dart';
import 'package:edu_cluezer/core/helper/logger_helper.dart';
import 'package:edu_cluezer/core/routes/app_routes.dart';
import 'package:edu_cluezer/features/login/data/data_source/login_data_source.dart';
import 'package:edu_cluezer/features/login/data/model/req_login_model.dart';
import 'package:edu_cluezer/features/login/presentation/page/otp_verification_bts.dart';
import 'package:edu_cluezer/widgets/custom_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';

/*class LoginController extends GetxController
    implements GetTickerProviderStateMixin {
  LoginDataSource dataSource;

  LoginController({required this.dataSource});

  var mobileController = TextEditingController();
  var passwordController = TextEditingController();

  var isRemember = true.obs;
  var isPasswordVisible = true.obs;
  var selectedPhone = countries.where((p) => p.dialCode == "91").first.obs;

  var countryController = TextEditingController();
  var isLoading = false.obs;
  final formKey = GlobalKey<FormState>();

  @override
  void onInit() {
    _initCountry();
    super.onInit();
  }

  @override
  Ticker createTicker(TickerCallback onTick) {
    return Ticker(onTick);
  }

  @override
  void didChangeDependencies(BuildContext context) {}

  void pickCountry() {
    Get.to(() => CountriesList(onTap: (p) => selectedPhone.value = p));
  }

  Future<void> performLogin() async {
    try {
      if (formKey.currentState!.validate()) {
        isLoading.value = true;
        var res = await dataSource.makeOtpLoginRequest(
          ReqLoginModel(
            phoneCode: selectedPhone.value.displayCC,
            mobileNumber: mobileController.text,
            password: passwordController.text,
            isLoginPass: !isRemember.value,
          ),
        );
        CustomSnackBar.showSuccess(
          message: res,
          position: SnackBarPosition.top,
        );
        VerifyOtpBottomSheet.show(this);
      } else {
        Get.toNamed(AppRoutes.dashboard);
      }
    } catch (e, stk) {
      CustomSnackBar.showError(message: e.toString());
      printMessage("performLogin $stk");
    } finally {
      isLoading.value = false;
    }
  }

  void _initCountry() {}
}*/




import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../../common/api/apiClient.dart';
import '../../../../db/shared_pref_manager.dart';
import '../../data/model/res_login_model.dart'; // your model

class LoginController extends GetxController
    implements GetTickerProviderStateMixin {
  LoginDataSource dataSource;

  LoginController({required this.dataSource});

  var mobileController = TextEditingController();
  var passwordController = TextEditingController();

  final apiClient = ApiClient(
    baseUrl: 'https://greenyellow-grouse-707123.hostingersite.com/public/api',
  );

  var isRemember = true.obs;
  var isPasswordVisible = true.obs;
  var selectedPhone = countries.where((p) => p.dialCode == "91").first.obs;

  var countryController = TextEditingController();
  var isLoading = false.obs;
  final formKey = GlobalKey<FormState>();

  Rx<LoginResponse?> loginResponse = Rx<LoginResponse?>(null); // Store API response

  @override
  void onInit() {
    _initCountry();
    super.onInit();
  }

  @override
  Ticker createTicker(TickerCallback onTick) {
    return Ticker(onTick);
  }

  void pickCountry() {
    Get.to(() => CountriesList(onTap: (p) => selectedPhone.value = p));
  }

  /// Perform login using API
  /*Future<void> performLogin() async {
    if (!formKey.currentState!.validate()) return;

    try {
      isLoading.value = true;

      // Create request body
      final reqBody = {
        "email": mobileController.text,
        "password": passwordController.text,
      };

      // Call POST function
      final response = await apiClient.post(
        '/auth/login', // API endpoint
        body: reqBody,
        headers: {"Content-Type": "application/json"},
      );

      print("loginresponse : "+response.body);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        // Parse response using your model
        loginResponse.value = LoginResponse.fromJson(decoded);

        String? msg = loginResponse.value?.message.toString();

        // Optional: show success snackbar
        Get.snackbar("Success", loginResponse.value!.message);
        // CustomSnackBar.showSuccess(
        //   message: loginResponse.value!.message,
        //   position: SnackBarPosition.top,
        // );

        // Open OTP bottom sheet if needed
        VerifyOtpBottomSheet.show(this);

        // You can now access user data anywhere via loginResponse.value
        print('User name: ${loginResponse.value!.data.user.name}');
        print('Token: ${loginResponse.value!.data.token}');
      } else {
        final decoded = jsonDecode(response.body);
        Get.snackbar("Error", loginResponse.value!.message.toString());
        // CustomSnackBar.showError(
        //     message: decoded['message'] ?? 'Login failed');
      }
    } catch (e, stk) {
      Get.snackbar("Message ", e.toString());
     // CustomSnackBar.showError(message: e.toString());
      printMessage("performLogin $stk");
    } finally {
      isLoading.value = false;
    }
  }*/


  Future<void> performLogin() async {
    try {
      isLoading.value = true;

      final response = await apiClient.post(
        '/auth/login',
        body: {
          "email": mobileController.text,
          "password": passwordController.text,
        },
      );

      final decoded = jsonDecode(response.body);

      print("login response : "+response.body);

      // Show API message always
      Get.snackbar(
        decoded['success'] == true ? 'Success' : 'Error',
        decoded['message'] ?? '',
      );

      if (decoded['success'] != true) return;

      // Parse LoginResponse model
      final loginResp = LoginResponse.fromJson(decoded);

      // Save entire model in SharedPreferences
      await SharedPrefManager().saveLoginResponse(loginResp);

      // Save token separately (optional)
      await SharedPrefManager().saveToken(loginResp.data.token);

      Get.toNamed(AppRoutes.dashboard);

      // Open OTP sheet
     // VerifyOtpBottomSheet.show(this);

      print('Saved User: ${loginResp.data.user.name}');
      print('Saved Token: ${loginResp.data.token}');

    } catch (e, stk) {
      Get.snackbar('Error', e.toString());
      printMessage("performLogin $stk");
    } finally {
      isLoading.value = false;
    }
  }



/*
  Future<void> performLogin() async {
    try {
      isLoading.value = true;

      final response = await apiClient.post(
        '/auth/login',
        body: {
          "email": mobileController.text,
          "password": passwordController.text,
        },
      );

      final Map<String, dynamic> decoded = jsonDecode(response.body);

      // ✅ ALWAYS show API message
      Get.snackbar(
        decoded['success'] == true ? 'Success' : 'Error',
        decoded['message'] ?? '',
      );

      // ✅ Parse model ONLY when success = true
      if (decoded['success'] == true) {
        loginResponse.value = LoginResponse.fromJson(decoded);

        VerifyOtpBottomSheet.show(this);

        print('User: ${loginResponse.value!.data.user.name}');
        print('Token: ${loginResponse.value!.data.token}');
      }

    } catch (e, stk) {
      Get.snackbar('Error', e.toString());
      printMessage("performLogin $stk");
    } finally {
      isLoading.value = false;
    }
  }*/


  void _initCountry() {}

  @override
  void didChangeDependencies(BuildContext context) {
    // TODO: implement didChangeDependencies
  }
}

