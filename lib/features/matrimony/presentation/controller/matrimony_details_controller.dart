import 'package:get/get.dart';
import '../../domain/repository/matrimony_repository.dart';
import '../../data/model/search_matrimony_response.dart';

class MatrimonyDetailsController extends GetxController {
  final MatrimonyRepository _repository = Get.find<MatrimonyRepository>();
  
  RxBool isLoading = false.obs;
  Rx<MatrimonyProfile?> profile = Rx<MatrimonyProfile?>(null);
  
  @override
  void onInit() {
    super.onInit();
    final id = Get.arguments['id'];
    if (id != null) {
      fetchProfileDetails(id);
    }
  }

  Future<void> fetchProfileDetails(int id) async {
    isLoading.value = true;
    try {
      final response = await _repository.getProfileDetails(id);
      if (response.success == true && response.data?.profile != null) {
        profile.value = response.data!.profile;
      } else {
        Get.snackbar("Error", "Failed to fetch profile details");
      }
    } catch (e) {
      Get.snackbar("Error", "Something went wrong: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> sendRequest() async {
    if (profile.value == null) return;
    
    isLoading.value = true;
    try {
      final data = {
        "receiver_id": profile.value!.id.toString(),
        "message": "Hello, I would like to connect with you!"
      };
      final response = await _repository.sendConnectionRequest(data);
      if (response['success'] == true) {
        profile.value!.connectionStatus = "pending";
        profile.refresh();
        Get.snackbar("Success", response['message'] ?? "Connection request sent successfully");
      } else {
        Get.snackbar("Error", response['message'] ?? "Failed to send connection request");
      }
    } catch (e) {
      Get.snackbar("Error", "Something went wrong: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
