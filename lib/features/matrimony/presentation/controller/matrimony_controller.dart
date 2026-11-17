import 'package:dio/dio.dart';
import 'package:edu_cluezer/features/matrimony/domain/repository/matrimony_repository.dart';
import 'package:edu_cluezer/packages/card_swiper/flutter_card_swiper.dart';
import 'package:edu_cluezer/widgets/custom_snack_bar.dart';
import 'package:get/get.dart';
import '../../data/model/search_matrimony_response.dart';

class MatrimonyController extends GetxController {
  final MatrimonyRepository _repository = Get.find<MatrimonyRepository>();
  final CardSwiperController swiperController = CardSwiperController();

  final RxList<MatrimonyProfile> profiles = <MatrimonyProfile>[].obs;
  final RxBool isLoading = false.obs;
  final RxInt currentIndex = 0.obs;
  CancelToken? _cancelToken;

  @override
  void onInit() {
    super.onInit();
    fetchProfiles();
  }

  Future<void> fetchProfiles({Map<String, dynamic> filters = const {}, bool isSilent = false}) async {
    try {
      _cancelToken?.cancel("New search initiated");
      _cancelToken = CancelToken();

      if (!isSilent) isLoading.value = true;
      currentIndex.value = 0;
      final response = await _repository.searchMatrimony(filters, cancelToken: _cancelToken);
      
      if (response.data != null) {
        profiles.value = response.data!.data;
      } else {
        if (!isSilent) profiles.clear();
      }
      
    } catch (e) {
      if (e is DioException && CancelToken.isCancel(e)) {
        return;
      }
      print("Error fetching profiles: $e");
    } finally {
      if (_cancelToken == null || !_cancelToken!.isCancelled) {
        isLoading.value = false;
      }
    }
  }

  Future<void> sendConnectionRequest(int? receiverId) async {
    if (receiverId == null) return;
    try {
      final data = {
        "receiver_id": receiverId.toString(),
        "message": "Hello, I would like to connect with you!"
      };
      
      // We don't need full page loading for this action
      final response = await _repository.sendConnectionRequest(data);
      if (response['success'] == true) {
        CustomSnackBar.showSuccess(message: response['message'] ?? "Connection request sent successfully");
        // Silent refresh to update statuses or fetch new ones if list is low
        fetchProfiles(isSilent: true); 
      } else {
        CustomSnackBar.showError(message: response['message'] ?? "Failed to send connection request");
      }
    } catch (e) {
      CustomSnackBar.showError(message: "Something went wrong: $e");
    }
  }

  Future<void> rejectRequest(int? receiverId) async {
    if (receiverId == null) return;
    try {
      // No loading spinner for better UX - removing from stack is visual feedback
      final data = {
        "receiver_id": receiverId.toString(),
        "message": "Reject"
      };
      final response = await _repository.removeConnectionRequest(data);
      if (response['success'] == true) {
        // CustomSnackBar.showSuccess(message: response['message'] ?? "User removed successfully"); // Optional: suppress snackbar for reject to be faster
        fetchProfiles(isSilent: true); // Refresh list silently
      } else {
        CustomSnackBar.showError(message: response['message'] ?? "Failed to remove request");
      }
    } catch (e) {
      CustomSnackBar.showError(message: "Something went wrong: $e");
    }
  }
}