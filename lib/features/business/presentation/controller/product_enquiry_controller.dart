import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:edu_cluezer/widgets/custom_snack_bar.dart';
import '../../data/model/product_enquiry_model.dart';
import '../../domain/usecase/send_product_enquiry_usecase.dart';

class ProductEnquiryController extends GetxController {
  final SendProductEnquiryUseCase sendEnquiryUseCase;

  ProductEnquiryController({required this.sendEnquiryUseCase});

  final RxBool isSubmitting = false.obs;

  Future<bool> sendEnquiry({
    int? productId,
    int? serviceId,
    required double price,
    required String description,
  }) async {
    final cleanDesc = description.trim();
    if (cleanDesc.isEmpty) {
      CustomSnackBar.showError(message: 'Please write your enquiry message.');
      return false;
    }

    if (productId == null && serviceId == null) {
      CustomSnackBar.showError(message: 'Invalid item to enquire.');
      return false;
    }

    try {
      isSubmitting.value = true;
      final request = ProductEnquiryRequest(
        productId: productId,
        serviceId: serviceId,
        price: price,
        description: cleanDesc,
      );

      final response = await sendEnquiryUseCase(request);
      if (response.success) {
        CustomSnackBar.showSuccess(
          message: response.message ?? 'Enquiry submitted successfully!',
        );
        return true;
      } else {
        CustomSnackBar.showError(
          message: response.message ?? 'Failed to submit enquiry. Please try again.',
        );
        return false;
      }
    } catch (e) {
      debugPrint('[ProductEnquiryController] Error sending enquiry: $e');
      CustomSnackBar.showError(
        message: 'Something went wrong while submitting your enquiry.',
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }
}
