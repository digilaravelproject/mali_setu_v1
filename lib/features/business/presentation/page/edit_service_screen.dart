import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:edu_cluezer/core/constent/api_constants.dart';
import 'package:edu_cluezer/widgets/custom_image_view.dart';
import 'package:edu_cluezer/widgets/custom_snack_bar.dart';
import 'package:edu_cluezer/widgets/custom_buttons.dart';
import 'package:edu_cluezer/widgets/basic_text_field.dart';
import 'package:edu_cluezer/core/widgets/full_screen_image_viewer.dart';
import 'package:edu_cluezer/features/business/data/model/res_all_business_model.dart';
import 'package:edu_cluezer/features/business/presentation/controller/business_controller.dart';
import 'package:edu_cluezer/features/business/presentation/controller/single_service_controller.dart';

class EditServiceController extends GetxController {
  late Service service;
  int? businessId;

  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final descriptionController = TextEditingController();

  final RxList<String> existingImages = <String>[].obs;
  final RxList<String> removedImagePaths = <String>[].obs;
  final RxList<File> newImages = <File>[].obs;

  final RxBool isLoading = false.obs;
  final errors = <String, String>{}.obs;
  final ImagePicker _picker = ImagePicker();

  static const int maxImageCount = 10;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map) {
      service = args['service'] as Service;
      businessId = args['businessId'] as int? ?? service.businessId;
    } else if (args is Service) {
      service = args;
      businessId = service.businessId;
    }

    nameController.text = service.name ?? '';
    priceController.text = service.cost ?? '';
    descriptionController.text = service.description ?? '';

    // Load existing images from service
    if (service.images != null && service.images!.isNotEmpty) {
      for (final img in service.images!) {
        if (img.path != null && img.path!.isNotEmpty) {
          existingImages.add(img.path!);
        }
      }
    }
    if (existingImages.isEmpty && service.imagePaths != null && service.imagePaths!.isNotEmpty) {
      existingImages.assignAll(service.imagePaths!.where((p) => p.isNotEmpty));
    }
    if (existingImages.isEmpty && service.imagePath != null && service.imagePath!.isNotEmpty) {
      existingImages.add(service.imagePath!);
    }

    nameController.addListener(() => errors.remove('name'));
    priceController.addListener(() => errors.remove('price'));
    descriptionController.addListener(() => errors.remove('description'));
  }

  @override
  void onClose() {
    nameController.dispose();
    priceController.dispose();
    descriptionController.dispose();
    super.onClose();
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      final totalImages = existingImages.length + newImages.length;
      if (totalImages >= maxImageCount) {
        CustomSnackBar.showInfo(message: 'Maximum $maxImageCount images limit reached.');
        return;
      }

      if (source == ImageSource.gallery) {
        final List<XFile> images = await _picker.pickMultiImage(
          maxWidth: 1200,
          maxHeight: 1200,
          imageQuality: 85,
        );
        if (images.isNotEmpty) {
          final remainingSlots = maxImageCount - (existingImages.length + newImages.length);
          if (remainingSlots <= 0) {
            CustomSnackBar.showInfo(message: 'Maximum $maxImageCount images limit reached.');
            return;
          }
          if (images.length > remainingSlots) {
            CustomSnackBar.showInfo(
              message: 'Only $remainingSlots image(s) added. Maximum limit is $maxImageCount.',
            );
          }
          for (final img in images.take(remainingSlots)) {
            newImages.add(File(img.path));
          }
          errors.remove('image');
        }
      } else {
        final XFile? image = await _picker.pickImage(
          source: ImageSource.camera,
          maxWidth: 1200,
          maxHeight: 1200,
          imageQuality: 85,
        );
        if (image != null) {
          newImages.add(File(image.path));
          errors.remove('image');
        }
      }
    } catch (e) {
      CustomSnackBar.showError(message: 'Error selecting image: $e');
    }
  }

  void removeExistingImage(int index) {
    if (index >= 0 && index < existingImages.length) {
      final path = existingImages.removeAt(index);
      removedImagePaths.add(path);
      if (existingImages.isEmpty && newImages.isEmpty) {
        errors['image'] = 'please_select_at_least_one_image'.tr;
      }
    }
  }

  void removeNewImage(int index) {
    if (index >= 0 && index < newImages.length) {
      newImages.removeAt(index);
      if (existingImages.isEmpty && newImages.isEmpty) {
        errors['image'] = 'please_select_at_least_one_image'.tr;
      }
    }
  }

  Future<void> saveService() async {
    errors.clear();
    final totalImages = existingImages.length + newImages.length;
    if (totalImages == 0) {
      errors['image'] = 'please_select_at_least_one_image'.tr;
    }
    if (nameController.text.trim().isEmpty) {
      errors['name'] = 'please_enter_service_name'.tr;
    }
    if (descriptionController.text.trim().isEmpty) {
      errors['description'] = 'please_enter_service_description'.tr;
    }
    if (errors.isNotEmpty) return;

    isLoading.value = true;
    try {
      final bCtrl = Get.find<BusinessController>();
      final data = <String, dynamic>{
        'business_id': businessId ?? service.businessId,
        'name': nameController.text.trim(),
        'cost': priceController.text.trim(),
        'description': descriptionController.text.trim(),
        'status': service.status ?? 'active',
        if (removedImagePaths.isNotEmpty)
          'remove_image_paths': removedImagePaths.toList(),
      };

      final success = await bCtrl.updateService(
        service.id!,
        data,
        newImages.toList(),
      );

      isLoading.value = false;
      if (success) {
        service.name = nameController.text.trim();
        service.cost = priceController.text.trim();
        service.description = descriptionController.text.trim();

        // 1. Immediately refresh single service details controller if registered
        if (Get.isRegistered<SingleServiceController>()) {
          Get.find<SingleServiceController>().fetchServiceDetails(service.id!);
        }

        // 2. Immediately pop back to the details screen with result true
        Get.back(result: true);

        // 3. Show success notification on the details screen
        CustomSnackBar.showSuccess(message: 'Service updated successfully!');
      }
    } catch (e) {
      isLoading.value = false;
      CustomSnackBar.showError(message: 'Failed to update service: $e');
    }
  }
}

