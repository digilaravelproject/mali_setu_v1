import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../widgets/custom_snack_bar.dart';
import '../../data/models/webinar_model.dart';
import '../controllers/webinars_controller.dart';

class WebinarLiveScreen extends StatefulWidget {
  final Webinar webinar;

  const WebinarLiveScreen({
    super.key,
    required this.webinar,
  });

  @override
  State<WebinarLiveScreen> createState() => _WebinarLiveScreenState();
}

class _WebinarLiveScreenState extends State<WebinarLiveScreen> {
  final controller = Get.find<WebinarsController>();
  final ScrollController _commentsScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    controller.liveViewerCount.value = widget.webinar.registeredCount;
    controller.fetchWebinarComments(widget.webinar.id, isRefresh: true);
  }

  @override
  void dispose() {
    _commentsScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Column(
          children: [
            // Top Header Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  // Back button + Title
                  GestureDetector(
                    onTap: () => Get.back(),
                    behavior: HitTestBehavior.opaque,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 18,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFFEF4444),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          "Live Webinar",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // 🔴 LIVE Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(radius: 3, backgroundColor: Colors.white),
                        SizedBox(width: 4),
                        Text(
                          "LIVE",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // 👥 Viewer Count Badge
                  Obx(() {
                    final count = controller.liveViewerCount.value;
                    if (count <= 0) return const SizedBox.shrink();
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.14),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(CupertinoIcons.person_2_fill, size: 12, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            "$count",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),

            // Video Player Area
            AspectRatio(
              aspectRatio: 16 / 9.5,
              child: Stack(
                children: [
                  // Speaker Video Feed / Thumbnail
                  Positioned.fill(
                    child: CachedNetworkImage(
                      imageUrl: widget.webinar.videoThumbnailUrl,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => Container(
                        color: Colors.black,
                        child: const Center(
                          child: Icon(Icons.person, size: 60, color: Colors.white38),
                        ),
                      ),
                    ),
                  ),

                  // Dark gradient overlay
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),

                  // Host / Speaker Badge at bottom-left of video
                  Positioned(
                    left: 12,
                    bottom: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.mic, color: Color(0xFF10B981), size: 13),
                          const SizedBox(width: 5),
                          Text(
                            "${widget.webinar.speaker.name} (Speaker)",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Interactive Controls Bar (Mic, Camera, Chat, Participants, Leave)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              color: const Color(0xFF1E293B),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // 1. Mic
                  Obx(() {
                    final isOn = controller.isMicOn.value;
                    return _buildControlButton(
                      icon: isOn ? Icons.mic_rounded : Icons.mic_off_rounded,
                      label: "Mic",
                      isActive: isOn,
                      onTap: controller.toggleMic,
                    );
                  }),

                  // 2. Camera
                  Obx(() {
                    final isOn = controller.isCameraOn.value;
                    return _buildControlButton(
                      icon: isOn ? Icons.videocam_rounded : Icons.videocam_off_rounded,
                      label: "Camera",
                      isActive: isOn,
                      onTap: controller.toggleCamera,
                    );
                  }),

                  // 3. Chat
                  _buildControlButton(
                    icon: CupertinoIcons.chat_bubble_2_fill,
                    label: "Chat",
                    isActive: true,
                    onTap: () {
                      controller.activeLiveTab.value = 1;
                    },
                  ),

                  // 4. Participants
                  _buildControlButton(
                    icon: CupertinoIcons.person_3_fill,
                    label: "Participants",
                    isActive: false,
                    onTap: () {
                      CustomSnackBar.showInfo(
                        message: "${controller.liveViewerCount.value} Community members currently watching",
                      );
                    },
                  ),

                  // 5. Leave Button
                  _buildControlButton(
                    icon: Icons.call_end_rounded,
                    label: "Leave",
                    isActive: false,
                    isDestructive: true,
                    onTap: () {
                      Get.back();
                      CustomSnackBar.showInfo(message: "Left webinar session");
                    },
                  ),
                ],
              ),
            ),

            // Lower Section: Q&A and Live Chat Tabs + Messages List
            Expanded(
              child: Container(
                color: Colors.white,
                child: Column(
                  children: [
                    // Tab Bar: Q&A | Live Chat (with clean underline indicator)
                    Obx(() {
                      final selected = controller.activeLiveTab.value;
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          border: Border(
                            bottom: BorderSide(color: Color(0xFFE2E8F0)),
                          ),
                        ),
                        child: Row(
                          children: [
                            _buildTabItem(
                              title: "Q&A",
                              count: controller.qaMessages.length,
                              isSelected: selected == 0,
                              onTap: () => controller.activeLiveTab.value = 0,
                            ),
                            const SizedBox(width: 8),
                            _buildTabItem(
                              title: "Live Chat",
                              count: controller.chatMessages.length,
                              isSelected: selected == 1,
                              onTap: () => controller.activeLiveTab.value = 1,
                            ),
                          ],
                        ),
                      );
                    }),

                    // Messages List (Top-to-Bottom display)
                    Expanded(
                      child: Obx(() {
                        if (controller.isLoadingComments.value && controller.chatMessages.isEmpty) {
                          return const Center(child: CupertinoActivityIndicator());
                        }

                        final isQA = controller.activeLiveTab.value == 0;
                        final list = isQA ? controller.qaMessages : controller.chatMessages;

                        if (list.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFF1F5F9),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      isQA ? Icons.help_outline_rounded : Icons.chat_bubble_outline_rounded,
                                      size: 32,
                                      color: const Color(0xFF94A3B8),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    isQA ? "No questions yet" : "No comments yet",
                                    style: const TextStyle(
                                      color: Color(0xFF475569),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    isQA
                                        ? "Be the first to ask a question!"
                                        : "Be the first to comment in this session.",
                                    style: const TextStyle(
                                      color: Color(0xFF94A3B8),
                                      fontSize: 12,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        // Display top to bottom
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (_commentsScrollController.hasClients) {
                            _commentsScrollController.animateTo(
                              _commentsScrollController.position.maxScrollExtent,
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeOut,
                            );
                          }
                        });

                        return ListView.separated(
                          controller: _commentsScrollController,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          reverse: false,
                          itemCount: list.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final msg = list[index];
                            return _buildMessageItem(msg);
                          },
                        );
                      }),
                    ),

                    // Bottom Chat / Q&A Input Field
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      child: SafeArea(
                        top: false,
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: Obx(() {
                                  final isQA = controller.activeLiveTab.value == 0;
                                  return TextField(
                                    controller: controller.chatInputController,
                                    style: const TextStyle(fontSize: 13.5, color: Color(0xFF1E293B)),
                                    decoration: InputDecoration(
                                      hintText: isQA ? "Ask a question..." : "Say something...",
                                      hintStyle: TextStyle(fontSize: 13, color: Colors.grey[500]),
                                      border: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      filled: false,
                                      contentPadding: const EdgeInsets.symmetric(vertical: 11),
                                    ),
                                    onSubmitted: (text) {
                                      controller.sendLiveMessage(
                                        widget.webinar.id,
                                        text,
                                        isQuestion: controller.activeLiveTab.value == 0,
                                      );
                                    },
                                  );
                                }),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Obx(() {
                              final isPosting = controller.isPostingComment.value;
                              return GestureDetector(
                                onTap: isPosting
                                    ? null
                                    : () {
                                        controller.sendLiveMessage(
                                          widget.webinar.id,
                                          controller.chatInputController.text,
                                          isQuestion: controller.activeLiveTab.value == 0,
                                        );
                                      },
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: const BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: isPosting
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CupertinoActivityIndicator(
                                            color: Colors.white,
                                            radius: 7,
                                          ),
                                        )
                                      : const Icon(
                                          Icons.send_rounded,
                                          size: 16,
                                          color: Colors.white,
                                        ),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required bool isActive,
    bool isDestructive = false,
    required VoidCallback onTap,
  }) {
    final bgColor = isDestructive
        ? const Color(0xFFEF4444)
        : (isActive ? AppColors.primary : Colors.white.withOpacity(0.12));

    final labelColor = isDestructive ? const Color(0xFFF87171) : Colors.white70;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 18,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: labelColor,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem({
    required String title,
    required int count,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: isSelected ? AppColors.primaryDark : const Color(0xFF64748B),
                    fontSize: 13.5,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  ),
                ),
                if (count > 0) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primaryLight : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      "$count",
                      style: TextStyle(
                        color: isSelected ? AppColors.primary : const Color(0xFF64748B),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Container(
            height: 2.5,
            width: 44,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageItem(WebinarChatMessage msg) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 15,
          backgroundColor: AppColors.primaryLight,
          backgroundImage: msg.userAvatar.isNotEmpty ? NetworkImage(msg.userAvatar) : null,
          child: msg.userAvatar.isEmpty
              ? Text(
                  msg.userName.isNotEmpty ? msg.userName[0].toUpperCase() : "U",
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                )
              : null,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        msg.userName,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      if (msg.isQuestion) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            "Q",
                            style: TextStyle(
                              color: Color(0xFFD97706),
                              fontSize: 8.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  Text(
                    msg.time,
                    style: const TextStyle(
                      fontSize: 10.5,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                msg.message,
                style: const TextStyle(
                  fontSize: 12.5,
                  color: Color(0xFF475569),
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
