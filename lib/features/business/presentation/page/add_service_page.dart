import 'package:edu_cluezer/widgets/custom_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

import 'package:edu_cluezer/widgets/basic_text_field.dart';
import 'package:edu_cluezer/widgets/custom_buttons.dart';
import 'package:edu_cluezer/features/business/presentation/controller/business_controller.dart';

class AddServiceController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();

  final Rx<File?> selectedImage = Rx<File?>(null);
  final ImagePicker _picker = ImagePicker();
  final RxBool isLoading = false.obs;
  final errors = <String, String>{}.obs;
  late int businessId;

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
      final XFile? image = await _picker.pickImage(source: source, maxWidth: 1080, maxHeight: 1080, imageQuality: 85);
      if (image != null) {
        selectedImage.value = File(image.path);
        errors.remove('image');
      }
    } catch (e) {
      CustomSnackBar.showError(message: 'Error picking image: $e');
    }
  }

  void removeImage() => selectedImage.value = null;

  Future<void> createProduct() async {
    errors.clear();
    if (nameController.text.trim().isEmpty) errors['name'] = 'please_enter_service_name'.tr;
    if (descriptionController.text.trim().isEmpty) errors['description'] = 'please_enter_service_description'.tr;
    if (priceController.text.trim().isEmpty) errors['price'] = 'please_enter_service_price'.tr;
    if (selectedImage.value == null) errors['image'] = 'please_select_image'.tr;
    if (errors.isNotEmpty) return;

    isLoading.value = true;
    final data = {
      'business_id': businessId,
      'name': nameController.text.trim(),
      'description': descriptionController.text.trim(),
      'cost': priceController.text.trim(),
    };
    final success = await Get.find<BusinessController>().addService(data, [selectedImage.value!]);
    isLoading.value = false;
    if (success) {
      Get.back();
      CustomSnackBar.showSuccess(message: 'Service created successfully!');
    }
  }
}

class AddServiceScreen extends StatelessWidget {
  const AddServiceScreen({Key? key}) : super(key: key);

  void _showImageSourceDialog(BuildContext context, AddServiceController controller) {
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
                _buildOption(Icons.camera_alt, 'camera'.tr, () { Navigator.pop(context); controller.pickImage(ImageSource.camera); }),
                _buildOption(Icons.photo_library, 'gallery'.tr, () { Navigator.pop(context); controller.pickImage(ImageSource.gallery); }),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
        child: Column(children: [Icon(icon, size: 40, color: Colors.black87), const SizedBox(height: 8), Text(label)]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AddServiceController());
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: Get.back, icon: Icon(Icons.arrow_back_ios_new_outlined, color: context.iconColor)),
        title: Text("add_service".tr, style: context.textTheme.titleMedium),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('service_image'.tr, style: context.textTheme.titleMedium),
            const SizedBox(height: 12),
            Obx(() => GestureDetector(
              onTap: () => _showImageSourceDialog(context, controller),
              child: Container(
                height: 160,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: controller.errors['image'] != null ? Colors.red : context.theme.dividerColor,
                    width: controller.errors['image'] != null ? 1.5 : 1,
                  ),
                ),
                child: controller.selectedImage.value != null
                    ? Stack(children: [
                        ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(controller.selectedImage.value!, width: double.infinity, height: double.infinity, fit: BoxFit.cover)),
                        Positioned(top: 8, right: 8, child: GestureDetector(
                          onTap: controller.removeImage,
                          child: Container(padding: const EdgeInsets.all(6), decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle), child: const Icon(Icons.close, color: Colors.white, size: 18)),
                        )),
                      ])
                    : Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(Icons.add_photo_alternate_outlined, size: 50, color: context.theme.focusColor),
                        const SizedBox(height: 8),
                        Text('tap_to_add_images'.tr, style: context.textTheme.bodyLarge),
                        Text('camera_or_gallery'.tr, style: context.textTheme.bodySmall),
                      ]),
              ),
            )),
            Obx(() => controller.errors['image'] != null
                ? Padding(padding: const EdgeInsets.only(top: 4, left: 4), child: Text(controller.errors['image']!, style: const TextStyle(color: Colors.red, fontSize: 12)))
                : const SizedBox.shrink()),
            const SizedBox(height: 8),
            Obx(() => AppInputTextField(label: "service_name".tr, isRequired: true, textInputType: TextInputType.text, controller: controller.nameController, errorText: controller.errors['name'])),
            Obx(() => AppInputTextField(label: "service_description".tr, isRequired: true, textInputType: TextInputType.text, controller: controller.descriptionController, maxLines: 4, errorText: controller.errors['description'])),
            Obx(() => AppInputTextField(label: "service_price".tr, isRequired: true, textInputType: TextInputType.number, controller: controller.priceController, errorText: controller.errors['price'])),
            const SizedBox(height: 24),
            Obx(() => CustomButton(
              onPressed: controller.isLoading.value ? null : controller.createProduct,
              title: controller.isLoading.value ? "creating".tr : "create_service".tr,
            )),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
