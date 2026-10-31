import 'dart:async';
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
import 'package:edu_cluezer/features/business/presentation/page/my_products_services_screen.dart';

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

  Future<void> _navigateToEditProduct(Product product) async {
    final result = await Get.toNamed(
      AppRoutes.editProduct,
      arguments: {
        'product': product,
        'businessId': product.businessId ?? product.business?.id,
      },
    );
    if ((result == true || result != null) && product.id != null) {
      await controller.fetchProductDetails(product.id!);
    }
  }

  void _showDeleteConfirmDialog(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (dialogCtx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  color: Color(0xFFFEE2E2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  color: Color(0xFFDC2626),
                  size: 30,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Delete Product',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Are you sure you want to delete '${product.name ?? 'this product'}'? This action cannot be undone.",
                style: const TextStyle(
                  fontSize: 13.5,
                  color: Color(0xFF4B5563),
                  height: 1.45,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(dialogCtx).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: Color(0xFFE5E7EB)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: Color(0xFF374151),
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        // 1. Close dialog immediately using dialog context
                        Navigator.of(dialogCtx).pop();

                        // 2. Call delete API without triggering premature snackbar
                        BusinessController? bCtrl;
                        try {
                          bCtrl = Get.find<BusinessController>();
                        } catch (_) {}

                        if (bCtrl != null && product.id != null) {
                          final businessId = product.businessId ?? product.business?.id;
                          final success = await bCtrl.deleteProduct(
                            product.id!,
                            businessId: businessId,
                            showSuccessSnackbar: false,
                          );
                          // 3. Pop product detail page back to the list
                          if (success) {
                            if (Get.isRegistered<MyProductsServicesController>()) {
                              Get.find<MyProductsServicesController>().loadData();
                            }
                            if (context.mounted) {
                              Navigator.of(context).pop(true);
                            } else {
                              Get.back(result: true);
                            }
                            CustomSnackBar.showSuccess(message: 'Product deleted successfully!');
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFDC2626),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Delete',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
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

  String _formatDate(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) return '';
    try {
      final dt = DateTime.parse(rawDate).toLocal();
      const months = [
        '01', '02', '03', '04', '05', '06',
        '07', '08', '09', '10', '11', '12'
      ];
      final day = dt.day.toString().padLeft(2, '0');
      return '$day.${months[dt.month - 1]}.${dt.year}';
    } catch (_) {
      return rawDate.split('T').first;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87, size: 20),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Product details',
          style: TextStyle(
            color: Color(0xFF111827),
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          Obx(() {
            final product = controller.product.value;
            if (product != null && _isOwner(product)) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, color: Colors.black87, size: 20),
                    onPressed: () => _navigateToEditProduct(product),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFDC2626), size: 21),
                    onPressed: () => _showDeleteConfirmDialog(context, product),
                  ),
                ],
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline_rounded, size: 54, color: Colors.red.shade400),
                  const SizedBox(height: 14),
                  Text(
                    controller.errorMessage.value,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 18),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {
                      final args = Get.arguments;
                      if (args is int) {
                        controller.fetchProductDetails(args);
                      } else if (args is Product && args.id != null) {
                        controller.fetchProductDetails(args.id!);
                      }
                    },
                    child: const Text('Try Again', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          );
        }

        final product = controller.product.value;
        if (product == null) {
          return const Center(child: Text('Product not found'));
        }

        final isOwnerUser = _isOwner(product);
        final images = product.allImages;
        final hasPrice = product.cost != null &&
            product.cost!.trim().isNotEmpty &&
            product.cost!.trim().toLowerCase() != 'null';
        final displayPrice = hasPrice ? '₹${product.cost}' : 'Price on request';

        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Full-Width Edge-to-Edge Image Box
                    EcommerceImageBox(
                      images: images,
                      productId: product.id ?? 0,
                      statusBadge: product.status?.toUpperCase() ?? 'ACTIVE',
                      primaryColor: primaryColor,
                    ),

                    const SizedBox(height: 16),

                    // 2. Product Name, Subtitle & Price
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Product Title (Size reduced slightly for sleek look)
                          Text(
                            product.name ?? 'Unnamed Product',
                            style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF111827),
                              letterSpacing: -0.2,
                              height: 1.25,
                            ),
                          ),

                          const SizedBox(height: 4),

                          // Subtitle (Category or Business)
                          Text(
                            product.business?.category?.name ??
                                product.business?.businessName ??
                                'Product Item',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF6B7280),
                              fontWeight: FontWeight.w500,
                            ),
                          ),

                          const SizedBox(height: 10),

                          // Price Row (Reduced text size: 19sp instead of 24sp)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                displayPrice,
                                style: TextStyle(
                                  fontSize: hasPrice ? 19 : 16,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFFDC2626), // Bold vibrant red
                                  letterSpacing: -0.2,
                                ),
                              ),
                              if (hasPrice) ...[
                                const SizedBox(width: 8),
                                Text(
                                  'inclusive of taxes',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[500],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Divider
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                      child: Divider(color: Color(0xFFE5E7EB), thickness: 1, height: 1),
                    ),

                    // 3. E-commerce Specs & Details
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Calendar row
                          if (product.createdAt != null && product.createdAt!.isNotEmpty) ...[
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: const Color(0xFFD1D5DB)),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Icon(Icons.calendar_month_outlined, size: 16, color: Color(0xFF374151)),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'Listed on: ${_formatDate(product.createdAt)}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF374151),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                          ],

                          // Item Info rows
                          _buildSpecRow(
                            label: 'Product ID:',
                            value: '#${product.id ?? "-"}',
                          ),
                          const SizedBox(height: 8),

                          _buildSpecRow(
                            label: 'Availability:',
                            value: product.status?.capitalizeFirst ?? 'In Stock',
                            valueColor: const Color(0xFF059669),
                          ),
                          const SizedBox(height: 8),

                          if (hasPrice) ...[
                            _buildSpecRow(
                              label: 'Regular price per item:',
                              value: '₹${product.cost}',
                            ),
                            const SizedBox(height: 8),
                          ],

                          if (product.business?.businessName != null) ...[
                            _buildSpecRow(
                              label: 'Seller / Store:',
                              value: product.business!.businessName!,
                              isLink: true,
                              onTap: () {
                                Get.toNamed(AppRoutes.businessDetails, arguments: product.business);
                              },
                            ),
                            const SizedBox(height: 8),
                          ],

                          if (product.business?.address != null && product.business!.address!.isNotEmpty) ...[
                            _buildSpecRow(
                              label: 'Location:',
                              value: product.business!.address!,
                            ),
                            const SizedBox(height: 8),
                          ],

                          const SizedBox(height: 10),

                          // Description
                          if (product.description != null && product.description!.trim().isNotEmpty) ...[
                            const SizedBox(height: 8),
                            const Text(
                              'Product details & description:',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF111827),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              product.description!.trim(),
                              style: const TextStyle(
                                fontSize: 13.5,
                                height: 1.55,
                                color: Color(0xFF4B5563),
                              ),
                            ),
                            const SizedBox(height: 14),
                          ],

                          // Seller Quick Contact Row
                          if (product.business != null) ...[
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF9FAFB),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFE5E7EB)),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundColor: primaryColor.withOpacity(0.1),
                                    backgroundImage: (product.business?.photo != null &&
                                            product.business!.photo!.isNotEmpty)
                                        ? CachedNetworkImageProvider(
                                            product.business!.photo!.startsWith('http')
                                                ? product.business!.photo!
                                                : '${ApiConstants.imageBaseUrl}/${product.business!.photo}',
                                          )
                                        : null,
                                    child: (product.business?.photo == null || product.business!.photo!.isEmpty)
                                        ? Icon(Icons.storefront_rounded, color: primaryColor, size: 20)
                                        : null,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          product.business?.businessName ?? 'Verified Seller',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF111827),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          product.business?.contactPhone ?? 'Tap to contact',
                                          style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (product.business?.contactPhone != null &&
                                      product.business!.contactPhone!.isNotEmpty)
                                    IconButton(
                                      onPressed: () => _makePhoneCall(product.business!.contactPhone!),
                                      icon: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: primaryColor.withOpacity(0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(Icons.phone, color: primaryColor, size: 18),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 4. Large Action Button with Primary Color
            Container(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFF3F4F6), width: 1.2)),
              ),
              child: SafeArea(
                top: false,
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      if (isOwnerUser) {
                        _navigateToEditProduct(product);
                      } else if (product.business?.contactPhone != null &&
                          product.business!.contactPhone!.isNotEmpty) {
                        _makePhoneCall(product.business!.contactPhone!);
                      } else {
                        CustomSnackBar.showInfo(message: 'Contact details not provided.');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor, // Primary brand color
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      isOwnerUser ? 'Edit product' : 'Contact seller',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildSpecRow({
    required String label,
    required String value,
    Color? valueColor,
    bool isLink = false,
    VoidCallback? onTap,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label ',
          style: const TextStyle(
            fontSize: 13.5,
            color: Color(0xFF374151),
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: onTap,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: valueColor ?? (isLink ? const Color(0xFF2563EB) : const Color(0xFF111827)),
                decoration: isLink ? TextDecoration.underline : TextDecoration.none,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Full-Width E-Commerce Product Image Box
class EcommerceImageBox extends StatefulWidget {
  final List<String> images;
  final int productId;
  final String statusBadge;
  final Color primaryColor;

  const EcommerceImageBox({
    Key? key,
    required this.images,
    required this.productId,
    required this.statusBadge,
    required this.primaryColor,
  }) : super(key: key);

  @override
  State<EcommerceImageBox> createState() => _EcommerceImageBoxState();
}

class _EcommerceImageBoxState extends State<EcommerceImageBox> {
  late PageController _pageController;
  int _currentIndex = 0;
  Timer? _autoSlideTimer;
  bool _isUserInteracting = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startTimer();
  }

  void _startTimer() {
    if (widget.images.length <= 1) return;
    _autoSlideTimer?.cancel();
    _autoSlideTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!mounted || !_pageController.hasClients || _isUserInteracting) return;
      final nextPage = (_currentIndex + 1) % widget.images.length;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  void _pauseTimer() {
    _isUserInteracting = true;
    _autoSlideTimer?.cancel();
  }

  void _resumeTimer() {
    _isUserInteracting = false;
    _startTimer();
  }

  @override
  void didUpdateWidget(covariant EcommerceImageBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.images.length != widget.images.length) {
      _startTimer();
    }
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Full width edge-to-edge container
    return Container(
      width: double.infinity,
      height: 350,
      color: const Color(0xFFF9FAFB),
      child: Stack(
        children: [
          if (widget.images.isEmpty)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_bag_outlined, size: 54, color: Colors.grey[400]),
                  const SizedBox(height: 8),
                  Text(
                    'No image available',
                    style: TextStyle(color: Colors.grey[500], fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            )
          else
            Listener(
              onPointerDown: (_) => _pauseTimer(),
              onPointerUp: (_) => _resumeTimer(),
              onPointerCancel: (_) => _resumeTimer(),
              child: PageView.builder(
                controller: _pageController,
                itemCount: widget.images.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  final imageUrl = widget.images[index];
                  return GestureDetector(
                    onTap: () {
                      Get.to(() => FullScreenImageViewer(
                            imageUrl: imageUrl,
                            tag: 'product_img_${widget.productId}_$index',
                          ));
                    },
                    child: Hero(
                      tag: 'product_img_${widget.productId}_$index',
                      child: Container(
                        width: double.infinity,
                        height: 350,
                        color: Colors.transparent,
                        child: Center(
                          child: CustomImageView(
                            url: imageUrl,
                            width: double.infinity,
                            height: 350,
                            fit: BoxFit.cover, // Full coverage as requested
                            errorBuilder: (_, __, ___) => Center(
                              child: Icon(Icons.broken_image_outlined, size: 48, color: Colors.grey[400]),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

          // Red Badge on Top-Left
          Positioned(
            top: 14,
            left: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFDC2626), // Bold vibrant red
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                widget.statusBadge,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),

          // Dots indicator at bottom center if multiple images
          if (widget.images.length > 1)
            Positioned(
              bottom: 12,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(widget.images.length, (index) {
                  final isSelected = index == _currentIndex;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: isSelected ? 16 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? widget.primaryColor
                          : Colors.white.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }
}
