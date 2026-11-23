import 'dart:async';

import 'package:edu_cluezer/core/constent/api_constants.dart';
import 'package:edu_cluezer/core/network/api_client.dart';
import 'package:edu_cluezer/widgets/custom_snack_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../domain/repository/matrimony_repository.dart';
import '../../data/model/search_matrimony_response.dart';
import 'matrimony_controller.dart';
import 'matrimony_members_controller.dart';
import 'matrimony_requests_controller.dart';

class MatrimonyDetailsController extends GetxController {
  final MatrimonyRepository _repository = Get.find<MatrimonyRepository>();
  
  RxBool isLoading = false.obs;
  RxBool isSendingRequest = false.obs;
  Rx<MatrimonyProfile?> profile = Rx<MatrimonyProfile?>(null);
  RxInt currentImageIndex = 0.obs;
  Rx<int?> conversationId = Rx<int?>(null);

  PageController? pageController;
  Timer? _timer;
  
  @override
  void onInit() {
    super.onInit();
    pageController = PageController();
    final args = Get.arguments;
    int? id;
    if (args is Map) {
      id = args['id'] is int ? args['id'] as int : int.tryParse(args['id']?.toString() ?? '');
      conversationId.value = args['conversation_id'] is int
          ? args['conversation_id'] as int
          : int.tryParse(args['conversation_id']?.toString() ?? '');
    } else if (args is int) {
      id = args;
    }
    if (id != null) {
      fetchProfileDetails(id);
    }
  }
  @override
  void onClose() {
    _timer?.cancel();
    pageController?.dispose();
    super.onClose();
  }

