import 'package:edu_cluezer/features/matrimony/data/model/connection_requests_response.dart';
import 'package:edu_cluezer/features/matrimony/domain/repository/matrimony_repository.dart';
import 'package:get/get.dart';

class MatrimonyRequestsController extends GetxController {
  final MatrimonyRepository _repository = Get.find<MatrimonyRepository>();

  final RxBool isLoading = false.obs;
  final RxList<ConnectionRequest> sentRequests = <ConnectionRequest>[].obs;
  final RxList<ConnectionRequest> receivedRequests = <ConnectionRequest>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchRequests();
  }

  Future<void> fetchRequests() async {
    try {
      isLoading.value = true;
      final response = await _repository.getConnectionRequests();
      if (response.success == true && response.data != null) {
        sentRequests.value = response.data!.sentRequests ?? [];
        receivedRequests.value = response.data!.receivedRequests ?? [];
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch requests: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> respondToRequest(int requestId, String status) async {
    try {
      final data = {
        "request_id": requestId.toString(),
        "status": status.toLowerCase(),
      };
      
      final response = await _repository.respondToConnectionRequest(data);
      if (response['success'] == true) {
        Get.snackbar("Success", response['message'] ?? "Request $status successfully");
        fetchRequests(); // Refresh the list
      } else {
        Get.snackbar("Error", response['message'] ?? "Failed to update request");
      }
    } catch (e) {
      Get.snackbar("Error", "Something went wrong: $e");
    }
  }
}
