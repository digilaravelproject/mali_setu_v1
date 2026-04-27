import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io';
import '../../data/data_source/blog_data_source.dart';
import 'blog_controller.dart';
import '../../../../widgets/custom_snack_bar.dart';

class CreateBlogController extends GetxController {
  /// For Double Back Exit
  DateTime? lastPressedTime;
  final canExit = false.obs;

  void handleBack() {
    final now = DateTime.now();
    if (lastPressedTime == null ||
        now.difference(lastPressedTime!) > const Duration(seconds: 2)) {
      lastPressedTime = now;
      canExit.value = true;
      CustomSnackBar.showInfo(
        message: "Back karne pe data remove ho jayega. Dubara back dabaye bahar jane ke liye.",
      );
      // Reset canExit after 2 seconds
      Future.delayed(const Duration(seconds: 2), () {
        canExit.value = false;
      });
      return;
    }
    Get.back();
  }

  final BlogRepository _repository = BlogRepository();
  final ImagePicker _picker = ImagePicker();
  
  final titleCtrl = TextEditingController();
  final descriptionCtrl = TextEditingController();
  final tagInputCtrl = TextEditingController(); 
  final blogTypeCtrl = TextEditingController();
  
  final blogType = ''.obs;
  final RxList<String> tags = <String>[].obs;
  final Rxn<File> selectedFile = Rxn<File>();
  final mediaType = RxnString(); // 'image' or 'video'
  final isSubmitting = false.obs;
  final errors = <String, String>{}.obs;
  
  @override
  void onInit() {
    super.onInit();
    titleCtrl.addListener(() => errors.remove('title'));
    descriptionCtrl.addListener(() => errors.remove('description'));
    blogTypeCtrl.addListener(() => errors.remove('type'));
    blogType.listen((_) => errors.remove('type'));
    tags.listen((_) => errors.remove('tags'));
  }
  
  final List<String> blogTypesList = [
    "Investment Guidance",
    "Legal Guidance",
    "Job opportunity",
    "Farming made easy",
    "Education Guidance / Competitive Exams Guidance",
    "How Become an Entrepreneur / Opportunities"
  ];

  Future<void> pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1080,
      );

      if (image != null) {
        final file = File(image.path);
        final int sizeInBytes = await file.length();
        final double sizeInMb = sizeInBytes / (1024 * 1024);
        
        final String extension = image.path.split('.').last.toLowerCase();
        final List<String> allowedExtensions = ['jpg', 'jpeg', 'png'];

        if (sizeInMb <= 2 && allowedExtensions.contains(extension)) {
          selectedFile.value = file;
          mediaType.value = 'image';
          errors.remove('photos'); 
        } else {
          CustomSnackBar.showError(
            message: "Max size 2MB, Formats: JPG, PNG",
          );
        }
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

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
          selectedFile.value = file;
          mediaType.value = 'video';
          errors.remove('photos');
        } else {
          CustomSnackBar.showError(
            message: "Max size 10MB, Formats: MP4, MOV",
          );
        }
      }
    } catch (e) {
      debugPrint("Error picking video: $e");
    }
  }

  void removeMedia() {
    selectedFile.value = null;
    mediaType.value = null;
  }

  void addTag() {
    final tag = tagInputCtrl.text.trim();
    if (tag.isNotEmpty && !tags.contains(tag)) {
      tags.add(tag);
      tagInputCtrl.clear();
    }
  }

  void removeTag(String tag) {
    tags.remove(tag);
  }

  Future<void> createBlog() async {
    final title = titleCtrl.text.trim();
    final description = descriptionCtrl.text.trim();
    final type = blogTypeCtrl.text.trim();

    errors.clear();

    if (title.isEmpty) {
        errors['title'] = "Please enter blog title";
    }
    if (type.isEmpty) {
        errors['type'] = "Please select a blog type";
    }
    if (description.isEmpty) {
        errors['description'] = "Please enter blog description";
    }
    if (tags.isEmpty) {
        errors['tags'] = "Please add at least one tag";
    }

    if (errors.isNotEmpty) return;

    try {
      isSubmitting.value = true;
      debugPrint("Starting blog creation process for: $title");
      
      String? base64Media; 
      if (selectedFile.value != null) {
        final bytes = await selectedFile.value!.readAsBytes();
        final base64String = base64Encode(bytes);
        final ext = selectedFile.value!.path.split('.').last.toLowerCase();
        
        String mimeType = 'image/jpeg';
        if (ext == 'png') mimeType = 'image/png';
        if (ext == 'mp4') mimeType = 'video/mp4';
        if (ext == 'mov') mimeType = 'video/quicktime';
        if (ext == 'avi') mimeType = 'video/x-msvideo';

        base64Media = 'data:$mimeType;base64,$base64String';
      }

      final body = {
        "title": title,
        "description": description,
        "blogs_type": type,
        "tags": tags.toList(),
        "media": base64Media ?? "" // API seems to expect an empty string if null
      };

      debugPrint("Creating blog with body: $body");
      final response = await _repository.createBlog(body);
      
      if (response != null && (response['success'] == true || response['success'] == "true")) {
        CustomSnackBar.showSuccess(message: response['message'] ?? "Blog created successfully!");
        Get.back();
        
        // Refresh the list if BlogController is active
        if (Get.isRegistered<BlogController>()) {
          Get.find<BlogController>().fetchBlogs(refresh: true);
        }
        
        // Wait a small bit so user can feel the success before popping
        Future.delayed(const Duration(milliseconds: 500), () {
           Get.back(); // return to previous screen
        });
      } else {
        String errorMessage = "Failed to create blog";
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
