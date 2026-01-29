import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constent/api_constants.dart';
import '../../../../widgets/custom_image_view.dart';
import '../../../Auth/service/auth_service.dart';
import '../../data/model/matrimony_chat_response.dart';
import '../controller/matrimony_chat_controller.dart';
import 'package:intl/intl.dart';

class MatrimonyChatScreen extends GetView<MatrimonyChatController> {
  const MatrimonyChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.messages.isEmpty) {
                return const Center(child: CircularProgressIndicator(color: Colors.purple));
              }
              if (controller.messages.isEmpty) {
                return _buildEmptyState();
              }
              return ListView.builder(
                controller: controller.scrollController,
                padding: const EdgeInsets.all(16),
                reverse: true, // Show latest messages at bottom
                itemCount: controller.messages.length,
                itemBuilder: (context, index) {
                  return _buildMessageBubble(controller.messages[index]);
                },
              );
            }),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
        onPressed: () => Get.back(),
      ),
      title: Obx(() {
        final conv = controller.conversation.value;
        final currentUserId = Get.find<AuthService>().currentUser.value?.id;
        final otherUser = conv?.user1Id == currentUserId ? conv?.user2 : conv?.user1;
        final name = nameByOtherUserId() ?? otherUser?.name ?? "Chat";
        final imageUrl = otherUser?.profileImage != null ? ApiConstants.imageBaseUrl + otherUser!.profileImage! : null;

        return Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: SizedBox(
                width: 36,
                height: 36,
                child: CustomImageView(
                  url: imageUrl,
                  fit: BoxFit.cover,
                  placeHolder: (context, url) => Container(
                    color: Colors.purple.withOpacity(0.1),
                    child: const Icon(Icons.person, color: Colors.purple, size: 20),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Text(
                    "Online",
                    style: TextStyle(color: Colors.green, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
      actions: [
        IconButton(icon: const Icon(Icons.videocam_outlined, color: Colors.purple), onPressed: () {}),
        IconButton(icon: const Icon(Icons.call_outlined, color: Colors.purple), onPressed: () {}),
        const SizedBox(width: 4),
      ],
    );
  }

  String? nameByOtherUserId() {
     // If we passed a name or other user info via navigation, we could use it here
     return null;
  }

  Widget _buildMessageBubble(MatrimonyMessage message) {
    final bool isMe = message.senderId == Get.find<AuthService>().currentUser.value?.id;
    final time = message.createdAt != null 
        ? DateFormat('hh:mm a').format(DateTime.parse(message.createdAt!))
        : "";

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(
              bottom: 4,
              top: 4,
              left: isMe ? 60 : 0,
              right: isMe ? 0 : 60,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isMe ? Colors.purple : Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(20),
                topRight: const Radius.circular(20),
                bottomLeft: Radius.circular(isMe ? 20 : 0),
                bottomRight: Radius.circular(isMe ? 0 : 20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              message.messageText ?? "",
              style: TextStyle(
                color: isMe ? Colors.white : Colors.black87,
                fontSize: 15,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              time,
              style: TextStyle(color: Colors.grey[500], fontSize: 10),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.add, color: Colors.purple),
                onPressed: () {},
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: controller.messageController,
                  decoration: const InputDecoration(
                    hintText: "Type a message...",
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                  maxLines: null,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              decoration: const BoxDecoration(
                color: Colors.purple,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white, size: 20),
                onPressed: controller.sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.chat_bubble_outline, size: 60, color: Colors.purple),
          ),
          const SizedBox(height: 16),
          const Text(
            "No messages yet",
            style: TextStyle(color: Colors.grey, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            "Send a message to start the conversation",
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
