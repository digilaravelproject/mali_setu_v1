import 'dart:convert';
import 'package:flutter/cupertino.dart'; // Added
import 'package:get/get.dart';

import '../../../core/constent/api_constants.dart';
import '../../../core/constent/app_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import '../../../core/storage/shared_prefs.dart';
import '../../../core/storage/token_manger.dart';
import '../login/data/model/res_login_model.dart';
import '../login/data/data_source/login_data_source.dart'; // Added
import '../login/data/repository/login_repository_impl.dart'; // Added
import '../login/domain/usecase/logout_usecase.dart'; // Added
import '../../../../core/routes/app_routes.dart'; // Added

class AuthService extends GetxService {
  final ApiClient _apiClient = Get.find<ApiClient>();

  // Observable for login state
  final isLoggedIn = false.obs;
  final isCompanyLogin = false.obs;
  final currentUser = Rxn<User>();

  // Added for logout functionality
  late final LogoutUseCase _logoutUseCase;

  @override
  void onInit() {
    super.onInit();
    _checkLoginStatus();
    
    // Initialize LogoutUseCase (following project structure)
    final dataSource = LoginDataSourceImpl(apiClient: _apiClient);
    final repository = LoginRepositoryImpl(dataSource: dataSource);
    _logoutUseCase = LogoutUseCase(repository: repository);
  }

  void _checkLoginStatus() {
    isLoggedIn.value = SharedPrefs.getBool(AppConstants.isLoggedInPref) ?? false;
    isCompanyLogin.value = SharedPrefs.getBool(AppConstants.isCompanyLoginPref) ?? false;
    
    if (isLoggedIn.value) {
      final userJson = SharedPrefs.getString(AppConstants.userDataPref);
      if (userJson != null) {
        try {
          currentUser.value = User.fromJson(jsonDecode(userJson));
        } catch (e) {
          currentUser.value = null;
        }
      }
    }
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
            final user = User.fromJson(data['data']['user']);
            currentUser.value = user;
            await SharedPrefs.setString(
              AppConstants.userDataPref,
              jsonEncode(user.toJson()),
            );
            await SharedPrefs.setString(
              AppConstants.profileDataPref,
              jsonEncode(data['data']['user']),
            );
          } else if (data['user'] != null) {
            final user = User.fromJson(data['user']);
            currentUser.value = user;
            await SharedPrefs.setString(
              AppConstants.userDataPref,
              jsonEncode(user.toJson()),
            );
            await SharedPrefs.setString(
              AppConstants.profileDataPref,
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

  /// Process user logout
  Future<void> logout() async {
    try {
      // Call Logout API
      await _logoutUseCase();
    } catch (e) {
      debugPrint("Logout API error: $e");
      // Even if API fails, we should clear local data
    } finally {
      // Clear local data
      currentUser.value = null;
      isLoggedIn.value = false;
      isCompanyLogin.value = false;
      await TokenManager.clearToken();
      await SharedPrefs.remove(AppConstants.userDataPref);
      await SharedPrefs.setBool(AppConstants.isLoggedInPref, false);
      await SharedPrefs.setBool(AppConstants.isCompanyLoginPref, false);
      
      // Navigate to Login
      Get.offAllNamed(AppRoutes.login);
    }
  }

  /// Fetch latest profile data
  Future<ApiResponse<User>> refreshProfile() async {
    try {
      final response = await _apiClient.get(ApiConstants.authProfile);

      if (response.statusCode == 200) {
        final data = response.data;
        // User object is usually directly in data or in data['user']
        final userData = data['user'] ?? data['data']?['user'] ?? data['data'] ?? data;
        final user = User.fromJson(userData);
        
        currentUser.value = user;

        // Fetch Matrimony status if applicable
        if (user.isMatrimony == true && user.id != null) {
          try {
            final matResponse = await _apiClient.get("${ApiConstants.GetMatrimonyProfile}/${user.id}");
            if (matResponse.statusCode == 200) {
              final matData = matResponse.data['data']?['profile'] ?? matResponse.data['profile'] ?? matResponse.data['data'];
              if (matData != null && (matData['approval_status'] != null || matData['status'] != null)) {
                user.matrimonyApprovalStatus = (matData['approval_status'] ?? matData['status']).toString();
                currentUser.value = user; // Refresh observable
                currentUser.refresh();
              }
            }
          } catch (e) {
            debugPrint("Error fetching matrimony status: $e");
          }
        }

        await SharedPrefs.setString(
          AppConstants.userDataPref,
          jsonEncode(user.toJson()),
        );
        await SharedPrefs.setString(
          AppConstants.profileDataPref,
          jsonEncode(data),
        );
        
        return ApiResponse.success(user);
      } else {
        return ApiResponse.error(response.data['message'] ?? 'Failed to fetch profile');
      }
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  /// Check if user has paid for a specific feature
  // bool hasPaymentFor(String purpose) {
  //   final user = currentUser.value;
  //   if (user == null) return false;
  //   return user.hasPayment == true && user.paymentPurpose == purpose;
  // }


  bool hasPaymentForMatrimony() {
    final user = currentUser.value;
    if (user == null) return false;
    return user.hasMatrimonyPayment == true;
  }


  bool hasPaymentForBusiness() {
    final user = currentUser.value;
    if (user == null) return false;
    return user.hasBusinessPayment == true;
  }


  bool hasMatrimony() {
    final user = currentUser.value;
    if (user == null) return false;
    return user.isMatrimony == true;
  }


  bool hasBusiness() {
    final user = currentUser.value;
    if (user == null) return false;
    return user.isBusiness == true;
  }



  /// Update profile data
  Future<ApiResponse<User>> updateProfile(Map<String, dynamic> updateData) async {
    try {
      debugPrint("🔧 Updating profile with data: $updateData");
      
      final response = await _apiClient.put(
        ApiConstants.authProfileUpdate,
        data: updateData,
      );

      debugPrint("📡 Update profile response status: ${response.statusCode}");
      debugPrint("📡 Update profile response data: ${response.data}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        final userData = data['user'] ?? data['data']?['user'] ?? data['data'] ?? data;
        
        debugPrint("👤 Parsed user data: $userData");
        
        final user = User.fromJson(userData);
        
        debugPrint("📸 New profile image from API: ${user.profileImage}");
        
        currentUser.value = user;
        await SharedPrefs.setString(
          AppConstants.userDataPref,
          jsonEncode(user.toJson()),
        );

        await SharedPrefs.setString(
          AppConstants.profileDataPref,
          jsonEncode(data),
        );


        debugPrint("✅ User data saved to SharedPrefs");
        debugPrint("📸 Current user profile image: ${currentUser.value?.profileImage}");
        
        return ApiResponse.success(user);
      } else {
        return ApiResponse.error(response.data['message'] ?? 'Failed to update profile');
      }
    } catch (e) {
      debugPrint("❌ Update profile error: $e");
      return ApiResponse.error(e.toString());
    }
  }
}
