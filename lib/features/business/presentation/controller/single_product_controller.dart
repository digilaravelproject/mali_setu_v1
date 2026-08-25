import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:edu_cluezer/features/business/domain/repository/all_business_repository.dart';
import 'package:edu_cluezer/features/business/data/model/res_all_business_model.dart';

class SingleProductController extends GetxController {
  final BusinessRepository repository;

  SingleProductController({required this.repository});

  final isLoading = false.obs;
  final product = Rxn<Product>();
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args != null && args is int) {
      fetchProductDetails(args);
    }
  }

  Future<void> fetchProductDetails(int productId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final response = await repository.getSingleProductDetails(productId);
      
      if (response.success == true && response.product != null) {
        product.value = response.product;
      } else {
        errorMessage.value = response.message ?? 'Failed to fetch product details';
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
