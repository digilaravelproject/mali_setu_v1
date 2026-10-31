import 'package:edu_cluezer/widgets/custom_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

import 'package:edu_cluezer/widgets/basic_text_field.dart';
import 'package:edu_cluezer/widgets/custom_buttons.dart';
import 'package:edu_cluezer/features/business/presentation/controller/business_controller.dart';
import 'package:edu_cluezer/core/widgets/full_screen_image_viewer.dart';

import '../../../../widgets/custom_scaffold.dart';

class AddProductController extends GetxController {
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

  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();

  final RxList<File> selectedImages = <File>[].obs;
  final ImagePicker _picker = ImagePicker();
  final RxBool isLoading = false.obs;
  final errors = <String, String>{}.obs;
  late int businessId;

  static const int maxImageCount = 10;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null) {
      businessId = Get.arguments as int;
    } else {
      Get.back();
    }
    nameController.addListener(() => errors.remove('name'));
    descriptionController.addListener(() => errors.remove('description'));
    priceController.addListener(() => errors.remove('price'));
  }

  @override
  void onClose() {
    nameController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    super.onClose();
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      if (source == ImageSource.gallery) {
        final List<XFile> images = await _picker.pickMultiImage(
          maxWidth: 1200,
          maxHeight: 1200,
          imageQuality: 85,
        );
        if (images.isNotEmpty) {
          final remainingSlots = maxImageCount - selectedImages.length;
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
            selectedImages.add(File(img.path));
          }
          errors.remove('image');
        }
      } else {
        if (selectedImages.length >= maxImageCount) {
          CustomSnackBar.showInfo(message: 'Maximum $maxImageCount images limit reached.');
          return;
        }
        final XFile? image = await _picker.pickImage(
          source: ImageSource.camera,
          maxWidth: 1200,
          maxHeight: 1200,
          imageQuality: 85,
        );
        if (image != null) {
          selectedImages.add(File(image.path));
          errors.remove('image');
        }
      }
    } catch (e) {
      CustomSnackBar.showError(message: 'Error picking image: $e');
    }
  }

  void removeImage(int index) {
    if (index >= 0 && index < selectedImages.length) {
      selectedImages.removeAt(index);
    }
  }

  Future<void> createProduct() async {
    errors.clear();
    if (nameController.text.trim().isEmpty) {
      errors['name'] = 'please_enter_product_name'.tr;
    }
    if (descriptionController.text.trim().isEmpty) {
      errors['description'] = 'please_enter_product_description'.tr;
    }
    if (selectedImages.isEmpty) {
      errors['image'] = 'please_select_at_least_one_image'.tr;
    }
    if (errors.isNotEmpty) return;

    isLoading.value = true;
    final data = {
      'business_id': businessId,
      'name': nameController.text.trim(),
      'description': descriptionController.text.trim(),
      'cost': priceController.text.trim(),
    };
    final success = await Get.find<BusinessController>().addProduct(
      data,
      selectedImages.toList(),
    );
    isLoading.value = false;
    if (success) {
      Get.back();
      CustomSnackBar.showSuccess(message: 'Product created successfully!');
    }
  }
}

class AddProductScreen extends StatelessWidget {
  const AddProductScreen({Key? key}) : super(key: key);

