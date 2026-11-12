import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/styles/app_colors.dart';
import '../controller/referral_controller.dart';
import '../../data/models/referral_model.dart';

class ReferralHistoryView extends StatelessWidget {
  final ReferralController controller;

  const ReferralHistoryView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Filter Chips Row
        _buildFilterHeader(),

        // History List
        Expanded(
          child: Obx(() {
            if (controller.isLoadingHistory.value) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }

            final history = controller.history;

            if (history.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.history_rounded, size: 56, color: Colors.grey.shade300),
                      const SizedBox(height: 12),
                      Text(
                        'no_history_yet'.tr,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'history_empty_desc'.tr,
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                ),
              );
            }

            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () => controller.fetchHistory(
                userType: controller.selectedHistoryUserType.value,
                status: controller.selectedHistoryFilter.value,
              ),
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                itemCount: history.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  return _buildHistoryCard(history[index]);
                },
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildFilterHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: Obx(() {
        final currentFilter = controller.selectedHistoryFilter.value;
        final currentType = controller.selectedHistoryUserType.value;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildChip(
                label: ('all'.tr.toLowerCase() == 'all') ? 'All' : 'all'.tr,
                isSelected: currentFilter == 'all' && currentType == 'all',
                onTap: () {
                  controller.selectedHistoryFilter.value = 'all';
                  controller.selectedHistoryUserType.value = 'all';
                  controller.fetchHistory();
                },
              ),
              const SizedBox(width: 8),
              _buildChip(
                label: 'active'.tr,
                isSelected: currentFilter == 'active',
                onTap: () {
                  controller.selectedHistoryFilter.value =
                      currentFilter == 'active' ? 'all' : 'active';
                  controller.fetchHistory(
                    status: controller.selectedHistoryFilter.value,
                    userType: controller.selectedHistoryUserType.value,
                  );
                },
              ),
              const SizedBox(width: 8),
              _buildChip(
                label: 'general'.tr,
                isSelected: currentType == 'general',
                onTap: () {
                  controller.selectedHistoryUserType.value =
                      currentType == 'general' ? 'all' : 'general';
                  controller.fetchHistory(
                    status: controller.selectedHistoryFilter.value,
                    userType: controller.selectedHistoryUserType.value,
                  );
                },
              ),
              const SizedBox(width: 8),
              _buildChip(
                label: 'matrimony'.tr,
                isSelected: currentType == 'matrimony',
                onTap: () {
                  controller.selectedHistoryUserType.value =
                      currentType == 'matrimony' ? 'all' : 'matrimony';
                  controller.fetchHistory(
                    status: controller.selectedHistoryFilter.value,
                    userType: controller.selectedHistoryUserType.value,
                  );
                },
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryCard(ReferredUserItem item) {
    final user = item.user;
    final bool isCredited = item.status.toLowerCase() == 'active';
    final name = user?.name ?? 'Member';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
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
          // Avatar or Icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isCredited
                  ? AppColors.success.withOpacity(0.12)
                  : AppColors.warning.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : 'M',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isCredited ? AppColors.success : AppColors.warning,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // User Details
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
                        color: isCredited
                            ? AppColors.success.withOpacity(0.1)
                            : AppColors.warning.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        isCredited ? 'active'.tr : 'pending'.tr,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isCredited ? AppColors.success : AppColors.warning,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),

                // Referral code used & user type
                if (item.referralCodeUsed != null && item.referralCodeUsed!.isNotEmpty)
                  Text(
                    'Code: ${item.referralCodeUsed}${user?.userType != null ? " • ${user!.userType}" : ""}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),

                // Location / Phone if available
                if (user?.location != null && user!.location!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 12, color: Colors.grey.shade500),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          user.location!,
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 3),
                Text(
                  item.referredAt?.split('T').first ?? '',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
                ),
              ],
            ),
          ),

          // Commission Points
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '+${item.commissionPoints} ${'pts'.tr}',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: isCredited ? AppColors.success : AppColors.warning,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'commission_points'.tr,
                style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
