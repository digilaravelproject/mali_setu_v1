import 'package:edu_cluezer/features/matrimony/domain/repository/matrimony_repository.dart';
import 'package:edu_cluezer/packages/card_swiper/flutter_card_swiper.dart';
import 'package:get/get.dart';
import '../../data/model/search_matrimony_response.dart';

class MatrimonyController extends GetxController {
  final MatrimonyRepository _repository = Get.find<MatrimonyRepository>();
  final CardSwiperController swiperController = CardSwiperController();

  final RxList<MatrimonyProfile> profiles = <MatrimonyProfile>[].obs;
  final RxBool isLoading = false.obs;
  final RxInt currentIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProfiles();
  }

  Future<void> fetchProfiles({Map<String, dynamic> filters = const {}}) async {
    try {
      isLoading.value = true;
      final response = await _repository.searchMatrimony(filters);
      
      if (response.data != null && response.data!.data != null) {
        profiles.value = response.data!.data!;
      } else {
        profiles.clear();
      }
      
    } catch (e) {
      print("Error fetching profiles: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> sendConnectionRequest(int? receiverId) async {
    if (receiverId == null) return;
    try {
      final data = {
        "receiver_id": receiverId.toString(),
        "message": "Hello, I would like to connect with you!"
      };
      final response = await _repository.sendConnectionRequest(data);
      if (response['success'] == true) {
        profiles[currentIndex.value].connectionStatus = "pending";
        profiles.refresh();
        Get.snackbar("Success", response['message'] ?? "Connection request sent successfully");
      } else {
        Get.snackbar("Error", response['message'] ?? "Failed to send connection request");
      }
    } catch (e) {
      Get.snackbar("Error", "Something went wrong: $e");
    }
  }

  Future<void> rejectRequest(int? receiverId) async {
    if (receiverId == null) return;
    try {
      isLoading.value = true;
      final data = {
        "receiver_id": receiverId.toString(),
        "message": "Reject"
      };
      final response = await _repository.removeConnectionRequest(data);
      if (response['success'] == true) {
        Get.snackbar("Success", response['message'] ?? "User removed successfully");
        fetchProfiles(); // Refresh list
      } else {
        Get.snackbar("Error", response['message'] ?? "Failed to remove request");
      }
    } catch (e) {
      Get.snackbar("Error", "Something went wrong: $e");
    } finally {
      isLoading.value = false;
    }
  }
}