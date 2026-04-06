import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/matrimony_chat_controller.dart';

class MatrimonyAttachmentPreviewScreen extends GetView<MatrimonyChatController> {
  const MatrimonyAttachmentPreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () {
            controller.clearSelectedFiles();
            Get.back();
          },
        ),
        title: Obx(() => Text(
              "${controller.currentPreviewIndex.value + 1} of ${controller.selectedFiles.length}",
              style: const TextStyle(color: Colors.white, fontSize: 16),
            )),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (controller.selectedFiles.isEmpty) return const SizedBox.shrink();
              return PageView.builder(
                controller: controller.previewPageController,
                itemCount: controller.selectedFiles.length,
                onPageChanged: (index) => controller.currentPreviewIndex.value = index,
                itemBuilder: (context, index) {
                  return InteractiveViewer(
                    child: Center(
                      child: Image.file(
                        controller.selectedFiles[index],
                        fit: BoxFit.contain,
                        width: double.infinity,
                      ),
                    ),
                  );
                },
              );
            }),
          ),
          _buildBottomPanel(),
        ],
      ),
    );
  }

  Widget _buildBottomPanel() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.0),
            Colors.black.withOpacity(0.8),
            Colors.black,
          ],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(0, 16, 0, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildThumbnailList(),
          const SizedBox(height: 20),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildThumbnailList() {
    return SizedBox(
      height: 80, // Increased height to prevent clipping of the close button
      child: Obx(() {
        return ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), // Added vertical padding
          itemCount: controller.selectedFiles.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              // Add More button at the beginning
              return GestureDetector(
                onTap: () => controller.pickMultipleImages(),
                child: Container(
                  width: 60,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                       Icon(Icons.add, color: Colors.white, size: 20),
                       Text("Add", style: TextStyle(color: Colors.white70, fontSize: 10)),
                    ],
                  ),
                ),
              );
            }

            final fileIndex = index - 1;
            return Obx(() {
              final isSelected = controller.currentPreviewIndex.value == fileIndex;
              return GestureDetector(
                onTap: () {
                  controller.currentPreviewIndex.value = fileIndex;
                  controller.previewPageController.animateToPage(
                    fileIndex,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? Colors.purple : Colors.white24,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          controller.selectedFiles[fileIndex],
                          height: 60,
                          width: 60,
                          fit: BoxFit.cover,
                        ),
                      ),
                      if (isSelected && controller.selectedFiles.length > 1)
                        Positioned(
                          top: -10,
                          right: -10,
                          child: GestureDetector(
                            onTap: () {
                              controller.removeFile(fileIndex);
                              if (controller.selectedFiles.isEmpty) {
                                Get.back();
                              } else if (controller.currentPreviewIndex.value >= controller.selectedFiles.length) {
                                controller.currentPreviewIndex.value = controller.selectedFiles.length - 1;
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close, color: Colors.white, size: 12),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            });
          },
        );
      }),
    );
  }

  Widget _buildInputBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller.messageController,
              cursorColor: Colors.purple,
              style: const TextStyle(color: Colors.white, fontSize: 15),
              decoration: InputDecoration(
                hintText: "Add a caption...",
                hintStyle: TextStyle(color: Colors.white60, fontSize: 14),
                contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                fillColor: Colors.white12,
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
              if (!controller.isLoading.value) {
                controller.sendMessage();
                Get.back();
              }
            },
            child: Obx(() => Container(
              padding: const EdgeInsets.all(14),
              decoration: const BoxDecoration(
                color: Colors.purple,
                shape: BoxShape.circle,
              ),
              child: controller.isLoading.value
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.send, color: Colors.white, size: 24),
            )),
          ),
        ],
      ),
    );
  }
}
