import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
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
            child: RefreshIndicator(
              color: Colors.purple,
              onRefresh: () async {
                await controller.refreshChat();
              },
              child: Obx(() {
                if (controller.isLoading.value && controller.messages.isEmpty) {
                  return const Center(child: CircularProgressIndicator(color: Colors.purple));
                }
                if (controller.messages.isEmpty) {
                  return _buildEmptyState();
                }
                return ListView.builder(
                  controller: controller.scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  reverse: true, // Show latest messages at bottom
                  itemCount: controller.messages.length,
                  itemBuilder: (context, index) {
                    return _buildMessageBubble(controller.messages[index]);
                  },
                );
              }),
            ),
          ),
          Obx(() {
            if (controller.isBlocked.value) {
              return _buildBlockedBottomBar();
            }
            return _buildMessageInput();
          }),
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
        final titleText = controller.rxUserName.value.trim().isNotEmpty
            ? controller.rxUserName.value.trim()
            : (controller.userName ?? "Chat");
        return Text(
          titleText,
          style: const TextStyle(
            color: Colors.black, 
            fontSize: 18, 
            fontWeight: FontWeight.bold,
          ),
          overflow: TextOverflow.ellipsis,
        );
      }),
      actions: [
        // IconButton(
        //   icon: const Icon(Icons.refresh, color: Colors.black87),
        //   tooltip: 'Refresh',
        //   onPressed: () => controller.refreshChat(),
        // ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.black87),
          tooltip: 'Options',
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          onSelected: (value) {
            if (value == 'block') {
              _showBlockDialog();
            } else if (value == 'unblock') {
              _showUnblockDialog();
            }
          },
          itemBuilder: (context) => [
            if (controller.isBlocked.value)
              PopupMenuItem(
                value: 'unblock',
                child: Row(
                  children: [
                    const Icon(Icons.lock_open_rounded, color: Color(0xFF00A884), size: 20),
                    const SizedBox(width: 10),
                    Text(
                      'unblock_user'.tr,
                      style: const TextStyle(
                        color: Color(0xFF00A884),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              )
            else
              PopupMenuItem(
                value: 'block',
                child: Row(
                  children: [
                    const Icon(Icons.block, color: Colors.red, size: 20),
                    const SizedBox(width: 10),
                    Text(
                      'block_user'.tr,
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  void _showBlockDialog() {
    final titleText = controller.rxUserName.value.trim().isNotEmpty
        ? controller.rxUserName.value.trim()
        : (controller.userName ?? "User");
    bool isSubmitting = false;

    Get.dialog(
      StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.block_rounded, color: Colors.red, size: 36),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    titleText.isNotEmpty ? "${'block_user'.tr} - $titleText" : 'block_confirm_title'.tr,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'block_confirm_message'.tr,
                    style: TextStyle(
                      fontSize: 13.5,
                      color: Colors.grey.shade600,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: isSubmitting ? null : () => Navigator.of(dialogContext).pop(),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            side: BorderSide(color: Colors.grey.shade300),
                          ),
                          child: Text(
                            'cancel'.tr,
                            style: const TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: isSubmitting
                              ? null
                              : () async {
                                  setDialogState(() => isSubmitting = true);
                                  final success = await controller.blockUser();
                                  setDialogState(() => isSubmitting = false);
                                  if (success) {
                                    Navigator.of(dialogContext).pop();
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                          ),
                          child: isSubmitting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  'block_user'.tr,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showUnblockDialog() {
    final titleText = controller.rxUserName.value.trim().isNotEmpty
        ? controller.rxUserName.value.trim()
        : (controller.userName ?? "User");
    bool isSubmitting = false;

    Get.dialog(
      StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00A884).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.lock_open_rounded, color: Color(0xFF00A884), size: 36),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    titleText.isNotEmpty ? "${'unblock_user'.tr} - $titleText" : 'unblock_confirm_title'.tr,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'unblock_confirm_message'.tr,
                    style: TextStyle(
                      fontSize: 13.5,
                      color: Colors.grey.shade600,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: isSubmitting
                              ? null
                              : () {
                                  if (Get.isDialogOpen == true) {
                                    Get.back();
                                  } else if (dialogContext.mounted && Navigator.of(dialogContext).canPop()) {
                                    Navigator.of(dialogContext).pop();
                                  }
                                },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            side: BorderSide(color: Colors.grey.shade300),
                          ),
                          child: Text(
                            'cancel'.tr,
                            style: const TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: isSubmitting
                              ? () {}
                              : () async {
                                  setDialogState(() => isSubmitting = true);
                                  final success = await controller.unblockUser();
                                  if (success) {
                                    if (Get.isDialogOpen == true) {
                                      Get.back();
                                    } else if (dialogContext.mounted && Navigator.of(dialogContext).canPop()) {
                                      Navigator.of(dialogContext).pop();
                                    }
                                  } else {
                                    setDialogState(() => isSubmitting = false);
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00A884),
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: const Color(0xFF00A884),
                            disabledForegroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                          ),
                          child: isSubmitting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  'unblock'.tr,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBlockedBottomBar() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // System message pill: "You blocked this user. Tap to unblock."
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: InkWell(
            onTap: () => _showUnblockDialog(),
            borderRadius: BorderRadius.circular(10),
            child: Text(
              'you_blocked_user_tap_to_unblock'.tr,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        // WhatsApp style bottom bar: Unblock
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Colors.grey.shade200, width: 1)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 6,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 52,
              child: InkWell(
                onTap: () => _showUnblockDialog(),
                child: Center(
                  child: Text(
                    'unblock'.tr,
                    style: const TextStyle(
                      color: Color(0xFF00A884),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
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
        ? DateFormat('hh:mm a').format(DateTime.parse(message.createdAt!).toLocal())
        : "";

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              constraints: BoxConstraints(
                maxWidth: Get.width * 0.85,
                minWidth: message.messageType == 'image' ? 0 : 60,
              ),
              margin: EdgeInsets.only(
                left: isMe ? 40 : 12,
                right: isMe ? 12 : 40,
              ),
              decoration: message.messageType == 'image' 
                ? null // No decoration for pure images
                : BoxDecoration(
                    color: isMe ? const Color(0xFF8E24AA) : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isMe ? 16 : 4),
                      bottomRight: Radius.circular(isMe ? 4 : 16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Column(
                  crossAxisAlignment: message.messageType == 'image' 
                      ? CrossAxisAlignment.stretch 
                      : CrossAxisAlignment.start,
                  children: [
                    if (message.messageType == 'image' && message.attachmentPath != null)
                      GestureDetector(
                        onTap: () => Get.to(() => Scaffold(
                          backgroundColor: Colors.black,
                          appBar: AppBar(
                            backgroundColor: Colors.black,
                            elevation: 0,
                            leading: IconButton(
                              icon: const Icon(Icons.close, color: Colors.white),
                              onPressed: () => Get.back(),
                            ),
                          ),
                          body: Center(
                            child: InteractiveViewer(
                              minScale: 0.5,
                              maxScale: 4.0,
                              child: CustomImageView(
                                url: ApiConstants.imageBaseUrl + message.attachmentPath!,
                                fit: BoxFit.contain,
                                width: double.infinity,
                                height: double.infinity,
                              ),
                            ),
                          ),
                        )),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey[200]!, width: 0.5),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: CustomImageView(
                              url: ApiConstants.imageBaseUrl + message.attachmentPath!,
                              fit: BoxFit.cover,
                              height: 250,
                              width: double.infinity,
                              placeHolder: (context, url) => Container(
                                height: 250,
                                color: Colors.grey[100],
                                child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                              ),
                            ),
                          ),
                        ),
                      ),
                    if (message.messageText != null && message.messageText!.isNotEmpty && message.messageText != "image")
                      Container(
                        width: message.messageType == 'image' ? double.infinity : null,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: message.messageType == 'image' 
                          ? BoxDecoration(
                              color: isMe ? const Color(0xFF8E24AA) : Colors.white,
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(16),
                                bottomRight: Radius.circular(16),
                              ),
                            )
                          : null,
                        child: Text(
                          message.messageText!,
                          style: TextStyle(
                            color: isMe ? Colors.white : Colors.black87,
                            fontSize: 15,
                            height: 1.3,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                left: isMe ? 0 : 16,
                right: isMe ? 16 : 0,
                top: 4,
              ),
              child: Text(
                time,
                style: TextStyle(color: Colors.grey[500], fontSize: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _showAttachmentSheet(),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add_rounded, color: Colors.purple, size: 22),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller.messageController,
              cursorColor: Colors.purple,
              style: const TextStyle(fontSize: 15),
              decoration: InputDecoration(
                hintText: "type_message".tr,
                hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
                contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                fillColor: const Color(0xFFF5F5F7),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
              maxLines: 4,
              minLines: 1,
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () {
              if (!controller.isSending.value) {
                controller.sendMessage();
              }
            },
            child: Obx(() => Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Colors.purple,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.purpleAccent,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: controller.isSending.value
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.send_rounded, color: Colors.white, size: 20),
            )),
          ),
        ],
      ),
    );
  }

  void _showAttachmentSheet() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Select Attachment",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildAttachmentOption(
                  icon: Icons.camera_alt,
                  label: "Camera",
                  onTap: () {
                    Get.back();
                    controller.pickImage(ImageSource.camera);
                  },
                ),
                _buildAttachmentOption(
                  icon: Icons.photo_library,
                  label: "Gallery",
                  onTap: () {
                    Get.back();
                    controller.pickMultipleImages();
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.purple, size: 30),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Center(
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
                Text(
                  "no_messages_yet".tr,
                  style: const TextStyle(color: Colors.grey, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  "start_conversation".tr,
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
