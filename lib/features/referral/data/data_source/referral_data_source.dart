import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../../../core/constent/api_constants.dart';
import '../../../../core/constent/app_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/storage/shared_prefs.dart';
import '../../../Auth/service/auth_service.dart';
import '../models/referral_model.dart';

abstract class ReferralDataSource {
  Future<VolunteerEarningsData> getVolunteerEarnings({String? referralCode});
  Future<List<ReferredUserItem>> getReferredUsers({
    String? referralCode,
    String? userType,
    String? status,
    int page = 1,
    int perPage = 20,
  });
  Future<List<ReferredUserItem>> getReferralHistory({
    String? referralCode,
    String? userType,
    String? status,
    int page = 1,
    int perPage = 20,
  });
  Future<ReferralNetworkNode> getReferralNetwork({
    String? referralCode,
    int depth = 3,
    String? district,
    String? taluka,
    String? cityVillage,
  });
  Future<ShareableLinkData> getShareableLink({String? referralCode});
  Future<SendReferralResult> sendReferralLink({
    required String email,
    String? referralCode,
    String? recipientName,
    String? message,
  });
}

class ReferralDataSourceImpl implements ReferralDataSource {
  final ApiClient apiClient;

  ReferralDataSourceImpl({required this.apiClient});

  /// Helper: Retrieve dynamic referral code from SharedPreferences
  String _getReferralCodeFromPrefs([String? fallbackCode]) {
    // 1. First priority: from AuthService current logged-in user
    if (Get.isRegistered<AuthService>()) {
      final auth = Get.find<AuthService>();
      final userCode = auth.currentUser.value?.reffralCode;
      if (userCode != null && userCode.trim().isNotEmpty) {
        return userCode.trim();
      }
    }

    // 2. Second priority: from SharedPreferences saved user_data JSON
    final userJson = SharedPrefs.getString(AppConstants.userDataPref);
    if (userJson != null && userJson.isNotEmpty) {
      try {
        final Map<String, dynamic> userMap = jsonDecode(userJson);
        final userCode = userMap['referral_code'] ?? userMap['reffral_code'];
        if (userCode != null && userCode.toString().trim().isNotEmpty) {
          final code = userCode.toString().trim();
          SharedPrefs.setString(AppConstants.referralCodePref, code);
          return code;
        }
      } catch (_) {}
    }

    // 3. Third priority: Direct from SharedPreferences AppConstants.referralCodePref
    final prefCode = SharedPrefs.getString(AppConstants.referralCodePref);
    if (prefCode != null && prefCode.trim().isNotEmpty) {
      return prefCode.trim();
    }

    // 4. Fourth priority: direct key "referral_code"
    final directPref = SharedPrefs.getString("referral_code");
    if (directPref != null && directPref.trim().isNotEmpty) {
      return directPref.trim();
    }

    return fallbackCode ?? '';
  }

  @override
  Future<VolunteerEarningsData> getVolunteerEarnings({String? referralCode}) async {
    final code = (referralCode != null && referralCode.trim().isNotEmpty)
        ? referralCode.trim()
        : _getReferralCodeFromPrefs();

    // 1. Primary: GET /api/referrals/{code}/earnings
    if (code.isNotEmpty) {
      try {
        final endpoint = ApiConstants.referralEarnings(code);
        final response = await apiClient.get(endpoint);
        if (response.statusCode == 200 && response.data != null) {
          final data = response.data['data'] ?? response.data;
          final earnings = VolunteerEarningsData.fromJson(data);

          // Store verified referral code into SharedPreferences
          final respCode = earnings.volunteer?.referralCode;
          if (respCode != null && respCode.isNotEmpty) {
            await SharedPrefs.setString(AppConstants.referralCodePref, respCode);
            if (Get.isRegistered<AuthService>()) {
              Get.find<AuthService>().currentUser.value?.reffralCode = respCode;
            }
            debugPrint("DEBUG_REFERRAL: Cached own referral code to SharedPreferences: $respCode");
          }

          return earnings;
        }
      } catch (e) {
        debugPrint("⚠️ ReferralDataSource.getVolunteerEarnings ($code) error: $e");
      }
    }

    // 2. Fallback: Generic GET /api/volunteer/earnings
    try {
      final response = await apiClient.get(ApiConstants.referralEarningsFallback);
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'] ?? response.data;
        final earnings = VolunteerEarningsData.fromJson(data);
        final respCode = earnings.volunteer?.referralCode;
        if (respCode != null && respCode.isNotEmpty) {
          await SharedPrefs.setString(AppConstants.referralCodePref, respCode);
          if (Get.isRegistered<AuthService>()) {
            Get.find<AuthService>().currentUser.value?.reffralCode = respCode;
          }
        }
        return earnings;
      }
    } catch (e) {
      debugPrint("⚠️ ReferralDataSource.getVolunteerEarnings fallback error: $e");
    }

