import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:edu_cluezer/core/constent/api_constants.dart';
import 'package:edu_cluezer/core/routes/app_routes.dart';
import 'package:edu_cluezer/core/widgets/full_screen_image_viewer.dart';
import 'package:edu_cluezer/widgets/custom_image_view.dart';
import 'package:edu_cluezer/widgets/custom_snack_bar.dart';
import 'package:edu_cluezer/features/Auth/service/auth_service.dart';
import 'package:edu_cluezer/features/business/data/model/res_all_business_model.dart';
import 'package:edu_cluezer/features/business/presentation/controller/business_controller.dart';
import 'package:edu_cluezer/features/business/presentation/controller/single_product_controller.dart';

class SingleProductDetailsScreen extends StatelessWidget {
  final SingleProductController controller = Get.find<SingleProductController>();

  SingleProductDetailsScreen({Key? key}) : super(key: key);

  bool _isOwner(Product product) {
    final currentUserId = Get.isRegistered<AuthService>()
        ? Get.find<AuthService>().currentUser.value?.id
        : null;
    final bCtrl = Get.isRegistered<BusinessController>()
        ? Get.find<BusinessController>()
        : null;

    if (product.business != null) {
      if (currentUserId != null &&
          product.business?.userId != null &&
          currentUserId == product.business!.userId) {
        return true;
      }
      if (bCtrl != null &&
          bCtrl.myBusinesses.any((b) => b.id != null && b.id == product.business!.id)) {
        return true;
      }
    }
    if (product.businessId != null && bCtrl != null) {
      if (bCtrl.myBusinesses.any((b) => b.id != null && b.id == product.businessId)) {
        return true;
      }
    }
    return false;
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        CustomSnackBar.showError(message: 'Could not launch dialer for $phoneNumber');
      }
    } catch (_) {
      CustomSnackBar.showError(message: 'Could not open phone dialer');
    }
  }

  Future<void> _sendEmail(String email) async {
    final Uri launchUri = Uri(scheme: 'mailto', path: email);
    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        CustomSnackBar.showError(message: 'Could not open email app for $email');
      }
    } catch (_) {
      CustomSnackBar.showError(message: 'Could not open email app');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
                onPressed: () => Get.back(),
              ),
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline, size: 56, color: Colors.red.shade400),
                    const SizedBox(height: 16),
                    Text(
                      controller.errorMessage.value,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        final args = Get.arguments;
                        if (args is int) controller.fetchProductDetails(args);
                      },
                      child: const Text('Retry', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final product = controller.product.value;
        if (product == null) {
          return const Center(child: Text('Product not found'));
        }

        final isOwnerUser = _isOwner(product);
        final hasImage = product.imagePath != null && product.imagePath!.isNotEmpty;
        final imageUrl = hasImage ? '${ApiConstants.imageBaseUrl}/${product.imagePath}' : null;

        return Stack(
          children: [
            CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Collapsible Image AppBar
                SliverAppBar(
                  expandedHeight: 340,
                  pinned: true,
                  stretch: true,
                  backgroundColor: Colors.white,
                  elevation: 0,
                  leading: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircleAvatar(
                      backgroundColor: Colors.black.withOpacity(0.38),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
                        onPressed: () => Get.back(),
                      ),
                    ),
                  ),
                  actions: [
                    if (isOwnerUser)
                      Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: CircleAvatar(
                          backgroundColor: Colors.black.withOpacity(0.38),
                          child: IconButton(
                            icon: const Icon(Icons.edit_outlined, color: Colors.white, size: 20),
                            onPressed: () async {
                              final result = await Get.toNamed(
                                AppRoutes.editProduct,
                                arguments: {
                                  'product': product,
                                  'businessId': product.businessId ?? product.business?.id,
                                },
                              );
                              if (result == true && product.id != null) {
                                controller.fetchProductDetails(product.id!);
                              }
                            },
                          ),
                        ),
                      ),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (hasImage)
                          GestureDetector(
                            onTap: () {
                              Get.to(() => FullScreenImageViewer(
                                    imageUrl: imageUrl,
                                    tag: 'product_img_${product.id}',
                                  ));
                            },
                            child: Hero(
                              tag: 'product_img_${product.id}',
                              child: CustomImageView(
                                url: imageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => _buildImagePlaceholder(primaryColor),
                              ),
                            ),
                          )
                        else
                          _buildImagePlaceholder(primaryColor),

                        // Gradient overlays for contrast (pass-through taps)
                        Positioned.fill(
                          child: IgnorePointer(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.black.withOpacity(0.4),
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.45),
                                  ],
                                  stops: const [0.0, 0.45, 1.0],
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Tap to enlarge hint
                        if (hasImage)
                          Positioned(
                            bottom: 24,
                            right: 16,
                            child: GestureDetector(
                              onTap: () {
                                Get.to(() => FullScreenImageViewer(
                                      imageUrl: imageUrl,
                                      tag: 'product_img_${product.id}',
                                    ));
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.55),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.fullscreen, color: Colors.white, size: 16),
                                    SizedBox(width: 4),
                                    Text(
                                      'View Photo',
                                      style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // Content Section
                SliverToBoxAdapter(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Badge Row
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: primaryColor.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.inventory_2_outlined, size: 14, color: primaryColor),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Product',
                                      style: TextStyle(
                                        color: primaryColor,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8F5E9),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.check_circle_outline, size: 14, color: Color(0xFF2E7D32)),
                                    SizedBox(width: 6),
                                    Text(
                                      'Available',
                                      style: TextStyle(
                                        color: Color(0xFF2E7D32),
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),

                          // Product Name
                          Text(
                            product.name ?? 'Unnamed Product',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1E293B),
                              letterSpacing: -0.5,
                              height: 1.25,
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Price Card
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey.shade200),
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
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Price',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      product.cost != null && product.cost!.isNotEmpty
                                          ? '₹${product.cost}'
                                          : 'Price on request',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w900,
                                        color: primaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: primaryColor.withOpacity(0.08),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.sell_outlined, color: primaryColor, size: 24),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Description Section
                          if (product.description != null && product.description!.trim().isNotEmpty) ...[
                            Row(
                              children: [
                                Icon(Icons.description_outlined, size: 20, color: Colors.grey.shade700),
                                const SizedBox(width: 8),
                                const Text(
                                  'Description',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Text(
                                product.description!,
                                style: const TextStyle(
                                  fontSize: 14.5,
                                  height: 1.6,
                                  color: Color(0xFF334155),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],

                          // Business Info Card
                          if (product.business != null) _buildBusinessCard(context, product.business!, primaryColor),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Sticky Bottom Action Bar
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 16,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: Row(
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Price',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          Text(
                            product.cost != null && product.cost!.isNotEmpty ? '₹${product.cost}' : 'N/A',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: primaryColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            if (isOwnerUser) {
                              Get.toNamed(
                                AppRoutes.editProduct,
                                arguments: {
                                  'product': product,
                                  'businessId': product.businessId ?? product.business?.id,
                                },
                              )?.then((value) {
                                if (value == true && product.id != null) {
                                  controller.fetchProductDetails(product.id!);
                                }
                              });
                            } else if (product.business?.contactPhone != null &&
                                product.business!.contactPhone!.isNotEmpty) {
                              _makePhoneCall(product.business!.contactPhone!);
                            } else {
                              CustomSnackBar.showInfo(message: 'Contact details not provided.');
                            }
                          },
                          icon: Icon(
                            isOwnerUser ? Icons.edit : Icons.phone_in_talk_rounded,
                            size: 18,
                            color: Colors.white,
                          ),
                          label: Text(
                            isOwnerUser ? 'Edit Product' : 'Contact Business',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildImagePlaceholder(Color primaryColor) {
    return Container(
      color: const Color(0xFFF1F5F9),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_bag_outlined, size: 64, color: primaryColor.withOpacity(0.5)),
            const SizedBox(height: 8),
            Text(
              'No photo available',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBusinessCard(BuildContext context, Business business, Color primaryColor) {
    final photoUrl = business.photo != null && business.photo!.isNotEmpty
        ? '${ApiConstants.imageBaseUrl}/${business.photo}'
        : null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.storefront_outlined, size: 20, color: Colors.grey.shade700),
              const SizedBox(width: 8),
              const Text(
                'Business Information',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Business Header
          InkWell(
            onTap: () {
              Get.toNamed(AppRoutes.businessDetails, arguments: business);
            },
            borderRadius: BorderRadius.circular(12),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: photoUrl != null
                        ? CachedNetworkImage(
                            imageUrl: photoUrl,
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) => Icon(Icons.store, color: primaryColor, size: 26),
                          )
                        : Icon(Icons.store, color: primaryColor, size: 26),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        business.businessName ?? 'Unnamed Business',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E293B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (business.address != null && business.address!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.location_on_outlined, size: 14, color: Colors.grey.shade500),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                business.address!,
                                style: TextStyle(fontSize: 12.5, color: Colors.grey.shade600),
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
                const Icon(Icons.chevron_right, color: Colors.grey, size: 24),
              ],
            ),
          ),

          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 12),

          // Contact Actions Row
          Row(
            children: [
              if (business.contactPhone != null && business.contactPhone!.isNotEmpty)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _makePhoneCall(business.contactPhone!),
                    icon: Icon(Icons.phone_outlined, size: 16, color: primaryColor),
                    label: Text(
                      'Call',
                      style: TextStyle(color: primaryColor, fontWeight: FontWeight.w700),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: primaryColor.withOpacity(0.3)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              if (business.contactPhone != null &&
                  business.contactPhone!.isNotEmpty &&
                  business.contactEmail != null &&
                  business.contactEmail!.isNotEmpty)
                const SizedBox(width: 10),
              if (business.contactEmail != null && business.contactEmail!.isNotEmpty)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _sendEmail(business.contactEmail!),
                    icon: const Icon(Icons.email_outlined, size: 16, color: Color(0xFF475569)),
                    label: const Text(
                      'Email',
                      style: TextStyle(color: Color(0xFF475569), fontWeight: FontWeight.w700),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
