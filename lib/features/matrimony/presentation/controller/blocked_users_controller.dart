import 'package:edu_cluezer/features/matrimony/data/model/blocked_users_response.dart';
import 'package:edu_cluezer/features/matrimony/domain/repository/matrimony_repository.dart';
import 'package:edu_cluezer/features/matrimony/presentation/controller/matrimony_members_controller.dart';
import 'package:edu_cluezer/widgets/custom_snack_bar.dart';
import 'package:get/get.dart';

class BlockedUsersController extends GetxController {
  final MatrimonyRepository _repository = Get.find<MatrimonyRepository>();

  final RxBool isLoading = false.obs;
  final RxList<BlockedUserItem> blockedUsers = <BlockedUserItem>[].obs;
  final RxList<BlockedUserItem> filteredBlockedUsers = <BlockedUserItem>[].obs;
  final RxString searchQuery = "".obs;
  final RxBool isUnblocking = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchBlockedUsers();
  }

  Future<void> fetchBlockedUsers() async {
    isLoading.value = true;
    try {
      final response = await _repository.getBlockedUsers();
      if (response.success == true && response.data?.blockedUsers != null) {
        blockedUsers.value = response.data!.blockedUsers!;
        filterUsers(searchQuery.value);
      } else {
        blockedUsers.clear();
        filteredBlockedUsers.clear();
      }
    } catch (e) {
      CustomSnackBar.showError(message: "Failed to fetch blocked users: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void filterUsers(String query) {
    searchQuery.value = query;
    if (query.trim().isEmpty) {
      filteredBlockedUsers.value = blockedUsers;
    } else {
      final q = query.toLowerCase().trim();
      filteredBlockedUsers.value = blockedUsers.where((item) {
        final name = (item.profile?.personalDetails?.name ??
                      item.user?.name ??
                      "").toLowerCase();
        final city = (item.profile?.locationDetails?.city ??
                      item.user?.city ??
                      "").toLowerCase();
        final profession = (item.profile?.professionalDetails?.jobTitle ??
                            item.profile?.personalDetails?.occupation ??
                            item.user?.occupation ??
                            "").toLowerCase();
        return name.contains(q) || city.contains(q) || profession.contains(q);
      }).toList();
    }
  }

  Future<bool> unblockUser(BlockedUserItem item) async {
    final targetId = item.userId ?? item.profile?.userId ?? item.user?.id;
    if (targetId == null) {
      CustomSnackBar.showError(message: "User ID not found");
      return false;
    }

    try {
      isUnblocking.value = true;
      final data = {
        "blocked_user_id": targetId,
        "is_block": false,
      };
      final response = await _repository.unblockUser(data);
      if (response != null &&
          (response['success'] == true ||
           response['status'] == true ||
           response['status'] == 'success' ||
           response['status'] == 200 ||
           response['code'] == 200 ||
           (response is Map && (response['message'] != null && response['error'] == null)))) {
        // Remove from list immediately
        blockedUsers.removeWhere((u) => u.userId == targetId || u.blockId == item.blockId);
        filterUsers(searchQuery.value);

        // Sync with MatrimonyMembersController if registered
        if (Get.isRegistered<MatrimonyMembersController>()) {
          Get.find<MatrimonyMembersController>().updateBlockStatusByUserId(targetId, false);
        }
        return true;
      } else {
        final msg = response is Map ? (response['message'] ?? response['error']) : null;
        CustomSnackBar.showError(message: msg ?? 'Failed to unblock user');
        return false;
      }
    } catch (e) {
      CustomSnackBar.showError(message: "Failed to unblock user: $e");
      return false;
    } finally {
      isUnblocking.value = false;
    }
  }
}