  void _startAutoScroll() {
    _timer?.cancel();
    final photos = profile.value?.personalDetails?.photos ?? [];
    if (photos.length <= 1) return;

    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (pageController != null && pageController!.hasClients) {
        int nextPage = currentImageIndex.value + 1;
        if (nextPage >= photos.length) {
          nextPage = 0;
        }
        pageController!.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  Future<void> refreshData() async {
    if (profile.value?.userId != null) {
      await fetchProfileDetails(profile.value!.userId!);
    } else {
      final args = Get.arguments;
      final id = args is Map
          ? (args['id'] is int ? args['id'] as int : int.tryParse(args['id']?.toString() ?? ''))
          : (args is int ? args : null);
      if (id != null) {
        await fetchProfileDetails(id);
      }
    }
  }

  void _applyNavigationOverrides(MatrimonyProfile fetchedProfile) {
    final args = Get.arguments;
    final String? argStatus = args is Map ? args['connection_status']?.toString() : null;

    if ((fetchedProfile.connectionStatus == null ||
            fetchedProfile.connectionStatus == 'not_connected' ||
            fetchedProfile.connectionStatus == 'no_connected') &&
        argStatus != null &&
        argStatus != 'not_connected' &&
        argStatus != 'no_connected') {
      fetchedProfile.connectionStatus = argStatus;
    }

    if (fetchedProfile.conversationId == null && conversationId.value != null) {
      fetchedProfile.conversationId = conversationId.value;
    }

    conversationId.value = fetchedProfile.conversationId;
  }

  Future<void> fetchProfileDetails(int id) async {
    isLoading.value = true;
    profile.value = null; // Clear previous profile immediately so old profile is never displayed
    try {
      // 1. Try fetching by user_id (/matrimony/profile_user_id/{id})
      try {
        final response = await _repository.getProfileDetails(id);
        if (response.success == true && response.data?.profile != null) {
          final fetchedProfile = response.data!.profile!;
          _applyNavigationOverrides(fetchedProfile);
          profile.value = fetchedProfile;
          _startAutoScroll();
          return;
        }
      } catch (_) {
        // Fall through to profile_id fallback if profile_user_id returned 404/error
      }

      // 2. Fallback: check if id was profile_id instead of user_id (/matrimony/profile/{id})
      try {
        final profileByIdRes = await Get.find<ApiClient>().get("${ApiConstants.matrimonyProfile}/$id");
        final parsed = MatrimonyProfileDetailResponse.fromJson(profileByIdRes.data);
        if (parsed.success == true && parsed.data?.profile != null) {
          final fetchedProfile = parsed.data!.profile!;
          _applyNavigationOverrides(fetchedProfile);
          profile.value = fetchedProfile;
          _startAutoScroll();
          return;
        }
      } catch (_) {}

      CustomSnackBar.showError(message: "Failed to fetch profile details");
    } catch (e) {
      CustomSnackBar.showError(message: "Something went wrong: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> sendRequest() async {
    if (profile.value == null || isSendingRequest.value) return;

    final targetUserId = profile.value!.userId ?? profile.value!.user?.id ?? profile.value!.id;
    if (targetUserId == null) {
      CustomSnackBar.showError(message: "Invalid profile user ID");
      return;
    }

    isSendingRequest.value = true;
    try {
      final data = {
        "receiver_id": targetUserId.toString(),
        "message": "Hello, I would like to connect with you!"
      };
      final response = await _repository.sendConnectionRequest(data);
      if (response != null && (response['success'] == true || response['status'] == true)) {
        profile.value!.connectionStatus = "pending";
        profile.refresh();
        CustomSnackBar.showSuccess(message: response['message'] ?? "Connection request sent successfully");
      } else {
        CustomSnackBar.showError(message: response?['message'] ?? "Failed to send connection request");
      }
    } catch (e) {
      CustomSnackBar.showError(message: "Something went wrong: $e");
    } finally {
      isSendingRequest.value = false;
    }
  }

  Future<bool> reportUser({
    required int reportedUserId,
    required String reasonKey,
    String? details,
  }) async {
    try {
      final data = {
        "reported_user_id": reportedUserId,
        "reason_key": reasonKey,
        "details": details ?? "",
      };
      print("REPORT USER REQUEST (details): $data");
      final response = await _repository.reportUser(data);
      print("REPORT USER RESPONSE (details): $response");
      if (response != null &&
          (response['success'] == true ||
           response['status'] == true ||
           response['status'] == 'success' ||
           response['status'] == 200 ||
           response['code'] == 200 ||
           (response is Map && (response['message'] != null && response['error'] == null)))) {
        CustomSnackBar.showSuccess(message: response['message'] ?? 'report_submitted'.tr);
        if (Get.isRegistered<MatrimonyController>()) {
          Get.find<MatrimonyController>().removeProfileById(reportedUserId);
        }
        return true;
      } else {
        final msg = response is Map ? (response['message'] ?? response['error']) : null;
        CustomSnackBar.showError(message: msg ?? 'Failed to submit report');
        return false;
      }
    } catch (e) {
      print("REPORT USER ERROR (details): $e");
      CustomSnackBar.showError(message: "Failed to submit report: $e");
      return false;
    }
  }

  Future<bool> blockUser(int blockedUserId) async {
    try {
      final data = {
        "blocked_user_id": blockedUserId,
      };
      print("BLOCK USER REQUEST (details): $data");
      final response = await _repository.blockUser(data);
      print("BLOCK USER RESPONSE (details): $response");
      if (response != null &&
          (response['success'] == true ||
           response['status'] == true ||
           response['status'] == 'success' ||
           response['status'] == 200 ||
           response['code'] == 200 ||
           (response is Map && (response['message'] != null && response['error'] == null)))) {
        CustomSnackBar.showSuccess(message: response['message'] ?? 'user_blocked'.tr);
        if (Get.isRegistered<MatrimonyController>()) {
          Get.find<MatrimonyController>().removeProfileById(blockedUserId);
        }
        if (Get.isRegistered<MatrimonyMembersController>()) {
          Get.find<MatrimonyMembersController>().removeMemberByUserId(blockedUserId);
        }
        if (Get.isRegistered<MatrimonyRequestsController>()) {
          Get.find<MatrimonyRequestsController>().removeRequestByUserId(blockedUserId);
        }
        return true;
      } else {
        final msg = response is Map ? (response['message'] ?? response['error']) : null;
        CustomSnackBar.showError(message: msg ?? 'Failed to block user');
        return false;
      }
    } catch (e) {
      print("BLOCK USER ERROR (details): $e");
      CustomSnackBar.showError(message: "Failed to block user: $e");
      return false;
    }
  }
}
