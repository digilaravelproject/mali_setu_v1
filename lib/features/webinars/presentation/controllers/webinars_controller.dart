import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:edu_cluezer/core/network/api_client.dart';
import 'package:edu_cluezer/core/constent/api_constants.dart';
import 'package:edu_cluezer/features/Auth/service/auth_service.dart';
import 'package:edu_cluezer/widgets/custom_snack_bar.dart';
import 'package:edu_cluezer/features/dashboard/presentation/controller/home_controller.dart';
import '../../data/models/webinar_model.dart';
import '../../data/models/agora_token_model.dart';
import '../widgets/webinar_notice_dialog.dart';

class WebinarsController extends GetxController {
  final RxList<Webinar> webinars = <Webinar>[].obs;
  final RxString selectedCategory = 'All'.obs;
  final RxString searchQuery = ''.obs;
  final Rx<Webinar?> selectedWebinar = Rx<Webinar?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMore = true.obs;
  final RxInt currentPage = 1.obs;
  final RxInt lastPage = 1.obs;
  final RxInt totalWebinars = 0.obs;
  final RxSet<int> registeredWebinarIds = <int>{}.obs;

  // Controllers
  final ScrollController scrollController = ScrollController();
  final TextEditingController searchController = TextEditingController();
  Timer? _debounceTimer;
  final TextEditingController regNameController = TextEditingController();
  final TextEditingController regEmailController = TextEditingController();
  final TextEditingController regPhoneController = TextEditingController();
  final RxBool isApprovedUserAccepted = true.obs;
  final RxBool isUpdatesAccepted = true.obs;
  final RxBool isRegistering = false.obs;

  // Live Screen
  final RxInt activeLiveTab = 0.obs; // 0: Q&A, 1: Live Chat
  final RxBool isMicOn = false.obs;
  final RxBool isCameraOn = false.obs;
  final RxInt liveViewerCount = 0.obs;
  final TextEditingController chatInputController = TextEditingController();
  final RxList<WebinarChatMessage> chatMessages = <WebinarChatMessage>[].obs;
  final RxList<WebinarChatMessage> qaMessages = <WebinarChatMessage>[].obs;
  final RxBool isLoadingComments = false.obs;
  final RxBool isPostingComment = false.obs;
  final RxInt commentsCurrentPage = 1.obs;
  final RxInt commentsLastPage = 1.obs;
  final RxInt commentsTotal = 0.obs;
  final RxBool isLoadingJoinToken = false.obs;
  final Rx<AgoraJoinTokenData?> agoraTokenData = Rx<AgoraJoinTokenData?>(null);

