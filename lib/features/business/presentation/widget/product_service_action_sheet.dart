import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:edu_cluezer/core/constent/api_constants.dart';
import 'package:edu_cluezer/core/routes/app_routes.dart';
import 'package:edu_cluezer/widgets/custom_image_view.dart';
import 'package:edu_cluezer/widgets/custom_snack_bar.dart';
import 'package:edu_cluezer/core/widgets/full_screen_image_viewer.dart';
import 'package:edu_cluezer/features/business/data/model/res_all_business_model.dart';
import 'package:edu_cluezer/features/business/presentation/controller/business_controller.dart';

class ProductServiceActionSheet extends StatelessWidget {
  final Product? product;
  final Service? service;
  final int? businessId;
  final VoidCallback? onRefresh;

  const ProductServiceActionSheet({
    Key? key,
    this.product,
    this.service,
    this.businessId,
    this.onRefresh,
  }) : super(key: key);

  bool get isProduct => product != null;
  String get name => (isProduct ? product?.name : service?.name) ?? 'Unnamed';
  String get cost => (isProduct ? product?.cost : service?.cost) ?? '0';
  String? get imagePath => isProduct ? product?.imagePath : service?.imagePath;
  String get status => (isProduct ? product?.status : service?.status) ?? 'Active';
  bool get isActive => status.toLowerCase() != 'inactive' && status.toLowerCase() != 'deactivated';

  static void show(
    BuildContext context, {
    Product? product,
    Service? service,
    int? businessId,
    VoidCallback? onRefresh,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ProductServiceActionSheet(
        product: product,
        service: service,
        businessId: businessId,
        onRefresh: onRefresh,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Drag Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header Card
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Image thumbnail (tap to view full screen)
                  GestureDetector(
                    onTap: () {
                      if (imagePath != null && imagePath!.isNotEmpty) {
                        Navigator.of(context).pop();
                        final fullUrl = ApiConstants.imageBaseUrl + (imagePath!.startsWith('/') ? imagePath! : '/$imagePath');
                        Get.to(() => FullScreenImageViewer(
                              imageUrl: fullUrl,
                              tag: 'action_thumb_${isProduct ? product?.id : service?.id}',
                            ));
                      }
                    },
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: imagePath != null && imagePath!.isNotEmpty
                            ? CustomImageView(
                                url: ApiConstants.imageBaseUrl + imagePath!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Icon(
                                  isProduct ? Icons.shopping_bag_outlined : Icons.design_services_outlined,
                                  color: primaryColor,
                                  size: 28,
                                ),
                              )
                            : Icon(
                                isProduct ? Icons.shopping_bag_outlined : Icons.design_services_outlined,
                                color: primaryColor,
                                size: 28,
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Title, Cost, Badge
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              '₹$cost',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: isActive
                                    ? const Color(0xFFE8F5E9)
                                    : Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                isActive ? 'Active' : 'Inactive',
                                style: TextStyle(
                                  color: isActive ? const Color(0xFF2E7D32) : Colors.grey.shade700,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Close 'x' button
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close, color: Colors.grey.shade600, size: 22),
                    splashRadius: 20,
                  ),
                ],
              ),

              const SizedBox(height: 12),
              Divider(color: Colors.grey.shade200, height: 1),
              const SizedBox(height: 8),

              // 1. Edit Product / Service
              _buildActionTile(
                context,
                icon: Icons.edit_outlined,
                title: isProduct ? 'Edit Product' : 'Edit Service',
                onTap: () async {
                  Navigator.of(context).pop();
                  final route = isProduct ? AppRoutes.editProduct : AppRoutes.editService;
                  final result = await Get.toNamed(
                    route,
                    arguments: isProduct
                        ? {'product': product, 'businessId': businessId ?? product?.businessId}
                        : {'service': service, 'businessId': businessId ?? service?.businessId},
                  );
                  if (result == true) {
                    onRefresh?.call();
                  }
                },
              ),

              // 2. View Photo (Full Screen)
              _buildActionTile(
                context,
                icon: Icons.fullscreen_rounded,
                title: 'View Photo',
                onTap: () {
                  Navigator.of(context).pop();
                  final path = imagePath;
                  if (path != null && path.isNotEmpty) {
                    final fullUrl = ApiConstants.imageBaseUrl + (path.startsWith('/') ? path : '/$path');
                    Get.to(() => FullScreenImageViewer(
                          imageUrl: fullUrl,
                          tag: 'full_img_action_${isProduct ? product?.id : service?.id}',
                        ));
                  } else {
                    CustomSnackBar.showInfo(message: 'No photo available to display');
                  }
                },
              ),

              // 3. View Details
              _buildActionTile(
                context,
                icon: Icons.visibility_outlined,
                title: 'View Details',
                onTap: () async {
                  Navigator.of(context).pop();
                  if (isProduct && product?.id != null) {
                    final res = await Get.toNamed(AppRoutes.singleProductDetails, arguments: product!.id);
                    if (res == true) {
                      onRefresh?.call();
                    }
                  } else if (!isProduct && service?.id != null) {
                    Get.toNamed(AppRoutes.singleServiceDetails, arguments: service!.id);
                  }
                },
              ),

              // 3. Delete
              _buildActionTile(
                context,
                icon: Icons.delete_outline,
                title: 'Delete',
                isDestructive: true,
                onTap: () {
                  Navigator.of(context).pop();
                  _showDeleteConfirmDialog(context);
                },
              ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final color = isDestructive ? const Color(0xFFE53935) : Colors.black87;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 13),
        child: Row(
          children: [
            Icon(icon, size: 22, color: color),
            const SizedBox(width: 14),
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: isDestructive ? FontWeight.w600 : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.delete_forever_outlined, color: Color(0xFFEF4444), size: 28),
            const SizedBox(width: 8),
            Text(isProduct ? 'Delete Product' : 'Delete Service'),
          ],
        ),
        content: Text(
          "Are you sure you want to delete '$name'? This action cannot be undone.",
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              Get.back();
              final businessCtrl = Get.find<BusinessController>();
              final bId = businessId ?? (isProduct ? product?.businessId : service?.businessId);
              bool success = false;
              if (isProduct && product?.id != null) {
                success = await businessCtrl.deleteProduct(product!.id!, businessId: bId);
              } else if (!isProduct && service?.id != null) {
                success = await businessCtrl.deleteService(service!.id!, businessId: bId);
              }
              if (success) {
                onRefresh?.call();
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
