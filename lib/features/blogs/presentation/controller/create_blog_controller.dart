import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io';
import '../../data/data_source/blog_data_source.dart';
import 'blog_controller.dart';
import '../../../../widgets/custom_snack_bar.dart';

class CreateBlogController extends GetxController {
  final BlogRepository _repository = BlogRepository();
  
  final titleCtrl = TextEditingController();
  final descriptionCtrl = TextEditingController();
  final tagInputCtrl = TextEditingController(); 
  
  final blogType = ''.obs;
  final RxList<String> tags = <String>[].obs;
  final Rxn<File> selectedImage = Rxn<File>();
  final isSubmitting = false.obs;
  
  final List<String> blogTypesList = [
    'Investment Guidance',
    'Business Strategy',
    'Financial Planning',
    'Career Advice',
    'Industry News',
    'Other'
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
        selectedImage.value = File(image.path);
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  void removeImage() {
    selectedImage.value = null;
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
    final type = blogType.value;

    if (title.isEmpty) {
        CustomSnackBar.showError(message: "Please enter blog title");
        return;
    }
    if (type.isEmpty) {
        CustomSnackBar.showError(message: "Please select a blog type");
        return;
    }
    if (description.isEmpty) {
        CustomSnackBar.showError(message: "Please enter blog description");
        return;
    }
    if (tags.isEmpty) {
        CustomSnackBar.showError(message: "Please add at least one tag");
        return;
    }

    try {
      isSubmitting.value = true;
      debugPrint("Starting blog creation process for: $title");
      
      String? base64Media; 
      if (selectedImage.value != null) {
        final bytes = await selectedImage.value!.readAsBytes();
        final base64String = base64Encode(bytes);
        final ext = selectedImage.value!.path.split('.').last.toLowerCase();
        final mimeType = (ext == 'png') ? 'image/png' : 'image/jpeg';
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
    super.onClose();
  }
}
