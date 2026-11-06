import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/styles/app_colors.dart';
import '../controller/referral_controller.dart';
import '../../data/models/referral_model.dart';

class ReferralListView extends StatelessWidget {
  final ReferralController controller;

  const ReferralListView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final items = controller.filteredUsers;

      return Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                onChanged: (val) => controller.searchQuery.value = val,
                decoration: InputDecoration(
                  hintText: 'search_user_hint'.tr,
                  hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
                  prefixIcon: const Icon(Icons.search, size: 20, color: Colors.grey),
                  suffixIcon: controller.searchQuery.value.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () => controller.searchQuery.value = '',
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),

          // List or Empty
          Expanded(
            child: items.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.person_search_outlined, size: 56, color: Colors.grey.shade300),
                          const SizedBox(height: 12),
                          Text(
                            'no_members_found'.tr,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'refer_friends_earn'.tr,
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return _buildUserCard(item);
                    },
                  ),
          ),
        ],
      );
    });
  }

  Widget _buildUserCard(ReferredUserItem item) {
    final user = item.user;
    final bool isActive = item.status == 'active';
    final name = user?.name ?? 'Member';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isActive ? AppColors.primary.withOpacity(0.15) : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          CircleAvatar(
            radius: 22,
            backgroundColor: isActive ? AppColors.primaryLight : Colors.grey.shade200,
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : 'U',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isActive ? AppColors.primary : Colors.grey.shade700,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // User details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppColors.success.withOpacity(0.12)
                            : AppColors.warning.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isActive ? 'active'.tr : 'pending'.tr,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isActive ? AppColors.success : AppColors.warning,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                if (user?.phone != null && user!.phone!.isNotEmpty) ...[
                  Row(
                    children: [
                      Icon(Icons.phone_outlined, size: 12, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Text(
                        user.phone!,
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                ],

                if (user?.email != null && user!.email!.isNotEmpty) ...[
                  Row(
                    children: [
                      Icon(Icons.email_outlined, size: 12, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          user.email!,
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                ],

                if (user?.location != null && user!.location!.isNotEmpty) ...[
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 12, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Text(
                        user.location!,
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                ],

                Text(
                  '${'joined'.tr}: ${item.referredAt?.split('T').first ?? 'N/A'}${user?.userType != null ? " • ${user!.userType}" : ""}',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),

          // Commission earned chip
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.success.withOpacity(0.12)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.stars_rounded,
                      size: 14,
                      color: isActive ? AppColors.success : Colors.grey.shade500,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '+${item.commissionPoints}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isActive ? AppColors.success : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'commission_points'.tr,
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
