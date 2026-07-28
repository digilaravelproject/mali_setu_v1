import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../core/constent/api_constants.dart';
import '../../data/data_source/blog_data_source.dart';
import '../../data/model/blog_model.dart';
import 'blog_controller.dart';
import '../../../../widgets/custom_snack_bar.dart';
import '../../../../features/Auth/service/auth_service.dart';

class CreateBlogController extends GetxController {
  final Blog? blogToEdit;

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
      CustomSnackBar.showInfo(message: "press_back_again_to_exit".tr);
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

  final RxString categorySearch = ''.obs; // search query for category dropdown
  final RxList<String> tags = <String>[].obs;

  // 🆕 Mixed media selection lists
  final RxList<File> selectedFiles = <File>[].obs;
  final RxList<String> existingMediaPaths = <String>[].obs;
  // Track if all existing media have been removed
  final RxBool existingMediaRemoved = false.obs;

  final isSubmitting = false.obs;
  final errors = <String, String>{}.obs;

  final RxString blogType = ''.obs; // selected blog type observable

  @override
  void onInit() {
    super.onInit();
    _fetchCategories();

    if (blogToEdit != null) {
      titleCtrl.text = blogToEdit!.title ?? '';
      descriptionCtrl.text = blogToEdit!.description ?? '';
      final categoryName =
          blogToEdit!.category?.name ?? blogToEdit!.blogType ?? '';
      blogTypeCtrl.text = categoryName;
      blogType.value = categoryName;
      if (blogToEdit!.tags != null) {
        tags.assignAll(blogToEdit!.tags!);
      }

      // Populate existing media files
      if (blogToEdit!.mediaPaths != null &&
          blogToEdit!.mediaPaths!.isNotEmpty) {
        existingMediaPaths.assignAll(blogToEdit!.mediaPaths!);
      } else if (blogToEdit!.mediaPath != null) {
        existingMediaPaths.assignAll([blogToEdit!.mediaPath!]);
      }
    } else {
      // 🆕 Pre-fill category for bloggers
      if (Get.isRegistered<AuthService>()) {
        final authService = Get.find<AuthService>();
        _initBloggerCategory(authService);
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

  Future<void> _initBloggerCategory(AuthService authService) async {
    var user = authService.currentUser.value;

    // If it's a blogger but local data is stale (missing category name), refresh it
    if (user?.userType?.toLowerCase().trim() == 'bloger' &&
        user?.blogCategoryName == null) {
      await authService.refreshProfile();
      user = authService.currentUser.value;
    }

    if (user?.userType?.toLowerCase().trim() == 'bloger' &&
        user?.blogCategoryName != null) {
      blogTypeCtrl.text = user!.blogCategoryName!;
      blogType.value = user.blogCategoryName!;
    }
  }

  final RxList<String> blogTypesList = <String>[].obs;
  final RxMap<String, int> categoryNameToId = <String, int>{}.obs;

  Future<void> _fetchCategories() async {
    try {
      final response = await _repository.getBlogCategories();
      if (response != null && response.data != null) {
        categoryNameToId.clear();
        for (var cat in response.data!) {
          if (cat.name != null && cat.name!.isNotEmpty && cat.id != null) {
            categoryNameToId[cat.name!] = cat.id!;
          }
        }
        blogTypesList.assignAll(categoryNameToId.keys.toList());
      }
    } catch (e) {
      debugPrint("Error fetching categories: $e");
    }
  }

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
              message:
                  "Image ${image.name} exceeds 2MB limit or is not JPG/PNG",
            );
          }
        }
      }
    } catch (e) {
      debugPrint("Error picking images: $e");
    }
  }

  // 🆕 Picks multiple video files and appends them using native picker
  Future<void> pickVideo() async {
    try {
      final List<XFile>? media = await _picker.pickMultipleMedia();

      if (media != null && media.isNotEmpty) {
        for (final item in media) {
          final file = File(item.path);
          final int sizeInBytes = await file.length();
          final double sizeInMb = sizeInBytes / (1024 * 1024);

          final String extension = item.path.split('.').last.toLowerCase();
          final List<String> allowedVideoExtensions = ['mp4', 'mov', 'avi'];
          final List<String> allowedImageExtensions = ['jpg', 'jpeg', 'png'];

          if (allowedVideoExtensions.contains(extension)) {
            if (sizeInMb <= 10) {
              selectedFiles.add(file);
              errors.remove('media');
            } else {
              CustomSnackBar.showError(
                message: "Video ${item.name} exceeds 10MB limit",
              );
            }
          } else if (allowedImageExtensions.contains(extension)) {
            if (sizeInMb <= 2) {
              selectedFiles.add(file);
              errors.remove('media');
            } else {
              CustomSnackBar.showError(
                message: "Image ${item.name} exceeds 2MB limit",
              );
            }
          } else {
            CustomSnackBar.showError(
              message: "File ${item.name} is not a supported format",
            );
          }
        }
      }
    } catch (e) {
      debugPrint("Error picking video: $e");
    }
  }

  void removeSelectedFile(int index) {
    selectedFiles.removeAt(index);
  }

  /// Returns a combined list of existing media URLs and newly selected files
  List<dynamic> get allMedia => [...existingMediaPaths, ...selectedFiles];

  /// Removes an existing media item by index and updates removal flag
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
      int? categoryId = categoryNameToId[type];

      // Fallback for blogger if categories haven't loaded yet
      if (categoryId == null && Get.isRegistered<AuthService>()) {
        final user = Get.find<AuthService>().currentUser.value;
        if (user?.blogCategoryName == type) {
          categoryId = user?.blogCategoryId;
        }
      }

      final Map<String, dynamic> fields = {
        "title": title,
        "description": content,
        "blog_type": categoryId ?? type,
        "tags": tags.join(
          ',',
        ), // 🆕 Join tags with comma as expected by the API
      };

      if (blogToEdit != null) {
        fields["_method"] =
            "PUT"; // 🆕 Laravel method spoofing for PUT request with files
      }

      final formData = FormData.fromMap(fields);

      /*Future<void> _attachMedia() async {
        // Attach existing media URLs as multipart files (download them)
        for (final path in existingMediaPaths) {
          try {
            final String mediaUrl = "https://malisetu.com/" + path;
            final response = await Dio().get<List<int>>(mediaUrl,
                options: Options(responseType: ResponseType.bytes));
            final bytes = response.data;
            if (bytes != null) {
              final fileName = path.split('/').last;
              // Determine mime type from extension
              String ext = fileName.split('.').last.toLowerCase();
              String mime;
              if (['jpg', 'jpeg', 'png', 'gif'].contains(ext)) {
                mime = 'image/' + (ext == 'jpg' ? 'jpeg' : ext);
              } else if (['mp4', 'mov', 'avi', 'webm'].contains(ext)) {
                mime = 'video/' + ext;
              } else {
                mime = 'application/octet-stream';
              }
              formData.files.add(MapEntry(
                "media[]",
                MultipartFile.fromBytes(
                  bytes,
                  filename: fileName,
                  contentType: MediaType.parse(mime),
                ),
              ));
            }
          } catch (e) {
            debugPrint("Failed to fetch existing media $path: $e");
          }
        }
        // Attach newly selected files as multipart
        for (final file in selectedFiles) {
          final fileName = file.path.split('/').last;
          formData.files.add(MapEntry(
              "media[]",
              await MultipartFile.fromFile(file.path, filename: fileName)));
        }
      }*/

      Future<void> _attachMedia(FormData formData) async {
        final Dio dio = Dio();

        // 1. Existing media URL/path ko download karke multipart me convert karo
        if (blogToEdit != null) {
          for (final path in existingMediaPaths) {
            try {
              String mediaUrl = path;

              // Agar path already full URL nahi hai to base URL add karo
              if (!mediaUrl.startsWith('http')) {
                mediaUrl = "${ApiConstants.imageBaseUrl}$path";
              }

              debugPrint("Downloading existing media: $mediaUrl");

              final response = await dio.get<List<int>>(
                mediaUrl,
                options: Options(responseType: ResponseType.bytes),
              );

              final bytes = response.data;

              if (bytes != null && bytes.isNotEmpty) {
                final fileName = path.split('/').last.split('?').first;
                final ext = fileName.split('.').last.toLowerCase();

                String mimeType = 'application/octet-stream';

                if (ext == 'jpg' || ext == 'jpeg') {
                  mimeType = 'image/jpeg';
                } else if (ext == 'png') {
                  mimeType = 'image/png';
                } else if (ext == 'gif') {
                  mimeType = 'image/gif';
                } else if (ext == 'mp4') {
                  mimeType = 'video/mp4';
                } else if (ext == 'mov') {
                  mimeType = 'video/quicktime';
                } else if (ext == 'avi') {
                  mimeType = 'video/x-msvideo';
                } else if (ext == 'webm') {
                  mimeType = 'video/webm';
                }

                formData.files.add(
                  MapEntry(
                    "media[]",
                    MultipartFile.fromBytes(
                      bytes,
                      filename: fileName,
                      contentType: MediaType.parse(mimeType),
                    ),
                  ),
                );

                debugPrint("Existing media attached: $fileName");
              }
            } catch (e) {
              debugPrint("Failed to attach existing media $path: $e");
            }
          }
        }

        // 2. Newly selected files attach karo
        for (final file in selectedFiles) {
          final fileName = file.path.split('/').last;

          formData.files.add(
            MapEntry(
              "media[]",
              await MultipartFile.fromFile(file.path, filename: fileName),
            ),
          );

          debugPrint("New media attached: $fileName");
        }
      }

      await _attachMedia(formData);

      debugPrint("Submitting blog multipart request...");
      final response = blogToEdit != null
          ? await _repository.updateBlog(
              blogToEdit!.id ?? 0,
              formData,
            ) // POST /blogs/{id} with _method=PUT
          : await _repository.createBlog(formData);

      final String successMessage = blogToEdit != null
          ? "Blog updated successfully!"
          : "Blog created successfully!";

      if (response != null &&
          (response['success'] == true ||
              response['success'] == 1 ||
              response['success'] == "true")) {
        isSubmitting.value = false; // Reset before navigating

        // Go back to the previous screen FIRST, so GetX doesn't swallow the back command to close the snackbar
        Get.back();

        // Show snackbar after navigating
        CustomSnackBar.showSuccess(
          message: response['message'] ?? successMessage,
        );

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
        String errorMessage = blogToEdit != null
            ? "Failed to update blog"
            : "Failed to create blog";
        if (response != null) {
          if (response['message'] != null)
            errorMessage = response['message'].toString();

          if (response['errors'] != null && response['errors'] is Map) {
            final Map errorsMap = response['errors'];
            final List<String> allErrors = [];
            errorsMap.forEach((key, val) {
              if (val is List) {
                for (final e in val) {
                  allErrors.add(e.toString());
                }
              } else if (val is String) {
                allErrors.add(val);
              } else {
                allErrors.add(val.toString());
              }
            });
            if (allErrors.isNotEmpty) {
              errorMessage = allErrors.join('\n');
            }
          }
        }
        CustomSnackBar.showError(message: errorMessage);
      }
    } catch (e) {
      debugPrint("Error in CreateBlogController.createBlog: $e");
      CustomSnackBar.showError(
        message: "An unexpected error occurred. Please try again.",
      );
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
