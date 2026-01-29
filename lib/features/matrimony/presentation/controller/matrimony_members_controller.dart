import 'package:edu_cluezer/features/Auth/service/auth_service.dart';
import 'package:edu_cluezer/features/matrimony/data/model/connection_requests_response.dart';
import 'package:edu_cluezer/features/matrimony/domain/repository/matrimony_repository.dart';
import 'package:get/get.dart';

class MatrimonyMembersController extends GetxController {
  final MatrimonyRepository _repository = Get.find<MatrimonyRepository>();
  final AuthService _authService = Get.find<AuthService>();

  final RxBool isLoading = false.obs;
  final RxList<ConnectionRequest> members = <ConnectionRequest>[].obs;
  final RxList<ConnectionRequest> filteredMembers = <ConnectionRequest>[].obs;
  final RxString searchQuery = "".obs;

  @override
  void onInit() {
    super.onInit();
    fetchMembers();
  }

  Future<void> fetchMembers() async {
    try {
      isLoading.value = true;
      final response = await _repository.getConnectionRequests();
      if (response.success == true && response.data != null) {
        List<ConnectionRequest> allMembers = [];
        
        if (response.data!.sentRequests != null) {
          allMembers.addAll(response.data!.sentRequests!.where((r) => r.status == "accepted"));
        }
        
        if (response.data!.receivedRequests != null) {
          allMembers.addAll(response.data!.receivedRequests!.where((r) => r.status == "accepted"));
        }

        members.value = allMembers;
        filterMembers(searchQuery.value);
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch members: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void filterMembers(String query) {
    searchQuery.value = query;
    if (query.isEmpty) {
      filteredMembers.value = members;
    } else {
      final currentUserId = _authService.currentUser.value?.id;
      filteredMembers.value = members.where((m) {
        final user = m.senderId == currentUserId ? m.receiver : m.sender;
        final name = (user?.name ?? "").toLowerCase();
        return name.contains(query.toLowerCase());
      }).toList();
    }
  }
}
