import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_navigation/src/snackbar/snackbar.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:get/get_utils/src/extensions/context_extensions.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/helper/form_validator.dart';
import '../../../../widgets/basic_text_field.dart';
import '../../../../widgets/custom_buttons.dart';

/*class AddServiceController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();

  final Rx<File?> selectedImage = Rx<File?>(null);
  final ImagePicker _picker = ImagePicker();
  final RxBool isLoading = false.obs;

  @override
  void onClose() {
    nameController.dispose();
    descriptionController.dispose();
    priceController.dispose();
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
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error picking image: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void removeImage() {
    selectedImage.value = null;
  }

  Future<void> createProduct() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    if (selectedImage.value == null) {
      Get.snackbar(
        'Error',
        'Please select a product image',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    isLoading.value = false;

    // Show success message
    Get.snackbar(
      'Success',
      'Product created successfully!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );

    // Clear form
    nameController.clear();
    descriptionController.clear();
    priceController.clear();
    selectedImage.value = null;
  }
}

// Stateless Screen
class AddServiceScreen extends StatelessWidget {
  const AddServiceScreen({Key? key}) : super(key: key);

  void _showImageSourceDialog(BuildContext context, AddServiceController controller) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select Image Source',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildImageSourceOption(
                  icon: Icons.camera_alt,
                  label: 'Camera',
                  onTap: () {
                    Navigator.pop(context);
                    controller.pickImage(ImageSource.camera);
                  },
                ),
                _buildImageSourceOption(
                  icon: Icons.photo_library,
                  label: 'Gallery',
                  onTap: () {
                    Navigator.pop(context);
                    controller.pickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 40, color: Colors.black87),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AddServiceController());

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: Get.back,
          icon: Icon(Icons.arrow_back_ios_new_outlined, color: context.iconColor),
        ),
        title: Text("Add Product", style: context.textTheme.titleMedium),
      ),
      body: Form(
        key: controller.formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Section
              Text(
                'Product Image',
                style: context.textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              Obx(() => GestureDetector(
                onTap: () => _showImageSourceDialog(context, controller),
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    //   color: context.theme.hoverColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: context.theme.dividerColor, width: 1),
                  ),
                  child: controller.selectedImage.value != null
                      ? Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          controller.selectedImage.value!,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: controller.removeImage,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                      : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_photo_alternate_outlined,
                        size: 60,
                        color:context.theme.focusColor,
                      ),
                      const SizedBox(height: 12),
                      Text(
                          'Tap to add product image',
                          style:context.textTheme.bodyLarge

                      ),
                      const SizedBox(height: 4),
                      Text(
                          'Camera or Gallery',
                          style:context.textTheme.bodySmall

                      ),
                    ],
                  ),
                ),
              )),
              const SizedBox(height: 10),

              AppInputTextField(
                label: "Product Name ",
                // iconData: CupertinoIcons.mail_solid,
                textInputType: TextInputType.text,
                //controller: controller.mobileController,
                hint: const [AutofillHints.name],
                validator: FormValidator.name,
              ),
              const SizedBox(height: 8),

              AppInputTextField(
                label: "Product Description",
                // iconData: CupertinoIcons.mail_solid,
                textInputType: TextInputType.text,
                //controller: controller.mobileController,
                hint: const [AutofillHints.name],
                maxLines: 4,
                validator: FormValidator.name,
              ),
              const SizedBox(height: 8),
              AppInputTextField(
                label: "Product Price",
                // iconData: CupertinoIcons.mail_solid,
                textInputType: TextInputType.number,
                //controller: controller.mobileController,
                //hint: const [AutofillHints.n],
                validator:(value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter product price';
                  }
                  final price = int.tryParse(value);
                  if (price == null || price <= 0) {
                    return 'Please enter a valid price';
                  }
                  return null;
                },
              ),



              SizedBox(height: 30,),


              CustomButton(onPressed: controller.createProduct, title: "Create Product"),


              const SizedBox(height: 20),
            ],
          ),
        ),
      ),

    );
  }
}*/


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';

