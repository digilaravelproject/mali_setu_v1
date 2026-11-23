import 'dart:io';
import 'package:edu_cluezer/core/network/multipart.dart';
import 'package:edu_cluezer/widgets/custom_snack_bar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:edu_cluezer/features/matrimony/presentation/page/matrimony_attachment_preview_screen.dart';
import '../../../Auth/service/auth_service.dart';
import '../../data/model/matrimony_chat_response.dart';
import '../../data/model/search_matrimony_response.dart';
import '../../domain/repository/matrimony_repository.dart';
import 'matrimony_members_controller.dart';
import 'matrimony_controller.dart';
import 'matrimony_requests_controller.dart';

class MatrimonyChatController extends GetxController {
  final MatrimonyRepository _repository = Get.find<MatrimonyRepository>();
  final AuthService _authService = Get.find<AuthService>();

  final RxBool isLoading = false.obs;
  final RxBool isSending = false.obs;
  final RxBool isBlocked = false.obs;
  final RxList<MatrimonyMessage> messages = <MatrimonyMessage>[].obs;
  final Rx<MatrimonyConversation?> conversation = Rx<MatrimonyConversation?>(null);
  
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();
  final RxList<File> selectedFiles = <File>[].obs;
  final RxInt currentPreviewIndex = 0.obs;
  final PageController previewPageController = PageController();

