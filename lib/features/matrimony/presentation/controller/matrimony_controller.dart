import 'package:edu_cluezer/features/matrimony/domain/repository/matrimony_repository.dart';
import 'package:get/get.dart';

class MatrimonyController extends GetxController {
  final MatrimonyRepository _repository = Get.find<MatrimonyRepository>();

  final RxList<dynamic> profiles = <dynamic>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProfiles();
  }

  Future<void> fetchProfiles() async {
    try {
      isLoading.value = true;
      final response = await _repository.getProfiles();
      
      // Assuming response is a list or contains a list in 'data' field
      if (response is List) {
        profiles.value = response;
      } else if (response is Map && response.containsKey('data')) {
        profiles.value = response['data'] as List;
      }
      
    } catch (e) {
      print("Error fetching profiles: $e");
    } finally {
      isLoading.value = false;
    }
  }
}