import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:edu_cluezer/core/constent/api_constants.dart';
import 'package:edu_cluezer/core/routes/app_routes.dart';
import 'package:edu_cluezer/core/utils/app_assets.dart';
import 'package:edu_cluezer/widgets/custom_image_view.dart';
import 'package:edu_cluezer/features/business/data/model/res_all_business_model.dart';
import 'package:edu_cluezer/features/business/presentation/controller/business_controller.dart';
import 'package:edu_cluezer/features/business/presentation/widget/product_service_action_sheet.dart';
import 'package:edu_cluezer/features/notification/presentation/controller/notification_controller.dart';
import 'package:edu_cluezer/features/Auth/service/auth_service.dart';
import 'package:edu_cluezer/core/widgets/full_screen_image_viewer.dart';

class MyProductsServicesController extends GetxController with GetSingleTickerProviderStateMixin {
  late TabController tabController;
  final searchController = TextEditingController();

  final RxList<Product> products = <Product>[].obs;
  final RxList<Service> services = <Service>[].obs;

  final RxList<Product> filteredProducts = <Product>[].obs;
  final RxList<Service> filteredServices = <Service>[].obs;

  final RxString searchQuery = ''.obs;
  final RxBool isLoading = false.obs;

  Business? business;
  int? businessId;

  bool get isOwner {
    final bCtrl = Get.isRegistered<BusinessController>() ? Get.find<BusinessController>() : null;
    final currentUserId = Get.isRegistered<AuthService>() ? Get.find<AuthService>().currentUser.value?.id : null;

    if (business != null) {
      if (currentUserId != null && business?.userId != null && currentUserId == business!.userId) {
        return true;
      }
      if (bCtrl != null && bCtrl.myBusinesses.any((b) => b.id != null && b.id == business!.id)) {
        return true;
      }
    }
    if (businessId != null && bCtrl != null) {
      if (bCtrl.myBusinesses.any((b) => b.id != null && b.id == businessId)) {
        return true;
      }
    }
    return false;
  }

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    int initialIndex = 0;

    if (args is Map) {
      business = args['business'] as Business?;
      businessId = args['businessId'] as int? ?? business?.id;
      initialIndex = args['initialTab'] as int? ?? 0;
    } else if (args is Business) {
      business = args;
      businessId = business?.id;
    } else if (args is int) {
      businessId = args;
    }

    tabController = TabController(length: 2, vsync: this, initialIndex: initialIndex);
    tabController.addListener(() {
      update();
    });

    searchController.addListener(_onSearchChanged);

    loadData();
  }

  void _onSearchChanged() {
    final query = searchController.text.trim().toLowerCase();
    searchQuery.value = query;

    if (query.isEmpty) {
      filteredProducts.assignAll(products);
      filteredServices.assignAll(services);
    } else {
      filteredProducts.assignAll(
        products.where((p) => (p.name ?? '').toLowerCase().contains(query)),
      );
      filteredServices.assignAll(
        services.where((s) => (s.name ?? '').toLowerCase().contains(query)),
      );
    }
  }

  Future<void> loadData() async {
    isLoading.value = true;
    try {
      final bCtrl = Get.find<BusinessController>();

      // If businessId is not specified, use selectedBusiness or first myBusiness
      if (businessId == null) {
        if (bCtrl.selectedBusiness.value != null) {
          businessId = bCtrl.selectedBusiness.value!.id;
          business = bCtrl.selectedBusiness.value;
        } else if (bCtrl.myBusinesses.isNotEmpty) {
          businessId = bCtrl.myBusinesses.first.id;
          business = bCtrl.myBusinesses.first;
        } else {
          await bCtrl.fetchMyBusinesses();
          if (bCtrl.myBusinesses.isNotEmpty) {
            businessId = bCtrl.myBusinesses.first.id;
            business = bCtrl.myBusinesses.first;
          }
        }
      }

      if (businessId != null) {
        await Future.wait([
          bCtrl.fetchBusinessProducts(businessId!),
          bCtrl.fetchBusinessServices(businessId!),
        ]);

        products.assignAll(bCtrl.businessProducts);
        services.assignAll(bCtrl.businessServices);
      } else if (business != null) {
        products.assignAll(business!.products ?? []);
        services.assignAll(business!.services ?? []);
      }

      _onSearchChanged();
    } catch (e) {
      debugPrint('Error loading products & services: $e');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    tabController.dispose();
    searchController.dispose();
    super.onClose();
  }
}

