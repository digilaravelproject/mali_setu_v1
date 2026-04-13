import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:edu_cluezer/core/routes/app_routes.dart';
import 'package:edu_cluezer/widgets/custom_buttons.dart';
import 'package:edu_cluezer/core/helper/string_extensions.dart';
import 'package:edu_cluezer/features/business/data/model/res_all_business_model.dart';
import 'package:edu_cluezer/features/business/presentation/controller/business_controller.dart';
import 'package:edu_cluezer/features/business/presentation/controller/reg_business_controller.dart';
import 'package:edu_cluezer/features/Auth/service/auth_service.dart';

import '../../../../core/constent/api_constants.dart';


class MyBusinessScreen extends GetWidget<BusinessController> {
  const MyBusinessScreen({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        final businesses = controller.myBusinesses;


        return RefreshIndicator(
          onRefresh: () => controller.fetchMyBusinesses(),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // App Bar
              SliverAppBar(
                elevation: 2,
                pinned: true,
                centerTitle: false,
                title: Text(
                  'my_businesses'.tr,
                  style: context.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 22,
                  ),
                ),
                leading: InkWell(
                  onTap: () => Get.back(),
                  child: Icon(
                    Icons.arrow_back_ios,
                    color: context.iconColor,
                    size: 18,
                  ),
                ),
                actions: [
                  IconButton(
                    onPressed: () => Get.toNamed(AppRoutes.jobAnalytics),
                    icon: const Icon(Icons.analytics_outlined),
                    tooltip: 'job_analytics'.tr,
                  ),
                ],
              ),

              // Promotion Card
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [context.theme.primaryColorLight, context.theme.primaryColorLight],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: context.theme.primaryColor.withOpacity(0.4),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.rocket_launch,
                                  color: context.theme.cardColor,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  "expand_network".tr,
                                  style: context.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "add_another_business".tr,
                            style: context.textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 16),
                          CustomButton(
                            title: "add_new_business".tr,
                            height: 40,
                            borderRadius: 12,
                            onPressed: () {
                              Get.toNamed(AppRoutes.regBusiness);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Business Count
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "my_businesses".tr,
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Business List
              if (businesses.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Text("no_businesses_found".tr),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) => _buildBusinessCard(businesses[index], context: context),
                    childCount: businesses.length,
                  ),
                ),

              // Bottom Padding
              const SliverToBoxAdapter(
                child: SizedBox(height: 30),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildBusinessCard(Business business, {required BuildContext context}) {
    final bool isApproved = business.verificationStatus?.toLowerCase() == 'approved';
    final String statusText = business.verificationStatus?.toTitleCase() ?? 'Pending';
    final Color statusColor = isApproved ? const Color(0xFF10B981) : const Color(0xFFF59E0B);
    final isPending = business.verificationStatus?.toLowerCase() != 'approved';
    final hasSubscription = business.subscriptionStatus?.toLowerCase() == 'active';



    return GestureDetector(
      onTap: (){
        if (isPending) {
          if (hasSubscription) {
            _showWaitingForApprovalDialog(context);
          } else {
            _showPurchasePlanDialog(context, business);
          }
        } else {
          Get.toNamed(AppRoutes.businessDetails, arguments: business);
        }
      },
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        decoration: BoxDecoration(
          color: context.theme.cardColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Column(
            children: [
              // Header: Image, Info, and 3-Dot Menu
              Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Business Image
                    Hero(
                      tag: 'business_image_${business.id}',
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: (business.photo != null)
                              ? Image.network(
                            ApiConstants.imageBaseUrl + business.photo!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => _buildPlaceholderIcon(),
                          )
                              : _buildPlaceholderIcon(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 18),

                    // Business Info & Actions
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Title & Category
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      business.businessName?.toTitleCase() ?? 'unnamed_business'.tr,
                                      style: context.textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 18,
                                        letterSpacing: -0.5,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: context.theme.dividerColor.withOpacity(0.05),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        business.category?.name?.toTitleCase() ?? 'category'.tr,
                                        style: context.textTheme.bodySmall?.copyWith(
                                          color: context.textTheme.bodySmall?.color?.withOpacity(0.7),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // 3-Dot Menu Button
                              _buildCardPopupMenu(context, business),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // Status & Time
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  statusText,
                                  style: context.textTheme.labelSmall?.copyWith(
                                    color: statusColor,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  Icon(Icons.access_time, size: 14, color: Colors.grey.shade500),
                                  const SizedBox(width: 4),
                                  Text(
                                    business.createdAt != null ? _calculateTimeAgo(business.createdAt!) : '',
                                    style: context.textTheme.bodySmall?.copyWith(
                                      color: Colors.grey.shade500,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Horizontal Metric Pills
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Row(
                  children: [
                    _buildMetricPill(
                      context: context,
                      icon: Icons.inventory_2_outlined,
                      label: 'products'.tr,
                      value: '${business.products?.length ?? 0}',
                      color: const Color(0xFF3B82F6),
                    ),
                    const SizedBox(width: 12),
                    _buildMetricPill(
                      context: context,
                      icon: Icons.auto_awesome_outlined,
                      label: 'services'.tr,
                      value: '${business.services?.length ?? 0}',
                      color: const Color(0xFF8B5CF6),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Subtle Contact Section
              Container(
                margin: const EdgeInsets.fromLTRB(18, 0, 18, 18),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: context.theme.dividerColor.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _buildContactItem(
                      context,
                      Icons.phone_iphone_outlined,
                      business.contactPhone ?? 'N/A',
                    ),
                    const SizedBox(height: 10),
                    _buildContactItem(
                      context,
                      Icons.alternate_email_outlined,
                      business.contactEmail ?? 'N/A',
                    ),
                    if (business.website != null && business.website!.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      _buildContactItem(
                        context,
                        Icons.public_outlined,
                        business.website!,
                      ),
                    ],
                    const SizedBox(height: 12),
                    _buildSubscriptionBadge(context, business),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardPopupMenu(BuildContext context, Business business) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        switch (value) {
          case 'view':
            final isPending = business.verificationStatus?.toLowerCase() != 'approved';
            final hasSubscription = business.subscriptionStatus?.toLowerCase() == 'active';

            if (isPending) {
              if (hasSubscription) {
                _showWaitingForApprovalDialog(context);
              } else {
                _showPurchasePlanDialog(context, business);
              }
            } else {
              Get.toNamed(AppRoutes.businessDetails, arguments: business);
            }
            break;
          case 'edit':
            Get.toNamed(AppRoutes.regBusiness, arguments: business);
            break;
          case 'delete':
            _showDeleteConfirmation(context, business);
            break;
        }
      },
      icon: Icon(Icons.more_vert, color: Colors.grey.shade600),
      elevation: 8,
      offset: const Offset(0, 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      itemBuilder: (context) => [
        _buildPopupMenuItem(
          value: 'view',
          icon: Icons.visibility_outlined,
          label: 'view'.tr,
          color: const Color(0xFF3B82F6),
        ),
        _buildPopupMenuItem(
          value: 'edit',
          icon: Icons.edit_note_outlined,
          label: 'edit'.tr,
          color: const Color(0xFF10B981),
        ),
        _buildPopupMenuItem(
          value: 'delete',
          icon: Icons.delete_sweep_outlined,
          label: 'delete'.tr,
          color: const Color(0xFFEF4444),
        ),
      ],
    );
  }

  PopupMenuItem<String> _buildPopupMenuItem({
    required String value,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricPill({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.12)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 16),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: context.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: color,
                    ),
                  ),
                  Text(
                    label,
                    style: context.textTheme.bodySmall?.copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: color.withOpacity(0.8),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionBadge(BuildContext context, Business business) {
    final isActive = business.subscriptionStatus?.toLowerCase() == 'active';
    final expiresAt = business.subscriptionExpiresAt;

    String label;
    String sublabel;
    Color color;
    IconData icon;

    if (isActive && expiresAt != null) {
      try {
        final expiry = DateTime.parse(expiresAt);
        final daysLeft = expiry.difference(DateTime.now()).inDays;
        label = 'plan_purchased'.tr;
        sublabel = daysLeft > 0
            ? '${'valid_for'.tr} $daysLeft ${'days'.tr}'
            : 'plan_expired'.tr;
        color = daysLeft > 30 ? Colors.green : Colors.orange;
        icon = Icons.verified_rounded;
      } catch (_) {
        label = 'plan_purchased'.tr;
        sublabel = '';
        color = Colors.green;
        icon = Icons.verified_rounded;
      }
    } else {
      label = 'plan_not_purchased'.tr;
      sublabel = 'purchase_plan_to_activate'.tr;
      color = Colors.grey;
      icon = Icons.lock_outline_rounded;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
                if (sublabel.isNotEmpty)
                  Text(sublabel, style: TextStyle(fontSize: 11, color: color.withOpacity(0.8))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(BuildContext context, IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: context.theme.primaryColor.withOpacity(0.6)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            value,
            style: context.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  void _showPurchasePlanDialog(BuildContext context, Business business) {
    final theme = Theme.of(context);
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.verified_outlined, size: 48, color: theme.primaryColor),
              ),
              const SizedBox(height: 20),
              Text(
                'plan_required'.tr,
                style: context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'purchase_plan_to_approve_business'.tr,
                textAlign: TextAlign.center,
                style: context.textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Get.back(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text('cancel'.tr, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Get.back();
                        final regCtrl = Get.find<RegBusinessController>();
                        // Pass business type so correct plans are shown
                        await regCtrl.fetchAndShowBusinessPlansForType(
                          business.businessType ?? '',
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: Text('purchase_now'.tr, style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showWaitingForApprovalDialog(BuildContext context) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.hourglass_empty_rounded, size: 48, color: Colors.orange),
              ),
              const SizedBox(height: 20),
              Text(
                'Waiting for Approval',
                style: context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'Your plan has been purchased successfully. Please wait a little while for the admin to approve your business.',
                textAlign: TextAlign.center,
                style: context.textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: const Text('OK', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Business business) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.delete_forever_outlined, size: 40, color: Color(0xFFEF4444)),
              ),
              const SizedBox(height: 20),
              Text(
                "delete_business".tr,
                style: context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              Text(
                "delete_confirmation".tr,
                textAlign: TextAlign.center,
                style: context.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Get.back(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Text("cancel".tr, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        if (business.id != null) {
                          controller.deleteBusiness(business.id!);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF4444),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Text("delete".tr, style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderIcon() {
    return Container(
      color: Colors.grey[100],
      child: Icon(
        Icons.business_center_outlined,
        size: 32,
        color: Colors.grey[400],
      ),
    );
  }

  String _calculateTimeAgo(String date) {
    try {
      final dateTime = DateTime.parse(date);
      final diff = DateTime.now().difference(dateTime);
      if (diff.inDays >= 365) {
        return '${(diff.inDays / 365).floor()}y ago';
      } else if (diff.inDays >= 30) {
        return '${(diff.inDays / 30).floor()}mo ago';
      } else if (diff.inDays >= 1) {
        return '${diff.inDays}d ago';
      } else if (diff.inHours >= 1) {
        return '${diff.inHours}h ago';
      } else {
        return '${diff.inMinutes}m ago';
      }
    } catch (e) {
      return '';
    }
  }
}