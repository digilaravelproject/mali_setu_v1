import 'package:flutter/material.dart';
import 'package:edu_cluezer/widgets/custom_image_view.dart';
import 'package:get/get.dart';
import '../../../../core/constent/api_constants.dart';
import '../../../../widgets/custom_scaffold.dart';
import '../controller/create_blog_controller.dart';
import 'package:edu_cluezer/core/widgets/full_screen_image_viewer.dart';
import '../../data/model/blog_model.dart';
import '../../../../features/Auth/service/auth_service.dart';

class CreateBlogScreen extends StatelessWidget {
  final Blog? blog;
  const CreateBlogScreen({super.key, this.blog});

  @override
  Widget build(BuildContext context) {
    if (Get.isRegistered<CreateBlogController>()) {
      Get.delete<CreateBlogController>();
    }
    final controller = Get.put(CreateBlogController(blogToEdit: blog));
    final primaryColor = context.theme.primaryColor;

    return Obx(() {
      controller.canExit.value; // Dummy read for Obx
      return CustomScaffold(
        onWillPop: controller.handleBack,
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1F2937), size: 20),
          ),
          title: Text(
            blog != null ? 'Edit Blog' : 'Create Blog',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
              fontFamily: 'Nunito-Bold',
              fontSize: 19,
              letterSpacing: -0.5,
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          shape: const Border(bottom: BorderSide(color: Color(0xFFF3F4F6), width: 1.5)),
        ),
        body: Container(
          color: const Color(0xFFF9FAFB), // Cool neutral canvas
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 36),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Form Card Container for a clean structured look
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      )
                    ],
                    border: Border.all(color: const Color(0xFFF3F4F6)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Blog Title
                      Obx(() => _buildPremiumField(
                            label: "Blog Title",
                            hintText: "Enter an engaging title...",
                            controller: controller.titleCtrl,
                            prefixIcon: Icons.title_rounded,
                            maxLength: 100,
                            errorText: controller.errors['title'],
                            primaryColor: primaryColor,
                          )),
                      const SizedBox(height: 12),

                      // Category Selector
                      _buildCategoryDropdown(context, controller, primaryColor),
                      const SizedBox(height: 12),

                      // Blog Content / Body
                      Obx(() => _buildPremiumField(
                            label: "Content",
                            hintText: "Write your blog content here...",
                            controller: controller.descriptionCtrl,
                            prefixIcon: Icons.article_outlined,
                            maxLines: 8,
                            maxLength: 5000,
                            errorText: controller.errors['description'],
                            primaryColor: primaryColor,
                          )),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Tags Section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      )
                    ],
                    border: Border.all(color: const Color(0xFFF3F4F6)),
                  ),
                  child: _buildTagsSection(context, controller, primaryColor),
                ),
                const SizedBox(height: 12),

                // Media Upload Section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      )
                    ],
                    border: Border.all(color: const Color(0xFFF3F4F6)),
                  ),
                  child: _buildMediaSection(context, controller, primaryColor),
                ),
                const SizedBox(height: 12),

                // Allow Comments switch container
                // Container(
                //   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                //   decoration: BoxDecoration(
                //     color: Colors.white,
                //     borderRadius: BorderRadius.circular(12),
                //     border: Border.all(color: const Color(0xFFF3F4F6)),
                //   ),
                //   child: _buildCommentsToggle(primaryColor),
                // ),
                // const SizedBox(height: 24),

                // Premium Publish Button with drop shadow
                Obx(() => Container(
                      height: 52,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: controller.isSubmitting.value
                            ? []
                            : [
                                BoxShadow(
                                  color: primaryColor.withOpacity(0.25),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                )
                              ],
                      ),
                      child: ElevatedButton(
                        onPressed: controller.isSubmitting.value ? null : controller.createBlog,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          disabledBackgroundColor: primaryColor.withOpacity(0.6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: controller.isSubmitting.value
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    blog != null ? "Update Blog" : "Publish Blog",
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    )),
              ],
            ),
          ),
        ),
      );
    });
  }

  // Modern input field styling with subtle shading and thin clean boundaries
  Widget _buildPremiumField({
    required String label,
    required String hintText,
    required TextEditingController controller,
    required IconData prefixIcon,
    required Color primaryColor,
    int? maxLines,
    int maxLength = 100,
    String? errorText,
  }) {
    final charCount = 0.obs;
    charCount.value = controller.text.length;
    
    controller.addListener(() {
      charCount.value = controller.text.length;
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Color(0xFF374151),
                letterSpacing: -0.1,
              ),
            ),
            const Text(" *", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines ?? 1,
          maxLength: maxLength,
          style: const TextStyle(color: Color(0xFF1F2937), fontSize: 14, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            prefixIcon: Icon(prefixIcon, color: const Color(0xFF9CA3AF), size: 18),
            hintText: hintText,
            hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 13, fontWeight: FontWeight.normal),
            errorText: errorText,
            counterText: "",
            filled: true,
            fillColor: const Color(0xFFF9FAFB), // Clean subtle field background
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: primaryColor, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red.shade300, width: 1),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Align(
          alignment: Alignment.centerRight,
          child: Obx(() => Text(
                "${charCount.value}/$maxLength",
                style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF), fontWeight: FontWeight.w500),
              )),
        ),
      ],
    );
  }

  // Premium Custom Dropdown with Clean Bottom Sheet Radio Toggles
  Widget _buildCategoryDropdown(
      BuildContext context, CreateBlogController controller, Color primaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              "Category",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Color(0xFF374151),
                letterSpacing: -0.1,
              ),
            ),
            const Text(" *", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () {
            // 🆕 Disable category change for bloggers
            if (Get.isRegistered<AuthService>()) {
              final user = Get.find<AuthService>().currentUser.value;
              if (user?.userType?.toLowerCase().trim() == 'bloger' && user?.blogCategoryName != null) {
                return; // Do nothing
              }
            }
            
            showModalBottomSheet(
              context: context,
              backgroundColor: Colors.white,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              builder: (context) {
                return SafeArea(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 40,
                          height: 4.5,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE5E7EB),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        const SizedBox(height: 18),
                        const Text(
                          "Select Category",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Color(0xFF111827),
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Divider(color: Color(0xFFF3F4F6), thickness: 1),
                        Flexible(
  child: Column(
    children: [
      // Search field
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: TextField(
          onChanged: (value) {
            controller.categorySearch.value = value;
          },
          decoration: InputDecoration(
            hintText: 'Search category',
            prefixIcon: Icon(Icons.search, size: 20, color: Color(0xFF9CA3AF)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: primaryColor, width: 1.5),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
      ),
      // Filtered list
      Expanded(
        child: Obx(() {
          final filtered = controller.blogTypesList.where((type) =>
              type.toLowerCase().contains(controller.categorySearch.value.toLowerCase()))
              .toList();
          return ListView.builder(
            shrinkWrap: true,
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final type = filtered[index];
              final isSelected = controller.blogTypeCtrl.text == type;
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                title: Text(
                  type,
                  style: TextStyle(
                    color: isSelected ? const Color(0xFF111827) : const Color(0xFF4B5563),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                trailing: isSelected
                    ? Icon(Icons.check_circle_rounded, color: primaryColor, size: 22)
                    : Icon(Icons.radio_button_off_rounded, color: Colors.grey[400], size: 22),
                onTap: () {
                  controller.blogTypeCtrl.text = type;
                  controller.blogType.value = type; // 🆕 Update reactive value
                  controller.errors.remove('type');
                  Get.back();
                },
              );
            },
          );
        }),
      ),
    ],
  ),
),
                      ],
                    ),
                  ),
                );
              },
            );
          },
          child: Obx(() {
            final hasError = controller.errors.containsKey('type');
            final selected = controller.blogType.value; // Use the reactive RxString
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: hasError ? Colors.red.shade400 : const Color(0xFFE5E7EB),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.category_outlined, color: Color(0xFF9CA3AF), size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      selected.isNotEmpty ? selected : "Select category",
                      style: TextStyle(
                        color: selected.isNotEmpty ? const Color(0xFF1F2937) : const Color(0xFF9CA3AF),
                        fontSize: 14,
                        fontWeight: selected.isNotEmpty ? FontWeight.w500 : FontWeight.normal,
                      ),
                    ),
                  ),
                  Builder(
                    builder: (context) {
                      bool isBlogger = false;
                      if (Get.isRegistered<AuthService>()) {
                        final user = Get.find<AuthService>().currentUser.value;
                        if (user?.userType?.toLowerCase().trim() == 'bloger' && user?.blogCategoryName != null) {
                          isBlogger = true;
                        }
                      }
                      if (isBlogger) return const SizedBox.shrink();
                      return const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF9CA3AF));
                    },
                  ),
                ],
              ),
            );
          }),
        ),
        Obx(() {
          if (controller.errors.containsKey('type')) {
            return Padding(
              padding: const EdgeInsets.only(top: 6, left: 4),
              child: Text(
                controller.errors['type']!,
                style: TextStyle(color: Colors.red.shade700, fontSize: 12),
              ),
            );
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }

  // Premium Tags field with elegant styling
  Widget _buildTagsSection(
      BuildContext context, CreateBlogController controller, Color primaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              "Tags",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Color(0xFF374151),
                letterSpacing: -0.1,
              ),
            ),
            const Text(" *", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: TextField(
                  controller: controller.tagInputCtrl,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.local_offer_outlined, color: Color(0xFF9CA3AF), size: 18),
                    hintText: "Enter tags (e.g. travel, nature)",
                    hintStyle: TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16),
                  ),
                  style: const TextStyle(fontSize: 14, color: Color(0xFF1F2937), fontWeight: FontWeight.w500),
                  onSubmitted: (_) => controller.addTag(),
                ),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: controller.addTag,
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 18),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    )
                  ],
                ),
                alignment: Alignment.center,
                child: const Text(
                  "Add",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        const Text(
          "Press Enter or tap 'Add' to insert tags",
          style: TextStyle(fontSize: 11, color: Color(0xFF9CA3AF), fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 10),
        
        // Chip list
        Obx(() => Wrap(
              spacing: 8,
              runSpacing: 6,
              children: controller.tags.map((tag) {
                return Chip(
                  label: Text(tag, style: TextStyle(color: primaryColor, fontSize: 12, fontWeight: FontWeight.bold)),
                  backgroundColor: primaryColor.withOpacity(0.06),
                  deleteIcon: Icon(Icons.close, size: 14, color: primaryColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(color: primaryColor.withOpacity(0.2)),
                  ),
                  onDeleted: () => controller.removeTag(tag),
                );
              }).toList(),
            )),
        Obx(() {
          if (controller.errors.containsKey('tags')) {
            return Padding(
              padding: const EdgeInsets.only(top: 6, left: 4),
              child: Text(
                controller.errors['tags']!,
                style: TextStyle(color: Colors.red.shade700, fontSize: 12),
              ),
            );
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }

  // Stunning Upload Media Panel
  Widget _buildMediaSection(
      BuildContext context, CreateBlogController controller, Color primaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Media Files",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Color(0xFF374151),
            letterSpacing: -0.1,
          ),
        ),
        const SizedBox(height: 10),
        Obx(() {
          final selected = controller.selectedFiles;
          final existing = controller.existingMediaPaths;
          final totalCount = selected.length + existing.length;

          if (totalCount == 0) {
            return Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: controller.pickImages,
                    child: _dashedUploadBox(
                      title: "Add Cover Images",
                      subtitle: "Select multiple (Max. 2MB each)",
                      icon: Icons.image_outlined,
                      primaryColor: primaryColor,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: controller.pickVideo,
                    child: _dashedUploadBox(
                      title: "Add Video Files",
                      subtitle: "Select multiple (Max. 10MB each)",
                      icon: Icons.videocam_outlined,
                      primaryColor: primaryColor,
                    ),
                  ),
                ),
              ],
            );
          }

          return Wrap(
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              // 1. Existing Media Thumbnails
              ...List.generate(existing.length, (index) {
                final path = existing[index];
                final url = "${ApiConstants.imageBaseUrl}$path";
                final isVideo = path.toLowerCase().endsWith('.mp4') ||
                    path.toLowerCase().endsWith('.mov') ||
                    path.toLowerCase().endsWith('.avi');

                // Reverted implementation with tap to view full-screen image
return Stack(
  children: [
    Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(11),
        child: isVideo
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.videocam_rounded, size: 24, color: primaryColor),
                  const SizedBox(height: 4),
                  const Text("Video", style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF4B5563))),
                ],
              )
            : CustomImageView(url: 
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Center(
                  child: Icon(Icons.broken_image_outlined, color: Colors.grey, size: 24),
                ),
              ),
      ),
    ),
    Positioned(
      top: 4,
      right: 4,
      child: GestureDetector(
        onTap: () => controller.removeExistingMedia(index),
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: const BoxDecoration(
            color: Colors.red,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.close, size: 10, color: Colors.white),
        ),
      ),
    ),
  ],
);

              }),

              // 2. Newly Selected Media Thumbnails
              ...List.generate(selected.length, (index) {
                final file = selected[index];
                final isVideo = file.path.toLowerCase().endsWith('.mp4') ||
                    file.path.toLowerCase().endsWith('.mov') ||
                    file.path.toLowerCase().endsWith('.avi');

                return Stack(
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(11),
                        child: isVideo
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.videocam_rounded, size: 24, color: primaryColor),
                                  const SizedBox(height: 4),
                                  const Text("Video", style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF4B5563))),
                                ],
                              )
                            : Image.file(
                                file,
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => controller.removeSelectedFile(index),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close, size: 10, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                );
              }),

              // 3. Small Mini Add Card option
              GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.white,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    builder: (context) => SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              "Add More Media",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
                            ),
                            const SizedBox(height: 16),
                            ListTile(
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(color: primaryColor.withOpacity(0.08), shape: BoxShape.circle),
                                child: Icon(Icons.image_outlined, color: primaryColor),
                              ),
                              title: const Text("Add Cover Images", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              subtitle: const Text("Select images from gallery (Max. 2MB each)", style: TextStyle(fontSize: 11)),
                              onTap: () {
                                Get.back();
                                controller.pickImages();
                              },
                            ),
                            ListTile(
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(color: primaryColor.withOpacity(0.08), shape: BoxShape.circle),
                                child: Icon(Icons.videocam_outlined, color: primaryColor),
                              ),
                              title: const Text("Add Video Files", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              subtitle: const Text("Select videos from gallery (Max. 10MB each)", style: TextStyle(fontSize: 11)),
                              onTap: () {
                                Get.back();
                                controller.pickVideo();
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: primaryColor.withOpacity(0.3),
                      style: BorderStyle.solid,
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_rounded, size: 24, color: primaryColor),
                      const SizedBox(height: 4),
                      Text("Add More", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: primaryColor)),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ],
    );
  }

  Widget _dashedUploadBox({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color primaryColor,
  }) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
          style: BorderStyle.solid,
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.06),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: primaryColor, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1F2937)),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 10, color: Color(0xFF9CA3AF), fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsToggle(Color primaryColor) {
    final allowComments = true.obs;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Allow Comments",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Color(0xFF374151),
            letterSpacing: -0.1,
          ),
        ),
        Obx(() => Switch(
              value: allowComments.value,
              onChanged: (val) => allowComments.value = val,
              activeColor: primaryColor,
            )),
      ],
    );
  }
}
