import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../widgets/custom_buttons.dart';
import '../../../../core/helper/string_extensions.dart';
import '../../../Auth/service/auth_service.dart';
import '../controller/business_controller.dart';
import '../../data/model/res_all_business_model.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../../../core/widgets/custom_confirm_dialog.dart';
import '../controller/create_job_controller.dart';

class BusinessDetailScreen extends GetView<BusinessController> {
  const BusinessDetailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Initial fetch
    final argBusiness = Get.arguments as Business;
    // We can use the passed business object for initial display,
    // but we should also fetch fresh details.
    // Let's trigger the fetch.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (argBusiness.id != null) {
        controller.fetchBusinessDetails(argBusiness.id!);
      }
    });

    return Scaffold(
      body: Stack(
        children: [
          DefaultTabController(
            length: 4,
            child: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  floating: false,
                  pinned: true,
                  centerTitle: false,
                  backgroundColor: context.theme.cardColor,
                  elevation: 0,
                  title: Obx(() {
                    final business = controller.selectedBusiness.value ?? argBusiness;
                    return Text(
                      business.businessName ?? 'Business Details',
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 22
                      ),
                    );
                  }),
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
                  child: Obx(() {
                    final business = controller.selectedBusiness.value ?? argBusiness;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                         _buildBusinessHeader(business, context),
                        const SizedBox(height: 16),
                        _buildQuickActions(context),
                        const SizedBox(height: 20),
                        _buildStatsRow(business, context),
                        const SizedBox(height: 20),
                        _buildManageSection(context),
                        const SizedBox(height: 16),
                      ],
                    );
                  }),
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _StickyTabBarDelegate(
                    TabBar(
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
                children: [
                  _buildProductsTab(context),
                  _buildServicesTab(context),
                  _buildJobsTab(context),
                  Obx(() {
                     final business = controller.selectedBusiness.value ?? argBusiness;
                     return _buildBusinessInfoTab(business, context);
                  }),
                ],
              ),
            ),
          ),
          ),
          _buildBottomActionBar(context),
        ],
      ),
    );
  }

  Widget _buildBusinessHeader(Business business, BuildContext context) {
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
                        business.businessName ?? 'Unnamed Business',
                        style: context.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 22,
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
                      style: context.textTheme.bodyMedium,
                    ),
                    const SizedBox(width: 8),
                    if (business.verificationStatus == 'approved') ...[
                      const Icon(Icons.verified, color: Colors.blue, size: 16),
                      const SizedBox(width: 4),
                      const Text(
                        'Verified',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: context.iconColor),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        business.category?.name ?? 'Category',
                        style: context.textTheme.bodyMedium,
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
                const SizedBox(height: 8),
                Row(
                  children: [
                    // Status
                     Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: business.status == 'active' ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              (business.status ?? 'active').toTitleCase(),
                              style: context.textTheme.bodyMedium?.copyWith(
                                color: business.status == 'active' ? Colors.green.shade700 : Colors.grey.shade700,
                              ),
                            ),
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
              child: business.photo != null ? Image.network(
                business.photo!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _buildDetailPlaceholderIcon(),
              ) : _buildDetailPlaceholderIcon(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildQuickActionButton(Icons.call, 'Call', Colors.blue, context),
            const SizedBox(width: 20),
            _buildQuickActionButton(FontAwesomeIcons.whatsapp, 'WhatsApp', Colors.green, context),
            const SizedBox(width: 20),
            _buildQuickActionButton(FontAwesomeIcons.message, 'Enquiry', Colors.grey, context),
            const SizedBox(width: 20),
            _buildQuickActionButton(Icons.directions, 'Direction', Colors.grey, context),
            const SizedBox(width: 20),
            _buildQuickActionButton(Icons.star_border, 'Review', Colors.grey, context),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton(IconData icon, String label, Color color, BuildContext context) {
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
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow(Business business, BuildContext context) {
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
          _buildStatItem('Products', '${business.products?.length ?? 0}', Icons.inventory_2_outlined, context),
          _buildDivider(),
          _buildStatItem('Services', '${business.services?.length ?? 0}', Icons.room_service_outlined, context),
          _buildDivider(),
          _buildStatItem('Jobs', '0', Icons.work_outline, context),
          _buildDivider(),
          _buildStatItem('Value', '0', Icons.currency_rupee, context),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: context.iconColor, size: 22),
        const SizedBox(height: 8),
        Text(
            value,
            style: context.textTheme.titleMedium
        ),
        const SizedBox(height: 4),
        Text(label, style: context.textTheme.bodyMedium),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(height: 50, width: 1, color: Colors.grey[400]);
  }

  Widget _buildManageSection(BuildContext context) {
    // Determine if the current user is the owner
    final authService = Get.find<AuthService>();
    final currentUser = authService.currentUser.value;
    final business = controller.selectedBusiness.value ?? Get.arguments as Business;
    
    // If user is not logged in or doesn't match owner ID, hide section
    if (currentUser?.id != business.userId) {
       return const SizedBox.shrink();
    }

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
                    Get.toNamed(AppRoutes.addProduct, arguments: business.id);
                  },
                  child: _buildActionButton('Add Product', Icons.add_box_outlined, context),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    Get.toNamed(AppRoutes.addService, arguments: business.id);
                  },
                  child: _buildActionButton('Add Service', Icons.add_circle_outline, context),
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
                    child: _buildActionButton('Create Job', Icons.work_outline, context)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, BuildContext context) {
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
  }
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
  
  Widget _buildBottomActionBar(BuildContext context) {
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

  Widget _buildProductsTab(BuildContext context) {
    return Obx(() {
        if (controller.isDetailsLoading.isTrue) {
             return _buildShimmerList(context);
        }
        if (controller.businessProducts.isEmpty) {
            return const Center(child: Text("No Products Found"));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.businessProducts.length,
          itemBuilder: (context, index) {
            final product = controller.businessProducts[index];
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
                          child: product.imagePath != null 
                             ? ClipRRect(
                                 borderRadius: BorderRadius.circular(10),
                                 child: Image.network(product.imagePath!, fit: BoxFit.cover, errorBuilder: (c,e,s) => Icon(Icons.shopping_bag_outlined, color: context.theme.primaryColor))
                               )
                             : Icon(
                            Icons.shopping_bag_outlined,
                            color: context.theme.primaryColor,
                          ),
                        ),
                        SizedBox(width: 10,),
                        Expanded(
                            child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name ?? 'Unknown Product',
                              style: context.textTheme.titleLarge,
                              maxLines: 1, overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '₹${product.cost ?? '0.00'}',
                              style: context.textTheme.titleMedium?.copyWith(color: context.theme.primaryColor),
                            ),
                          ],)
                        )
                      ],
                    ),
                    if (product.description != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 10,top: 10),
                      child: Text(product.description!, style: context.textTheme.bodyMedium, maxLines: 2, overflow: TextOverflow.ellipsis,),
                    ),
                    // Padding(
                    //   padding: const EdgeInsets.symmetric(horizontal: 15),
                    //   child: Align(
                    //       alignment: Alignment.centerRight,
                    //       child: Text("4 nov 2025",style: context.textTheme.titleSmall,)),
                    // ),
                  ],
                ),
              ),
            );
          },
        );
    });
  }

  Widget _buildServicesTab(BuildContext context) {
    return Obx(() {
        if (controller.isDetailsLoading.isTrue) {
             return _buildShimmerList(context);
        }
        if (controller.businessServices.isEmpty) {
            return const Center(child: Text("No Services Found"));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.businessServices.length,
          itemBuilder: (context, index) {
            final service = controller.businessServices[index];
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
                           child: service.imagePath != null 
                             ? ClipRRect(
                                 borderRadius: BorderRadius.circular(10),
                                 child: Image.network(service.imagePath!, fit: BoxFit.cover, errorBuilder: (c,e,s) => Icon(Icons.medical_services, color: context.theme.primaryColor))
                               )
                          : Icon(
                            Icons.medical_services,
                            color: context.theme.primaryColor,
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              service.name ?? 'Unknown Service',
                              style: context.textTheme.titleLarge,
                               maxLines: 1, overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '₹${service.cost ?? '0.00'}',
                              style: context.textTheme.titleMedium?.copyWith(color: context.theme.primaryColor),
                            ),
                          ],))
                      ],
                    ),
                    if (service.description != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 10,top: 10),
                      child: Text(service.description!,style: context.textTheme.bodyMedium, maxLines: 2, overflow: TextOverflow.ellipsis,),
                    ),
                    // Padding(
                    //   padding: const EdgeInsets.symmetric(horizontal: 15),
                    //   child: Align(
                    //       alignment: Alignment.centerRight,
                    //       child: Text("4 nov 2025",style: context.textTheme.titleSmall,)),
                    // ),
                  ],
                ),
              ),
            );
          },
        );
    });
  }

  Widget _buildJobsTab(BuildContext context) {
    return Obx(() {
      if (controller.isDetailsLoading.isTrue) {
        return _buildShimmerList(context);
      }
      if (controller.businessJobs.isEmpty) {
         return Center(
           child: SingleChildScrollView(
             padding: const EdgeInsets.all(32.0),
             child: Column(
               mainAxisAlignment: MainAxisAlignment.center,
               mainAxisSize: MainAxisSize.min,
               children: [
                 Icon(Icons.work_off_outlined, size: 64, color: context.theme.disabledColor),
                 const SizedBox(height: 16),
                 Text("No jobs posted yet", style: context.textTheme.titleMedium),
               ],
             ),
           ),
         );
      }

      return ListView(
        padding: const EdgeInsets.all(16),
        children: [

          Row(
            children: [
              Expanded(
                child: CustomButton(
                  title: "Job Analytics",
                  height: 40,
                  borderRadius: 12,
                  onPressed: () {
                    Get.toNamed(AppRoutes.jobAnalytics);
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomButton(
                  title: "Applied Jobs",
                  height: 40,
                  borderRadius: 12,
                  onPressed: () {
                    Get.toNamed(AppRoutes.appliedJobList);
                  },
                ),
              ),
            ],
          ),


          const SizedBox(height: 16),
          ...controller.businessJobs.map((job) {
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
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        job.title ?? 'No Title',
                                        style: context.textTheme.titleLarge,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    _buildJobStatusBadge(job, context),
                                  ],
                                ),
                                Text(
                                  job.salaryRange ?? 'Salary not specified',
                                  style: context.textTheme.titleMedium
                                      ?.copyWith(color: context.theme.primaryColor),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10, top: 10),
                        child: Text(
                          job.description ?? '',
                          style: context.textTheme.bodyMedium,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Icon(Icons.location_on,
                              size: 16, color: context.theme.primaryColor),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              job.location ?? 'Unknown',
                              style: context.textTheme.titleSmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.business_rounded,
                              size: 16, color: context.theme.primaryColor),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              job.jobType ?? 'Not specified',
                              style: context.textTheme.titleSmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.alarm,
                              size: 16, color: context.theme.primaryColor),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              job.employmentType ?? 'Full Time',
                              style: context.textTheme.titleSmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.business_center,
                              size: 16, color: context.theme.primaryColor),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              job.status?.toUpperCase() ?? 'PENDING',
                              style: context.textTheme.titleSmall
                                  ?.copyWith(color: context.theme.primaryColor),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      if (job.status == 'pending')
                         CustomButton(
                           title: "Waiting for Approval",
                           backgroundColor: Colors.orange,
                           borderRadius: 12,
                           height: 40,
                           onPressed: () {},
                         ),
                      const SizedBox(height: 10),
                      CustomButton(
                        backgroundColor: context.theme.primaryColor,
                        title: "View Details",
                        borderRadius: 12,
                        height: 40,
                        onPressed: () {
                          Get.toNamed(AppRoutes.jobDetails, arguments: job);
                        },
                      ),
                    ],
                  ),
                ),
              );
          }),
        ],
      );
    });
  }

  Widget _buildBusinessInfoTab(Business business, BuildContext context) {
    if (controller.isDetailsLoading.isTrue) {
       return _buildShimmerInfo(context);
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard('Business Details', [
            _buildInfoRow(Icons.business, 'Name', business.businessName ?? 'N/A', context),
            _buildInfoRow(Icons.category, 'Category', business.category?.name ?? 'N/A', context),
            _buildInfoRow(Icons.verified, 'Verification Status', (business.verificationStatus ?? 'pending').toTitleCase(), context, isGreen: business.verificationStatus == 'approved'),
            _buildInfoRow(Icons.stacked_bar_chart_sharp, 'Business Status', (business.status ?? 'active').toTitleCase(), context),
            _buildInfoRow(Icons.description, 'Description', business.description ?? 'No description available', context, maxLines: 5),
          ], context),
          const SizedBox(height: 16),
          _buildInfoCard('Contact Information', [
            _buildInfoRow(Icons.phone, 'Phone', business.contactPhone ?? 'N/A', context),
            _buildInfoRow(Icons.email, 'Email', business.contactEmail ?? 'N/A', context),
            _buildInfoRow(Icons.language, 'Website', business.website ?? 'N/A', context),
          ], context),
          const SizedBox(height: 16),
          _buildInfoCard('Additional Information', [
            _buildInfoRow(Icons.calendar_today, 'Created At', business.createdAt != null ? business.createdAt!.split('T')[0] : 'N/A', context),
             _buildInfoRow(Icons.update, 'Last Updated', business.updatedAt != null ? business.updatedAt!.split('T')[0] : 'N/A', context),
          ], context),
          const SizedBox(height: 30),
          SizedBox(height: 16),
          _buildInfoCard('Additional Information', [
            _buildInfoRow(Icons.inventory, 'Total Products', '${business.products?.length ?? 0}', context),
            _buildInfoRow(Icons.room_service, 'Total Services', '${business.services?.length ?? 0}', context),
            _buildInfoRow(Icons.work, 'Active Jobs', '0', context),
          ], context),
        ],
      ),
    );
  }

  Widget _buildDetailPlaceholderIcon() {
    return Container(
      color: Colors.grey[200],
      child: const Icon(
        Icons.business,
        size: 40,
        color: Colors.grey,
      ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children, BuildContext context) {
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
      String value,
      BuildContext context, {
        bool isGreen = false,
        int? maxLines,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: context.iconColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: context.textTheme.bodyMedium,
                ),
                 const SizedBox(height: 2),
                 Text(
                    value,
                    style: context.textTheme.titleSmall?.copyWith(color: isGreen ? Colors.green : context.iconColor),
                    maxLines: maxLines,
                    overflow: maxLines != null ? TextOverflow.ellipsis : null,
                  ),
              ],
            ),
          ),
          // Expanded(
          //   child: Text(
          //     label,
          //     style: context.textTheme.bodyMedium,
          //   ),
          // ),
          // Text(
          //     value,
          //     style: context.textTheme.titleSmall?.copyWith(color: isGreen ? Colors.green : context.iconColor)
          //   // TextStyle(
          //   //   fontWeight: FontWeight.w600,
          //   //   fontSize: 14,
          //   //   color: isGreen ? Colors.green : Colors.black87,
          //   // ),
          // ),
        ],
      ),
    );
  }
  Widget _buildShimmerList(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                   Container(
                     width: 60, height: 60,
                     decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                   ),
                   const SizedBox(width: 10),
                   Expanded(child: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       Container(height: 14, width: 150, color: Colors.white),
                       const SizedBox(height: 8),
                       Container(height: 12, width: 100, color: Colors.white),
                       const SizedBox(height: 8),
                        Container(height: 10, width: double.infinity, color: Colors.white),
                     ],
                   ))
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildShimmerInfo(BuildContext context) {
     return SingleChildScrollView(
       padding: const EdgeInsets.all(16),
       child: Shimmer.fromColors(
          baseColor: Colors.purple.shade900.withOpacity(0.1),
          highlightColor: Colors.purple.shade900.withOpacity(0.05),
          child: Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               Container(height: 200, width: double.infinity, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12))),
               const SizedBox(height: 16),
               Container(height: 150, width: double.infinity, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12))),
             ],
          ),
       ),
     );
  }

  Widget _buildJobStatusBadge(Job job, BuildContext context) {
    final bool isActive = job.isActive ?? false;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: isActive ? Colors.green : Colors.red, width: 0.5),
      ),
      child: Text(
        isActive ? "Active" : "Inactive",
        style: context.textTheme.bodySmall?.copyWith(
          color: isActive ? Colors.green : Colors.red,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }

  void _handleToggleJobStatus(Job job) {
    if (job.id == null) return;
    final bool currentlyActive = job.isActive ?? false;
    CustomConfirmDialog.show(
      title: currentlyActive ? "Deactivate Job" : "Activate Job",
      message: currentlyActive 
          ? "Are you sure you want to deactivate this job posting? It will no longer be visible to applicants."
          : "Are you sure you want to activate this job posting? It will become visible to applicants.",
      confirmText: currentlyActive ? "Deactivate" : "Activate",
      confirmColor: currentlyActive ? Colors.orange : Colors.green,
      icon: currentlyActive ? Icons.visibility_off_outlined : Icons.visibility_outlined,
      onConfirm: () {
        controller.toggleJobStatus(job.id!);
      },
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
}