  void _showImageSourceDialog(BuildContext context, AddProductController controller) {
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
                        'Upload clear photos of your product',
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
                      'Supported formats: JPG, JPEG, PNG, WEBP\nYou can add up to ${AddProductController.maxImageCount} images. High quality photos attract more buyers.',
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
    final controller = Get.put(AddProductController());
    final screenWidth = MediaQuery.of(context).size.width;
    final itemSize = (screenWidth - 40 - 20) / 3;

    return Obx(() {
      controller.canExit.value; // Dummy read for Obx
      return CustomScaffold(
        onWillPop: controller.handleBack,
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => Get.back(),
            icon: Icon(Icons.arrow_back_ios_new_outlined, color: context.iconColor),
          ),
          title: Text("add_product".tr, style: context.textTheme.titleMedium),
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
                        'product_images'.tr,
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
                  Obx(
                    () => controller.selectedImages.isNotEmpty
                        ? Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: context.theme.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${controller.selectedImages.length}/${AddProductController.maxImageCount} Images',
                              style: TextStyle(
                                color: context.theme.primaryColor,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        : Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Multiple Allowed',
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Obx(() {
                if (controller.selectedImages.isEmpty) {
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
                            'Upload single or multiple images • Up to ${AddProductController.maxImageCount} images',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            alignment: WrapAlignment.center,
                            children: [
                              _buildFormatChip('JPG'),
                              _buildFormatChip('PNG'),
                              _buildFormatChip('WEBP'),
                              _buildFormatChip('Max 10MB'),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: context.theme.primaryColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.add_photo_alternate, size: 18, color: Colors.white),
                                const SizedBox(width: 6),
                                Text(
                                  'upload_images'.tr.isNotEmpty ? 'upload_images'.tr : 'Choose Images',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
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

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: context.theme.primaryColor.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.star_rounded, size: 16, color: context.theme.primaryColor),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'First image is your Main Cover Photo',
                              style: TextStyle(
                                fontSize: 12,
                                color: context.theme.primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => controller.selectedImages.clear(),
                            child: Text(
                              'Clear all',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.red[600],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        ...List.generate(controller.selectedImages.length, (index) {
                          final file = controller.selectedImages[index];
                          final isCover = index == 0;
                          return Stack(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Get.to(() => FullScreenImageViewer(
                                        imageFile: file,
                                        tag: 'product_photo_$index',
                                      ));
                                },
                                child: Hero(
                                  tag: 'product_photo_$index',
                                  child: Container(
                                    width: itemSize,
                                    height: itemSize,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isCover
                                            ? context.theme.primaryColor
                                            : context.theme.dividerColor.withOpacity(0.6),
                                        width: isCover ? 2 : 1,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.04),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
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
                              Positioned(
                                top: 5,
                                right: 5,
                                child: GestureDetector(
                                  onTap: () => controller.removeImage(index),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(0.95),
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 3,
                                        ),
                                      ],
                                    ),
                                    child: const Icon(Icons.close, color: Colors.white, size: 14),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 5,
                                left: 5,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: isCover
                                        ? context.theme.primaryColor
                                        : Colors.black.withOpacity(0.65),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (isCover) ...[
                                        const Icon(Icons.star, size: 10, color: Colors.white),
                                        const SizedBox(width: 3),
                                        const Text(
                                          'Cover',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ] else ...[
                                        Text(
                                          '${index + 1}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        }),
                        if (controller.selectedImages.length < AddProductController.maxImageCount)
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
                                  style: BorderStyle.solid,
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
                                    '(${controller.selectedImages.length}/${AddProductController.maxImageCount})',
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
                    const SizedBox(height: 8),
                    Text(
                      'Supported formats: JPG, PNG, WEBP (Max 10MB each)',
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    ),
                  ],
                );
              }),
              Obx(() => controller.errors['image'] != null
                  ? Padding(
                      padding: const EdgeInsets.only(top: 6, left: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            controller.errors['image']!,
                            style: const TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink()),
              const SizedBox(height: 16),
              Obx(() => AppInputTextField(
                    label: "product_name".tr,
                    isRequired: true,
                    textInputType: TextInputType.text,
                    controller: controller.nameController,
                    errorText: controller.errors['name'],
                  )),
              Obx(() => AppInputTextField(
                    label: "product_description".tr,
                    isRequired: true,
                    textInputType: TextInputType.text,
                    controller: controller.descriptionController,
                    maxLines: 4,
                    errorText: controller.errors['description'],
                  )),
              Obx(() => AppInputTextField(
                    label: "product_price".tr,
                    isRequired: false,
                    textInputType: TextInputType.number,
                    controller: controller.priceController,
                    errorText: controller.errors['price'],
                  )),
              const SizedBox(height: 24),
              Obx(() => CustomButton(
                    onPressed: controller.isLoading.value ? null : controller.createProduct,
                    title: controller.isLoading.value ? "creating".tr : "create_product".tr,
                  )),
              const SizedBox(height: 20),
            ],
          ),
        ),
      );
    });
  }
}