class EditServiceScreen extends StatelessWidget {
  const EditServiceScreen({Key? key}) : super(key: key);

  void _showImageSourceDialog(BuildContext context, EditServiceController controller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: context.theme.primaryColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.add_photo_alternate_rounded,
                    color: context.theme.primaryColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'select_image_source'.tr,
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Upload clear photos of your service',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildSourceCard(
              context: context,
              icon: Icons.photo_library_rounded,
              iconColor: const Color(0xFF2563EB),
              iconBgColor: const Color(0xFFEFF6FF),
              title: 'gallery'.tr,
              subtitle: 'Select multiple photos at once',
              badgeText: 'Multi-Select',
              onTap: () {
                Navigator.pop(context);
                controller.pickImage(ImageSource.gallery);
              },
            ),
            const SizedBox(height: 12),
            _buildSourceCard(
              context: context,
              icon: Icons.camera_alt_rounded,
              iconColor: const Color(0xFF059669),
              iconBgColor: const Color(0xFFECFDF5),
              title: 'camera'.tr,
              subtitle: 'Take a new photo directly',
              onTap: () {
                Navigator.pop(context);
                controller.pickImage(ImageSource.camera);
              },
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, size: 18, color: Colors.grey[600]),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Supported formats: JPG, JPEG, PNG, WEBP\nYou can add up to ${EditServiceController.maxImageCount} images. High quality photos attract more customers.',
                      style: TextStyle(fontSize: 12, color: Colors.grey[700], height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceCard({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    String? badgeText,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (badgeText != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFFBFDBFE)),
                          ),
                          child: Text(
                            badgeText,
                            style: const TextStyle(
                              color: Color(0xFF1D4ED8),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400], size: 22),
          ],
        ),
      ),
    );
  }

  Widget _buildFormatChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          color: Colors.grey[700],
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EditServiceController());
    final screenWidth = MediaQuery.of(context).size.width;
    final itemSize = (screenWidth - 40 - 20) / 3;

    return Scaffold(
      appBar: AppBar(
        elevation: 0.5,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back_ios_new_outlined, color: context.iconColor),
        ),
        title: Text(
          'Edit Service',
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      'service_image'.tr.isNotEmpty ? 'service_image'.tr : 'Service Images',
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      '*',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Obx(() {
                  final totalCount = controller.existingImages.length + controller.newImages.length;
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: context.theme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$totalCount/${EditServiceController.maxImageCount} Images',
                      style: TextStyle(
                        color: context.theme.primaryColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Upload up to ${EditServiceController.maxImageCount} photos. First photo is the main cover.',
              style: TextStyle(fontSize: 12, color: Colors.grey[600], height: 1.3),
            ),
            const SizedBox(height: 12),

            // Images Grid
            Obx(() {
              final totalCount = controller.existingImages.length + controller.newImages.length;

              if (totalCount == 0) {
                return GestureDetector(
                  onTap: () => _showImageSourceDialog(context, controller),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
                    decoration: BoxDecoration(
                      color: controller.errors['image'] != null
                          ? Colors.red.withOpacity(0.04)
                          : Colors.grey[50],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: controller.errors['image'] != null
                            ? Colors.red
                            : Colors.grey[300]!,
                        width: controller.errors['image'] != null ? 1.5 : 1.2,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: context.theme.primaryColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.add_photo_alternate_outlined,
                            size: 34,
                            color: context.theme.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Tap to upload service photos',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Supports multiple images (Gallery or Camera)',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          alignment: WrapAlignment.center,
                          children: [
                            _buildFormatChip('JPG'),
                            _buildFormatChip('PNG'),
                            _buildFormatChip('WEBP'),
                            _buildFormatChip('MAX 10MB'),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      // Existing Network Images
                      for (int i = 0; i < controller.existingImages.length; i++)
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            GestureDetector(
                              onTap: () {
                                final path = controller.existingImages[i];
                                final url = path.startsWith('http')
                                    ? path
                                    : '${ApiConstants.imageBaseUrl}/$path';
                                Get.to(() => FullScreenImageViewer(
                                      imageUrl: url,
                                      tag: 'edit_service_exist_$i',
                                    ));
                              },
                              child: Hero(
                                tag: 'edit_service_exist_$i',
                                child: Container(
                                  width: itemSize,
                                  height: itemSize,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: i == 0
                                          ? context.theme.primaryColor
                                          : Colors.grey[300]!,
                                      width: i == 0 ? 2 : 1,
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: CustomImageView(
                                      url: controller.existingImages[i].startsWith('http')
                                          ? controller.existingImages[i]
                                          : '${ApiConstants.imageBaseUrl}/${controller.existingImages[i]}',
                                      fit: BoxFit.cover,
                                      width: itemSize,
                                      height: itemSize,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // Primary / Cover Tag
                            if (i == 0)
                              Positioned(
                                bottom: 4,
                                left: 4,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: context.theme.primaryColor,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'COVER',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ),
                            // Delete Button
                            Positioned(
                              top: -6,
                              right: -6,
                              child: GestureDetector(
                                onTap: () => controller.removeExistingImage(i),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFDC2626),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 2),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.15),
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 13,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                      // Newly Added Local Files
                      for (int j = 0; j < controller.newImages.length; j++)
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Get.to(() => FullScreenImageViewer(
                                      imageFile: controller.newImages[j],
                                      tag: 'edit_service_new_$j',
                                    ));
                              },
                              child: Hero(
                                tag: 'edit_service_new_$j',
                                child: Container(
                                  width: itemSize,
                                  height: itemSize,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: (controller.existingImages.isEmpty && j == 0)
                                          ? context.theme.primaryColor
                                          : Colors.grey[300]!,
                                      width: (controller.existingImages.isEmpty && j == 0) ? 2 : 1,
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.file(
                                      controller.newImages[j],
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // Primary / Cover Tag (if no existing images)
                            if (controller.existingImages.isEmpty && j == 0)
                              Positioned(
                                bottom: 4,
                                left: 4,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: context.theme.primaryColor,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'COVER',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ),
                            // Delete Button
                            Positioned(
                              top: -6,
                              right: -6,
                              child: GestureDetector(
                                onTap: () => controller.removeNewImage(j),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFDC2626),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 2),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.15),
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 13,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                      // Add More Button (if total < maxImageCount)
                      if (totalCount < EditServiceController.maxImageCount)
                        GestureDetector(
                          onTap: () => _showImageSourceDialog(context, controller),
                          child: Container(
                            width: itemSize,
                            height: itemSize,
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.grey[300]!,
                                style: BorderStyle.solid,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_photo_alternate_outlined,
                                  size: 26,
                                  color: context.theme.primaryColor,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Add More',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: context.theme.primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              );
            }),

            Obx(
              () => controller.errors['image'] != null
                  ? Padding(
                      padding: const EdgeInsets.only(top: 6, left: 4),
                      child: Text(
                        controller.errors['image']!,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),

            const SizedBox(height: 16),
            Obx(
              () => AppInputTextField(
                label: "service_name".tr,
                isRequired: true,
                textInputType: TextInputType.text,
                controller: controller.nameController,
                errorText: controller.errors['name'],
              ),
            ),
            Obx(
              () => AppInputTextField(
                label: "service_description".tr,
                isRequired: true,
                textInputType: TextInputType.text,
                controller: controller.descriptionController,
                maxLines: 4,
                errorText: controller.errors['description'],
              ),
            ),
            Obx(
              () => AppInputTextField(
                label: "service_price".tr.isNotEmpty ? "service_price".tr : "Price",
                isRequired: false,
                textInputType: TextInputType.number,
                controller: controller.priceController,
                errorText: controller.errors['price'],
              ),
            ),
            const SizedBox(height: 24),
            Obx(
              () => CustomButton(
                onPressed: controller.isLoading.value ? null : controller.saveService,
                title: controller.isLoading.value ? "saving".tr : "Save Changes",
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
