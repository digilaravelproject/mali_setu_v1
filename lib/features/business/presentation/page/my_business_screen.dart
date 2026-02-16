import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:edu_cluezer/core/routes/app_routes.dart';
import 'package:edu_cluezer/widgets/custom_buttons.dart';
import 'package:edu_cluezer/core/helper/string_extensions.dart';
import 'package:edu_cluezer/features/business/data/model/res_all_business_model.dart';
import 'package:edu_cluezer/features/business/presentation/controller/business_controller.dart';


class MyBusinessScreen extends GetWidget<BusinessController> {
  const MyBusinessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        final businesses = controller.myBusinesses;

        return CustomScrollView(
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
                      "my_businesses (${businesses.length})".tr,
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
        );
      }),
    );
  }

  Widget _buildBusinessCard(Business business, {required BuildContext context}) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.theme.dividerColor),
      ),
      child: Column(
        children: [
          // Business Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Business Image
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: context.theme.dividerColor),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: (business.photo != null)
                        ? Image.network(
                            business.photo!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => _buildPlaceholderIcon(),
                          )
                        : _buildPlaceholderIcon(),
                  ),
                ),
                const SizedBox(width: 16),

                // Business Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              business.businessName ?? 'unnamed_business'.tr,
                              style: context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              business.status.toTitleCase() ?? 'Active',
                              style: context.textTheme.bodyMedium?.copyWith(
                                color: Colors.green.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        business.category?.name ?? 'category'.tr,
                        style: context.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '0.0', // No rating in API yet
                            style: context.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '(0 reviews)',
                            style: context.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                          ),
                          const Spacer(),
                          const SizedBox(width: 4),
                          Text(
                            business.createdAt != null ? _calculateTimeAgo(business.createdAt!) : '',
                            style: context.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Divider
          Divider(height: 1, color: context.theme.dividerColor),

          // Stats Row
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  context: context,
                  icon: Icons.inventory,
                  label: 'products'.tr,
                  value: '${business.products?.length ?? 0}',
                  color: Colors.blue,
                ),
                _buildStatItem(
                  context: context,
                  icon: Icons.design_services,
                  label: 'services'.tr,
                  value: '${business.services?.length ?? 0}',
                  color: Colors.purple,
                ),
                _buildStatItem(
                  context: context,
                  icon: Icons.currency_rupee,
                  label: 'revenue'.tr,
                  value: '0', // No revenue in API yet
                  color: Colors.green,
                ),
              ],
            ),
          ),

          // Divider
          Divider(height: 1, color: context.theme.dividerColor),

          // Contact Info & Actions
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Contact Info
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.phone, size: 16, color: Colors.blue.shade600),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              business.contactPhone ?? 'N/A',
                              style: context.textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.email, size: 16, color: Colors.blue.shade600),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              business.contactEmail ?? 'N/A',
                              style: context.textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                      if (business.website != null && business.website!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.language, size: 16, color: Colors.blue.shade600),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                business.website!,
                                style: context.textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // Action Buttons Row (Icon-based)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // View Details
                      _buildIconActionButton(
                        context: context,
                        icon: Icons.visibility_outlined,
                        label: 'view'.tr,
                        color: Colors.blue.shade600,
                        onPressed: () {
                          // TODO: Pass business ID
                          Get.toNamed(AppRoutes.businessDetails, arguments: business);
                        },
                      ),

                      // Edit Business
                      _buildIconActionButton(
                        context: context,
                        icon: Icons.edit_outlined,
                        label: 'edit'.tr,
                        color: Colors.green.shade600,
                        onPressed: () {
                          Get.toNamed(AppRoutes.regBusiness, arguments: business);
                        },
                      ),

                      // Delete Business
                      _buildIconActionButton(
                        context: context,
                        icon: Icons.delete_outline,
                        label: 'delete'.tr,
                        color: Colors.red.shade600,
                        onPressed: () {
                          Get.dialog(
                            Dialog(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.red.shade50,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(Icons.delete_outline, size: 32, color: Colors.red.shade600),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      "delete_business".tr,
                                      style: context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "delete_confirmation".tr,
                                      textAlign: TextAlign.center,
                                      style: context.textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                                    ),
                                    const SizedBox(height: 24),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: CustomOutlinedButton(
                                            title: "cancel".tr,
                                            height: 44,
                                            onPressed: () => Get.back(),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: CustomButton(
                                            title: "delete".tr,
                                            height: 44,
                                            onPressed: () {
                                              Get.back(); // Dismiss confirmation dialog first
                                              if (business.id != null) {
                                                controller.deleteBusiness(business.id!);
                                              }
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderIcon() {
    return Container(
      color: Colors.grey[200],
      child: Icon(
        Icons.business,
        size: 30,
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
        return '${(diff.inDays / 30).floor()}m ago';
      } else {
        return '${diff.inDays}d ago';
      }
    } catch (e) {
      return '';
    }
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required BuildContext context,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: context.textTheme.titleMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: context.textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildIconActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
    required BuildContext context,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: context.textTheme.titleSmall?.copyWith(color: color),
        ),
      ],
    );
  }
}
