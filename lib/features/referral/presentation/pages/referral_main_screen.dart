import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/styles/app_colors.dart';
import '../binding/referral_binding.dart';
import '../controller/referral_controller.dart';
import '../widgets/referral_list_view.dart';
import '../widgets/referral_tree_view.dart';
import '../widgets/referral_history_view.dart';

class ReferralMainScreen extends StatefulWidget {
  const ReferralMainScreen({super.key});

  @override
  State<ReferralMainScreen> createState() => _ReferralMainScreenState();
}

class _ReferralMainScreenState extends State<ReferralMainScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final ReferralController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ReferralBinding.init();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          'refer_and_earn'.tr,
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
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton.icon(
              onPressed: () {
                Get.toNamed(AppRoutes.referralAnalytics);
              },
              style: TextButton.styleFrom(
                backgroundColor: AppColors.primary.withValues(alpha: 0.08),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              ),
              icon: const Icon(Icons.insights_rounded, size: 16, color: AppColors.primary),
              label: Text(
                'analytics'.tr,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Obx(() {
        if (_controller.isLoading.value && _controller.earnings.value == null) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        final earnings = _controller.earnings.value;
        final vol = earnings?.volunteer;
        final totalReferrals = earnings?.totalReferrals ?? 0;
        final activeReferrals = earnings?.activeReferrals ?? 0;
        final totalEarned = earnings?.totalEarnedPoints ?? 0;
        final ptsPerRef = earnings?.commissionPointsPerReferral ?? 0;

        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () => _controller.fetchAllData(),
          child: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Compact Hero Share Card
                        _buildCompactHeroCard(vol),

                        const SizedBox(height: 10),

                        // Sleek Unified Quick Stats Bar
                        _buildCompactStatsBar(
                          total: totalReferrals,
                          active: activeReferrals,
                          earned: totalEarned,
                          perRef: ptsPerRef,
                        ),

                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _SliverAppBarDelegate(
                    TabBar(
                      controller: _tabController,
                      indicatorColor: AppColors.primary,
                      indicatorWeight: 3,
                      labelColor: AppColors.primary,
                      unselectedLabelColor: Colors.grey.shade600,
                      labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      tabs: [
                        Tab(
                          icon: const Icon(Icons.people_alt_outlined, size: 18),
                          text: 'referral_network'.tr,
                        ),
                        Tab(
                          icon: const Icon(Icons.history_rounded, size: 18),
                          text: 'points_history'.tr,
                        ),
                      ],
                    ),
                  ),
                ),
              ];
            },
            body: TabBarView(
              controller: _tabController,
              children: [
                // Tab 1: Network (Tree / List View)
                Column(
                  children: [
                    _buildNetworkViewSwitchHeader(),
                    Expanded(
                      child: Obx(() {
                        if (_controller.isTreeView.value) {
                          return ReferralTreeView(controller: _controller);
                        } else {
                          return ReferralListView(controller: _controller);
                        }
                      }),
                    ),
                  ],
                ),

                // Tab 2: History
                ReferralHistoryView(controller: _controller),
              ],
            ),
          ),
        );
      }),
    );
  }

  // --------------------------------------------------------------------------
  // Sleek, Compact Hero Card (Height ~130px instead of ~280px)
  // --------------------------------------------------------------------------
  Widget _buildCompactHeroCard(dynamic vol) {
    final code = _controller.getReferralCode();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primaryDark,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Header + Analytics Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.card_giftcard_rounded, color: Colors.white, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    'refer_earn_title'.tr,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                elevation: 2,
                shadowColor: Colors.black.withValues(alpha: 0.2),
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => Get.toNamed(AppRoutes.referralAnalytics),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.insights_rounded,
                          size: 14,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'analytics'.tr,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(width: 3),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 9,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Row 2: Code Box (with copy) + Direct Share Button
          Row(
            children: [
              // Code Box
              Expanded(
                flex: 6,
                child: Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          code,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                            color: AppColors.primary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _controller.copyReferralCode(context),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(Icons.copy_rounded, size: 15, color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // Share Button
              Expanded(
                flex: 4,
                child: SizedBox(
                  height: 40,
                  child: ElevatedButton.icon(
                    onPressed: () => _controller.shareReferral(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: Obx(() => _controller.isSharing.value
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary,
                            ),
                          )
                        : const Icon(Icons.share_rounded, size: 15)),
                    label: Text(
                      'share'.tr,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Quick action: Invite via Email
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () => _showEmailInviteSheet(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.email_outlined, color: Colors.white, size: 13),
                    const SizedBox(width: 4),
                    Text(
                      'send_link_email'.tr,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
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

  // --------------------------------------------------------------------------
  // Unified, Sleek Stats Bar (Height ~52px instead of ~85px)
  // --------------------------------------------------------------------------
  Widget _buildCompactStatsBar({
    required int total,
    required int active,
    required num earned,
    required num perRef,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => Get.toNamed(AppRoutes.referralAnalytics),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          decoration: BoxDecoration(
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
          child: Row(
            children: [
              Expanded(child: _buildCompactStatItem('$total', 'total_referrals'.tr, AppColors.primary)),
              _buildStatDivider(),
              Expanded(child: _buildCompactStatItem('$active', 'active'.tr, AppColors.success)),
              _buildStatDivider(),
              Expanded(child: _buildCompactStatItem('$earned', 'earned_points'.tr, Colors.deepPurple)),
              _buildStatDivider(),
              Expanded(child: _buildCompactStatItem('+$perRef', 'per_referral'.tr, AppColors.secondary)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(
      height: 22,
      width: 1,
      color: Colors.grey.shade200,
    );
  }

  Widget _buildCompactStatItem(String value, String label, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: color,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // --------------------------------------------------------------------------
  // Elegant Bottom Sheet for Email Invite (keeps main screen super clean!)
  // --------------------------------------------------------------------------
  void _showEmailInviteSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.email_outlined, color: AppColors.primary, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'send_link_email'.tr,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 1. Recipient Name (Optional)
                Container(
                  height: 46,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: TextField(
                    controller: _controller.recipientNameController,
                    keyboardType: TextInputType.name,
                    textCapitalization: TextCapitalization.words,
                    style: const TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'recipient_name_hint'.tr,
                      hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
                      prefixIcon: const Icon(Icons.person_outline_rounded, size: 18, color: Colors.grey),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // 2. Email Address (Required)
                Container(
                  height: 46,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: TextField(
                    controller: _controller.emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'enter_email_hint'.tr,
                      hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
                      prefixIcon: const Icon(Icons.mail_outline_rounded, size: 18, color: Colors.grey),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // 3. Optional Message
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: TextField(
                    controller: _controller.messageController,
                    maxLines: 2,
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'invite_msg_hint'.tr,
                      hintStyle: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                      prefixIcon: const Padding(
                        padding: EdgeInsets.only(bottom: 18),
                        child: Icon(Icons.chat_bubble_outline_rounded, size: 17, color: Colors.grey),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Send Button
                Obx(() {
                  final isSending = _controller.isSendingEmail.value;

                  return SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton(
                      onPressed: isSending
                          ? null
                          : () async {
                              final success = await _controller.sendReferralEmail();
                              if (success && Navigator.canPop(ctx)) {
                                Navigator.pop(ctx);
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: isSending
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : Text(
                              'send_btn'.tr,
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNetworkViewSwitchHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Obx(() {
            final count = _controller.filteredUsers.length;
            return Text(
              '${'members_list'.tr} ($count)',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            );
          }),
          Obx(() {
            final isTree = _controller.isTreeView.value;
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  _buildToggleBtn(
                    label: 'list_view'.tr,
                    icon: Icons.format_list_bulleted_rounded,
                    isSelected: !isTree,
                    onTap: () {
                      if (isTree) _controller.toggleViewMode();
                    },
                  ),
                  _buildToggleBtn(
                    label: 'tree_view'.tr,
                    icon: Icons.account_tree_rounded,
                    isSelected: isTree,
                    onTap: () {
                      if (!isTree) _controller.toggleViewMode();
                    },
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildToggleBtn({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 13,
              color: isSelected ? Colors.white : Colors.grey.shade600,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