    // Fallback: Populate from real logged-in user (no hardcoded dummy values)
    final authService = Get.isRegistered<AuthService>() ? Get.find<AuthService>() : null;
    final currentUser = authService?.currentUser.value;
    final fallbackCode = code.isNotEmpty ? code : (authService?.referralCode ?? currentUser?.reffralCode ?? '');
    final link = fallbackCode.isNotEmpty ? "https://malisetu.com/register?referral_code=$fallbackCode" : "";

    return VolunteerEarningsData(
      volunteer: VolunteerInfo(
        id: currentUser?.id ?? 0,
        name: currentUser?.name ?? '',
        referralCode: fallbackCode,
        referralLink: link,
        photoUrl: currentUser?.profileImage != null && currentUser!.profileImage!.isNotEmpty
            ? (currentUser.profileImage!.startsWith('http')
                ? currentUser.profileImage!
                : "${ApiConstants.imageBaseUrl}${currentUser.profileImage}")
            : "",
        userType: currentUser?.userType ?? 'general',
        isVolunteer: currentUser?.userType?.toLowerCase() == 'volunteer',
        commissionPoints: 0,
        totalReferrals: 0,
        totalEarnedPoints: 0,
        location: currentUser?.city != null ? "${currentUser!.city}, ${currentUser.state ?? 'India'}" : null,
      ),
      commissionPointsPerReferral: 0,
      totalReferrals: 0,
      activeReferrals: 0,
      totalEarnedPoints: 0,
      pendingPoints: 0,
    );
  }

  @override
  Future<List<ReferredUserItem>> getReferredUsers({
    String? referralCode,
    String? userType,
    String? status,
    int page = 1,
    int perPage = 20,
  }) async {
    final code = (referralCode != null && referralCode.trim().isNotEmpty)
        ? referralCode.trim()
        : _getReferralCodeFromPrefs();
    if (code.isEmpty) return [];

    final queryParams = <String, dynamic>{
      if (userType != null && userType.isNotEmpty && userType != 'all') 'user_type': userType,
      if (status != null && status.isNotEmpty && status != 'all') 'status': status,
      'per_page': perPage,
      'page': page,
    };

    try {
      final endpoint = ApiConstants.referralReferredUsers(code);
      final response = await apiClient.get(endpoint, queryParameters: queryParams);
      if (response.statusCode == 200 && response.data != null) {
        final list = response.data['data'];
        if (list is List) {
          return list.map((e) => ReferredUserItem.fromJson(e as Map<String, dynamic>)).toList();
        }
      }
    } catch (e) {
      debugPrint("⚠️ ReferralDataSource.getReferredUsers ($code) error: $e");
    }

    return [];
  }

  @override
  Future<List<ReferredUserItem>> getReferralHistory({
    String? referralCode,
    String? userType,
    String? status,
    int page = 1,
    int perPage = 20,
  }) async {
    final code = (referralCode != null && referralCode.trim().isNotEmpty)
        ? referralCode.trim()
        : _getReferralCodeFromPrefs();
    if (code.isEmpty) return [];

    final queryParams = <String, dynamic>{
      if (userType != null && userType.isNotEmpty && userType != 'all') 'user_type': userType,
      if (status != null && status.isNotEmpty && status != 'all') 'status': status,
      'per_page': perPage,
      'page': page,
    };

    try {
      final endpoint = ApiConstants.referralReferredUsers(code);
      final response = await apiClient.get(endpoint, queryParameters: queryParams);
      if (response.statusCode == 200 && response.data != null) {
        final list = response.data['data'];
        if (list is List) {
          return list.map((e) => ReferredUserItem.fromJson(e as Map<String, dynamic>)).toList();
        }
      }
    } catch (e) {
      debugPrint("⚠️ ReferralDataSource.getReferralHistory ($code) error: $e");
    }

    return [];
  }

  @override
  Future<ReferralNetworkNode> getReferralNetwork({
    String? referralCode,
    int depth = 3,
    String? district,
    String? taluka,
    String? cityVillage,
  }) async {
    final code = (referralCode != null && referralCode.trim().isNotEmpty)
        ? referralCode.trim()
        : _getReferralCodeFromPrefs();

    final queryParams = <String, dynamic>{
      'depth': depth,
      if (district != null && district.trim().isNotEmpty) 'district': district.trim(),
      if (taluka != null && taluka.trim().isNotEmpty) 'taluka': taluka.trim(),
      if (cityVillage != null && cityVillage.trim().isNotEmpty) 'city_village': cityVillage.trim(),
    };

    if (code.isNotEmpty) {
      try {
        final endpoint = ApiConstants.referralNetwork(code);
        final response = await apiClient.get(endpoint, queryParameters: queryParams);
        if (response.statusCode == 200 && response.data != null) {
          final data = response.data['data'] ?? response.data;
          return ReferralNetworkNode.fromJson(data);
        }
      } catch (e) {
        debugPrint("⚠️ ReferralDataSource.getReferralNetwork ($code) error: $e");
      }
    }

    final authService = Get.isRegistered<AuthService>() ? Get.find<AuthService>() : null;
    final currentUser = authService?.currentUser.value;

    return ReferralNetworkNode(
      userId: currentUser?.id ?? 0,
      name: currentUser?.name ?? '',
      referralCode: code,
      level: 0,
      userType: currentUser?.userType ?? 'general',
      commissionPoints: 0,
      children: [],
    );
  }

  @override
  Future<ShareableLinkData> getShareableLink({String? referralCode}) async {
    final code = (referralCode != null && referralCode.isNotEmpty)
        ? referralCode
        : _getReferralCodeFromPrefs();

    // 1. Primary: Dynamic code endpoint -> /api/referrals/{code}/share-link
    if (code.isNotEmpty) {
      try {
        final endpoint = ApiConstants.referralShareLink(code);
        final response = await apiClient.get(endpoint);
        if (response.statusCode == 200 && response.data != null) {
          final data = response.data['data'] ?? response.data;
          final result = ShareableLinkData.fromJson(data);

          if (result.referralCode.isNotEmpty) {
            await SharedPrefs.setString(AppConstants.referralCodePref, result.referralCode);
          }

          return result;
        }
      } catch (e) {
        debugPrint("⚠️ ReferralDataSource.getShareableLink ($code) error: $e");
      }
    }

    // 2. Fallback: Generic endpoint -> /api/referral/shareable-link
    try {
      final response = await apiClient.get(ApiConstants.referralShareableLink);
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'] ?? response.data;
        return ShareableLinkData.fromJson(data);
      }
    } catch (e) {
      debugPrint("⚠️ ReferralDataSource.getShareableLink fallback error: $e");
    }

    final link = code.isNotEmpty ? "https://malisetu.com/register?referral_code=$code" : "";
    return ShareableLinkData(
      referralCode: code,
      referralLink: link,
      shareMessage: link.isNotEmpty ? "Join Mali Setu using my referral link: $link" : "",
    );
  }

  @override
  Future<SendReferralResult> sendReferralLink({
    required String email,
    String? referralCode,
    String? recipientName,
    String? message,
  }) async {
    final code = (referralCode != null && referralCode.isNotEmpty)
        ? referralCode
        : _getReferralCodeFromPrefs();

    final body = <String, dynamic>{
      'email': email.trim(),
      if (recipientName != null && recipientName.trim().isNotEmpty)
        'recipient_name': recipientName.trim(),
      'message': (message != null && message.trim().isNotEmpty)
          ? message.trim()
          : "Please join Mali Setu using my referral invitation.",
    };

    // 1. Primary: POST /api/referrals/{code}/send-email
    if (code.isNotEmpty) {
      try {
        final endpoint = ApiConstants.referralSendEmail(code);
        final response = await apiClient.post(endpoint, data: body);
        if (response.statusCode == 200 && response.data != null) {
          final data = response.data['data'] ?? response.data;
          return SendReferralResult.fromJson(data);
        }
      } catch (e) {
        debugPrint("⚠️ ReferralDataSource.sendReferralLink ($code) error: $e");
      }
    }

    // 2. Fallback: Generic POST /api/referral/send
    final response = await apiClient.post(ApiConstants.sendReferralLink, data: body);
    if (response.statusCode == 200 && response.data != null) {
      final data = response.data['data'] ?? response.data;
      return SendReferralResult.fromJson(data);
    }

    throw Exception(
      (response.data is Map ? response.data['message'] : null) ??
          'Failed to send referral email. Please try again.',
    );
  }
}
