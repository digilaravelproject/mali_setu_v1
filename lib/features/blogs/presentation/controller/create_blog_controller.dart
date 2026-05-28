import 'package:flutter/material.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'dart:io';
import '../../data/data_source/blog_data_source.dart';
import '../../data/model/blog_model.dart';
import 'blog_controller.dart';
import '../../../../widgets/custom_snack_bar.dart';

class CreateBlogController extends GetxController {
  final Blog? blogToEdit;
  final existingMediaRemoved = false.obs;

  CreateBlogController({this.blogToEdit});

  /// For Double Back Exit
  DateTime? lastPressedTime;
  final canExit = false.obs;

  Future<bool> handleBack() async {
    final now = DateTime.now();
    if (lastPressedTime == null ||
        now.difference(lastPressedTime!) > const Duration(seconds: 2)) {
      lastPressedTime = now;
      canExit.value = true;
      CustomSnackBar.showInfo(
        message: "press_back_again_to_exit".tr,
      );
      // Reset canExit after 2 seconds
      Future.delayed(const Duration(seconds: 2), () {
        canExit.value = false;
      });
      return false;
    }
    return true;
  }

  final BlogRepository _repository = BlogRepository();
  final ImagePicker _picker = ImagePicker();
  
  final titleCtrl = TextEditingController();
  final descriptionCtrl = TextEditingController();
  final tagInputCtrl = TextEditingController(); 
  final blogTypeCtrl = TextEditingController();
  
  final blogType = ''.obs;
  final RxList<String> tags = <String>[].obs;
  
  // 🆕 Mixed media selection lists
  final RxList<File> selectedFiles = <File>[].obs;
  final RxList<String> existingMediaPaths = <String>[].obs;
  
  final isSubmitting = false.obs;
  final errors = <String, String>{}.obs;
  
  @override
  void onInit() {
    super.onInit();

    if (blogToEdit != null) {
      titleCtrl.text = blogToEdit!.title ?? '';
      descriptionCtrl.text = blogToEdit!.description ?? '';
      blogTypeCtrl.text = blogToEdit!.blogType ?? '';
      blogType.value = blogToEdit!.blogType ?? '';
      if (blogToEdit!.tags != null) {
        tags.assignAll(blogToEdit!.tags!);
      }
      
      // Populate existing media files
      if (blogToEdit!.mediaPaths != null && blogToEdit!.mediaPaths!.isNotEmpty) {
        existingMediaPaths.assignAll(blogToEdit!.mediaPaths!);
      } else if (blogToEdit!.mediaPath != null) {
        existingMediaPaths.assignAll([blogToEdit!.mediaPath!]);
      }
    }

    titleCtrl.addListener(() => errors.remove('title'));
    descriptionCtrl.addListener(() => errors.remove('description'));
    blogTypeCtrl.addListener(() => errors.remove('type'));
    blogType.listen((_) => errors.remove('type'));
    tags.listen((_) => errors.remove('tags'));

    // 🆕 Auto parse tags when user types a comma
    tagInputCtrl.addListener(() {
      final text = tagInputCtrl.text;
      if (text.contains(',')) {
        final parts = text.split(',');
        for (final part in parts) {
          final cleaned = part.trim();
          if (cleaned.isNotEmpty && !tags.contains(cleaned)) {
            tags.add(cleaned);
          }
        }
        tagInputCtrl.clear();
      }
    });
  }
  
  final List<String> blogTypesList = const [
    "Technology",
    "Business",
    "Finance",
    "Marketing",
    "Startups",
    "Artificial Intelligence (AI)",
    "Software Development",
    "Web Development",
    "Mobile App Development",
    "Cybersecurity",
    "Cloud Computing",
    "Data Science",
    "Health & Fitness",
    "Lifestyle",
    "Travel",
    "Food & Recipes",
    "Fashion & Beauty",
    "Education",
    "Career & Jobs",
    "Personal Development",
    "Entertainment",
    "Movies & TV",
    "Music",
    "Sports",
    "Gaming",
    "News & Current Affairs",
    "Politics",
    "Science",
    "Environment",
    "Parenting",
    "Relationships",
    "Real Estate",
    "Automotive",
    "Photography",
    "Home Improvement",
    "E-commerce",
    "Product Reviews",
    "Tutorials & Guides",
    "Case Studies",
    "Interviews",
  ];

  // 🆕 Picks multiple images and appends them
  Future<void> pickImages() async {
    try {
      final List<XFile>? images = await _picker.pickMultiImage(
        imageQuality: 80,
        maxWidth: 1080,
      );

      if (images != null && images.isNotEmpty) {
        for (final image in images) {
          final file = File(image.path);
          final int sizeInBytes = await file.length();
          final double sizeInMb = sizeInBytes / (1024 * 1024);
          
          final String extension = image.path.split('.').last.toLowerCase();
          final List<String> allowedExtensions = ['jpg', 'jpeg', 'png'];

          if (sizeInMb <= 2 && allowedExtensions.contains(extension)) {
            selectedFiles.add(file);
            errors.remove('media'); 
          } else {
            CustomSnackBar.showError(
              message: "Image ${image.name} exceeds 2MB limit or is not JPG/PNG",
            );
          }
        }
      }
    } catch (e) {
      debugPrint("Error picking images: $e");
    }
  }

