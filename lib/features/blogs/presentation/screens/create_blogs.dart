import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../widgets/custom_scaffold.dart';
import '../controller/create_blog_controller.dart';
import 'package:edu_cluezer/core/widgets/full_screen_image_viewer.dart';
import '../../../../widgets/basic_text_field.dart';

class CreateBlogScreen extends StatelessWidget {
  const CreateBlogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CreateBlogController());
    final primaryColor = context.theme.primaryColor;

    return Obx(() {
      controller.canExit.value; // Dummy read for Obx
      return CustomScaffold(
        onWillPop: controller.handleBack,
        // backgroundColor: Colors.white,
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.arrow_back),
          ),
          title: Text(
            'Create Blog',
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
          backgroundColor: const Color(0xFFFCE4EC),
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: primaryColor),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(() =>
                  AppInputTextField(
                    controller: controller.titleCtrl,
                    label: "Blog Title",
                    isRequired: true,
                    topPadding: 0,
                    errorText: controller.errors['title'],
                  )),
              const SizedBox(height: 8),

              Obx(() =>
                  AppInputTextField(
                    controller: controller.blogTypeCtrl,
                    label: "Blog Type",
                    isRequired: true,
                    isDropdown: true,
                    topPadding: 0,
                    dropdownItems: controller.blogTypesList,
                    errorText: controller.errors['type'],
                  )),
              const SizedBox(height: 8),

              Obx(() =>
                  AppInputTextField(
                    controller: controller.descriptionCtrl,
                    label: "Blog Description",
                    isRequired: true,
                    topPadding: 0,
                    errorText: controller.errors['description'],
                    maxLines: 4,
                  )),
              const SizedBox(height: 8),

              _buildSectionHeader(context, "Tags", isRequired: true),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: AppInputTextField(
                      controller: controller.tagInputCtrl,
                      showLabel: false,
                      hintText: "Add a tag",
                      onFieldSubmitted: (_) => controller.addTag(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: controller.addTag,
                    child: Container(
                      height: 48,
                      width: 48,
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.add, color: Colors.white),
                    ),
                  ),
                ],
              ),
              // const SizedBox(height: 8),
              Obx(() =>
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: controller.tags
                            .map((tag) =>
                            Chip(
                              label: Text(
                                tag,
                                style: const TextStyle(fontSize: 12),
                              ),
                              backgroundColor: primaryColor.withValues(
                                  alpha: 0.1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide(
                                    color: primaryColor.withValues(alpha: 0.3)),
                              ),
                              deleteIcon: Icon(
                                  Icons.close, size: 14, color: primaryColor),
                              onDeleted: () => controller.removeTag(tag),
                            ))
                            .toList(),
                      ),
                      if (controller.errors.containsKey('tags'))
                        Padding(
                          padding: const EdgeInsets.only(top: 6, left: 16),
                          child: Text(
                            controller.errors['tags']!,
                            style: context.textTheme.bodySmall?.copyWith(
                              color: Colors.red.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  )),
              const SizedBox(height: 16),

              _buildSectionHeader(context, "Media (Image/Video)"),
              Obx(() =>
              controller.selectedFile.value != null
                  ? Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: controller.mediaType.value == 'video'
                        ? Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.videocam_rounded, size: 64,
                              color: Colors.white),
                          const SizedBox(height: 12),
                          Text(
                            "Video selected",
                            style: context.textTheme.titleMedium?.copyWith(
                                color: Colors.white),
                          ),
                          const SizedBox(height: 4),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              controller.selectedFile.value!
                                  .path
                                  .split('/')
                                  .last,
                              style: context.textTheme.bodySmall?.copyWith(
                                  color: Colors.white70),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    )
                        : GestureDetector(
                      onTap: () {
                        Get.to(() =>
                            FullScreenImageViewer(
                              imageFile: controller.selectedFile.value,
                              tag: 'blog_media',
                            ));
                      },
                      child: Hero(
                        tag: 'blog_media',
                        child: Image.file(
                          controller.selectedFile.value!,
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: controller.removeMedia,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                            Icons.close, size: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              )
                  : GestureDetector(
                onTap: () => _showMediaPicker(context, controller),
                child: Container(
                  width: double.infinity,
                  height: 150,
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: primaryColor.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.perm_media_rounded, size: 48,
                          color: primaryColor),
                      const SizedBox(height: 12),
                      Text(
                        "Tap to upload media",
                        style: TextStyle(
                            color: primaryColor, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Image (Max 2MB) | Video (Max 10MB)',
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.theme.hintColor.withValues(alpha: 0.7),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              )),

              const SizedBox(height: 40),

              Obx(() =>
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: controller.isSubmitting.value
                          ? null
                          : controller.createBlog,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        disabledBackgroundColor: primaryColor.withValues(
                            alpha: 0.6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: controller.isSubmitting.value
                          ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white,
                            strokeWidth: 2),
                      )
                          : const Text(
                        "Create Blog",
                        style: TextStyle(fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ),
                  )),
              const SizedBox(height: 20),
            ],
          ),
        ),
      );
    }
    );
  //  );
  }

  Widget _buildSectionHeader(BuildContext context, String text, {bool isRequired = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: context.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          if (isRequired)
            Text(
              ' *',
              style: context.textTheme.titleSmall?.copyWith(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }

  void _showMediaPicker(BuildContext context, CreateBlogController controller) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Upload Media",
                  style: context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Get.back();
                          controller.pickImage();
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              Icon(Icons.image_rounded, size: 36, color: context.theme.primaryColor),
                              const SizedBox(height: 8),
                              const Text("Image", style: TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text("Max 2MB", style: context.textTheme.bodySmall),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Get.back();
                          controller.pickVideo();
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              Icon(Icons.videocam_rounded, size: 36, color: context.theme.primaryColor),
                              const SizedBox(height: 8),
                              const Text("Video", style: TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text("Max 10MB", style: context.textTheme.bodySmall),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
       // ),
      );
    });
  }
}
