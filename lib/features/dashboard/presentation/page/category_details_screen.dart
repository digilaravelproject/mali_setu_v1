import 'package:edu_cluezer/features/dashboard/data/model/res_category_business_model.dart' hide Category, User;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:edu_cluezer/widgets/custom_image_view.dart';
import 'package:edu_cluezer/features/business/data/model/res_all_business_model.dart';
import 'package:flutter/cupertino.dart';

import '../../../../core/helper/string_extensions.dart';
import '../../../business/presentation/page/business_page.dart';
import '../../../business/presentation/page/single_business_details.dart';
import '../../../../core/routes/app_routes.dart';
import '../controller/cat_business_controller.dart';

class CategoryDetailsScreen extends GetWidget<CatBusinessController> {
  const CategoryDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Category category = Get.arguments;
    final theme = context.theme;

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: theme.primaryColor,
            elevation: 0,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                onPressed: () => Get.back(),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text(
                category.name?.toTitleCase() ?? "",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.primaryColor,
                      theme.primaryColor.withOpacity(0.8),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -30,
                      top: -30,
                      child: TweenAnimationBuilder(
                        duration: const Duration(seconds: 3),
                        tween: Tween<double>(begin: 0, end: 1),
                        builder: (context, double value, child) {
                          return Transform.rotate(
                            angle: value * 6.28,
                            child: child,
                          );
                        },
                        child: Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: -50,
                      bottom: -50,
                      child: Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.05),
                        ),
                      ),
                    ),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 40),
                        child: TweenAnimationBuilder(
                          duration: const Duration(milliseconds: 800),
                          tween: Tween<double>(begin: 0, end: 1),
                          builder: (context, double value, child) {
                            return Transform.scale(
                              scale: value,
                              child: Opacity(
                                opacity: value,
                                child: child,
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Icon(
                              _getCategoryIcon(category.name),
                              size: 50,
                              color: theme.primaryColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (category.isActive == false)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                         color: Colors.red.withOpacity(0.1),
                         borderRadius: BorderRadius.circular(12),
                         border: Border.all(color: Colors.red.withOpacity(0.3))
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, color: Colors.red, size: 20),
                          const SizedBox(width: 8),
                           Expanded(
                            child: Text(
                              "category_inactive".tr,
                              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  Row(
                    children: [
                      Container(
                        height: 20, 
                        width: 4, 
                        decoration: BoxDecoration(
                          color: theme.primaryColor,
                          borderRadius: BorderRadius.circular(2)
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "related_businesses".tr,
                        style: context.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Search Bar
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: TextField(
                      controller: controller.searchController,
                      onChanged: (value) => controller.searchBusinesses(value),
                      decoration: InputDecoration(
                        hintText: 'Search by name, location...',
                        hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
                        prefixIcon: Icon(Icons.search_rounded, color: Colors.grey[500], size: 22),
                        suffixIcon: Obx(() => controller.searchQuery.value.isNotEmpty
                            ? GestureDetector(
                                onTap: () => controller.clearSearch(),
                                child: Icon(Icons.clear_rounded, color: Colors.grey[500], size: 20),
                              )
                            : const SizedBox.shrink()),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 0),
                      ),
                      style: const TextStyle(color: Colors.black87, fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          
          Obx(() {
            if (controller.isLoading.value) {
              return const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator()),
                ),
              );
            }

            if (controller.filteredBusinesses.isEmpty) {
              return SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(Icons.store_mall_directory_outlined, size: 60, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      Text(
                        controller.searchQuery.value.isNotEmpty 
                            ? "No businesses found for your search"
                            : "no_business_found".tr,
                        style: TextStyle(color: Colors.grey[500], fontSize: 16),
                      ),
                    ],
                  ),
                ),
              );
            }

            return SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: BusinessListCard(business: controller.filteredBusinesses[index]),
                  );
                },
                childCount: controller.filteredBusinesses.length,
              ),
            );
          }),
          
          const SliverPadding(padding: EdgeInsets.only(bottom: 20)),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String? categoryName) {
    if (categoryName == null) return Icons.category;
    
    final name = categoryName.toLowerCase();
    
    if (name.contains('health')) return Icons.local_hospital;
    if (name.contains('food')) return Icons.restaurant;
    if (name.contains('repair') || name.contains('service')) return Icons.build;
    if (name.contains('packer') || name.contains('mover')) return Icons.local_shipping;
    if (name.contains('gym')) return Icons.fitness_center;
    if (name.contains('education')) return Icons.school;
    if (name.contains('medical')) return Icons.medical_services;
    if (name.contains('test')) return Icons.science;
    if (name.contains('laundry') || name.contains('laundries')) return Icons.local_laundry_service;
    if (name.contains('fruit')) return Icons.apple;
    
    return Icons.category;
  }
}

class BusinessListCard extends StatelessWidget {
  final CatBusiness business;

  const BusinessListCard({Key? key, required this.business}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    String address = [
      business.user?.city,
      business.user?.address,
    ].where((e) => e != null && e.isNotEmpty).join(", ");

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 4),
            blurRadius: 10,
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () {
            Get.toNamed(
              AppRoutes.businessDetails,
              arguments: Business(
                id: business.id,
                userId: business.userId,
                businessName: business.businessName,
                businessType: business.businessType,
                categoryId: business.categoryId,
                description: business.description,
                contactPhone: business.contactPhone,
                contactEmail: business.contactEmail,
                website: business.website,
                verificationStatus: business.verificationStatus,
                status: business.verificationStatus,
                user: business.user != null
                    ? User(
                        id: business.user!.id,
                        name: business.user!.name,
                        email: business.user!.email,
                        phone: business.user!.phone,
                      )
                    : null,
                category: business.category != null
                    ? Category(
                        id: business.category!.id,
                        name: business.category!.name,
                      )
                    : null,
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Business Icon / Initial
                Container(
                  height: 60,
                  width: 60,
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: theme.primaryColor.withOpacity(0.1)),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.store_rounded,
                      size: 30,
                      color: theme.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              business.businessName ?? "business_name".tr,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                                height: 1.2
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                             margin: const EdgeInsets.only(left: 8),
                             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                             decoration: BoxDecoration(
                               color: business.status == 'active' ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                               borderRadius: BorderRadius.circular(8)
                             ),
                             child: Text(
                               (business.status ?? "Unknown").toUpperCase(),
                               style: TextStyle(
                                 fontSize: 10,
                                 fontWeight: FontWeight.bold,
                                 color: business.status == 'active' ? Colors.green : Colors.grey,
                               ),
                             ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 6),
                      
                      Row(
                        children: [
                          Icon(CupertinoIcons.location_solid, size: 14, color: Colors.grey[400]),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              address.isNotEmpty ? address : "location_na".tr,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w400
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 12),
                      Container(height: 1, color: Colors.grey[100]),
                      const SizedBox(height: 10),
                      
                      Row(
                        children: [
                           _buildStatItem(
                             icon: CupertinoIcons.cube_box,
                             label: "${business.products?.length ?? 0} products".tr,
                             color: Colors.blueAccent
                           ),
                           const SizedBox(width: 16),
                           _buildStatItem(
                             icon: CupertinoIcons.wrench,
                             label: "${business.services?.length ?? 0} services".tr,
                             color: Colors.orangeAccent
                           ),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem({required IconData icon, required String label, required Color color}) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700]
          ),
        )
      ],
    );
  }
}
