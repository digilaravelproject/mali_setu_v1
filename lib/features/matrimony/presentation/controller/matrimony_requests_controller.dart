import 'package:edu_cluezer/features/matrimony/data/model/connection_requests_response.dart';
import 'package:edu_cluezer/features/matrimony/domain/repository/matrimony_repository.dart';
import 'package:edu_cluezer/features/matrimony/presentation/controller/matrimony_controller.dart';
import 'package:edu_cluezer/features/matrimony/presentation/controller/matrimony_members_controller.dart';
import 'package:edu_cluezer/widgets/custom_snack_bar.dart';
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
      CustomSnackBar.showError(message: "Failed to fetch requests: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> respondToRequest(int requestId, String status) async {
    if (isLoading.value) return; 

    try {
      isLoading.value = true;
      final data = {
        "status": status.toLowerCase(),
        "response_message": "NA"
      };
      
      final response = await _repository.respondToConnectionRequest(requestId, data);
      
      if (response is Map && response['success'] == true) {
        CustomSnackBar.showSuccess(message: response['message'] ?? "Request $status successfully");
        
        // Refresh the local requests list
        await fetchRequests(); 
        
        // Proactively refresh other relevant controllers if they are active
        if (Get.isRegistered<MatrimonyMembersController>()) {
          Get.find<MatrimonyMembersController>().fetchMembers();
        }
        if (Get.isRegistered<MatrimonyController>()) {
          Get.find<MatrimonyController>().fetchProfiles();
        }
      } else {
        String message = "Failed to update request";
        if (response is Map && response['message'] != null) {
          message = response['message'];
        }
        CustomSnackBar.showError(message: message);
      }
    } catch (e) {
      CustomSnackBar.showError(message: "Something went wrong: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
