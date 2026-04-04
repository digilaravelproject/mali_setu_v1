import 'package:edu_cluezer/features/Auth/service/auth_service.dart';
import 'package:edu_cluezer/features/matrimony/data/model/matrimony_chat_response.dart';
import 'package:edu_cluezer/features/matrimony/domain/repository/matrimony_repository.dart';
import 'package:edu_cluezer/widgets/custom_snack_bar.dart';
import 'package:get/get.dart';

class MatrimonyMembersController extends GetxController {
  final MatrimonyRepository _repository = Get.find<MatrimonyRepository>();
  final AuthService _authService = Get.find<AuthService>();

  final RxBool isLoading = false.obs;
  final RxList<MatrimonyConversation> members = <MatrimonyConversation>[].obs;
  final RxList<MatrimonyConversation> filteredMembers = <MatrimonyConversation>[].obs;
  final RxString searchQuery = "".obs;

  @override
  void onInit() {
    super.onInit();
    fetchMembers();
  }

  Future<void> fetchMembers() async {
    try {
      isLoading.value = true;
      final response = await _repository.getConversations();
      if (response.success == true && response.data?.conversations != null) {
        members.value = response.data!.conversations ?? [];
        filterMembers(searchQuery.value);
      }
    } catch (e) {
      CustomSnackBar.showError(message: "Failed to fetch members: $e");
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
      final lowercaseQuery = query.toLowerCase();

      filteredMembers.value = members.where((m) {
        // Pick the partner profile (same logic as UI)
        var userProfile = (m.user1Id == currentUserId) ? m.user2 : m.user1;
        if (userProfile == null) {
          userProfile = m.user2 ?? m.user1;
        }

        // Searchable fields with fallbacks
        final name = (userProfile?.personalDetails?.name ?? 
                     userProfile?.user?.name ?? 
                     "").toLowerCase();
                     
        final profession = (userProfile?.professionalDetails?.jobTitle ?? 
                           userProfile?.personalDetails?.occupation ?? 
                           userProfile?.user?.occupation ?? 
                           "").toLowerCase();
                           
        final location = (userProfile?.locationDetails?.city ?? 
                         userProfile?.user?.city ?? 
                         "").toLowerCase();
        
        return name.contains(lowercaseQuery) || 
               profession.contains(lowercaseQuery) || 
               location.contains(lowercaseQuery);
      }).toList();
    }
  }
}
