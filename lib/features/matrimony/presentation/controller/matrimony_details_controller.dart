import 'dart:async';

import 'package:edu_cluezer/widgets/custom_snack_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../domain/repository/matrimony_repository.dart';
import '../../data/model/search_matrimony_response.dart';

class MatrimonyDetailsController extends GetxController {
  final MatrimonyRepository _repository = Get.find<MatrimonyRepository>();
  
  RxBool isLoading = false.obs;
  Rx<MatrimonyProfile?> profile = Rx<MatrimonyProfile?>(null);
  RxInt currentImageIndex = 0.obs;

  PageController? pageController;
  Timer? _timer;
  
  @override
  void onInit() {
    super.onInit();
    pageController = PageController();
    final id = Get.arguments['id'];
    if (id != null) {
      fetchProfileDetails(id);
    }
  }
  @override
  void onClose() {
    _timer?.cancel();
    pageController?.dispose();
    super.onClose();
  }

  void _startAutoScroll() {
    _timer?.cancel();
    final photos = profile.value?.personalDetails?.photos ?? [];
    if (photos.length <= 1) return;

    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (pageController != null && pageController!.hasClients) {
        int nextPage = currentImageIndex.value + 1;
        if (nextPage >= photos.length) {
          nextPage = 0;
        }
        pageController!.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  Future<void> fetchProfileDetails(int id) async {
    isLoading.value = true;
    try {
      final response = await _repository.getProfileDetails(id);
      if (response.success == true && response.data?.profile != null) {
        final fetchedProfile = response.data!.profile!;
        final String? argStatus = Get.arguments?['connection_status'];
        
        // If API says not_connected but we have a more specific status from navigation, prefer it.
        if ((fetchedProfile.connectionStatus == null || 
             fetchedProfile.connectionStatus == 'not_connected' || 
             fetchedProfile.connectionStatus == 'no_connected') && 
            argStatus != null && 
            argStatus != 'not_connected' && 
            argStatus != 'no_connected') {
          fetchedProfile.connectionStatus = argStatus;
        }
        
        profile.value = fetchedProfile;
        _startAutoScroll();
      } else {
        CustomSnackBar.showError(message: "Failed to fetch profile details");
      }
    } catch (e) {
      CustomSnackBar.showError(message: "Something went wrong: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> sendRequest() async {
    if (profile.value == null) return;
    
    isLoading.value = true;
    try {
      final data = {
        "receiver_id": profile.value!.userId.toString(),
        "message": "Hello, I would like to connect with you!"
      };
      final response = await _repository.sendConnectionRequest(data);
      if (response['success'] == true) {
        profile.value!.connectionStatus = "pending";
        profile.refresh();
        CustomSnackBar.showSuccess(message: response['message'] ?? "Connection request sent successfully");
      } else {
        CustomSnackBar.showError(message: response['message'] ?? "Failed to send connection request");
      }
    } catch (e) {
      CustomSnackBar.showError(message: "Something went wrong: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
