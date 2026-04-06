import 'dart:io';
import 'package:edu_cluezer/core/network/multipart.dart';
import 'package:edu_cluezer/widgets/custom_snack_bar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:edu_cluezer/features/matrimony/presentation/page/matrimony_attachment_preview_screen.dart';
import '../../../Auth/service/auth_service.dart';
import '../../data/model/matrimony_chat_response.dart';
import '../../domain/repository/matrimony_repository.dart';

class MatrimonyChatController extends GetxController {
  final MatrimonyRepository _repository = Get.find<MatrimonyRepository>();
  final AuthService _authService = Get.find<AuthService>();

  final RxBool isLoading = false.obs;
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

  @override
  void onInit() {
    super.onInit();
    conversationId = Get.arguments['conversation_id'];
    otherUserId = Get.arguments['other_user_id'];
    userName = Get.arguments['user_name'];


    print("conversationId : $conversationId  otherUserId: $otherUserId userName: $userName");

    if (conversationId != null) {
      fetchMessages();
    } else if (otherUserId != null) {
      // Logic to find or initiate conversation if id not provided
      fetchConversationsAndFindOne();
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
        _scrollToBottom();
      }
    } catch (e) {
      CustomSnackBar.showError(message: "Failed to fetch messages: $e");
    } finally {
      isLoading.value = false;
    }
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
          fetchMessages();
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
    if (text.isEmpty && selectedFiles.isEmpty) return;

    isLoading.value = true;
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
            // Handle specific failure if needed
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
        }
      }
    } catch (e) {
      CustomSnackBar.showError(message: "Failed to send message: $e");
    } finally {
      isLoading.value = false;
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

  @override
  void onClose() {
    messageController.dispose();
    scrollController.dispose();
    previewPageController.dispose();
    super.onClose();
  }
}
