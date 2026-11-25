import 'package:edu_cluezer/core/constent/api_constants.dart';
import 'package:edu_cluezer/core/widgets/whatsapp_support_fab.dart';
import 'package:edu_cluezer/features/matrimony/data/model/blocked_users_response.dart';
import 'package:edu_cluezer/features/matrimony/presentation/controller/blocked_users_controller.dart';
import 'package:edu_cluezer/widgets/custom_image_view.dart';
import 'package:edu_cluezer/widgets/custom_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BlockedUsersScreen extends GetView<BlockedUsersController> {
  const BlockedUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      floatingActionButton: const WhatsAppSupportFab(bottomPadding: 16),
      appBar: AppBar(
        title: Text(
          "blocked_users".tr,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.filteredBlockedUsers.isEmpty) {
                return const Center(child: CircularProgressIndicator(color: Colors.purple));
              }

              return RefreshIndicator(
                onRefresh: controller.fetchBlockedUsers,
                color: Colors.purple,
                child: controller.filteredBlockedUsers.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        itemCount: controller.filteredBlockedUsers.length,
                        itemBuilder: (context, index) {
                          return _buildBlockedUserCard(context, controller.filteredBlockedUsers[index]);
                        },
                      ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      color: Colors.white,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextField(
          onChanged: (value) => controller.filterUsers(value),
          decoration: InputDecoration(
            hintText: "search_members".tr,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            prefixIcon: Icon(Icons.search, color: Colors.grey.shade500, size: 20),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }

  Widget _buildBlockedUserCard(BuildContext context, BlockedUserItem item) {
    final profile = item.profile;
    final user = item.user;

    final name = profile?.personalDetails?.name ??
        user?.name ??
        "Blocked User";

    final profession = profile?.professionalDetails?.jobTitle ??
        profile?.personalDetails?.occupation ??
        user?.occupation ??
        "Member";

    final location = profile?.locationDetails?.city ??
        user?.city ??
        "";

    final age = profile?.age != null ? "${profile!.age} yrs" : "";

    // Image URL logic
    String? imageUrl;
    final photos = profile?.personalDetails?.photos;
    if (photos != null && photos.isNotEmpty) {
      imageUrl = ApiConstants.imageBaseUrl + photos[0];
    } else if (user?.profileImage != null && user!.profileImage!.isNotEmpty) {
      imageUrl = user.profileImage!.startsWith("http")
          ? user.profileImage
          : ApiConstants.imageBaseUrl + user.profileImage!;
    }

    Widget buildPlaceholder() {
      return Container(
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.person, color: Colors.red.shade300, size: 30),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
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
          const SizedBox(width: 14),

          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15.5,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.red.shade200, width: 0.8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.block, size: 10, color: Colors.red.shade700),
                          const SizedBox(width: 3),
                          Text(
                            'blocked'.tr,
                            style: TextStyle(
                              color: Colors.red.shade700,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    if (profession.isNotEmpty) ...[
                      Flexible(
                        child: Text(
                          profession,
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 12.5),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                    if (profession.isNotEmpty && age.isNotEmpty)
                      Text(" • ", style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
                    if (age.isNotEmpty)
                      Text(
                        age,
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 12.5),
                      ),
                  ],
                ),
                if (location.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 12, color: Colors.grey.shade400),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          location,
                          style: TextStyle(color: Colors.grey.shade500, fontSize: 11.5),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 10),

          // Unblock Button
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _showUnblockDialog(item, name),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: const Color(0xFF00A884).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF00A884),
                    width: 1.2,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.lock_open_rounded,
                      size: 14,
                      color: Color(0xFF00A884),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'unblock'.tr,
                      style: const TextStyle(
                        color: Color(0xFF00A884),
                        fontWeight: FontWeight.bold,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showUnblockDialog(BlockedUserItem item, String userName) {
    bool isSubmitting = false;

    Get.dialog(
      StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00A884).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.lock_open_rounded, color: Color(0xFF00A884), size: 36),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    userName.isNotEmpty ? "${'unblock_user'.tr} - $userName" : 'unblock_confirm_title'.tr,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'unblock_user_confirm'.tr,
                    style: TextStyle(
                      fontSize: 13.5,
                      color: Colors.grey.shade600,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: isSubmitting
                              ? null
                              : () {
                                  if (Get.isDialogOpen == true) {
                                    Get.back();
                                  } else if (dialogContext.mounted && Navigator.of(dialogContext).canPop()) {
                                    Navigator.of(dialogContext).pop();
                                  }
                                },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            side: BorderSide(color: Colors.grey.shade300),
                          ),
                          child: Text(
                            'cancel'.tr,
                            style: const TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: isSubmitting
                              ? () {}
                              : () async {
                                  setDialogState(() {
                                    isSubmitting = true;
                                  });
                                  final success = await controller.unblockUser(item);
                                  if (success) {
                                    if (Get.isDialogOpen == true) {
                                      Get.back();
                                    } else if (dialogContext.mounted && Navigator.of(dialogContext).canPop()) {
                                      Navigator.of(dialogContext).pop();
                                    }
                                    Future.delayed(const Duration(milliseconds: 150), () {
                                      CustomSnackBar.showSuccess(message: 'user_unblocked'.tr);
                                    });
                                  } else {
                                    setDialogState(() {
                                      isSubmitting = false;
                                    });
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00A884),
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: const Color(0xFF00A884),
                            disabledForegroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                          ),
                          child: isSubmitting
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  'unblock'.tr,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Container(
          height: constraints.maxHeight,
          alignment: Alignment.center,
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.block_flipped, size: 64, color: Colors.grey.shade400),
              ),
              const SizedBox(height: 18),
              Text(
                'no_blocked_users'.tr,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'no_blocked_users_desc'.tr,
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 13.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
