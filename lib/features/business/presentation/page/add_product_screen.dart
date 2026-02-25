import 'package:edu_cluezer/widgets/custom_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

import 'package:edu_cluezer/core/helper/form_validator.dart';
import 'package:edu_cluezer/widgets/basic_text_field.dart';
import 'package:edu_cluezer/widgets/custom_buttons.dart';


import 'package:edu_cluezer/features/business/presentation/controller/business_controller.dart';


// Controller
class AddProductController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();

  final RxList<File> selectedImages = <File>[].obs;
  final ImagePicker _picker = ImagePicker();
  final RxBool isLoading = false.obs;
  final int maxImages = 5;
  
  late int businessId;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null) {
      businessId = Get.arguments as int;
    } else {
      Get.back();
      // Get.snackbar("Error", "Business ID missing");
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    super.onClose();
  }

  Future<void> pickImage(ImageSource source) async {
    if (selectedImages.length >= maxImages) {
      CustomSnackBar.showWarning(
        message: 'You can only upload maximum $maxImages images',
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
      CustomSnackBar.showError(
        message: 'Error picking image: $e',
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

    isLoading.value = true;

    final data = {
      'business_id': businessId,
      'name': nameController.text.trim(),
      'description': descriptionController.text.trim(),
      'cost': priceController.text.trim(),
    };

    final businessController = Get.find<BusinessController>();
    final success = await businessController.addProduct(data, selectedImages);

    isLoading.value = false;

    if (success) {
      Get.back();
      CustomSnackBar.showSuccess(
        message: 'Product created successfully!',
      );
    }
  }
}

// Stateless Screen
class AddProductScreen extends StatelessWidget {
  const AddProductScreen({Key? key}) : super(key: key);

  void _showImageSourceDialog(BuildContext context, AddProductController controller) {
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
            Text(
              'select_image_source'.tr,
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
                  label: 'camera'.tr,
                  onTap: () {
                    Navigator.pop(context);
                    controller.pickImage(ImageSource.camera);
                  },
                ),
                _buildImageSourceOption(
                  icon: Icons.photo_library,
                  label: 'gallery'.tr,
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
    final controller = Get.put(AddProductController());

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: Get.back,
          icon: Icon(Icons.arrow_back_ios_new_outlined, color: context.iconColor),
        ),
        title: Text("add_product".tr, style: context.textTheme.titleMedium),
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
                    'product_images'.tr,
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
                        'tap_to_add_images'.tr,
                        style: context.textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'camera_or_gallery'.tr,
                        style: context.textTheme.bodySmall,
                      ),
                    ],
                  )
                      : Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ...List.generate(
                        controller.selectedImages.length,
                            (index) => Stack(
                          clipBehavior: Clip.none,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                controller.selectedImages[index],
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: -8,
                              right: -8,
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
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (controller.selectedImages.length < controller.maxImages)
                        GestureDetector(
                          onTap: () => _showImageSourceDialog(context, controller),
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: context.theme.hoverColor,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: context.theme.dividerColor,
                                width: 1,
                              ),
                            ),
                            child: Icon(
                              Icons.add,
                              size: 40,
                              color: context.theme.focusColor,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              )),
              const SizedBox(height: 10),

              AppInputTextField(
                label: "product_name".tr,
                textInputType: TextInputType.text,
                controller: controller.nameController,
                hint: const [AutofillHints.name],
                validator: FormValidator.name,
              ),
              const SizedBox(height: 8),

              AppInputTextField(
                label: "product_description".tr,
                textInputType: TextInputType.text,
                controller: controller.descriptionController,
                hint: const [AutofillHints.name],
                maxLines: 4,
                validator: FormValidator.name,
              ),
              const SizedBox(height: 8),
              AppInputTextField(
                label: "product_price".tr,
                textInputType: TextInputType.number,
                controller: controller.priceController,
              ),

              // Product Name
              // const Text(
              //   'Product Name',
              //   style: TextStyle(
              //     fontSize: 16,
              //     fontWeight: FontWeight.w600,
              //     color: Colors.black87,
              //   ),
              // ),
              // const SizedBox(height: 8),
              // TextFormField(
              //   controller: controller.nameController,
              //   decoration: InputDecoration(
              //     hintText: 'Enter product name',
              //     hintStyle: TextStyle(color: Colors.grey[400]),
              //     filled: true,
              //     fillColor: Colors.grey[50],
              //     border: OutlineInputBorder(
              //       borderRadius: BorderRadius.circular(12),
              //       borderSide: BorderSide(color: Colors.grey[300]!),
              //     ),
              //     enabledBorder: OutlineInputBorder(
              //       borderRadius: BorderRadius.circular(12),
              //       borderSide: BorderSide(color: Colors.grey[300]!),
              //     ),
              //     focusedBorder: OutlineInputBorder(
              //       borderRadius: BorderRadius.circular(12),
              //       borderSide: const BorderSide(color: Colors.blue, width: 2),
              //     ),
              //     errorBorder: OutlineInputBorder(
              //       borderRadius: BorderRadius.circular(12),
              //       borderSide: const BorderSide(color: Colors.red),
              //     ),
              //     contentPadding: const EdgeInsets.symmetric(
              //       horizontal: 16,
              //       vertical: 16,
              //     ),
              //   ),
              //   validator: (value) {
              //     if (value == null || value.trim().isEmpty) {
              //       return 'Please enter product name';
              //     }
              //     if (value.trim().length < 3) {
              //       return 'Name must be at least 3 characters';
              //     }
              //     return null;
              //   },
              // ),
              //
              //
              // // Product Description
              // const Text(
              //   'Product Description',
              //   style: TextStyle(
              //     fontSize: 16,
              //     fontWeight: FontWeight.w600,
              //     color: Colors.black87,
              //   ),
              // ),
              // const SizedBox(height: 8),
              // TextFormField(
              //   controller: controller.descriptionController,
              //   maxLines: 5,
              //   decoration: InputDecoration(
              //     hintText: 'Enter product description',
              //     hintStyle: TextStyle(color: Colors.grey[400]),
              //     filled: true,
              //     fillColor: Colors.grey[50],
              //     border: OutlineInputBorder(
              //       borderRadius: BorderRadius.circular(12),
              //       borderSide: BorderSide(color: Colors.grey[300]!),
              //     ),
              //     enabledBorder: OutlineInputBorder(
              //       borderRadius: BorderRadius.circular(12),
              //       borderSide: BorderSide(color: Colors.grey[300]!),
              //     ),
              //     focusedBorder: OutlineInputBorder(
              //       borderRadius: BorderRadius.circular(12),
              //       borderSide: const BorderSide(color: Colors.blue, width: 2),
              //     ),
              //     errorBorder: OutlineInputBorder(
              //       borderRadius: BorderRadius.circular(12),
              //       borderSide: const BorderSide(color: Colors.red),
              //     ),
              //     contentPadding: const EdgeInsets.symmetric(
              //       horizontal: 16,
              //       vertical: 16,
              //     ),
              //   ),
              //   validator: (value) {
              //     if (value == null || value.trim().isEmpty) {
              //       return 'Please enter product description';
              //     }
              //     if (value.trim().length < 10) {
              //       return 'Description must be at least 10 characters';
              //     }
              //     return null;
              //   },
              // ),
              // const SizedBox(height: 24),
              //
              // // Product Price
              // const Text(
              //   'Product Price',
              //   style: TextStyle(
              //     fontSize: 16,
              //     fontWeight: FontWeight.w600,
              //     color: Colors.black87,
              //   ),
              // ),
              // const SizedBox(height: 8),
              // TextFormField(
              //   controller: controller.priceController,
              //   keyboardType: TextInputType.number,
              //   inputFormatters: [
              //     FilteringTextInputFormatter.digitsOnly,
              //   ],
              //   decoration: InputDecoration(
              //     hintText: 'Enter product price',
              //     hintStyle: TextStyle(color: Colors.grey[400]),
              //     prefixIcon: const Padding(
              //       padding: EdgeInsets.only(left: 16, right: 8),
              //       child: Text(
              //         '₹',
              //         style: TextStyle(
              //           fontSize: 18,
              //           fontWeight: FontWeight.w600,
              //           color: Colors.black87,
              //         ),
              //       ),
              //     ),
              //     prefixIconConstraints: const BoxConstraints(minWidth: 0),
              //     filled: true,
              //     fillColor: Colors.grey[50],
              //     border: OutlineInputBorder(
              //       borderRadius: BorderRadius.circular(12),
              //       borderSide: BorderSide(color: Colors.grey[300]!),
              //     ),
              //     enabledBorder: OutlineInputBorder(
              //       borderRadius: BorderRadius.circular(12),
              //       borderSide: BorderSide(color: Colors.grey[300]!),
              //     ),
              //     focusedBorder: OutlineInputBorder(
              //       borderRadius: BorderRadius.circular(12),
              //       borderSide: const BorderSide(color: Colors.blue, width: 2),
              //     ),
              //     errorBorder: OutlineInputBorder(
              //       borderRadius: BorderRadius.circular(12),
              //       borderSide: const BorderSide(color: Colors.red),
              //     ),
              //     contentPadding: const EdgeInsets.symmetric(
              //       horizontal: 16,
              //       vertical: 16,
              //     ),
              //   ),
              //   validator: (value) {
              //     if (value == null || value.trim().isEmpty) {
              //       return 'Please enter product price';
              //     }
              //     final price = int.tryParse(value);
              //     if (price == null || price <= 0) {
              //       return 'Please enter a valid price';
              //     }
              //     return null;
              //   },
              // ),
              // const SizedBox(height: 40),

              // Create Product Button

              SizedBox(height: 30,),


              Obx(() => CustomButton(
                onPressed: controller.isLoading.value ? null : controller.createProduct,
                title: controller.isLoading.value ? "creating".tr : "create_product".tr,
              )),

              // Obx(() => SizedBox(
              //   width: double.infinity,
              //   height: 54,
              //   child: ElevatedButton(
              //     onPressed: controller.isLoading.value ? null : controller.createProduct,
              //     style: ElevatedButton.styleFrom(
              //       backgroundColor: Colors.blue,
              //       foregroundColor: Colors.white,
              //       elevation: 0,
              //       shape: RoundedRectangleBorder(
              //         borderRadius: BorderRadius.circular(12),
              //       ),
              //       disabledBackgroundColor: Colors.grey[300],
              //     ),
              //     child: controller.isLoading.value
              //         ? const SizedBox(
              //       height: 24,
              //       width: 24,
              //       child: CircularProgressIndicator(
              //         strokeWidth: 2.5,
              //         valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              //       ),
              //     )
              //         : const Text(
              //       'Create Product',
              //       style: TextStyle(
              //         fontSize: 16,
              //         fontWeight: FontWeight.w600,
              //       ),
              //     ),
              //   ),
              // )),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      // bottomNavigationBar: BottomAppBar(
      //   padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      //   child: CustomButton(
      //     title: "Register",
      //     onPressed: controller.createProduct,
      //   ),
      // ),
    );
  }
}
