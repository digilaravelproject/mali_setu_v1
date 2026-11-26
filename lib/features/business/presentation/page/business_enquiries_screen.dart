import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/styles/app_colors.dart';
import '../../data/model/business_enquiries_model.dart';
import '../controller/business_enquiries_controller.dart';

class BusinessEnquiriesScreen extends StatelessWidget {
  const BusinessEnquiriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(BusinessEnquiriesController());
    final primaryColor = context.theme.primaryColor;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Colors.black87),
          onPressed: () => Get.back(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Customer Enquiries",
              style: TextStyle(
                color: Colors.black87,
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.2,
              ),
            ),
            Obx(() {
              final bizName = controller.business.value?.businessName;
              if (bizName == null || bizName.isEmpty) return const SizedBox.shrink();
              return Text(
                bizName,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              );
            }),
          ],
        ),

        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey.shade200, height: 1),
        ),
      ),
      body: Column(
        children: [
          // Search & Filter header
          _buildFilterHeader(context, controller, primaryColor),

          // Enquiries List or State View
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.enquiries.isEmpty) {
                return _buildLoadingShimmer();
              }

              if (controller.errorMessage.value.isNotEmpty && controller.enquiries.isEmpty) {
                return _buildErrorState(controller);
              }

              final list = controller.filteredEnquiries;

              if (list.isEmpty) {
                return _buildEmptyState(controller);
              }

              return RefreshIndicator(
                color: primaryColor,
                onRefresh: () => controller.fetchEnquiries(isRefresh: true),
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  itemCount: list.length + (controller.isLoadMore.value ? 1 : 0),
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    if (index == list.length) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: CupertinoActivityIndicator(radius: 12),
                        ),
                      );
                    }
                    return _buildEnquiryCard(context, list[index], controller, primaryColor);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterHeader(
      BuildContext context, BusinessEnquiriesController controller, Color primaryColor) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        children: [
          // Search bar
          Container(
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: controller.searchController,
              onChanged: controller.onSearchChanged,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
              decoration: InputDecoration(
                hintText: "Search customer, item, phone...",
                hintStyle: TextStyle(fontSize: 13.5, color: Colors.grey.shade500),
                prefixIcon: Icon(Icons.search_rounded, size: 20, color: Colors.grey.shade500),
                suffixIcon: Obx(() {
                  if (controller.searchQuery.value.isEmpty) return const SizedBox.shrink();
                  return IconButton(
                    icon: Icon(Icons.cancel, size: 18, color: Colors.grey.shade500),
                    onPressed: controller.clearSearch,
                  );
                }),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Filter pills (All, Products, Services)
          Obx(() {
            final currentFilter = controller.filterType.value;
            final allCount = controller.enquiries.length;
            final prodCount = controller.productEnquiriesCount;
            final servCount = controller.serviceEnquiriesCount;

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  _buildTabPill(
                    label: "All Enquiries",
                    count: allCount,
                    isSelected: currentFilter == 'all',
                    color: primaryColor,
                    onTap: () => controller.setFilterType('all'),
                  ),
                  const SizedBox(width: 8),
                  _buildTabPill(
                    label: "Products",
                    count: prodCount,
                    icon: Icons.inventory_2_outlined,
                    isSelected: currentFilter == 'product',
                    color: const Color(0xFF3B82F6),
                    onTap: () => controller.setFilterType('product'),
                  ),
                  const SizedBox(width: 8),
                  _buildTabPill(
                    label: "Services",
                    count: servCount,
                    icon: Icons.design_services_outlined,
                    isSelected: currentFilter == 'service',
                    color: const Color(0xFF8B5CF6),
                    onTap: () => controller.setFilterType('service'),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTabPill({
    required String label,
    required int count,
    IconData? icon,
    required bool isSelected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? color : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 14,
                color: isSelected ? Colors.white : Colors.grey.shade700,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected ? Colors.white : Colors.grey.shade700,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white.withOpacity(0.25) : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                "$count",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : Colors.grey.shade800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnquiryCard(BuildContext context, BusinessEnquiryItem enquiry,
      BusinessEnquiriesController controller, Color primaryColor) {
    final user = enquiry.user;
    final item = enquiry.enquirable;
    final isService = enquiry.isService;

    final openDetail = () {
      Get.toNamed(
        AppRoutes.businessEnquiryDetail,
        arguments: {
          'enquiry_id': enquiry.id,
          'enquiry': enquiry,
        },
      );
    };

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tappable Header & Product Info (opens full detail view)
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: openDetail,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Customer Header: Name, Avatar, Timestamp, Type Badge
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // User Avatar
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: primaryColor.withOpacity(0.1),
                          backgroundImage: (user?.displayPhotoUrl.isNotEmpty ?? false)
                              ? CachedNetworkImageProvider(user!.displayPhotoUrl)
                              : null,
                          child: (user?.displayPhotoUrl.isEmpty ?? true)
                              ? Text(
                                  user?.initials ?? '?',
                                  style: TextStyle(
                                    color: primaryColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(width: 12),

                        // Name and timestamp
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      user?.name ?? 'Customer',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF0F172A),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  // Type badge (Product vs Service)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: isService
                                          ? const Color(0xFF8B5CF6).withOpacity(0.1)
                                          : const Color(0xFF3B82F6).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      enquiry.typeLabel.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.4,
                                        color: isService ? const Color(0xFF8B5CF6) : const Color(0xFF3B82F6),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              Row(
                                children: [
                                  Icon(Icons.access_time_rounded, size: 13, color: Colors.grey.shade500),
                                  const SizedBox(width: 4),
                                  Text(
                                    enquiry.formattedDateTime.isNotEmpty
                                        ? "${enquiry.formattedDateTime} (${enquiry.timeAgo})"
                                        : "Recent",
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Enquired Product / Service Box (Brief info)
                  if (item != null)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          // Item Image
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              width: 46,
                              height: 46,
                              color: Colors.grey.shade200,
                              child: item.displayImageUrl.isNotEmpty
                                  ? CachedNetworkImage(
                                      imageUrl: item.displayImageUrl,
                                      fit: BoxFit.cover,
                                      errorWidget: (_, __, ___) => Icon(
                                        isService ? Icons.design_services : Icons.inventory_2,
                                        color: Colors.grey.shade400,
                                        size: 22,
                                      ),
                                    )
                                  : Icon(
                                      isService ? Icons.design_services : Icons.inventory_2,
                                      color: Colors.grey.shade400,
                                      size: 22,
                                    ),
                            ),
                          ),
                          const SizedBox(width: 10),

                          // Item Title and Price
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name ?? (isService ? 'Service Enquiry' : 'Product Enquiry'),
                                  style: const TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1E293B),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  enquiry.formattedPrice.isNotEmpty
                                      ? "Price / Offer: ${enquiry.formattedPrice}"
                                      : (item.displayPrice.isNotEmpty ? "Price: ₹${item.displayPrice}" : ""),
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                    color: primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Arrow to indicate clickable full view
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 14,
                            color: Colors.grey.shade400,
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),

          const Divider(height: 1, color: Color(0xFFF1F5F9)),

          // Quick Action Contact Bar (Call, WhatsApp, Details)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                // Phone Call button
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.phone_rounded,
                    label: "Call",
                    color: const Color(0xFF0284C7),
                    bgColor: const Color(0xFFE0F2FE),
                    onTap: () => controller.makePhoneCall(user?.phone),
                  ),
                ),
                const SizedBox(width: 8),

                // WhatsApp button
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.chat_rounded,
                    label: "WhatsApp",
                    color: const Color(0xFF16A34A),
                    bgColor: const Color(0xFFDCFCE7),
                    onTap: () => controller.openWhatsApp(
                      user?.phone,
                      customerName: user?.name,
                      itemName: item?.name,
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Full Details button
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.remove_red_eye_outlined,
                    label: "Details",
                    color: primaryColor,
                    bgColor: primaryColor.withOpacity(0.08),
                    onTap: openDetail,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 15, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingShimmer() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 4,
      itemBuilder: (_, __) => Container(
        margin: const EdgeInsets.only(bottom: 14),
        height: 180,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: const Center(
          child: CupertinoActivityIndicator(radius: 14),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BusinessEnquiriesController controller) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.mark_email_unread_outlined,
                size: 56,
                color: Color(0xFF3B82F6),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "No Enquiries Yet",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "When interested customers send an enquiry for your products or services, they will appear here.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.5,
                color: Colors.grey.shade600,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => controller.fetchEnquiries(isRefresh: true),
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text("Refresh"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BusinessEnquiriesController controller) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, size: 48, color: Colors.red.shade400),
            const SizedBox(height: 12),
            Text(
              controller.errorMessage.value,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => controller.fetchEnquiries(isRefresh: true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text("Retry"),
            ),
          ],
        ),
      ),
    );
  }
}
