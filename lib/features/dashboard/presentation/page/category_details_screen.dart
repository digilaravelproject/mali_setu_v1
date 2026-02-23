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
      backgroundColor: Colors.grey[50], // Light background for contrast
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: theme.primaryColor,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              onPressed: () => Get.back(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                category.name?.toTitleCase() ?? "category_details".tr,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              centerTitle: false,
              background: Stack(
                fit: StackFit.expand,
                children: [
                  CustomImageView(
                    url: category.photo != null && category.photo!.isNotEmpty
                        ? category.photo
                        : "https://cdn-icons-png.freepik.com/512/10416/10416308.png",
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   if (category.description != null && category.description!.isNotEmpty)
                     Container(
                       padding: const EdgeInsets.all(12),
                       decoration: BoxDecoration(
                         color: Colors.white,
                         borderRadius: BorderRadius.circular(12),
                         boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))
                         ]
                       ),
                       child: Text(
                        category.description!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700], 
                          height: 1.5
                        ),
                      ),
                     ),
                  
                  if (category.isActive == false)
                    Container(
                      margin: const EdgeInsets.only(top: 16),
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
                  
                  const SizedBox(height: 24),
                  
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
                ],
              ),
            ),
          ),
          
          Obx(() {
            if (controller.allBusinesses.isEmpty) {
              return SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(Icons.store_mall_directory_outlined, size: 60, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      Text(
                        "no_business_found".tr,
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
                    child: BusinessListCard(business: controller.allBusinesses[index]),
                  );
                },
                childCount: controller.allBusinesses.length,
              ),
            );
          }),
          
          const SliverPadding(padding: EdgeInsets.only(bottom: 20)),
        ],
      ),
    );
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