// Controller
class AddServiceController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();

  final RxList<File> selectedImages = <File>[].obs;
  final ImagePicker _picker = ImagePicker();
  final RxBool isLoading = false.obs;
  final int maxImages = 5;

  @override
  void onClose() {
    nameController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    super.onClose();
  }

  Future<void> pickImage(ImageSource source) async {
    if (selectedImages.length >= maxImages) {
      Get.snackbar(
        'Limit Reached',
        'You can only upload maximum $maxImages images',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        selectedImages.add(File(image.path));
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error picking image: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void removeImage(int index) {
    selectedImages.removeAt(index);
  }

  Future<void> createProduct() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    if (selectedImages.isEmpty) {
      Get.snackbar(
        'Error',
        'Please select at least one product image',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    isLoading.value = false;

    // Show success message
    Get.snackbar(
      'Success',
      'Product created successfully with ${selectedImages.length} image(s)!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );

    // Clear form
    nameController.clear();
    descriptionController.clear();
    priceController.clear();
    selectedImages.clear();
  }
}

// Stateless Screen
class AddServiceScreen extends StatelessWidget {
  const AddServiceScreen({Key? key}) : super(key: key);

  void _showImageSourceDialog(BuildContext context, AddServiceController controller) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select Image Source',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildImageSourceOption(
                  icon: Icons.camera_alt,
                  label: 'Camera',
                  onTap: () {
                    Navigator.pop(context);
                    controller.pickImage(ImageSource.camera);
                  },
                ),
                _buildImageSourceOption(
                  icon: Icons.photo_library,
                  label: 'Gallery',
                  onTap: () {
                    Navigator.pop(context);
                    controller.pickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 40, color: Colors.black87),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AddServiceController());

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: Get.back,
          icon: Icon(Icons.arrow_back_ios_new_outlined, color: context.iconColor),
        ),
        title: Text("Add Service", style: context.textTheme.titleMedium),
      ),
      body: Form(
        key: controller.formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Upload Images',
                    style: context.textTheme.titleMedium,
                  ),
                  Obx(() => Text(
                    '${controller.selectedImages.length}/${controller.maxImages}',
                    style: context.textTheme.bodySmall,
                  )),
                ],
              ),
              const SizedBox(height: 12),
              Obx(() => GestureDetector(
                onTap: controller.selectedImages.length < controller.maxImages
                    ? () => _showImageSourceDialog(context, controller)
                    : null,
                child: Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(minHeight: 150),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: context.theme.dividerColor, width: 1),
                  ),
                  child: controller.selectedImages.isEmpty
                      ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_photo_alternate_outlined,
                        size: 60,
                        color: context.theme.focusColor,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Tap to add product images',
                        style: context.textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Camera or Gallery (Max 5)',
                        style: context.textTheme.bodySmall,
                      ),
                    ],
                  )
                      : Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      // Display selected images
                      ...List.generate(
                        controller.selectedImages.length,
                            (index) => Stack(
                          clipBehavior: Clip.none,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                controller.selectedImages[index],
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: -6,
                              right: -6,
                              child: GestureDetector(
                                onTap: () => controller.removeImage(index),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Add more button
                      if (controller.selectedImages.length < controller.maxImages)
                        GestureDetector(
                          onTap: () => _showImageSourceDialog(context, controller),
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: context.theme.hoverColor,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: context.theme.dividerColor,
                                width: 1,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add,
                                  size: 30,
                                  color: context.theme.focusColor,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Add',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: context.theme.focusColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              )),
              const SizedBox(height: 10),

              AppInputTextField(
                label: "Service Name",
                textInputType: TextInputType.text,
                controller: controller.nameController,
                hint: const [AutofillHints.name],
                validator: FormValidator.name,
              ),
              const SizedBox(height: 8),

              AppInputTextField(
                label: "Service Description",
                textInputType: TextInputType.text,
                controller: controller.descriptionController,
                hint: const [AutofillHints.name],
                maxLines: 4,
                validator: FormValidator.name,
              ),
              const SizedBox(height: 8),

              AppInputTextField(
                label: "Service Price",
                textInputType: TextInputType.number,
                controller: controller.priceController,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter product price';
                  }
                  final price = int.tryParse(value);
                  if (price == null || price <= 0) {
                    return 'Please enter a valid price';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 30),

              Obx(() => CustomButton(
                onPressed: controller.isLoading.value ? null : controller.createProduct,
                title: controller.isLoading.value ? "Creating..." : "Create Service",
              )),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
