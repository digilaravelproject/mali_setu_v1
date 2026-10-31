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
import 'package:edu_cluezer/features/business/presentation/controller/single_product_controller.dart';

class EditProductController extends GetxController {
  late Product product;
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
      product = args['product'] as Product;
      businessId = args['businessId'] as int? ?? product.businessId;
    } else if (args is Product) {
      product = args;
      businessId = product.businessId;
    }

    nameController.text = product.name ?? '';
    priceController.text = product.cost ?? '';
    descriptionController.text = product.description ?? '';

    // Load existing images from product
    if (product.images != null && product.images!.isNotEmpty) {
      for (final img in product.images!) {
        if (img.path != null && img.path!.isNotEmpty) {
          existingImages.add(img.path!);
        }
      }
    }
    if (existingImages.isEmpty && product.imagePaths != null && product.imagePaths!.isNotEmpty) {
      existingImages.assignAll(product.imagePaths!.where((p) => p.isNotEmpty));
    }
    if (existingImages.isEmpty && product.imagePath != null && product.imagePath!.isNotEmpty) {
      existingImages.add(product.imagePath!);
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

  Future<void> saveProduct() async {
    errors.clear();
    final totalImages = existingImages.length + newImages.length;
    if (totalImages == 0) {
      errors['image'] = 'please_select_at_least_one_image'.tr;
    }
    if (nameController.text.trim().isEmpty) {
      errors['name'] = 'please_enter_product_name'.tr;
    }
    if (descriptionController.text.trim().isEmpty) {
      errors['description'] = 'please_enter_product_description'.tr;
    }
    if (errors.isNotEmpty) return;

    isLoading.value = true;
    try {
      final bCtrl = Get.find<BusinessController>();
      final data = <String, dynamic>{
        'business_id': businessId ?? product.businessId,
        'name': nameController.text.trim(),
        'cost': priceController.text.trim(),
        'description': descriptionController.text.trim(),
        'status': product.status ?? 'active',
        if (removedImagePaths.isNotEmpty)
          'remove_image_paths': removedImagePaths.toList(),
      };

      final success = await bCtrl.updateProduct(
        product.id!,
        data,
        newImages.toList(),
      );

      isLoading.value = false;
      if (success) {
        product.name = nameController.text.trim();
        product.cost = priceController.text.trim();
        product.description = descriptionController.text.trim();

        // 1. Immediately refresh single product details controller if registered
        if (Get.isRegistered<SingleProductController>()) {
          Get.find<SingleProductController>().fetchProductDetails(product.id!);
        }

        // 2. Immediately pop back to the details screen with result true
        Get.back(result: true);

        // 3. Show success notification on the details screen
        CustomSnackBar.showSuccess(message: 'Product updated successfully!');
      }
    } catch (e) {
      isLoading.value = false;
      CustomSnackBar.showError(message: 'Failed to update product: $e');
    }
  }
}

class EditProductScreen extends StatelessWidget {
  const EditProductScreen({Key? key}) : super(key: key);