class MyProductsServicesScreen extends StatelessWidget {
  const MyProductsServicesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MyProductsServicesController());
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
        title: Image.asset(
          AppAssets.getAppLogo(),
          height: 32,
          fit: BoxFit.contain,
        ),
        actions: [
          IconButton(
            onPressed: () => Get.toNamed(AppRoutes.notification),
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.notifications_none_outlined, color: Colors.black87, size: 26),
                if (Get.isRegistered<NotificationController>())
                  Obx(() {
                    final count = Get.find<NotificationController>().unreadCount.value;
                    if (count <= 0) return const SizedBox.shrink();
                    return Positioned(
                      right: -2,
                      top: -2,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Color(0xFFEF4444),
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                        child: Text(
                          '$count',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }),
              ],
            ),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 18, vertical: 6),
            child: Text(
              'My Products & Services',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Colors.black87,
              ),
            ),
          ),

          // Tabs
          Container(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: TabBar(
              controller: controller.tabController,
              labelColor: primaryColor,
              unselectedLabelColor: Colors.grey.shade600,
              labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
              indicatorColor: primaryColor,
              indicatorWeight: 3,
              indicatorSize: TabBarIndicatorSize.tab,
              tabs: const [
                Tab(text: 'Products'),
                Tab(text: 'Services'),
              ],
            ),
          ),

          // Search Field
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 10),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: controller.searchController,
                decoration: InputDecoration(
                  hintText: 'Search products & services...',
                  hintStyle: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                  prefixIcon: Icon(Icons.search, color: Colors.grey.shade500, size: 20),
                  suffixIcon: Obx(() => controller.searchQuery.value.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () => controller.searchController.clear(),
                        )
                      : const SizedBox.shrink()),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),

          // Action Button (+ Add Product or + Add Service) - only for business owner
          if (controller.isOwner)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
              child: AnimatedBuilder(
                animation: controller.tabController,
                builder: (context, _) {
                  final isProductTab = controller.tabController.index == 0;
                  return SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final bId = controller.businessId;
                        final route = isProductTab ? AppRoutes.addProduct : AppRoutes.addService;
                        await Get.toNamed(route, arguments: bId);
                        controller.loadData();
                      },
                      icon: const Icon(Icons.add, color: Colors.white, size: 18),
                      label: Text(
                        isProductTab ? '+ Add Product' : '+ Add Service',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                    ),
                  );
                },
              ),
            ),

          const SizedBox(height: 8),

          // TabBarView List
          Expanded(
            child: TabBarView(
              controller: controller.tabController,
              children: [
                // Products List
                _buildProductsList(context, controller, primaryColor),

                // Services List
                _buildServicesList(context, controller, primaryColor),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsList(
    BuildContext context,
    MyProductsServicesController controller,
    Color primaryColor,
  ) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final items = controller.filteredProducts;
      if (items.isEmpty) {
        return RefreshIndicator(
          onRefresh: controller.loadData,
          child: ListView(
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.15),
              Center(
                child: Column(
                  children: [
                    Icon(Icons.inventory_2_outlined, size: 54, color: Colors.grey.shade300),
                    const SizedBox(height: 12),
                    Text(
                      'No products found',
                      style: TextStyle(fontSize: 16, color: Colors.grey.shade600, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: controller.loadData,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final product = items[index];
            final isActive = product.status?.toLowerCase() != 'inactive' &&
                product.status?.toLowerCase() != 'deactivated';

            return _buildItemCard(
              context: context,
              title: product.name ?? 'Unnamed Product',
              price: product.cost ?? '0',
              imagePath: product.imagePath,
              isActive: isActive,
              primaryColor: primaryColor,
              showMenu: controller.isOwner,
              onTap: () {
                if (product.id != null) {
                  Get.toNamed(AppRoutes.singleProductDetails, arguments: product.id);
                }
              },
              onMenuTap: () {
                ProductServiceActionSheet.show(
                  context,
                  product: product,
                  businessId: controller.businessId ?? product.businessId,
                  onRefresh: controller.loadData,
                );
              },
            );
          },
        ),
      );
    });
  }

  Widget _buildServicesList(
    BuildContext context,
    MyProductsServicesController controller,
    Color primaryColor,
  ) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final items = controller.filteredServices;
      if (items.isEmpty) {
        return RefreshIndicator(
          onRefresh: controller.loadData,
          child: ListView(
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.15),
              Center(
                child: Column(
                  children: [
                    Icon(Icons.design_services_outlined, size: 54, color: Colors.grey.shade300),
                    const SizedBox(height: 12),
                    Text(
                      'No services found',
                      style: TextStyle(fontSize: 16, color: Colors.grey.shade600, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: controller.loadData,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final service = items[index];
            final isActive = service.status?.toLowerCase() != 'inactive' &&
                service.status?.toLowerCase() != 'unavailable';

            return _buildItemCard(
              context: context,
              title: service.name ?? 'Unnamed Service',
              price: service.cost ?? '0',
              imagePath: service.imagePath,
              isActive: isActive,
              primaryColor: primaryColor,
              showMenu: controller.isOwner,
              onTap: () {
                if (service.id != null) {
                  Get.toNamed(AppRoutes.singleServiceDetails, arguments: service.id);
                }
              },
              onMenuTap: () {
                ProductServiceActionSheet.show(
                  context,
                  service: service,
                  businessId: controller.businessId ?? service.businessId,
                  onRefresh: controller.loadData,
                );
              },
            );
          },
        ),
      );
    });
  }

  Widget _buildItemCard({
    required BuildContext context,
    required String title,
    required String price,
    required String? imagePath,
    required bool isActive,
    required Color primaryColor,
    required VoidCallback onTap,
    required VoidCallback onMenuTap,
    bool showMenu = true,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Thumbnail (tap to view full screen)
                GestureDetector(
                  onTap: () {
                    if (imagePath != null && imagePath.isNotEmpty) {
                      final fullUrl = ApiConstants.imageBaseUrl + (imagePath.startsWith('/') ? imagePath : '/$imagePath');
                      Get.to(() => FullScreenImageViewer(
                            imageUrl: fullUrl,
                            tag: 'thumb_${title}_$price',
                          ));
                    }
                  },
                  child: Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: imagePath != null && imagePath.isNotEmpty
                        ? CustomImageView(
                            url: ApiConstants.imageBaseUrl + imagePath,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Icon(
                              Icons.image_outlined,
                              color: primaryColor,
                              size: 24,
                            ),
                          )
                        : Icon(
                            Icons.image_outlined,
                            color: primaryColor,
                            size: 24,
                          ),
                  ),
                ),
              ),
                const SizedBox(width: 14),

                // Title & Price & Badge
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            '₹$price',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
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
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // 3-Dots Button (only shown for owner)
                if (showMenu)
                  IconButton(
                    onPressed: onMenuTap,
                    icon: const Icon(Icons.more_vert, color: Colors.black87, size: 22),
                    splashRadius: 20,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