  // 🆕 Picks a video file and appends it
  Future<void> pickVideo() async {
    try {
      final XFile? video = await _picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 5),
      );

      if (video != null) {
        final file = File(video.path);
        final int sizeInBytes = await file.length();
        final double sizeInMb = sizeInBytes / (1024 * 1024);
        
        final String extension = video.path.split('.').last.toLowerCase();
        final List<String> allowedExtensions = ['mp4', 'mov', 'avi'];

        if (sizeInMb <= 10 && allowedExtensions.contains(extension)) {
          selectedFiles.add(file);
          errors.remove('media');
        } else {
          CustomSnackBar.showError(
            message: "Max video size 10MB, Formats: MP4, MOV, AVI",
          );
        }
      }
    } catch (e) {
      debugPrint("Error picking video: $e");
    }
  }

  void removeSelectedFile(int index) {
    selectedFiles.removeAt(index);
  }

  void removeExistingMedia(int index) {
    existingMediaPaths.removeAt(index);
    existingMediaRemoved.value = existingMediaPaths.isEmpty;
  }

  void addTag() {
    final text = tagInputCtrl.text.trim();
    if (text.isNotEmpty) {
      final parts = text.split(',');
      for (final part in parts) {
        final cleaned = part.trim();
        if (cleaned.isNotEmpty && !tags.contains(cleaned)) {
          tags.add(cleaned);
        }
      }
      tagInputCtrl.clear();
    }
  }

  void removeTag(String tag) {
    tags.remove(tag);
  }

  Future<void> createBlog() async {
    final title = titleCtrl.text.trim();
    final content = descriptionCtrl.text.trim();
    final type = blogTypeCtrl.text.trim();

    errors.clear();

    if (title.isEmpty) {
      errors['title'] = "Please enter blog title";
    }
    if (type.isEmpty) {
      errors['type'] = "Please select a blog type";
    }
    if (content.isEmpty) {
      errors['description'] = "Please enter blog content";
    }
    if (tags.isEmpty) {
      errors['tags'] = "Please add at least one tag";
    }

    if (errors.isNotEmpty) return;

    try {
      isSubmitting.value = true;
      debugPrint("Starting blog creation process for: $title");
      
      // Construct FormData to upload files and parameters dynamically
      final Map<String, dynamic> fields = {
        "title": title,
        "description": content,
        "blog_type": type,
        "tags": tags.join(','), // 🆕 Join tags with comma as expected by the API
      };

      if (blogToEdit != null) {
        fields["_method"] = "PUT"; // 🆕 Laravel method spoofing for PUT request with files
      }

      final formData = FormData.fromMap(fields);

      // Add selected media files to the FormData under "media[]" key!
      for (final file in selectedFiles) {
        final fileName = file.path.split('/').last;
        formData.files.add(MapEntry(
          "media[]",
          await MultipartFile.fromFile(
            file.path,
            filename: fileName,
          ),
        ));
      }

      // If updating, send the remaining existing media files list
      if (blogToEdit != null) {
        for (final path in existingMediaPaths) {
          formData.fields.add(MapEntry("existing_media[]", path));
        }
      }

      debugPrint("Submitting blog multipart request...");
      final response = blogToEdit != null
          ? await _repository.updateBlog(blogToEdit!.id ?? 0, formData) // POST /blogs/{id} with _method=PUT
          : await _repository.createBlog(formData);
      
      final String successMessage = blogToEdit != null ? "Blog updated successfully!" : "Blog created successfully!";

      if (response != null && (response['success'] == true || response['success'] == 1 || response['success'] == "true")) {
        isSubmitting.value = false; // Reset before navigating

        // Go back to the previous screen FIRST, so GetX doesn't swallow the back command to close the snackbar
        Get.back();
        
        // Show snackbar after navigating
        CustomSnackBar.showSuccess(message: response['message'] ?? successMessage);

        if (Get.isRegistered<BlogController>()) {
          final blogCtrl = Get.find<BlogController>();
          if (blogToEdit != null) {
            // Update: refresh the detail page data so it shows updated content when we go back
            blogCtrl.fetchBlogDetail(blogToEdit!.id ?? 0);
            blogCtrl.fetchMyBlogs(); // refresh My Blogs tab too
          } else {
            // Create: refresh both tabs
            blogCtrl.fetchBlogs(refresh: true);
            blogCtrl.fetchMyBlogs();
          }
        }

      } else {
        String errorMessage = blogToEdit != null ? "Failed to update blog" : "Failed to create blog";
        if (response != null) {
          if (response['message'] != null) errorMessage = response['message'].toString();
          
          if (response['errors'] != null && response['errors'] is Map) {
            Map errors = response['errors'];
            if (errors.isNotEmpty) {
              var firstErrorList = errors.values.first;
              if (firstErrorList is List && firstErrorList.isNotEmpty) {
                errorMessage = firstErrorList[0].toString();
              }
            }
          }
        }
        CustomSnackBar.showError(message: errorMessage);
      }
    } catch (e) {
      debugPrint("Error in CreateBlogController.createBlog: $e");
      CustomSnackBar.showError(message: "An unexpected error occurred. Please try again.");
    } finally {
      isSubmitting.value = false;
    }
  }

  @override
  void onClose() {
    titleCtrl.dispose();
    descriptionCtrl.dispose();
    tagInputCtrl.dispose();
    blogTypeCtrl.dispose();
    super.onClose();
  }
}
