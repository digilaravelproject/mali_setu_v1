import 'package:edu_cluezer/core/constent/app_constants.dart';
import 'package:edu_cluezer/core/styles/app_colors.dart';
import 'package:edu_cluezer/features/business/presentation/page/single_business_details.dart';
import 'package:edu_cluezer/widgets/custom_scaffold.dart';
import 'package:edu_cluezer/core/helper/string_extensions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import 'package:edu_cluezer/common/widgets/bg_gradient_border.dart';
import 'package:edu_cluezer/core/routes/app_routes.dart';
import 'package:edu_cluezer/widgets/custom_buttons.dart';
import 'package:edu_cluezer/features/business/presentation/controller/business_controller.dart';
import 'package:edu_cluezer/features/business/data/model/res_all_business_model.dart' as model;
import 'package:edu_cluezer/features/business/presentation/page/add_product_screen.dart';
import 'package:edu_cluezer/core/widgets/shimmer_loading.dart';

import '../../../../core/constent/api_constants.dart';


class BusinessScreen extends GetView<BusinessController> {
  const BusinessScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final topPadding = MediaQuery.of(context).padding.top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.grey[50],
        body: Obx(() {

          if (controller.isLoading.value && controller.businesses.isEmpty && controller.myBusiness.value == null) {
            return _buildShimmerLoading(context);
          }

          return RefreshIndicator(
            onRefresh: () => controller.fetchAllBusinesses(isRefresh: true),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
              slivers: [
              SliverAppBar(
                expandedHeight: 50 + topPadding,
                toolbarHeight: 50 + topPadding,
                pinned: false,
                floating: true,
                backgroundColor: theme.scaffoldBackgroundColor,
                elevation: 0,
                automaticallyImplyLeading: false,
                flexibleSpace: FlexibleSpaceBar(
                  background: Padding(
                    padding: EdgeInsets.only(top: topPadding, left: 16, right: 16),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'business_dashboard'.tr,
                        style: context.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ),
                centerTitle: false,
              ),
            
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (controller.myBusiness.value != null)
                      GestureDetector(
                        onTap: () {
                          Get.toNamed(AppRoutes.myBusiness);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                theme.primaryColor,
                                theme.primaryColor.withOpacity(0.8),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: theme.primaryColor.withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: const Icon(
                                      Icons.business_center_rounded,
                                      color: Colors.white,
                                      size: 32,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'my_business'.tr,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          'manage_business'.tr,
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(0.8),
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                       color: Colors.white.withOpacity(0.1),
                                       shape: BoxShape.circle
                                    ),
                                    child: const Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.white.withOpacity(0.1))
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            controller.myBusiness.value?.businessName ?? '',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            controller.myBusiness.value?.category?.name ?? 'business_category'.tr,
                                            style: TextStyle(
                                              color: Colors.white.withOpacity(0.7),
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      GestureDetector(
                        onTap: () {
                          Get.toNamed(AppRoutes.regBusiness);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                theme.primaryColor,
                                theme.primaryColor.withOpacity(0.8),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: theme.primaryColor.withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: const Icon(
                                      Icons.add_business_rounded,
                                      color: Colors.white,
                                      size: 32,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'register_business'.tr,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          'start_digital_journey'.tr,
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(0.8),
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                       color: Colors.white.withOpacity(0.1),
                                       shape: BoxShape.circle
                                    ),
                                    child: const Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Center(
                                  child: Text(
                                    'register_now'.tr,
                                    style: TextStyle(
                                      color: theme.primaryColor,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    
                    const SizedBox(height: 32),

                    // Header with View All
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'featured_businesses'.tr,
                          style: context.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: Colors.black87,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Get.to(() => const AllBusinessesScreen());
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: theme.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20)
                            ),
                            child: Row(
                              children: [
                                Text(
                                  'view_all'.tr,
                                  style: TextStyle(
                                    color: theme.primaryColor,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  color: theme.primaryColor,
                                  size: 16,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                 (context, index) {
                   return Padding(
                     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                     child: BusinessListCard(business: controller.businesses[index]),
                   );
                 },
                 childCount: controller.businesses.length > 10 ? 10 : controller.businesses.length,
               ),
             ),
             // Show pagination info if there are more businesses
             SliverToBoxAdapter(
               child: controller.businesses.length > 10 || controller.hasNextPage.value
                 ? Container(
                     margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                     padding: const EdgeInsets.all(12),
                     decoration: BoxDecoration(
                       color: Colors.blue.withOpacity(0.1),
                       borderRadius: BorderRadius.circular(12),
                       border: Border.all(color: Colors.blue.withOpacity(0.2)),
                     ),
                     child: Row(
                       children: [
                         Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                         const SizedBox(width: 8),
                         Expanded(
                           child: Text(
                             controller.businesses.length > 10 
                               ? "Showing first 10 businesses. Tap 'View All' to see all ${controller.businesses.length} businesses."
                               : "Total ${controller.businesses.length} businesses available.",
                             style: TextStyle(
                               color: Colors.blue[700],
                               fontSize: 13,
                               fontWeight: FontWeight.w500,
                             ),
                           ),
                         ),
                       ],
                     ),
                   )
                 : const SizedBox.shrink()
               
             ),
              const SliverPadding(padding: EdgeInsets.only(bottom: 120)),
            ],
          ),
          );
        }),
      ),
    );
  }
}

// All Businesses Screen
class AllBusinessesScreen extends GetWidget<BusinessController> {
  const AllBusinessesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Clear search text when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.onSearchCleared();
    });
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        automaticallyImplyLeading: true, // Show back button
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: Get.iconColor),
          onPressed: () {
            controller.onSearchCleared();
            Get.back();
          },
        ),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: false,
        titleSpacing: 0, 
        title: Text(
          "all_businesses".tr,
          style: context.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        actions: [
          Obx(() => controller.hasNextPage.value 
            ? IconButton(
                icon: const Icon(Icons.info_outline, color: Colors.white),
                onPressed: () {
                  Get.snackbar(
                    "Pagination Info",
                    "Page ${controller.currentPage.value} of ${controller.totalPages.value}",
                    backgroundColor: Colors.white,
                    colorText: Colors.black87,
                  );
                },
              )
            : const SizedBox.shrink()
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            height: 50,
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.black.withOpacity(0.8), width: 1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(width: 12),
                Obx(() => controller.isSearching.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.search, color: Colors.black54, size: 20)),
                Expanded(
                  child: TextField(
                    controller: controller.searchController,
                    onChanged: (value) {
                      controller.onSearchChanged(value);
                    },
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    textAlignVertical: TextAlignVertical.center,
                    decoration: InputDecoration(
                      hintText: "search_your_business".tr,
                      hintStyle: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 15),
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      suffixIcon: Obx(() => controller.searchText.value.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: Colors.grey, size: 20),
                              onPressed: controller.onSearchCleared,
                            )
                          : const SizedBox.shrink()),
                    ),
                  ),
                ),
                Container(
                  width: 1,
                  height: 20,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  color: Colors.black.withOpacity(0.15),
                ),
                Obx(() => GestureDetector(
                  onTap: controller.isListening.value 
                      ? controller.stopListening 
                      : controller.startListening,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: Icon(
                      controller.isListening.value ? Icons.mic : Icons.mic_none,
                      color: controller.isListening.value ? Colors.red : Get.theme.primaryColor,
                      size: 22,
                    ),
                  ),
                )),
              ],
            ),
          ),

          // Advanced Filter Section
          Obx(() => AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: controller.isFilterVisible.value ? null : 0,
            child: controller.isFilterVisible.value 
              ? Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildFilterField(
                        controller: controller.filterCityCtrl,
                        label: 'search'.tr,
                        icon: Icons.search,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: controller.clearFilters,
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: Text('clear_all'.tr),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: controller.searchBusinessWithFilters,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                backgroundColor: Get.theme.primaryColor,
                                foregroundColor: Colors.white,
                              ),
                              child: Text('search'.tr),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              : const SizedBox.shrink(),
          )),
          
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.businesses.isEmpty) {
                return _buildShimmerLoading(context);
              }

              final filteredList = controller.filteredBusinesses;
              final hasNext = controller.hasNextPage.value;
              final isLoadMore = controller.isLoadingMore.value;
              final currentPg = controller.currentPage.value;

              if (filteredList.isEmpty) {
                return RefreshIndicator(
                  onRefresh: () => controller.fetchAllBusinesses(isRefresh: true),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: SizedBox(
                      height: 400,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off_rounded, size: 64, color: Colors.grey[300]),
                            const SizedBox(height: 16),
                            Text(
                              "no_businesses_found".tr,
                              style: TextStyle(color: Colors.grey[600], fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }
              
              return RefreshIndicator(
                onRefresh: () => controller.fetchAllBusinesses(isRefresh: true),
                child: NotificationListener<ScrollNotification>(
                  onNotification: (ScrollNotification scrollInfo) {
                    if (controller.searchText.isEmpty && scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent * 0.8) {
                      controller.loadMoreBusinesses();
                    }
                    return false;
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    physics: const BouncingScrollPhysics(),
                    itemCount: filteredList.length +
                        ((hasNext && controller.searchText.isEmpty) ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index < filteredList.length) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: BusinessListCard(
                            business: filteredList[index],
                          ),
                        );
                      }

                      if (isLoadMore) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      if (hasNext) {
                        return Padding(
                          padding: const EdgeInsets.all(16),
                          child: Center(
                            child: ElevatedButton(
                              onPressed: controller.loadMoreBusinesses,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text("Load More (Page ${currentPg + 1})"),
                            ),
                          ),
                        );
                      }

                      return Padding(
                        padding: const EdgeInsets.all(16),
                        child: Center(
                          child: Text(
                            "All businesses loaded",
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: label,
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
          prefixIcon: Icon(icon, color: Colors.grey[600], size: 18),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
      ),
    );
  }
}

class BusinessListCard extends StatelessWidget {
  final model.Business business;

  const BusinessListCard({Key? key, required this.business}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // String address = [
    //    business.user?.city,
    //    business.user?.district,
    // ].where((e) => e != null && e.isNotEmpty).join(", ");
    String address = [
      business.state,
      business.district,
      business.city,
      business.pincode,
    ]
        .where((e) => e != null && e.trim().isNotEmpty)
        .join(", ");

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
             Get.to(() => const BusinessDetailScreen(), arguments: business);
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Business Icon / Initial
                /*Container(
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
                ),*/


                Container(
                  height: 60,
                  width: 60,
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: theme.primaryColor.withOpacity(0.1)),
                    image: business.photo != null && business.photo!.isNotEmpty
                        ? DecorationImage(
                      image: NetworkImage(ApiConstants.imageBaseUrl+business.photo!),
                      fit: BoxFit.cover,
                    )
                        : null, // agar image null ho to background image nahi lagegi
                  ),
                  child: business.photo == null || business.photo!.isEmpty
                      ? Center(
                    child: Icon(
                      Icons.store_rounded,
                      size: 30,
                      color: theme.primaryColor,
                    ),
                  )
                      : null, // agar image hai to icon nahi dikhana
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
                              business.businessName ?? "Business Name",
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
                               color: business.verificationStatus == 'active' ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                               borderRadius: BorderRadius.circular(8)
                             ),
                             child: Text(
                               (business.verificationStatus ?? "Unknown").toUpperCase(),
                               style: TextStyle(
                                 fontSize: 10,
                                 fontWeight: FontWeight.bold,
                                 color: business.verificationStatus == 'active' ? Colors.green : Colors.grey,
                               ),
                             ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 6),
                      
                     /* Row(
                        children: [
                          Icon(CupertinoIcons.location_solid, size: 14, color: Colors.grey[400]),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              address.isNotEmpty ? address : "Location not available",
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
                      ),*/



                      if (address.isNotEmpty)
                        Row(
                          children: [
                            Icon(
                              CupertinoIcons.location_solid,
                              size: 14,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                address,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w400,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      
                      const SizedBox(height: 10),

                      Text("${(business.KMfromuser ?? 0).toStringAsFixed(2)} Km ",style: TextStyle(color: AppColors.black,fontWeight: FontWeight.bold),),
                      const SizedBox(height: 5),

                      Container(height: 1, color: Colors.grey[100]),

                      const SizedBox(height: 10),
                      
                      Row(
                        children: [
                           _buildStatItem(
                             icon: CupertinoIcons.cube_box,
                             label: "${business.products?.length ?? 0} Products",
                             color: Colors.blueAccent
                           ),
                           const SizedBox(width: 16),
                           _buildStatItem(
                             icon: CupertinoIcons.wrench,
                             label: "${business.services?.length ?? 0} Services",
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






/*class BusinessDetailScreen extends StatefulWidget {
  const BusinessDetailScreen({Key? key}) : super(key: key);

  @override
  State<BusinessDetailScreen> createState() => _BusinessDetailScreenState();
}

class _BusinessDetailScreenState extends State<BusinessDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  bool _isPinned = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.offset > 10 && !_isPinned) {
      setState(() => _isPinned = true);
    } else if (_scrollController.offset <= 10 && _isPinned) {
      setState(() => _isPinned = false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          NestedScrollView(
            controller: _scrollController,
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  floating: false,
                  pinned: true,
                  centerTitle: false,
                  backgroundColor: context.theme.cardColor,
                  elevation: 0,
                  title: _isPinned
                      ? Text(
                          'Tech Solutions Pvt Ltd',
                          style: context.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            // style: TextStyle(
                            //   color: Colors.black87,
                            //   fontSize: 16,
                            //   fontWeight: FontWeight.w600,
                          ),
                        )
                      : null,
                  leading: InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    child: Icon(
                      Icons.arrow_back_ios,
                      color: context.iconColor,
                      size: 18,
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       const SizedBox(height: 8),
                      _buildBusinessHeader(),
                      const SizedBox(height: 16),
                      _buildQuickActions(),
                      const SizedBox(height: 20),
                      _buildStatsRow(),
                      const SizedBox(height: 20),
                      _buildManageSection(),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _StickyTabBarDelegate(
                    TabBar(
                      controller: _tabController,
                      labelColor: context.theme.primaryColor,
                      unselectedLabelColor: Colors.grey[600],
                      indicatorColor: context.theme.primaryColor,
                      indicatorWeight: 3,
                      labelStyle: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                      tabs: const [
                        Tab(text: 'Products'),
                        Tab(text: 'Services'),
                        Tab(text: 'Jobs'),
                        Tab(text: 'Business Info'),
                      ],
                    ),
                  ),
                ),
              ];
            },
            body: Padding(
              padding: const EdgeInsets.only(bottom: 70),
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildProductsTab(),
                  _buildServicesTab(),
                  _buildJobsTab(),
                  _buildBusinessInfoTab(),
                ],
              ),
            ),
          ),
          _buildBottomActionBar(),
        ],
      ),
    );
  }

  Widget _buildBusinessHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.business, size: 20, color: Colors.black87),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Tech Solutions Pvt Ltd',
                        style: context.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 22,
                          // style: TextStyle(
                          //   color: Colors.black87,
                          //   fontSize: 20,
                          //   fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text(
                            '4.4',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 3),
                          Icon(Icons.star, color: Colors.white, size: 12),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '118 Ratings',
                      style: context.textTheme.bodyMedium?.copyWith(
                        // fontWeight: FontWeight.w700,
                        // fontSize: 22,
                        // style: TextStyle(
                        //   color: Colors.grey[700],
                        //   fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.verified, color: Colors.blue, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      'Verified',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: context.iconColor),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Munshi Pulia, Lucknow',
                        style: context.textTheme.bodyMedium,
                        //TextStyle(color: Colors.grey[700], fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.directions_walk,
                      size: 16,
                      color: context.iconColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '6 min',
                      style:context.textTheme.bodyMedium,
                      //TextStyle(color: Colors.grey[700], fontSize: 13),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '500 mts',
                      style: context.textTheme.bodyMedium,
                      //TextStyle(color: Colors.grey[700], fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      'AC Repair & Services',
                      style:context.textTheme.bodyMedium?.copyWith(fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      //TextStyle(color: Colors.grey[700], fontSize: 13),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[600],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '5 Years in Business',
                      style:context.textTheme.bodyMedium?.copyWith(fontSize: 13),
                      //TextStyle(color: Colors.grey[700], fontSize: 13),
                    ),
                  ],
                ),
                // const SizedBox(height: 8),
                // Text(
                //   'Response time: 5 mins',
                //   style: TextStyle(color: Colors.grey[600], fontSize: 12),
                // ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      'Open Now: until 9:00 pm',
                      style: context.textTheme.bodyMedium?.copyWith(fontSize: 15),
                      // TextStyle(
                      //   color: Colors.grey[800],
                      //   fontSize: 13,
                      //   fontWeight: FontWeight.w500,
                      // ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.keyboard_arrow_down,
                      size: 16,
                      color: context.iconColor,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network2(
                'https://via.placeholder.com/80',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[200],
                    child: const Icon(
                      Icons.business,
                      size: 40,
                      color: Colors.grey,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildQuickActionButton(Icons.call, 'Call', Colors.blue),
            const SizedBox(width: 20),
            _buildQuickActionButton(FontAwesomeIcons.whatsapp, 'WhatsApp', Colors.green),
            const SizedBox(width: 20),
            _buildQuickActionButton(FontAwesomeIcons.message, 'Enquiry', Colors.grey,),
            const SizedBox(width: 20),
            _buildQuickActionButton(Icons.directions, 'Direction', Colors.grey),
            const SizedBox(width: 20),
            _buildQuickActionButton(Icons.star_border, 'Review', Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton(IconData icon, String label, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color == Colors.blue
                ? Colors.blue
                : color == Colors.green
                ? Colors.green
                : Colors.grey[200],
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10),
              bottomLeft: Radius.circular(10),
              topRight: Radius.circular(10),
              bottomRight: Radius.circular(10),
            ),
          ),
          child: Icon(
            icon,
            color: color == Colors.grey ? Colors.grey[700] : Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: context.textTheme.titleSmall?.copyWith(
          //  fontWeight: FontWeight.w700,
            //fontSize: 22,
            // style: TextStyle(
            //   fontSize: 12,
            //   color: Colors.grey[800],
            //   fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: context.theme.hoverColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: context.theme.dividerColor)
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Products', '24', Icons.inventory_2_outlined),
          _buildDivider(),
          _buildStatItem('Services', '12', Icons.room_service_outlined),
          _buildDivider(),
          _buildStatItem('Jobs', '8', Icons.work_outline),
          _buildDivider(),
          _buildStatItem('Value', '₹2.5L', Icons.currency_rupee),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: context.iconColor, size: 22),
        const SizedBox(height: 8),
        Text(
          value,
          style: context.textTheme.titleMedium
          // const TextStyle(
          //   color: Colors.black87,
          //   fontSize: 18,
          //   fontWeight: FontWeight.bold,
         // ),
        ),
        const SizedBox(height: 4),
        Text(label, style: context.textTheme.bodyMedium),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(height: 50, width: 1, color: Colors.grey[400]);
  }

  Widget _buildManageSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row(
          //   children: [
          //     Text(
          //       'Manage Business',
          //       style: context.textTheme.titleMedium
          //       // style: TextStyle(
          //       //   color: Colors.black87,
          //       //   fontSize: 16,
          //       //   fontWeight: FontWeight.w600,
          //       //),
          //     ),
          //     const SizedBox(width: 10),
          //     Container(
          //       padding: const EdgeInsets.symmetric(
          //         horizontal: 10,
          //         vertical: 4,
          //       ),
          //       decoration: BoxDecoration(
          //         color: Colors.green,
          //         borderRadius: BorderRadius.circular(12),
          //       ),
          //       child: const Text(
          //         'Approved',
          //         style: TextStyle(
          //           color: Colors.white,
          //           fontSize: 11,
          //           fontWeight: FontWeight.w600,
          //         ),
          //       ),
          //     ),
          //   ],
          // ),
          // const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    Get.toNamed(AppRoutes.addProduct);
                  },
                  child: _buildActionButton('Add Product', Icons.add_box_outlined,),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    Get.toNamed(AppRoutes.addService);
                  },
                  child: _buildActionButton('Add Service', Icons.add_circle_outline,),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: InkWell(
                    onTap: () {
                      if (Get.isRegistered<CreateJobController>()) {
                        Get.find<CreateJobController>().clearFields();
                      }
                      Get.toNamed(AppRoutes.createJob);
                    },
                    child: _buildActionButton('Create Job', Icons.work_outline)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: context.theme.hoverColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 22, color: context.iconColor),
          const SizedBox(height: 4),
          Text(
            label,
            style: context.textTheme.titleSmall
            //const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black87),
          ),
        ],
      ),
    );
    // return ElevatedButton(
    //   onPressed: () {},
    //   style: ElevatedButton.styleFrom(
    //     backgroundColor: context.theme.hoverColor,
    //     foregroundColor: Colors.black87,
    //     elevation: 0,
    //     padding: const EdgeInsets.symmetric(vertical: 12),
    //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    //   ),
    //   child: Column(
    //     children: [
    //       Icon(icon, size: 22),
    //       const SizedBox(height: 4),
    //       Text(
    //         label,
    //         style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
    //       ),
    //     ],
    //   ),
    // );
  }

  Widget _buildBottomActionBar() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.call, size: 18),
                  label: Text('Call Now', style: context.textTheme.titleSmall?.copyWith(color: context.theme.cardColor)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.theme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
              SizedBox(width: 10,),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                //  icon: const Icon(Icons.call, size: 18),
                  label: Text('Enquire Now', style: context.textTheme.titleSmall?.copyWith(color: context.theme.cardColor)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.theme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
              SizedBox(width: 10,),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(FontAwesomeIcons.whatsapp, size: 18),
                  label: Text('WhatsApp', style: context.textTheme.titleSmall?.copyWith(color: context.theme.cardColor)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.theme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 8,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: context.theme.dividerColor),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        color: context.theme.primaryColorLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.shopping_bag_outlined,
                        color: context.theme.primaryColor,
                      ),
                    ),
                    SizedBox(width: 10,),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                      Text(
                        'Paracetamol Tablet',
                        style: context.textTheme.titleLarge,
                      ),
                      Text(
                        '₹${(index + 1) * 1000}',
                        style: context.textTheme.titleMedium?.copyWith(color: context.theme.primaryColor),
                      ),
                    ],)
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10,top: 10),
                  child: Text("Release the pain",style: context.textTheme.bodyMedium,),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Align(
                    alignment: Alignment.centerRight,
                      child: Text("4 nov 2025",style: context.textTheme.titleSmall,)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildServicesTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: context.theme.dividerColor),
          ),
          child:Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        color: context.theme.primaryColorLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.medical_services,
                        color: context.theme.primaryColor,
                      ),
                    ),
                    SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ondemand medicine',
                          style: context.textTheme.titleLarge,
                        ),
                        Text(
                          '₹${(index + 1) * 1000}',
                          style: context.textTheme.titleMedium?.copyWith(color: context.theme.primaryColor),
                        ),
                      ],)
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10,top: 10),
                  child: Text("We get the order from customers and provide the medicine",style: context.textTheme.bodyMedium,),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Align(
                      alignment: Alignment.centerRight,
                      child: Text("4 nov 2025",style: context.textTheme.titleSmall,)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildJobsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: context.theme.dividerColor),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        color: context.theme.primaryColorLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.work_outline,
                        color: context.theme.primaryColor,
                      ),
                    ),
                    SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Shop Cleaner',
                          style: context.textTheme.titleLarge,
                        ),
                        Text(
                          '₹1000 - ₹2000',
                          style: context.textTheme.titleMedium?.copyWith(color: context.theme.primaryColor),
                        ),
                      ],)
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10,top: 10),
                  child: Text("We need the shop cleaner which clean all the shop and stock",style: context.textTheme.bodyMedium,),
                ),
                SizedBox(height: 16,),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: context.theme.primaryColor),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Lucknow',
                        style: context.textTheme.titleSmall,
                        //TextStyle(color: Colors.grey[700], fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 8,),
                Row(
                  children: [
                    Icon(Icons.business_rounded, size: 16, color: context.theme.primaryColor),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'On - Site',
                        style: context.textTheme.titleSmall,
                        //TextStyle(color: Colors.grey[700], fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 8,),
                Row(
                  children: [
                    Icon(Icons.alarm, size: 16, color: context.theme.primaryColor),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Full Time',
                        style: context.textTheme.titleSmall,
                        //TextStyle(color: Colors.grey[700], fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 8,),
                Row(
                  children: [
                    Icon(Icons.business_center, size: 16, color: context.theme.primaryColor),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Application Closed',
                        style: context.textTheme.titleSmall?.copyWith(color: context.theme.primaryColor),
                        //TextStyle(color: Colors.grey[700], fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10,),

                CustomButton(
                  title: "Application Closed",
                  backgroundColor: Colors.orange,
                  borderRadius: 12,
                  height: 40,
                  onPressed: (){

                  },
                ),
                SizedBox(height: 10,),
                CustomButton(
                  backgroundColor: context.theme.primaryColor,
                  title: "View Details",
                  borderRadius: 12,
                  height: 40,
                  onPressed: (){

                  },
                ),

              ],
            ),
          )
        );
      },
    );
  }

  Widget _buildBusinessInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard('Business Details', [
            _buildInfoRow(Icons.business, 'Name', 'Tech Solutions Pvt Ltd'),
            _buildInfoRow(Icons.category, 'Category', 'Technology'),
            _buildInfoRow(Icons.verified, 'Verification Status', 'Approved', isGreen: true),
            _buildInfoRow(Icons.stacked_bar_chart_sharp, 'Business Status', 'Active'),
          ]),
          const SizedBox(height: 16),
          _buildInfoCard('Contact Information', [
            _buildInfoRow(Icons.phone, 'Phone', '+91 98765 43210'),
            _buildInfoRow(Icons.email, 'Email', 'contact@techsolutions.com'),
            _buildInfoRow(Icons.location_on, 'Address', 'Mumbai, Maharashtra'),
          ]),
          const SizedBox(height: 16),
          _buildInfoCard('Additional Information', [
            _buildInfoRow(Icons.inventory, 'Total Products', '24'),
            _buildInfoRow(Icons.room_service, 'Total Services', '12'),
            _buildInfoRow(Icons.work, 'Active Jobs', '8'),
            _buildInfoRow(Icons.currency_rupee, 'Total Value', '₹2,50,000'),
          ]),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: context.theme.dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: context.textTheme.titleMedium?.copyWith(color: context.theme.primaryColor)
              // style: const TextStyle(
              //   fontSize: 16,
              //   fontWeight: FontWeight.bold,
              //   color: Color(0xFF6C63FF),
              // ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    bool isGreen = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: context.iconColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: context.textTheme.bodyMedium,
            ),
          ),
          Text(
            value,
            style: context.textTheme.titleSmall?.copyWith(color: isGreen ? Colors.green : context.iconColor)
            // TextStyle(
            //   fontWeight: FontWeight.w600,
            //   fontSize: 14,
            //   color: isGreen ? Colors.green : Colors.black87,
            // ),
          ),
        ],
      ),
    );
  }
}

class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _StickyTabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: context.theme.primaryColorLight, child: tabBar);
  }

  @override
  bool shouldRebuild(_StickyTabBarDelegate oldDelegate) {
    return false;
  }
}*/

Widget _buildShimmerLoading(BuildContext context) {
  return SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // My Business Shimmer
        ShimmerLoading.rounded(height: 160),
        const SizedBox(height: 32),
        
        // Featured Header Shimmer
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ShimmerLoading.rounded(height: 24, width: 200),
            ShimmerLoading.rounded(height: 20, width: 80),
          ],
        ),
        const SizedBox(height: 16),
        
        // Business List Shimmer
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 4,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: ShimmerLoading.rounded(height: 100),
            );
          },
        ),
      ],
    ),
  );
}
