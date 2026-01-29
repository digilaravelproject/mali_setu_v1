import 'package:flutter/material.dart';
import 'package:get/get.dart';
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

  int? conversationId;
  int? otherUserId;

  @override
  void onInit() {
    super.onInit();
    conversationId = Get.arguments['conversation_id'];
    otherUserId = Get.arguments['other_user_id'];
    
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
      Get.snackbar("Error", "Failed to fetch messages: $e");
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
      Get.snackbar("Error", "Failed to find conversation: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> sendMessage() async {
    final text = messageController.text.trim();
    if (text.isEmpty) return;

    // Optional: Optimistic UI update
    // final tempMsg = MatrimonyMessage(
    //   messageText: text,
    //   senderId: _authService.currentUser.value?.id,
    //   createdAt: DateTime.now().toIso8601String(),
    // );
    // messages.insert(0, tempMsg);

    try {
      final Map<String, dynamic> data = {
        "message_text": text,
        "message_type": "text",
        "attachment": ""
      };

      if (conversationId != null) {
        data["conversation_id"] = conversationId.toString();
      } else if (otherUserId != null) {
        // Assume backend creates conversation if id is missing but receiver is provided
        // Or specific endpoint for direct message
        data["receiver_id"] = otherUserId.toString();
      }

      final response = await _repository.sendMessage(data);
      if (response['success'] == true) {
        messageController.clear();
        if (conversationId == null && response['data'] != null) {
             final newMsg = MatrimonyMessage.fromJson(response['data']['message']);
             conversationId = newMsg.conversationId;
        }
        fetchMessages(); // Refresh to get the latest state from server
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to send message: $e");
    }
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
    super.onClose();
  }
}
