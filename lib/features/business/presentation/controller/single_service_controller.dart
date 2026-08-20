import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:edu_cluezer/features/business/domain/repository/all_business_repository.dart';
import 'package:edu_cluezer/features/business/data/model/res_all_business_model.dart';

class SingleServiceController extends GetxController {
  final BusinessRepository repository;

  SingleServiceController({required this.repository});

  final isLoading = false.obs;
  final service = Rxn<Service>();
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args != null && args is int) {
      fetchServiceDetails(args);
    }
  }

  Future<void> fetchServiceDetails(int serviceId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final response = await repository.getSingleServiceDetails(serviceId);
      
      if (response.success == true && response.service != null) {
        service.value = response.service;
      } else {
        errorMessage.value = response.message ?? 'Failed to fetch service details';
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
