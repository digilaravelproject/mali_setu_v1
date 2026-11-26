import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import '../../data/model/business_enquiries_model.dart';
import '../controller/business_enquiry_detail_controller.dart';

class BusinessEnquiryDetailScreen extends StatelessWidget {
  const BusinessEnquiryDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(BusinessEnquiryDetailController());
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
        title: Obx(() {
          final id = controller.enquiry.value?.id ?? controller.enquiryId;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Enquiry Details",
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
              ),

            ],
          );
        }),

        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey.shade200, height: 1),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.enquiry.value == null) {
          return _buildLoadingShimmer();
        }

        if (controller.errorMessage.value.isNotEmpty && controller.enquiry.value == null) {
          return _buildErrorState(controller);
        }

        final enquiry = controller.enquiry.value;
        if (enquiry == null) {
          return const Center(child: Text("Enquiry not found"));
        }

        return RefreshIndicator(
          color: primaryColor,
          onRefresh: () => controller.fetchEnquiryDetail(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Status & Timing Card
                _buildStatusBanner(context, enquiry, primaryColor),
                const SizedBox(height: 16),

                // Customer Information Card (with direct Call/WhatsApp/Email)
                _buildCustomerCard(context, enquiry, controller, primaryColor),
                const SizedBox(height: 16),

                // Enquiry Message / Description (Inner View as requested)
                _buildMessageCard(context, enquiry, primaryColor),
                const SizedBox(height: 16),

                // Enquired Product or Service Card
                if (enquiry.enquirable != null) ...[
                  _buildEnquirableItemCard(context, enquiry, controller, primaryColor),
                  const SizedBox(height: 16),
                ],

                // Business Info Card
                if (enquiry.business != null)
                  _buildBusinessInfoCard(context, enquiry.business!),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildStatusBanner(
      BuildContext context, BusinessEnquiryItem enquiry, Color primaryColor) {
    final status = (enquiry.status ?? 'new').toUpperCase();
    final isNew = status == 'NEW';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isNew
                      ? const Color(0xFF10B981).withOpacity(0.12)
                      : const Color(0xFF3B82F6).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isNew ? Icons.fiber_new_rounded : Icons.mark_email_read_outlined,
                  size: 20,
                  color: isNew ? const Color(0xFF059669) : const Color(0xFF2563EB),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Status: $status",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isNew ? const Color(0xFF059669) : const Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    enquiry.formattedDateTime.isNotEmpty
                        ? enquiry.formattedDateTime
                        : "Recent",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (enquiry.timeAgo.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                enquiry.timeAgo,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCustomerCard(BuildContext context, BusinessEnquiryItem enquiry,
      BusinessEnquiryDetailController controller, Color primaryColor) {
    final user = enquiry.user;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                Icon(Icons.person_pin_rounded, size: 20, color: primaryColor),
                const SizedBox(width: 8),
                const Text(
                  "Customer Details",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User Avatar
                CircleAvatar(
                  radius: 28,
                  backgroundColor: primaryColor.withOpacity(0.12),
                  backgroundImage: (user?.displayPhotoUrl.isNotEmpty ?? false)
                      ? CachedNetworkImageProvider(user!.displayPhotoUrl)
                      : null,
                  child: (user?.displayPhotoUrl.isEmpty ?? true)
                      ? Text(
                          user?.initials ?? '?',
                          style: TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 14),

                // Name, Phone, Email
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.name ?? 'Customer',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 6),
                      if (user?.phone != null && user!.phone!.isNotEmpty) ...[
                        Row(
                          children: [
                            Icon(Icons.phone_outlined, size: 14, color: Colors.grey.shade600),
                            const SizedBox(width: 6),
                            Text(
                              user.phone!,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade800,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                      ],
                      if (user?.email != null && user!.email!.isNotEmpty) ...[
                        Row(
                          children: [
                            Icon(Icons.mail_outline_rounded, size: 14, color: Colors.grey.shade600),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                user.email!,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: Color(0xFFF1F5F9)),

          // Action Contact Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.phone_rounded,
                    label: "Call",
                    color: const Color(0xFF0284C7),
                    bgColor: const Color(0xFFE0F2FE),
                    onTap: () => controller.makePhoneCall(user?.phone),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.chat_rounded,
                    label: "WhatsApp",
                    color: const Color(0xFF16A34A),
                    bgColor: const Color(0xFFDCFCE7),
                    onTap: () => controller.openWhatsApp(
                      user?.phone,
                      customerName: user?.name,
                      itemName: enquiry.enquirable?.name,
                    ),
                  ),
                ),
                if (user?.email != null && user!.email!.isNotEmpty) ...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.email_outlined,
                      label: "Email",
                      color: const Color(0xFF64748B),
                      bgColor: const Color(0xFFF1F5F9),
                      onTap: () => controller.sendEmail(
                        user.email,
                        itemName: enquiry.enquirable?.name,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageCard(
      BuildContext context, BusinessEnquiryItem enquiry, Color primaryColor) {
    final desc = enquiry.description?.trim() ?? '';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                Icon(Icons.format_quote_rounded, size: 20, color: Colors.amber.shade700),
                const SizedBox(width: 8),
                const Text(
                  "Enquiry Message / Requirements",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBEB),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFDE68A)),
                  ),
                  child: Text(
                    desc.isNotEmpty ? desc : "No additional description provided.",
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: Color(0xFF78350F),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (enquiry.formattedPrice.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text(
                        "Budget / Quoted Price: ",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      Text(
                        enquiry.formattedPrice,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnquirableItemCard(
      BuildContext context,
      BusinessEnquiryItem enquiry,
      BusinessEnquiryDetailController controller,
      Color primaryColor) {
    final item = enquiry.enquirable!;
    final isService = enquiry.isService;
    final images = item.allImageUrls;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      isService ? Icons.design_services_outlined : Icons.inventory_2_outlined,
                      size: 20,
                      color: isService ? const Color(0xFF8B5CF6) : const Color(0xFF3B82F6),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isService ? "Service Enquired" : "Product Enquired",
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isService
                        ? const Color(0xFF8B5CF6).withOpacity(0.12)
                        : const Color(0xFF3B82F6).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    enquiry.typeLabel.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: isService ? const Color(0xFF8B5CF6) : const Color(0xFF3B82F6),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),

          // Image Carousel or Image Gallery
          if (images.isNotEmpty) ...[
            SizedBox(
              height: 200,
              child: PageView.builder(
                itemCount: images.length,
                onPageChanged: (i) => controller.activeImageIndex.value = i,
                itemBuilder: (context, idx) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CachedNetworkImage(
                        imageUrl: images[idx],
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(
                          color: Colors.grey.shade100,
                          child: const Center(child: CupertinoActivityIndicator()),
                        ),
                        errorWidget: (_, __, ___) => Container(
                          color: Colors.grey.shade100,
                          child: Icon(
                            isService ? Icons.design_services : Icons.inventory_2,
                            size: 48,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            if (images.length > 1) ...[
              const SizedBox(height: 8),
              Obx(() => Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(images.length, (idx) {
                      final isActive = controller.activeImageIndex.value == idx;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        height: 6,
                        width: isActive ? 18 : 6,
                        decoration: BoxDecoration(
                          color: isActive ? primaryColor : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      );
                    }),
                  )),
            ],
          ],

          // Item Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name ?? 'Untitled Item',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 6),
                if (item.displayPrice.isNotEmpty) ...[
                  Row(
                    children: [
                      Text(
                        "₹${item.displayPrice}",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "(Item Standard Price)",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],

                if (item.description != null && item.description!.trim().isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    "Item Description",
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.description!.trim(),
                    style: TextStyle(
                      fontSize: 13.5,
                      height: 1.4,
                      color: Colors.grey.shade800,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessInfoCard(BuildContext context, dynamic business) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                const Icon(Icons.storefront_rounded, size: 20, color: Color(0xFF64748B)),
                const SizedBox(width: 8),
                const Text(
                  "Business Info",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  business.businessName ?? '',
                  style: const TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                if (business.category?.name != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    business.category!.name!,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
                if (business.address != null && business.address!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 14, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          "${business.address}, ${business.city ?? ''}",
                          style: TextStyle(
                            fontSize: 12.5,
                            color: Colors.grey.shade600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
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
          padding: const EdgeInsets.symmetric(vertical: 9),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 17, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
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
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Shimmer.fromColors(
          baseColor: Colors.grey.shade200,
          highlightColor: Colors.grey.shade50,
          child: Container(
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Shimmer.fromColors(
          baseColor: Colors.grey.shade200,
          highlightColor: Colors.grey.shade50,
          child: Container(
            height: 140,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Shimmer.fromColors(
          baseColor: Colors.grey.shade200,
          highlightColor: Colors.grey.shade50,
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(BusinessEnquiryDetailController controller) {
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
              style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => controller.fetchEnquiryDetail(),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text("Retry"),
            ),
          ],
        ),
      ),
    );
  }
}
