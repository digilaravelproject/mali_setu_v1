import 'package:edu_cluezer/features/business/data/model/res_all_business_model.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import '../../data/model/res_category_business_model.dart' hide Category;
import '../../domain/usecase/category_business_usecase.dart';

class CatBusinessController extends GetxController {
  final GetBusinessByCategoryUseCase useCase;

  CatBusinessController({required this.useCase});

  var isLoading = false.obs;
  var errorMessage = ''.obs;

  // ✅ Store all businesses here
  var allBusinesses = <CatBusiness>[].obs;

  @override
  void onInit() {
    super.onInit();
    final dynamic args = Get.arguments;
    if (args != null && args is Category) {
      if (args.id != null) {
        fetchBusinesses(args.id!);
      }
    }
  }

  // Fetch and store data
  Future<void> fetchBusinesses(int categoryId) async {

    try {
      isLoading.value = true;
      errorMessage.value = '';

      final res = await useCase(categoryId);

      if (res.success == true && res.businesses != null) {
        // Clear previous data
        allBusinesses.clear();

        // Add new data
        allBusinesses.addAll(res.businesses!);
      } else {
        errorMessage.value = res.message ?? 'Failed to fetch businesses';
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
