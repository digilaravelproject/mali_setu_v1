import 'package:get/get.dart';

import '../../data/model/res_all_business_model.dart';
import '../../domain/usecase/all_business_usecase.dart';


class BusinessController extends GetxController {
  final GetAllBusinessesUseCase getAllBusinessesUseCase;

  BusinessController({required this.getAllBusinessesUseCase});

  var businesses = <Business>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAllBusinesses();
  }

  Future<void> fetchAllBusinesses() async {
    try {
      isLoading.value = true;
      final list = await getAllBusinessesUseCase();
      businesses.value = list;
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
