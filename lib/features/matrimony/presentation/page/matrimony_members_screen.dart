import 'package:edu_cluezer/features/Auth/service/auth_service.dart';
import 'package:edu_cluezer/core/constent/api_constants.dart';
import 'package:edu_cluezer/core/routes/app_routes.dart';
import 'package:edu_cluezer/features/matrimony/data/model/matrimony_chat_response.dart';
import 'package:edu_cluezer/features/matrimony/presentation/controller/matrimony_members_controller.dart';
import 'package:edu_cluezer/widgets/custom_image_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MatrimonyMembersScreen extends GetWidget<MatrimonyMembersController> {
  const MatrimonyMembersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text("members".tr, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.swap_horizontal_circle_outlined, color: Colors.purple, size: 28),
            onPressed: () => Get.toNamed(AppRoutes.matrimonyRequests),
            tooltip: "requests".tr,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator(color: Colors.purple));
              }
              if (controller.filteredMembers.isEmpty) {
                return _buildEmptyState();
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: controller.filteredMembers.length,
                itemBuilder: (context, index) {
                  return _buildMemberCard(controller.filteredMembers[index]);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextField(
          onChanged: (value) => controller.filterMembers(value),
          decoration: InputDecoration(
            hintText: "search_members".tr,
            prefixIcon: const Icon(Icons.search, color: Colors.grey),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }

  Widget _buildMemberCard(MatrimonyConversation conversation) {
    final currentUser = Get.find<AuthService>().currentUser.value;
    final currentUserId = currentUser?.id;
    
    // Pick the user who is NOT the current user
    var userProfile = (conversation.user1Id == currentUserId) 
        ? conversation.user2 
        : conversation.user1;
        
    // Safety fallback: If identification fails or one is null, pick the non-null one
    if (userProfile == null) {
      userProfile = conversation.user2 ?? conversation.user1;
    }

    // Data Extraction with multiple fallbacks
    // 1. Name
    final name = userProfile?.personalDetails?.name ?? 
                 userProfile?.user?.name ?? 
                 "Matrimony Member";
                 
    // 2. Profession
    final profession = userProfile?.professionalDetails?.jobTitle ?? 
                       userProfile?.personalDetails?.occupation ?? 
                       userProfile?.user?.occupation ?? 
                       "Member";
                       
    // 3. Location
    final location = userProfile?.locationDetails?.city ?? 
                     userProfile?.user?.city ?? 
                     "Unknown Location";
    
    print("MEMBER CARD DEBUG: uid=$currentUserId c.u1=${conversation.user1Id} c.u2=${conversation.user2Id} selected_name=$name");

    print("conversation.user1 : ${conversation.user1}");
    print("conversation.user2 : ${conversation.user2}");
    print("currentUserId : $currentUserId");
    print("conversation.user1Id : ${conversation.user1Id}, conversation.user2Id: ${conversation.user2Id}");


    // Correct image logic
    String? imageUrl;
    if (userProfile?.personalDetails?.photos != null && userProfile!.personalDetails!.photos!.isNotEmpty) {
       imageUrl = ApiConstants.imageBaseUrl + userProfile.personalDetails!.photos![0];
    }
    
    // Fallback widget
    Widget buildPlaceholder() {
      return Container(
        decoration: BoxDecoration(
          color: Colors.purple.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.person, color: Colors.purple, size: 30),
      );
    }

    return GestureDetector(
      onTap: () {
      Get.toNamed(AppRoutes.matrimonyChat, arguments: {
        'conversation_id': conversation.id,
        'other_user_id': userProfile?.userId ?? userProfile?.user?.id,
        'user_name': name,
      });
    },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: imageUrl != null
                    ? CustomImageView(
                        url: imageUrl,
                        fit: BoxFit.cover,
                        placeHolder: (context, url) => buildPlaceholder(),
                        errorWidget: (context, url, error) => buildPlaceholder(),
                      )
                    : buildPlaceholder(),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(child: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                  const SizedBox(height: 4),
                  Text(profession, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 14, color: Colors.grey[400]),
                      const SizedBox(width: 2),
                      Text(location, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chat_bubble_outline, color: Colors.purple),
               onPressed: () {
                 Get.toNamed(AppRoutes.matrimonyChat, arguments: {
                   'conversation_id': conversation.id,
                   'other_user_id': userProfile?.userId ?? userProfile?.user?.id,
                   'user_name': name,
                 });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 80, color: Colors.grey[200]),
          const SizedBox(height: 16),
          Text(
            controller.searchQuery.isEmpty ? "No members yet." : "No results for '${controller.searchQuery.value}'",
            style: TextStyle(color: Colors.grey[400], fontSize: 16),
          ),
        ],
      ),
    );
  }
}
