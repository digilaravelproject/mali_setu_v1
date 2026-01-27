import 'dart:convert';
import 'package:get/get.dart';

import '../../../core/constent/api_constants.dart';
import '../../../core/constent/app_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import '../../../core/storage/shared_prefs.dart';
import '../../../core/storage/token_manger.dart';

class AuthService extends GetxService {
  final ApiClient _apiClient = Get.find<ApiClient>();

  // Observable for login state
  final isLoggedIn = false.obs;
  final isCompanyLogin = false.obs;

  @override
  void onInit() {
    super.onInit();
    _checkLoginStatus();
  }

  void _checkLoginStatus() {
    isLoggedIn.value = SharedPrefs.getBool(AppConstants.isLoggedInPref) ?? false;
    isCompanyLogin.value = SharedPrefs.getBool(AppConstants.isCompanyLoginPref) ?? false;
  }

  // ==================== USER AUTH ====================

  /// Login with Email and Password
  Future<ApiResponse<Map<String, dynamic>>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.authLogin,
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;

        if (data['success'] == true || data['status'] == 'success') {
           // Save token if present
          if (data['data'] != null && data['data']['token'] != null) {
            await TokenManager.saveToken(data['data']['token']);
          } else if (data['token'] != null) {
             await TokenManager.saveToken(data['token']);
          }

          // Save user data
          if (data['data'] != null && data['data']['user'] != null) {
             await SharedPrefs.setString(
              AppConstants.userDataPref,
              jsonEncode(data['data']['user']),
            );
          } else if (data['user'] != null) {
             await SharedPrefs.setString(
              AppConstants.userDataPref,
              jsonEncode(data['user']),
            );
          }

          // Update login state
          await SharedPrefs.setBool(AppConstants.isLoggedInPref, true);
          await SharedPrefs.setBool(AppConstants.isCompanyLoginPref, false);
          isLoggedIn.value = true;
          isCompanyLogin.value = false;

          return ApiResponse.success(
            data is Map<String, dynamic> ? data : {},
            message: data['message'] ?? 'Login successful',
            code: response.statusCode,
          );
        } else {
           return ApiResponse.error(
            data['message'] ?? 'Login failed',
            code: response.statusCode,
          );
        }
      } else {
        return ApiResponse.error(
          response.data['message'] ?? 'Login failed',
          code: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse.error(
        e.toString(),
        error: e,
      );
    }
  }

  /// Register new user
  Future<ApiResponse<Map<String, dynamic>>> register(Map<String, dynamic> registrationData) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.authRegister,
        data: registrationData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        
        if (data['success'] == true || data['status'] == 'success') {
          return ApiResponse.success(
            data is Map<String, dynamic> ? data : {},
            message: data['message'] ?? 'Registration successful',
            code: response.statusCode,
          );
        } else {
           return ApiResponse.error(
            data['message'] ?? 'Registration failed',
            code: response.statusCode,
          );
        }
      } else {
        return ApiResponse.error(
          response.data['message'] ?? 'Registration failed',
          code: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse.error(
        e.toString(),
        error: e,
      );
    }
  }

  /// Change Password (Authenticated)
  Future<ApiResponse<Map<String, dynamic>>> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.authChangePassword,
        data: {
          'current_password': oldPassword,
          'new_password': newPassword,
          'new_password_confirmation': confirmPassword,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
         final data = response.data;
         return ApiResponse.success(
            data is Map<String, dynamic> ? data : {},
            message: data['message'] ?? 'Password changed successfully',
            code: response.statusCode,
          );
      } else {
        return ApiResponse.error(
          response.data['message'] ?? 'Failed to change password',
          code: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse.error(
        e.toString(),
        error: e,
      );
    }
  }



}
