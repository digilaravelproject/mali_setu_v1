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

class EditServiceController extends GetxController {
  late Service service;
  int? businessId;

  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final descriptionController = TextEditingController();

  final Rx<File?> selectedImage = Rx<File?>(null);
  final RxString existingImagePath = ''.obs;
  final RxBool isLoading = false.obs;
  final errors = <String, String>{}.obs;
  final ImagePicker _picker = ImagePicker();

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
    existingImagePath.value = service.imagePath ?? '';

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
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (image != null) {
        selectedImage.value = File(image.path);
        errors.remove('image');
      }
    } catch (e) {
      CustomSnackBar.showError(message: 'Error selecting image: $e');
    }
  }

  void removeNewImage() {
    selectedImage.value = null;
  }

  Future<void> saveService() async {
    errors.clear();
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
      };

      final List<File> filesToSend = [];
      if (selectedImage.value != null) {
        filesToSend.add(selectedImage.value!);
      }

      final success = await bCtrl.updateService(
        service.id!,
        data,
        filesToSend,
      );

      isLoading.value = false;
      if (success) {
        service.name = nameController.text.trim();
        service.cost = priceController.text.trim();
        service.description = descriptionController.text.trim();

        CustomSnackBar.showSuccess(message: 'Service updated successfully!');
        Get.back(result: true);
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
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('select_image_source'.tr, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSourceOption(Icons.camera_alt, 'camera'.tr, () {
                  Navigator.pop(context);
                  controller.pickImage(ImageSource.camera);
                }),
                _buildSourceOption(Icons.photo_library, 'gallery'.tr, () {
                  Navigator.pop(context);
                  controller.pickImage(ImageSource.gallery);
                }),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceOption(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            Icon(icon, size: 40, color: Colors.black87),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EditServiceController());
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

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
            // Image Preview Card
            Text(
              'service_image'.tr.isNotEmpty ? 'service_image'.tr : 'Service Image',
              style: context.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 12),

            Obx(() {
              final newImg = controller.selectedImage.value;
              final hasExisting = controller.existingImagePath.value.isNotEmpty;

              return Container(
                height: 190,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.grey.shade50,
                  border: Border.all(
                    color: controller.errors['image'] != null
                        ? Colors.red
                        : Colors.grey.shade200,
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Main Image Display
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: newImg != null
                          ? GestureDetector(
                              onTap: () {
                                Get.to(() => FullScreenImageViewer(
                                      imageFile: newImg,
                                      tag: 'edit_service_img',
                                    ));
                              },
                              child: Hero(
                                tag: 'edit_service_img',
                                child: Image.file(
                                  newImg,
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            )
                          : hasExisting
                              ? CustomImageView(
                                  url: ApiConstants.imageBaseUrl +
                                      controller.existingImagePath.value,
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => _buildPlaceholder(context),
                                )
                              : _buildPlaceholder(context),
                    ),

                    // Change Photo Button Overlay
                    Positioned(
                      bottom: 12,
                      right: 12,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => _showImageSourceDialog(context, controller),
                          borderRadius: BorderRadius.circular(24),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: primaryColor,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: primaryColor.withOpacity(0.4),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.camera_alt_outlined, color: Colors.white, size: 16),
                                SizedBox(width: 6),
                                Text(
                                  'Change Photo',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Cancel picked image button (if user picked a new file)
                    if (newImg != null)
                      Positioned(
                        top: 10,
                        right: 10,
                        child: GestureDetector(
                          onTap: controller.removeNewImage,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close, color: Colors.white, size: 16),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 20),

            // Form Fields: EXACTLY matching original
            Obx(() => AppInputTextField(
                  label: "service_name".tr,
                  isRequired: true,
                  textInputType: TextInputType.text,
                  controller: controller.nameController,
                  errorText: controller.errors['name'],
                )),

            Obx(() => AppInputTextField(
                  label: "service_price".tr.isNotEmpty ? "service_price".tr : "Price",
                  isRequired: false,
                  textInputType: TextInputType.number,
                  controller: controller.priceController,
                  errorText: controller.errors['price'],
                )),

            Obx(() => AppInputTextField(
                  label: "service_description".tr,
                  isRequired: true,
                  textInputType: TextInputType.text,
                  controller: controller.descriptionController,
                  maxLines: 4,
                  errorText: controller.errors['description'],
                )),

            const SizedBox(height: 32),

            // Save Button
            Obx(() => CustomButton(
                  onPressed: controller.isLoading.value ? null : controller.saveService,
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