  void _showImageSourceDialog(BuildContext context, EditProductController controller) {
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
                        'Upload photos of your product',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildSourceOption(
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
            _buildSourceOption(
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
                      'Supported formats: JPG, JPEG, PNG, WEBP\nMaximum limit: ${EditProductController.maxImageCount} images.',
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

  Widget _buildSourceOption({
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
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EditProductController());
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
          'Edit Product',
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
            // Header: Product Images and Counter
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      'product_images'.tr,
                      style: context.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
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
                      '$totalCount/${EditProductController.maxImageCount} Images',
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
            const SizedBox(height: 12),

            // Multiple Images Preview / Grid
            Obx(() {
              final totalCount = controller.existingImages.length + controller.newImages.length;

              if (totalCount == 0) {
                return GestureDetector(
                  onTap: () => _showImageSourceDialog(context, controller),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                    decoration: BoxDecoration(
                      color: context.theme.primaryColor.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: controller.errors['image'] != null
                            ? Colors.red
                            : context.theme.primaryColor.withOpacity(0.35),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 58,
                          height: 58,
                          decoration: BoxDecoration(
                            color: context.theme.primaryColor.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.cloud_upload_outlined,
                            size: 32,
                            color: context.theme.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'tap_to_add_images'.tr,
                          style: context.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Upload single or multiple images • Up to ${EditProductController.maxImageCount}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
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
                      // 1. Existing Network Images
                      ...List.generate(controller.existingImages.length, (index) {
                        final path = controller.existingImages[index];
                        final url = path.startsWith('http') ? path : '${ApiConstants.imageBaseUrl}/$path';
                        final isCover = index == 0;

                        return Stack(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Get.to(() => FullScreenImageViewer(
                                      imageUrl: url,
                                      tag: 'edit_existing_$index',
                                    ));
                              },
                              child: Hero(
                                tag: 'edit_existing_$index',
                                child: Container(
                                  width: itemSize,
                                  height: itemSize,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isCover
                                          ? context.theme.primaryColor
                                          : context.theme.dividerColor.withOpacity(0.5),
                                      width: isCover ? 2 : 1,
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(11),
                                    child: CustomImageView(
                                      url: url,
                                      width: itemSize,
                                      height: itemSize,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => _buildPlaceholder(context),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // Delete button (removes existing image)
                            Positioned(
                              top: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: () => controller.removeExistingImage(index),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.close, color: Colors.white, size: 14),
                                ),
                              ),
                            ),
                            // Cover badge on first image
                            if (isCover)
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
                                    'Cover',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        );
                      }),

                      // 2. Newly Picked Local Image Files
                      ...List.generate(controller.newImages.length, (index) {
                        final file = controller.newImages[index];

                        return Stack(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Get.to(() => FullScreenImageViewer(
                                      imageFile: file,
                                      tag: 'edit_new_$index',
                                    ));
                              },
                              child: Hero(
                                tag: 'edit_new_$index',
                                child: Container(
                                  width: itemSize,
                                  height: itemSize,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.green.shade400,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(11),
                                    child: Image.file(
                                      file,
                                      width: itemSize,
                                      height: itemSize,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // Delete button for newly added image
                            Positioned(
                              top: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: () => controller.removeNewImage(index),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.close, color: Colors.white, size: 14),
                                ),
                              ),
                            ),
                            // "New" badge
                            Positioned(
                              bottom: 4,
                              left: 4,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade700,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'New',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }),

                      // 3. "+ Add More" Button Card
                      if (totalCount < EditProductController.maxImageCount)
                        GestureDetector(
                          onTap: () => _showImageSourceDialog(context, controller),
                          child: Container(
                            width: itemSize,
                            height: itemSize,
                            decoration: BoxDecoration(
                              color: context.theme.primaryColor.withOpacity(0.04),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: context.theme.primaryColor.withOpacity(0.4),
                                width: 1.2,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_photo_alternate_outlined,
                                  size: 28,
                                  color: context.theme.primaryColor,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Add More',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: context.theme.primaryColor,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  '($totalCount/${EditProductController.maxImageCount})',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey[600],
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

            Obx(() => controller.errors['image'] != null
                ? Padding(
                    padding: const EdgeInsets.only(top: 6, left: 4),
                    child: Text(
                      controller.errors['image']!,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  )
                : const SizedBox.shrink()),

            const SizedBox(height: 20),

            // Form Fields
            Obx(() => AppInputTextField(
                  label: "product_name".tr,
                  isRequired: true,
                  textInputType: TextInputType.text,
                  controller: controller.nameController,
                  errorText: controller.errors['name'],
                )),

            Obx(() => AppInputTextField(
                  label: "product_price".tr,
                  isRequired: false,
                  textInputType: TextInputType.number,
                  controller: controller.priceController,
                  errorText: controller.errors['price'],
                )),

            Obx(() => AppInputTextField(
                  label: "product_description".tr,
                  isRequired: true,
                  textInputType: TextInputType.text,
                  controller: controller.descriptionController,
                  maxLines: 4,
                  errorText: controller.errors['description'],
                )),

            const SizedBox(height: 32),

            // Save Button
            Obx(() => CustomButton(
                  onPressed: controller.isLoading.value ? null : controller.saveProduct,
                  title: controller.isLoading.value ? "saving".tr : "Save Changes",
                )),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_photo_alternate_outlined, size: 50, color: context.theme.focusColor),
          const SizedBox(height: 8),
          Text('tap_to_add_images'.tr, style: context.textTheme.bodyLarge),
          Text('camera_or_gallery'.tr, style: context.textTheme.bodySmall),
        ],
      ),
    );
  }
}