  ApiClient get _apiClient =>
      Get.isRegistered<ApiClient>() ? Get.find<ApiClient>() : ApiClient();

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_onScroll);
    fetchWebinars(isRefresh: true);
    _prefillUserData();
  }

  void _onScroll() {
    if (scrollController.hasClients &&
        scrollController.position.pixels >= scrollController.position.maxScrollExtent - 250) {
      if (!isLoading.value && !isLoadingMore.value && hasMore.value) {
        fetchWebinars(isRefresh: false);
      }
    }
  }

  @override
  void onClose() {
    _debounceTimer?.cancel();
    scrollController.dispose();
    searchController.dispose();
    regNameController.dispose();
    regEmailController.dispose();
    regPhoneController.dispose();
    chatInputController.dispose();
    super.onClose();
  }

  Future<void> fetchWebinars({bool isRefresh = false}) async {
    if (isRefresh) {
      currentPage.value = 1;
      hasMore.value = true;
      isLoading.value = true;
    } else {
      if (isLoadingMore.value || !hasMore.value) return;
      isLoadingMore.value = true;
    }

    try {
      final pageToLoad = isRefresh ? 1 : currentPage.value + 1;
      final queryParams = <String, dynamic>{
        'per_page': 12,
        'page': pageToLoad,
      };

      final q = searchQuery.value.trim();
      if (q.isNotEmpty) {
        queryParams['search'] = q;
      }

      final response = await _apiClient.get(
        ApiConstants.getWebinars,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data != null) {
        final parsed = WebinarListResponse.fromJson(response.data as Map<String, dynamic>);
        currentPage.value = parsed.currentPage;
        lastPage.value = parsed.lastPage;
        totalWebinars.value = parsed.total;
        hasMore.value = parsed.currentPage < parsed.lastPage;

        if (isRefresh) {
          if (parsed.data.isNotEmpty || q.isNotEmpty) {
            webinars.assignAll(parsed.data);
          } else {
            _fallbackToLocalData();
          }
        } else {
          for (final item in parsed.data) {
            if (!webinars.any((w) => w.id == item.id)) {
              webinars.add(item);
            }
          }
        }
      } else {
        if (webinars.isEmpty && q.isEmpty) {
          _fallbackToLocalData();
        }
      }
    } catch (e) {
      print("ERROR_WEBINARS_API: $e");
      if (webinars.isEmpty && searchQuery.value.trim().isEmpty) {
        _fallbackToLocalData();
      }
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  Future<Webinar?> fetchWebinarDetail(int id) async {
    try {
      final response = await _apiClient.get("${ApiConstants.getWebinars}/$id");
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        final Map<String, dynamic> webinarMap = data['data'] is Map<String, dynamic>
            ? data['data'] as Map<String, dynamic>
            : (data is Map<String, dynamic> ? data : <String, dynamic>{});

        final fetched = Webinar.fromApiJson(webinarMap);

        // Update in list if exists
        final idx = webinars.indexWhere((w) => w.id == id);
        if (idx != -1) {
          webinars[idx] = fetched;
          webinars.refresh();
        }
        if (fetched.isRegistered) {
          registeredWebinarIds.add(id);
        }
        selectedWebinar.value = fetched;
        return fetched;
      }
    } catch (e) {
      print("ERROR_FETCH_WEBINAR_DETAIL: $e");
    }
    return null;
  }

  void _fallbackToLocalData() {
    if (Get.isRegistered<HomeController>()) {
      final homeWebinars = Get.find<HomeController>().upcomingWebinars;
      if (homeWebinars.isNotEmpty) {
        webinars.assignAll(homeWebinars);
        return;
      }
    }
    webinars.clear();
  }

  void setWebinarsFromApi(List<Webinar> apiWebinars) {
    if (apiWebinars.isNotEmpty && webinars.isEmpty) {
      webinars.assignAll(apiWebinars);
    }
  }

  void _prefillUserData() {
    if (Get.isRegistered<AuthService>()) {
      final user = Get.find<AuthService>().currentUser.value;
      if (user != null) {
        regNameController.text = user.name ?? '';
        regEmailController.text = user.email ?? '';
        regPhoneController.text = user.phone ?? '';
      }
    }
  }

  List<Webinar> get filteredWebinars {
    var list = webinars.toList();

    // Category filter
    if (selectedCategory.value != 'All') {
      list = list.where((w) => w.category.toLowerCase() == selectedCategory.value.toLowerCase()).toList();
    }

    return list;
  }

  void setCategory(String category) {
    HapticFeedback.selectionClick();
    selectedCategory.value = category;
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      fetchWebinars(isRefresh: true);
    });
  }

  void onSearchSubmitted(String query) {
    _debounceTimer?.cancel();
    searchQuery.value = query;
    fetchWebinars(isRefresh: true);
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
    _debounceTimer?.cancel();
    fetchWebinars(isRefresh: true);
  }

  void selectWebinar(Webinar webinar) {
    selectedWebinar.value = webinar;
  }

  Future<bool> registerForWebinar([int? webinarId]) async {
    final targetId = webinarId ?? selectedWebinar.value?.id;
    if (targetId == null) {
      CustomSnackBar.showError(message: "Webinar details not found");
      return false;
    }

    if (isRegistering.value) return false;
    isRegistering.value = true;
    HapticFeedback.mediumImpact();

    try {
      final response = await _apiClient.post(
        "${ApiConstants.getWebinars}/$targetId/register",
        data: '',
      );

      final data = response.data;
      final int statusCode = response.statusCode ?? 500;
      final bool isSuccess = (statusCode == 200 || statusCode == 201) &&
          (data is Map
              ? (data['success'] == true ||
                  data['success'] == 1 ||
                  data['status'] == true)
              : true);

      String msg = isSuccess
          ? "Webinar registration successful. Details were emailed to you."
          : "Failed to register for webinar";

      if (data is Map && data['message'] != null && data['message'].toString().isNotEmpty) {
        msg = data['message'].toString();
      }

      if (isSuccess) {
        registeredWebinarIds.add(targetId);

        final idx = webinars.indexWhere((w) => w.id == targetId);
        if (idx != -1) {
          final current = webinars[idx];
          webinars[idx] = current.copyWith(
            isRegistered: true,
            registeredCount: current.registeredCount + 1,
          );
          if (selectedWebinar.value?.id == targetId) {
            selectedWebinar.value = webinars[idx];
          }
          webinars.refresh();
        }

        if (Get.isRegistered<HomeController>()) {
          final homeCtrl = Get.find<HomeController>();
          final hIdx = homeCtrl.upcomingWebinars.indexWhere((w) => w.id == targetId);
          if (hIdx != -1) {
            final hCurrent = homeCtrl.upcomingWebinars[hIdx];
            homeCtrl.upcomingWebinars[hIdx] = hCurrent.copyWith(
              isRegistered: true,
              registeredCount: hCurrent.registeredCount + 1,
            );
            homeCtrl.upcomingWebinars.refresh();
          }
        }

        WebinarNoticeDialog.show(
          title: "Registration Successful!",
          message: msg,
          type: WebinarNoticeType.success,
          buttonText: "Awesome",
        );
        return true;
      } else {
        _handleRegistrationFailure(targetId, msg);
        return false;
      }
    } catch (e) {
      print("ERROR_REGISTER_WEBINAR: $e");
      String msg = "Failed to register for webinar. Please try again.";
      if (e is DioException && e.response?.data != null) {
        final res = e.response?.data;
        if (res is Map && res['message'] != null) {
          msg = res['message'].toString();
        }
      }
      _handleRegistrationFailure(targetId, msg);
      return false;
    } finally {
      isRegistering.value = false;
    }
  }

  void _handleRegistrationFailure(int targetId, String msg) {
    final webinar = webinars.firstWhereOrNull((w) => w.id == targetId) ?? selectedWebinar.value;
    final lowerMsg = msg.toLowerCase();

    if (lowerMsg.contains("not open") ||
        lowerMsg.contains("closed") ||
        lowerMsg.contains("already started") ||
        lowerMsg.contains("not available") ||
        (webinar != null && webinar.isLiveSession)) {
      WebinarNoticeDialog.showRegistrationClosed(
        message: "This webinar has already started and registration is now closed.\n\nOnly attendees who registered prior to the session can participate.",
      );
    } else {
      WebinarNoticeDialog.show(
        title: "Registration Notice",
        message: msg,
        type: WebinarNoticeType.warning,
        buttonText: "OK",
      );
    }
  }

  bool isWebinarRegistered(int webinarId) {
    return registeredWebinarIds.contains(webinarId) ||
        (webinars.firstWhereOrNull((w) => w.id == webinarId)?.isRegistered ?? false);
  }

  Future<void> fetchWebinarComments(int webinarId, {bool isRefresh = true}) async {
    if (isRefresh) {
      commentsCurrentPage.value = 1;
      isLoadingComments.value = true;
    }

    try {
      final pageToLoad = isRefresh ? 1 : commentsCurrentPage.value + 1;
      final response = await _apiClient.get(
        "${ApiConstants.getWebinars}/$webinarId/comments",
        queryParameters: {'page': pageToLoad},
      );

      if (response.statusCode == 200 && response.data != null) {
        final parsed = WebinarCommentsResponse.fromJson(response.data as Map<String, dynamic>);
        commentsCurrentPage.value = parsed.currentPage;
        commentsLastPage.value = parsed.lastPage;
        commentsTotal.value = parsed.total;

        if (isRefresh) {
          if (parsed.data.isNotEmpty) {
            chatMessages.assignAll(parsed.data);
            qaMessages.assignAll(parsed.data.where((m) => m.isQuestion).toList());
          }
        } else {
          for (final msg in parsed.data) {
            if (!chatMessages.any((m) => m.id == msg.id)) {
              chatMessages.add(msg);
              if (msg.isQuestion) {
                qaMessages.add(msg);
              }
            }
          }
        }
      }
    } catch (e) {
      print("ERROR_FETCH_COMMENTS: $e");
    } finally {
      isLoadingComments.value = false;
    }
  }

  Future<bool> sendLiveMessage(int webinarId, String text, {bool isQuestion = false}) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || isPostingComment.value) return false;

    isPostingComment.value = true;
    HapticFeedback.lightImpact();

    String currentUserName = "You";
    String currentUserPhoto = "";
    if (Get.isRegistered<AuthService>()) {
      final user = Get.find<AuthService>().currentUser.value;
      if (user?.name != null && user!.name!.isNotEmpty) {
        currentUserName = user.name!;
      }
      if (user?.profileImage != null && user!.profileImage!.isNotEmpty) {
        currentUserPhoto = user.profileImage!;
      }
    }

    final tempId = "temp_${DateTime.now().millisecondsSinceEpoch}";
    final bool isQ = isQuestion || trimmed.contains('?');

    final optimisticMsg = WebinarChatMessage(
      id: tempId,
      userName: currentUserName,
      userAvatar: currentUserPhoto,
      time: "Just now",
      message: trimmed,
      isQuestion: isQ,
    );

    // Optimistic append in natural top-to-bottom order
    chatMessages.add(optimisticMsg);
    if (isQ) {
      qaMessages.add(optimisticMsg);
    }

    chatInputController.clear();

    // Call API to persist comment: POST /api/webinars/{id}/comments
    try {
      final response = await _apiClient.post(
        "${ApiConstants.getWebinars}/$webinarId/comments",
        data: {'comment': trimmed},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final resData = response.data;
        if (resData is Map<String, dynamic> && resData['data'] is Map<String, dynamic>) {
          final serverComment = WebinarChatMessage.fromApiJson(resData['data'] as Map<String, dynamic>);

          final idx = chatMessages.indexWhere((m) => m.id == tempId);
          if (idx != -1) {
            chatMessages[idx] = serverComment;
            chatMessages.refresh();
          }

          final qIdx = qaMessages.indexWhere((m) => m.id == tempId);
          if (qIdx != -1) {
            qaMessages[qIdx] = serverComment;
            qaMessages.refresh();
          }
        }
        return true;
      } else {
        CustomSnackBar.showError(
          message: response.data?['message']?.toString() ?? "Failed to post comment",
        );
      }
    } catch (e) {
      print("ERROR_POST_COMMENT_API: $e");
      CustomSnackBar.showError(message: "Failed to post comment. Please try again.");
    } finally {
      isPostingComment.value = false;
    }
    return false;
  }

  void toggleMic() {
    HapticFeedback.lightImpact();
    isMicOn.value = !isMicOn.value;
    CustomSnackBar.showInfo(
      message: isMicOn.value ? "Microphone turned on" : "Microphone muted",
    );
  }

  void toggleCamera() {
    HapticFeedback.lightImpact();
    isCameraOn.value = !isCameraOn.value;
    CustomSnackBar.showInfo(
      message: isCameraOn.value ? "Camera turned on" : "Camera turned off",
    );
  }

  Future<AgoraJoinTokenData?> getWebinarJoinToken(int webinarId) async {
    isLoadingJoinToken.value = true;
    try {
      final response = await _apiClient.get(
        "${ApiConstants.getWebinars}/$webinarId/join-token",
      );

      if (response.statusCode == 200 && response.data != null) {
        final resData = response.data;
        if (resData is Map<String, dynamic>) {
          final data = AgoraJoinTokenData.fromJson(resData);
          agoraTokenData.value = data;
          return data;
        }
      }
      final msg = response.data?['message']?.toString() ?? "Could not get join token for webinar.";
      CustomSnackBar.showError(message: msg);
      return null;
    } catch (e) {
      print("ERROR_GET_JOIN_TOKEN: $e");
      String msg = "Webinar meeting has not started yet or access is restricted.";
      if (e is DioException && e.response?.data != null) {
        final res = e.response?.data;
        if (res is Map && res['message'] != null) {
          msg = res['message'].toString();
        }
      }
      CustomSnackBar.showError(message: msg);
      return null;
    } finally {
      isLoadingJoinToken.value = false;
    }
  }
}