  int? conversationId;
  int? otherUserId;
  String? userName;
  final RxString rxUserName = 'Chat'.obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments is Map) {
      conversationId = Get.arguments['conversation_id'];
      otherUserId = Get.arguments['other_user_id'];
      if (Get.arguments['is_blocked'] != null) {
        isBlocked.value = Get.arguments['is_blocked'] == true;
      }
      final rawName = Get.arguments['user_name']?.toString() ?? '';
      userName = rawName;
      if (_isValidPersonName(rawName)) {
        rxUserName.value = rawName;
      }
    } else {
      userName = Get.arguments?.toString();
      if (_isValidPersonName(userName)) {
        rxUserName.value = userName!;
      }
    }

    // Also check if conversation is known to be blocked from MatrimonyMembersController
    if (Get.isRegistered<MatrimonyMembersController>()) {
      final match = Get.find<MatrimonyMembersController>().members.firstWhereOrNull((c) =>
          (conversationId != null && c.id == conversationId) ||
          (otherUserId != null && (c.user1Id == otherUserId || c.user2Id == otherUserId || c.user1?.userId == otherUserId || c.user2?.userId == otherUserId)));
      if (match != null && match.isBlock != null) {
        isBlocked.value = match.isBlock == true;
      }
    }

    print("conversationId : $conversationId  otherUserId: $otherUserId isBlocked: ${isBlocked.value} userName: ${rxUserName.value}");

    if (conversationId != null) {
      fetchMessages();
    } else if (otherUserId != null) {
      // Logic to find or initiate conversation if id not provided
      fetchConversationsAndFindOne();
    }
  }

  /// Re-sync when switching conversations or re-opening with new arguments
  void updateConversation({int? convId, int? otherUserId, String? userName, bool? isBlocked}) {
    if (convId != null) conversationId = convId;
    if (otherUserId != null) this.otherUserId = otherUserId;
    if (isBlocked != null) this.isBlocked.value = isBlocked;
    if (userName != null && _isValidPersonName(userName)) {
      rxUserName.value = userName;
      this.userName = userName;
    }
    messages.clear();
    if (conversationId != null) {
      fetchMessages();
    } else if (this.otherUserId != null) {
      fetchConversationsAndFindOne();
    }
  }

  Future<void> refreshChat() async {
    if (conversationId != null) {
      await fetchMessages();
    } else if (otherUserId != null) {
      await fetchConversationsAndFindOne();
    }
  }

  Future<void> fetchMessages() async {
    if (conversationId == null) return;
    isLoading.value = true;
    try {
      final response = await _repository.getMessages(conversationId!);
      if (response.success == true && response.data != null) {
        messages.value = response.data!.messages?.data ?? [];
        conversation.value = response.data!.conversation;
        if (response.data!.conversation?.isBlock != null) {
          isBlocked.value = response.data!.conversation!.isBlock == true;
        } else if (!isBlocked.value) {
          _checkBlockStatusFromConversations();
        }
        _resolveOtherUserName();
        _scrollToBottom();
      }
    } catch (e) {
      CustomSnackBar.showError(message: "Failed to fetch messages: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _checkBlockStatusFromConversations() async {
    try {
      if (Get.isRegistered<MatrimonyMembersController>()) {
        final existing = Get.find<MatrimonyMembersController>().members.firstWhereOrNull(
          (c) => (conversationId != null && c.id == conversationId) ||
                 (otherUserId != null && (c.user1Id == otherUserId || c.user2Id == otherUserId || c.user1?.userId == otherUserId || c.user2?.userId == otherUserId)),
        );
        if (existing != null && existing.isBlock != null) {
          isBlocked.value = existing.isBlock == true;
          return;
        }
      }
      final convRes = await _repository.getConversations();
      if (convRes.success == true && convRes.data?.conversations != null) {
        final match = convRes.data!.conversations!.firstWhereOrNull(
          (c) => (conversationId != null && c.id == conversationId) ||
                 (otherUserId != null && (c.user1Id == otherUserId || c.user2Id == otherUserId || c.user1?.userId == otherUserId || c.user2?.userId == otherUserId)),
        );
        if (match != null && match.isBlock == true) {
          isBlocked.value = true;
          if (Get.isRegistered<MatrimonyMembersController>()) {
            Get.find<MatrimonyMembersController>().updateBlockStatusByUserId(otherUserId ?? match.user1Id ?? 0, true);
          }
        }
      }
    } catch (_) {}
  }

  /// Automatically resolves the correct sender / chat partner's real name from the conversation data
  void _resolveOtherUserName() {
    final currentUserId = _authService.currentUser.value?.id;
    final conv = conversation.value;

    // 1. Try from conversation participants (user1 / user2)
    if (conv != null) {
      MatrimonyProfile? otherProfile;

      // Identify which participant is the OTHER person
      if (currentUserId != null) {
        if (conv.user1Id == currentUserId || conv.user1?.userId == currentUserId) {
          otherProfile = conv.user2;
          otherUserId ??= conv.user2Id ?? conv.user2?.userId;
        } else if (conv.user2Id == currentUserId || conv.user2?.userId == currentUserId) {
          otherProfile = conv.user1;
          otherUserId ??= conv.user1Id ?? conv.user1?.userId;
        }
      }

      // If otherUserId was explicitly provided, match by otherUserId
      if (otherProfile == null && otherUserId != null) {
        if (conv.user1Id == otherUserId || conv.user1?.userId == otherUserId) {
          otherProfile = conv.user1;
        } else if (conv.user2Id == otherUserId || conv.user2?.userId == otherUserId) {
          otherProfile = conv.user2;
        }
      }

      if (otherProfile != null) {
        final profileName = _extractNameFromProfile(otherProfile);
        if (_isValidPersonName(profileName)) {
          rxUserName.value = profileName;
          userName = profileName;
          return;
        }
      }
    }

    // 2. Try from messages list: find any message where senderId != currentUserId
    for (final msg in messages) {
      if (currentUserId != null && msg.senderId != null && msg.senderId != currentUserId) {
        otherUserId ??= msg.senderId;
        final senderName = msg.sender?.name?.trim() ?? '';
        if (_isValidPersonName(senderName)) {
          rxUserName.value = senderName;
          userName = senderName;
          return;
        }
      }
    }

    // 3. Fallback: fetch profile from API if otherUserId is known
    if (otherUserId != null && (!_isValidPersonName(rxUserName.value) || rxUserName.value == 'Chat')) {
      _fetchOtherUserProfileName(otherUserId!);
    }
  }

  String _extractNameFromProfile(MatrimonyProfile? profile) {
    if (profile == null) return '';
    final pName = profile.personalDetails?.name?.trim() ?? '';
    if (pName.isNotEmpty) return pName;

    final uName = profile.user?.name?.trim() ?? '';
    if (uName.isNotEmpty) return uName;

    return '';
  }

  bool _isValidPersonName(String? name) {
    if (name == null) return false;
    final trimmed = name.trim();
    if (trimmed.isEmpty) return false;
    final lower = trimmed.toLowerCase();
    if (lower == 'chat' ||
        lower == 'member' ||
        lower == 'new message' ||
        lower == 'new messages' ||
        lower == 'new chat message' ||
        lower == 'chat message' ||
        lower == 'message' ||
        lower == 'messages' ||
        lower == 'notification' ||
        lower == 'notifications' ||
        lower == 'mali setu' ||
        lower == 'mali_setu' ||
        lower == 'null') {
      return false;
    }
    return true;
  }

  Future<void> _fetchOtherUserProfileName(int userId) async {
    try {
      final res = await _repository.getProfiles(userId);
      if (res != null && res is Map<String, dynamic>) {
        final profile = res['data']?['profile'] ?? res['data'] ?? res['profile'];
        if (profile is Map<String, dynamic>) {
          final personal = profile['personal_details'] as Map<String, dynamic>?;
          final fName = personal?['first_name']?.toString() ?? '';
          final lName = personal?['last_name']?.toString() ?? '';
          final pName = personal?['name']?.toString() ?? '';
          final combined = [fName, lName].where((s) => s.isNotEmpty).join(' ');
          final resolved = combined.isNotEmpty ? combined : pName;
          if (_isValidPersonName(resolved)) {
            rxUserName.value = resolved;
            userName = resolved;
          }
        }
      }
    } catch (_) {}
  }

  Future<void> fetchConversationsAndFindOne() async {
    isLoading.value = true;
    try {
      final response = await _repository.getConversations();
      if (response.success == true && response.data?.conversations != null) {
        final existing = response.data!.conversations!.firstWhereOrNull((c) => 
          c.user1Id == otherUserId || c.user2Id == otherUserId
        );
        if (existing != null) {
          conversationId = existing.id;
          if (existing.isBlock != null) {
            isBlocked.value = existing.isBlock == true;
          }
          await fetchMessages();
        } else {
          // If no conversation exists, it will be created on first message
          // Or we could have an explicit create conversation API
        }
      }
    } catch (e) {
      CustomSnackBar.showError(message: "Failed to find conversation: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> sendMessage() async {
    final text = messageController.text.trim();
    if ((text.isEmpty && selectedFiles.isEmpty) || isSending.value) return;

    isSending.value = true;
    try {
      if (selectedFiles.isNotEmpty) {
        // Send each image as a separate message
        for (int i = 0; i < selectedFiles.length; i++) {
          final file = selectedFiles[i];
          final Map<String, String> body = {
            // Attach the text caption to the first image ONLY
            "message_text": (i == 0 && text.isNotEmpty) ? text : "image",
            "message_type": "image",
          };

          if (conversationId != null) {
            body["conversation_id"] = conversationId.toString();
          } else if (otherUserId != null) {
            body["receiver_id"] = otherUserId.toString();
          }

          final List<MultipartBody> multipartBody = [
            MultipartBody(key: "attachment", file: file),
          ];

          final response = await _repository.sendMessageWithFile(body, multipartBody);
          if (response['success'] == true) {
            if (conversationId == null && response['data'] != null) {
              final newMsg = MatrimonyMessage.fromJson(response['data']['message']);
              conversationId = newMsg.conversationId;
            }
          } else {
            CustomSnackBar.showError(message: response['message'] ?? "Failed to send attachment");
          }
        }
        _handleSendMessageSuccess(null); // Clear everything
      } else {
        // Send text only
        final Map<String, dynamic> data = {
          "message_text": text,
          "message_type": "text",
          "attachment": ""
        };

        if (conversationId != null) {
          data["conversation_id"] = conversationId.toString();
        } else if (otherUserId != null) {
          data["receiver_id"] = otherUserId.toString();
        }

        final response = await _repository.sendMessage(data);
        if (response['success'] == true) {
          _handleSendMessageSuccess(response);
        } else {
          CustomSnackBar.showError(message: response['message'] ?? "Failed to send message");
        }
      }
    } catch (e) {
      CustomSnackBar.showError(message: "Failed to send message: $e");
    } finally {
      isSending.value = false;
    }
  }

  void _handleSendMessageSuccess(dynamic response) {
    messageController.clear();
    selectedFiles.clear();
    if (response != null && conversationId == null && response['data'] != null) {
      final newMsg = MatrimonyMessage.fromJson(response['data']['message']);
      conversationId = newMsg.conversationId;
    }
    fetchMessages();
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source, imageQuality: 70);
      if (image != null) {
        selectedFiles.add(File(image.path));
        currentPreviewIndex.value = selectedFiles.length - 1;
        _navigateToPreview();
        // If already in preview, jump to last page
        if (previewPageController.hasClients) {
          previewPageController.jumpToPage(selectedFiles.length - 1);
        }
      }
    } catch (e) {
      CustomSnackBar.showError(message: "Failed to pick image: $e");
    }
  }

  Future<void> pickMultipleImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(imageQuality: 70);
      if (images.isNotEmpty) {
        selectedFiles.addAll(images.map((img) => File(img.path)));
        currentPreviewIndex.value = 0;
        _navigateToPreview();
        // If already in preview, jump to first page or stay
        if (previewPageController.hasClients) {
          previewPageController.jumpToPage(0);
        }
      }
    } catch (e) {
      CustomSnackBar.showError(message: "Failed to pick images: $e");
    }
  }

  void _navigateToPreview() {
    if (selectedFiles.isNotEmpty) {
      Get.to(() => const MatrimonyAttachmentPreviewScreen());
    }
  }

  void removeFile(int index) {
    selectedFiles.removeAt(index);
  }

  void clearSelectedFiles() {
    selectedFiles.clear();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<bool> blockUser() async {
    final targetId = otherUserId ?? conversation.value?.user2Id ?? conversation.value?.user1Id;
    if (targetId == null) {
      CustomSnackBar.showError(message: "User ID not found");
      return false;
    }
    return blockUserById(targetId);
  }

  Future<bool> blockUserById(int userId) async {
    try {
      final data = {
        "blocked_user_id": userId,
      };
      print("BLOCK USER REQUEST: $data");
      final response = await _repository.blockUser(data);
      print("BLOCK USER RESPONSE: $response");
      if (response != null &&
          (response['success'] == true ||
           response['status'] == true ||
           response['status'] == 'success' ||
           response['status'] == 200 ||
           response['code'] == 200 ||
           (response is Map && (response['message'] != null && response['error'] == null)))) {
        CustomSnackBar.showSuccess(message: response['message'] ?? 'user_blocked'.tr);
        isBlocked.value = true;

        // Update block status in members list
        if (Get.isRegistered<MatrimonyMembersController>()) {
          Get.find<MatrimonyMembersController>().updateBlockStatusByUserId(userId, true);
        }
        // Remove from matrimony feed/cards
        if (Get.isRegistered<MatrimonyController>()) {
          Get.find<MatrimonyController>().removeProfileById(userId);
        }
        // Remove from requests list
        if (Get.isRegistered<MatrimonyRequestsController>()) {
          Get.find<MatrimonyRequestsController>().removeRequestByUserId(userId);
        }
        return true;
      } else {
        final msg = response is Map ? (response['message'] ?? response['error']) : null;
        CustomSnackBar.showError(message: msg ?? 'Failed to block user');
        return false;
      }
    } catch (e) {
      print("BLOCK USER ERROR: $e");
      CustomSnackBar.showError(message: "Failed to block user: $e");
      return false;
    }
  }

  Future<bool> unblockUser() async {
    final targetId = otherUserId ?? conversation.value?.user2Id ?? conversation.value?.user1Id;
    if (targetId == null) {
      CustomSnackBar.showError(message: "User ID not found");
      return false;
    }
    return unblockUserById(targetId);
  }

  Future<bool> unblockUserById(int userId) async {
    try {
      final data = {
        "blocked_user_id": userId,
        "user_id": userId,
      };
      print("UNBLOCK USER REQUEST: $data");
      final response = await _repository.unblockUser(data);
      print("UNBLOCK USER RESPONSE: $response");
      if (response != null &&
          (response['success'] == true ||
           response['status'] == true ||
           response['status'] == 'success' ||
           response['status'] == 200 ||
           response['code'] == 200 ||
           (response is Map && (response['message'] != null && response['error'] == null)))) {
        CustomSnackBar.showSuccess(message: response['message'] ?? 'user_unblocked'.tr);
        isBlocked.value = false;
        if (Get.isRegistered<MatrimonyMembersController>()) {
          Get.find<MatrimonyMembersController>().updateBlockStatusByUserId(userId, false);
        }
        return true;
      } else {
        isBlocked.value = false;
        if (Get.isRegistered<MatrimonyMembersController>()) {
          Get.find<MatrimonyMembersController>().updateBlockStatusByUserId(userId, false);
        }
        CustomSnackBar.showSuccess(message: 'user_unblocked'.tr);
        return true;
      }
    } catch (e) {
      print("UNBLOCK USER ERROR: $e");
      isBlocked.value = false;
      if (Get.isRegistered<MatrimonyMembersController>()) {
        Get.find<MatrimonyMembersController>().updateBlockStatusByUserId(userId, false);
      }
      CustomSnackBar.showSuccess(message: 'user_unblocked'.tr);
      return true;
    }
  }

  @override
  void onClose() {
    messageController.dispose();
    scrollController.dispose();
    previewPageController.dispose();
    super.onClose();
  }
}
