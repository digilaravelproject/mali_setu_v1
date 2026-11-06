import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/styles/app_colors.dart';
import '../binding/referral_binding.dart';
import '../controller/referral_controller.dart';
import '../../data/models/referral_model.dart';

class ReferralAnalyticsScreen extends StatelessWidget {
  const ReferralAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ReferralBinding.init();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          'referral_analytics'.tr,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh_rounded, color: Colors.black87, size: 20),
            onPressed: () => controller.fetchAllData(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.earnings.value == null) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        final earnings = controller.earnings.value;
        final vol = earnings?.volunteer;

        if (earnings == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.analytics_outlined, size: 56, color: Colors.grey.shade400),
                const SizedBox(height: 12),
                Text(
                  'no_data_available'.tr,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => controller.fetchAllData(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text('retry'.tr),
                ),
              ],
            ),
          );
        }

        final num totalEarnedPoints = earnings.totalEarnedPoints;
        final num ptsPerRef = earnings.commissionPointsPerReferral;
        final int totalReferrals = earnings.totalReferrals;
        final int activeReferrals = earnings.activeReferrals;
        final num pendingPoints = earnings.pendingPoints;

        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () => controller.fetchAllData(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Volunteer Profile & Referral Details (Directly from volunteer object)
                _buildProfileCard(vol, controller, context),

                const SizedBox(height: 14),

                // 2. Total Commission Points Hero Banner (Directly from API)
                _buildPointsHeroCard(
                  totalEarnedPoints: totalEarnedPoints,
                  ptsPerRef: ptsPerRef,
                  pendingPoints: pendingPoints,
                ),

                const SizedBox(height: 14),

                // 3. Exact API Metrics Grid
                _buildApiMetricsGrid(
                  totalReferrals: totalReferrals,
                  activeReferrals: activeReferrals,
                  totalEarnedPoints: totalEarnedPoints,
                  ptsPerRef: ptsPerRef,
                  pendingPoints: pendingPoints,
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      }),
    );
  }

  // --------------------------------------------------------------------------
  // 1. Volunteer Profile & Referral Code Card (Data from API volunteer object)
  // --------------------------------------------------------------------------
  Widget _buildProfileCard(
    VolunteerInfo? vol,
    ReferralController controller,
    BuildContext context,
  ) {
    final photoUrl = vol?.photoUrl;
    final name = (vol?.name != null && vol!.name!.isNotEmpty) ? vol.name! : 'Member';
    final userType = (vol?.userType != null && vol!.userType!.isNotEmpty)
        ? vol.userType!.capitalizeFirst!
        : 'General';
    final isVolunteer = vol?.isVolunteer ?? false;
    final volunteerStatus = vol?.volunteerStatus;
    final referralCode = vol?.referralCode ?? controller.getReferralCode();
    final location = vol?.location;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Header Row
          Row(
            children: [
              // Photo Avatar
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: photoUrl != null && photoUrl.isNotEmpty
                      ? Image.network(
                          photoUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildAvatarFallback(name),
                        )
                      : _buildAvatarFallback(name),
                ),
              ),
              const SizedBox(width: 12),

              // Name, User Type & Status
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        // User Type Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Text(
                            userType,
                            style: const TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ),

                        // Volunteer Status Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: isVolunteer
                                ? const Color(0xFFECFDF5)
                                : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: isVolunteer
                                  ? const Color(0xFFA7F3D0)
                                  : const Color(0xFFE2E8F0),
                            ),
                          ),
                          child: Text(
                            isVolunteer
                                ? (volunteerStatus != null && volunteerStatus.isNotEmpty
                                    ? volunteerStatus.capitalizeFirst!
                                    : 'Volunteer')
                                : 'Member',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: isVolunteer
                                  ? const Color(0xFF047857)
                                  : const Color(0xFF64748B),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Location (if present in API)
          if (location != null && location.isNotEmpty) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.location_on_rounded, size: 13, color: Color(0xFF94A3B8)),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    location,
                    style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 14),
          const Divider(height: 1, thickness: 0.8, color: Color(0xFFE2E8F0)),
          const SizedBox(height: 12),

          // Referral Code Box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                const Icon(Icons.qr_code_rounded, size: 18, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'your_referral_code'.tr,
                        style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                      ),
                      Text(
                        referralCode,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1E293B),
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
                // Copy Button
                InkWell(
                  onTap: () => controller.copyReferralCode(context),
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.copy_rounded, size: 12, color: AppColors.primary),
                        const SizedBox(width: 4),
                        Text(
                          'copy'.tr,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                // Share Button
                InkWell(
                  onTap: () => controller.shareReferral(context),
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.share_rounded, size: 14, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarFallback(String name) {
    return Center(
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : 'U',
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }

  // --------------------------------------------------------------------------
  // 2. Total Commission Points Hero Banner (Directly from API)
  // --------------------------------------------------------------------------
  Widget _buildPointsHeroCard({
    required num totalEarnedPoints,
    required num ptsPerRef,
    required num pendingPoints,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFC62D86),
            Color(0xFF720C48),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFC62D86).withValues(alpha: 0.28),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.stars_rounded, color: Colors.white, size: 20),
                  const SizedBox(width: 7),
                  Text(
                    'total_commission_points'.tr,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '+$ptsPerRef ${'per_referral'.tr}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Big Total Points Value
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$totalEarnedPoints',
                style: const TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'points_earned'.tr,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.hourglass_empty_rounded, size: 13, color: Colors.white70),
                const SizedBox(width: 5),
                Text(
                  '${'pending_points'.tr}: ',
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                ),
                Text(
                  '$pendingPoints pts',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  // 3. Exact API Metrics Grid (2x2 Grid)
  // --------------------------------------------------------------------------
  Widget _buildApiMetricsGrid({
    required int totalReferrals,
    required int activeReferrals,
    required num totalEarnedPoints,
    required num ptsPerRef,
    required num pendingPoints,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMetricTile(
                title: 'total_referrals'.tr,
                value: '$totalReferrals',
                icon: Icons.people_alt_rounded,
                iconColor: const Color(0xFF2563EB),
                bgColor: const Color(0xFFEFF6FF),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricTile(
                title: 'active_referrals'.tr,
                value: '$activeReferrals',
                icon: Icons.check_circle_rounded,
                iconColor: const Color(0xFF059669),
                bgColor: const Color(0xFFECFDF5),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMetricTile(
                title: 'pending_points'.tr,
                value: '$pendingPoints',
                icon: Icons.hourglass_bottom_rounded,
                iconColor: const Color(0xFFD97706),
                bgColor: const Color(0xFFFFFBEB),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricTile(
                title: 'per_referral'.tr,
                value: '$ptsPerRef pts',
                icon: Icons.stars_rounded,
                iconColor: AppColors.primary,
                bgColor: const Color(0xFFFFF1F8),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricTile({
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Color(0xFF64748B),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
