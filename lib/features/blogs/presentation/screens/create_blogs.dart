import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/create_blog_controller.dart';
import '../../../../widgets/basic_text_field.dart';

class CreateBlogScreen extends StatelessWidget {
  const CreateBlogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CreateBlogController());
    final primaryColor = context.theme.primaryColor;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
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
           // _buildSectionHeader(context, "Title"),
            AppInputTextField(
               controller: controller.titleCtrl,
               label: "Enter blog title",
            ),
            const SizedBox(height: 20),

            _buildSectionHeader(context, "Blog Type"),
            Obx(() => GestureDetector(
              onTap: () => _showTypeSelection(context, controller),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      controller.blogType.value.isEmpty ? "Select Blog Type" : controller.blogType.value,
                      style: TextStyle(
                        color: controller.blogType.value.isEmpty ? Colors.grey[500] : Colors.black87,
                        fontSize: 16,
                      ),
                    ),
                    const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                  ],
                ),
              ),
            )),
            const SizedBox(height: 20),

           // _buildSectionHeader(context, "Description"),
            AppInputTextField(
               controller: controller.descriptionCtrl,
               label: "Enter blog description",
               maxLines: 4,
            ),
            const SizedBox(height: 20),


            _buildSectionHeader(context, "Tags"),
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
            const SizedBox(height: 8),
            Obx(() => Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: controller.tags
                      .map((tag) => Chip(
                            label: Text(
                              tag,
                              style: const TextStyle(fontSize: 12),
                            ),
                            backgroundColor: primaryColor.withValues(alpha: 0.1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(color: primaryColor.withValues(alpha: 0.3)),
                            ),
                            deleteIcon: Icon(Icons.close, size: 14, color: primaryColor),
                            onDeleted: () => controller.removeTag(tag),
                          ))
                      .toList(),
                )),
            const SizedBox(height: 20),

            _buildSectionHeader(context, "Media (Image)"),
            Obx(() => controller.selectedImage.value != null
                ? Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          controller.selectedImage.value!,
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: controller.removeImage,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close, size: 16, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  )
                : GestureDetector(
                    onTap: controller.pickImage,
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
                          Icon(Icons.add_photo_alternate_rounded, size: 48, color: primaryColor),
                          const SizedBox(height: 8),
                          Text(
                             "Tap to upload an image",
                             style: TextStyle(color: primaryColor, fontWeight: FontWeight.w600),
                          )
                        ],
                      ),
                    ),
                  )),

            const SizedBox(height: 40),

            Obx(() => SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: controller.isSubmitting.value ? null : controller.createBlog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  disabledBackgroundColor: primaryColor.withValues(alpha: 0.6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: controller.isSubmitting.value 
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text(
                      "Create Blog",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
              ),
            )),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4),
      child: Text(
        text,
        style: context.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: Colors.grey[800],
        ),
      ),
    );
  }

  void _showTypeSelection(BuildContext context, CreateBlogController controller) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Select Blog Type",
                style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ...controller.blogTypesList.map((type) => ListTile(
                    title: Text(type),
                  //  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                    onTap: () {
                      controller.blogType.value = type;
                      Get.back();
                    },
                  )),
            ],
          ),
        );
      },
    );
  }
}
