import 'package:edu_cluezer/core/constent/api_constants.dart';
import 'package:edu_cluezer/core/constent/app_constants.dart';
import 'package:edu_cluezer/core/network/api_client.dart';
import 'package:edu_cluezer/core/styles/app_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:edu_cluezer/core/routes/app_routes.dart';
import 'package:edu_cluezer/widgets/custom_buttons.dart';
import 'package:edu_cluezer/core/helper/string_extensions.dart';
import 'package:edu_cluezer/features/Auth/service/auth_service.dart';
import 'package:edu_cluezer/features/business/presentation/controller/business_controller.dart';
import 'package:edu_cluezer/features/business/data/model/res_all_business_model.dart';
import 'package:edu_cluezer/core/widgets/shimmer_loading.dart';
import 'package:edu_cluezer/core/widgets/custom_confirm_dialog.dart';
import 'package:edu_cluezer/features/business/presentation/controller/create_job_controller.dart';

class BusinessDetailScreen extends StatefulWidget {
  const BusinessDetailScreen({Key? key}) : super(key: key);

  @override
  State<BusinessDetailScreen> createState() => _BusinessDetailScreenState();
}

class _BusinessDetailScreenState extends State<BusinessDetailScreen> {
  late final BusinessController controller;
  late final Business argBusiness;
  final ScrollController _outerScrollController = ScrollController();
  final RxBool _showTitle = false.obs;

  @override
  void initState() {
    super.initState();
    controller = Get.find<BusinessController>();
    // Store argBusiness once — safe from route argument changes on back navigation
    final args = Get.arguments;
    argBusiness = args is Business ? args : controller.selectedBusiness.value!;
    _outerScrollController.addListener(_onScroll);
  }

  void _onScroll() {
    // Show title when scrolled past ~200px (roughly when header collapses)
    final shouldShow = _outerScrollController.offset > 200;
    if (shouldShow != _showTitle.value) {
      _showTitle.value = shouldShow;
    }
  }

  @override
  void dispose() {
    _outerScrollController.removeListener(_onScroll);
    _outerScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            child: Obx(() {
              final business = controller.selectedBusiness.value ?? argBusiness;
              final authService = Get.find<AuthService>();
              final currentUser = authService.currentUser.value;
              final isOwner = currentUser?.id == business.userId;
              final topPadding = MediaQuery.of(context).padding.top;
              final fixedHeight = 500.0;

              return RefreshIndicator(
                onRefresh: () => controller.fetchBusinessDetails(argBusiness.id!, isRefresh: true),
                color: context.theme.primaryColor,
                backgroundColor: context.theme.scaffoldBackgroundColor,
                child: NestedScrollView(
                controller: _outerScrollController,
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    SliverOverlapAbsorber(
                      handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                      sliver: SliverAppBar(
                        floating: false,
                        pinned: false,
                        centerTitle: false,
                        backgroundColor: context.theme.scaffoldBackgroundColor,
                        elevation: innerBoxIsScrolled ? 4 : 0,
                        shadowColor: Colors.black.withOpacity(0.05),
                    //    expandedHeight: isOwner ? 580 : 460,
                        expandedHeight: fixedHeight + topPadding,
                        forceElevated: innerBoxIsScrolled,
                        title: Obx(() => AnimatedOpacity(
                          duration: const Duration(milliseconds: 200),
                          opacity: _showTitle.value ? 1.0 : 0.0,
                          child: Text(
                            business.businessName?.toTitleCase() ?? '',
                            style: context.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        )),
                        leading: IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
                          onPressed: () => Navigator.of(context).pop(),
                        ),

                        actions: [
                          PopupMenuButton<String>(
                            offset: const Offset(0, 48),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            icon: const Icon(Icons.more_vert, color: Colors.black87, size: 24),
                            onSelected: (value) {
                              if (value == 'refresh') {
                                if (argBusiness.id != null) {
                                  controller.fetchBusinessDetails(argBusiness.id!, isRefresh: true);
                                }
                              } else if (value == 'add_product') {
                                Get.toNamed(AppRoutes.addProduct, arguments: business.id);
                              } else if (value == 'add_service') {
                                Get.toNamed(AppRoutes.addService, arguments: business.id);
                              } else if (value == 'create_job') {
                                Get.toNamed(AppRoutes.createJob, arguments: business.id );
                              } else if (value == 'job_analytics') {
                                Get.toNamed(AppRoutes.jobAnalytics);
                              }
                            },
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 'refresh',
                                child: Row(children: [Icon(Icons.refresh, size: 20, color: context.theme.primaryColor), const SizedBox(width: 12), Text('refresh'.tr)]),
                              ),
                              if (isOwner) ...[
                                PopupMenuItem(
                                  value: 'add_product',
                                  child: Row(children: [Icon(Icons.add_box_outlined, size: 20, color: context.theme.primaryColor), const SizedBox(width: 12), Text('add_product'.tr)]),
                                ),
                                PopupMenuItem(
                                  value: 'add_service',
                                  child: Row(children: [Icon(Icons.add_circle_outline, size: 20, color: context.theme.primaryColor), const SizedBox(width: 12), Text('add_service'.tr)]),
                                ),
                                PopupMenuItem(
                                  value: 'create_job',
                                  child: Row(children: [Icon(Icons.work_outline, size: 20, color: context.theme.primaryColor), const SizedBox(width: 12), Text('create_job'.tr)]),
                                ),
                                PopupMenuItem(
                                  value: 'job_analytics',
                                  child: Row(children: [Icon(Icons.analytics_outlined, size: 20, color: context.theme.primaryColor), const SizedBox(width: 12), Text('job_analytics'.tr)]),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(width: 4),
                        ],
                        flexibleSpace: FlexibleSpaceBar(
                          collapseMode: CollapseMode.pin,
                          background: OverflowBox(
                            alignment: Alignment.topCenter,
                            maxHeight: double.infinity,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(height: MediaQuery.of(context).padding.top + 48),
                                _buildBusinessHeader(business, context),
                                const SizedBox(height: 20),
                                _buildQuickActions(business, context),
                                const SizedBox(height: 12),
                                _buildStatsRow(business, context),
                                const SizedBox(height: 16),
                              ],
                            ),
                          ),
                        ),
                        bottom: PreferredSize(
                          preferredSize: const Size.fromHeight(48),
                          child: Container(
                            decoration: BoxDecoration(
                              color: context.theme.cardColor,
                              border: Border(
                                bottom: BorderSide(color: context.theme.dividerColor, width: 0.5),
                              ),
                            ),
                            child: TabBar(
                              labelColor: context.theme.primaryColor,
                              unselectedLabelColor: Colors.grey[600],
                              indicatorColor: context.theme.primaryColor,
                              indicatorWeight: 2,
                              dividerColor: Colors.transparent,
                              labelStyle: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                              unselectedLabelStyle: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                              tabs: [
                                Tab(text: 'products'.tr),
                                Tab(text: 'services'.tr),
                                Tab(text: 'jobs'.tr),
                                Tab(text: 'info'.tr),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ];
                },
                body: Padding(
                  padding: const EdgeInsets.only(bottom: 70),
                  child: TabBarView(
                    children: [
                      Builder(builder: (context) => _buildProductsTab(context)),
                      Builder(builder: (context) => _buildServicesTab(context)),
                      Builder(builder: (context) => _buildJobsTab(context)),
                      Builder(builder: (context) => _buildBusinessInfoTab(business, context)),
                    ],
                  ),
                ),
              ),
            );
            }),
          ),
          Obx(() {
            final business = controller.selectedBusiness.value ?? argBusiness;
            return _buildBottomActionBar(business, context);
          }),
        ],
      ),
    );
  }

  Widget _buildBusinessHeader(Business business, BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      business.businessName?.toTitleCase() ?? 'unnamed_business'.tr,
                      style: context.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 24,
                        letterSpacing: -0.5,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        // Container(
                        //   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        //   decoration: BoxDecoration(
                        //     color: Colors.green,
                        //     borderRadius: BorderRadius.circular(6),
                        //   ),
                        //   child: Row(
                        //     mainAxisSize: MainAxisSize.min,
                        //     children: const [
                        //       Text(
                        //         '4.4',
                        //         style: TextStyle(
                        //           color: Colors.white,
                        //           fontSize: 12,
                        //           fontWeight: FontWeight.bold,
                        //         ),
                        //       ),
                        //       SizedBox(width: 4),
                        //       Icon(Icons.star, color: Colors.white, size: 12),
                        //     ],
                        //   ),
                        // ),
                        // Text(
                        //   '118 Ratings',
                        //   style: context.textTheme.bodyMedium?.copyWith(
                        //     color: Colors.grey[600],
                        //     fontWeight: FontWeight.w500,
                        //   ),
                        // ),
                        if (business.verificationStatus == 'approved')
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.verified, color: Colors.blue, size: 18),
                              const SizedBox(width: 4),
                              Text(
                                'verified'.tr,
                                style: TextStyle(
                                  color: Colors.blue[700],
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _buildHeaderIconLabel(Icons.category_outlined, business.category?.name?.toTitleCase() ?? 'category'.tr, context),
                    const SizedBox(height: 6),
                    _buildHeaderIconLabel(Icons.info_outline, business.description.toString(), context),
                    const SizedBox(height: 6),
                    _buildHeaderIconLabel(Icons.location_on_outlined, business.state.toString()+', '+business.city.toString()+', '+business.pincode.toString(), context),
                   // const SizedBox(height: 6),
                    // Row(
                    //   children: [
                    //     Text("distance : ",style: TextStyle(fontWeight: FontWeight.bold,color: AppColors.black,fontSize: 16),),
                    //     Text("${business.KMfromuser}",style: TextStyle(fontWeight: FontWeight.bold,color: AppColors.black,fontSize: 16),),
                    //   ],
                    // ),
                  //  _buildHeaderIconLabel(Icons.info_outline, business.description.toString(), context),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.withOpacity(0.2), width: 1.5),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: business.photo != null
                          ? Image.network(
                        ApiConstants.imageBaseUrl+ business.photo!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => _buildDetailPlaceholderIcon(),
                            )
                          : _buildDetailPlaceholderIcon(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: business.verificationStatus == 'active' ? Colors.green.withOpacity(0.12) : Colors.grey.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      (business.verificationStatus ?? 'active').toTitleCase(),
                      style: TextStyle(
                        color: business.verificationStatus == 'active' ? Colors.green[800] : Colors.grey[800],
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildTimingHighlight(business, context),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderIconLabel(IconData icon, String label, BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            label,
            style: context.textTheme.bodyMedium?.copyWith(
              color: Colors.grey[700],
              fontSize: 14,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(Business business, BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: context.theme.dividerColor.withOpacity(0.02),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.theme.dividerColor.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: _buildQuickActionItem(
              icon: Icons.phone_outlined,
              label: 'call'.tr,
              color: Colors.blue,
              onTap: () => controller.launchPhone(business.user!.phone.toString()),
            ),
          ),
          _buildVerticalDivider(context, height: 30),
          Expanded(
            child: _buildQuickActionItem(
              icon: Icons.email_outlined,
              label: 'email'.tr,
              color: Colors.red.shade400,
              onTap: () => controller.launchEmail(business.user!.email.toString()),
            ),
          ),
          _buildVerticalDivider(context, height: 30),
          Expanded(
            child: _buildQuickActionItem(
              icon: FontAwesomeIcons.whatsapp,
              label: 'whatsapp'.tr,
              color: Colors.green,
              onTap: () => controller.launchWhatsApp(business.user!.phone.toString()),
            ),
          ),
        ],
      ),
    );
  }
 
  Widget _buildQuickActionItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
 
  Widget _buildStatsRow(Business business, BuildContext context) {
    return Obx(() {
      // Check if current user is the owner
      final authService = Get.find<AuthService>();
      final currentUser = authService.currentUser.value;
      final b = controller.selectedBusiness.value ?? business;
      final isOwner = currentUser?.id == b.userId;
      
      // If owner, show all jobs count. Otherwise, hide pending jobs from count
      final jobCount = isOwner 
          ? controller.businessJobs.length 
          : controller.businessJobs.where((j) => j.status != 'pending').length;
      
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            Expanded(child: _buildStatItem('products'.tr, '${controller.businessProducts.length}', Icons.shopping_bag_outlined, Colors.orange, context)),
            _buildVerticalDivider(context),
            Expanded(child: _buildStatItem('services'.tr, '${controller.businessServices.length}', Icons.design_services_outlined, Colors.blue, context)),
            _buildVerticalDivider(context),
            Expanded(child: _buildStatItem('jobs'.tr, '$jobCount', Icons.work_outline, Colors.green, context)),
          ],
        ),
      );
    });
  }

  Widget _buildVerticalDivider(BuildContext context, {double height = 32}) {
    return Container(
      height: height,
      width: 1,
      color: context.theme.dividerColor.withOpacity(0.3),
    );
  }
 
  Widget _buildStatItem(String label, String value, IconData icon, Color color, BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.black54,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
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
    final business = controller.selectedBusiness.value ?? argBusiness;
    
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
                  child: _buildActionButton('add_product'.tr, Icons.add_box_outlined, context),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    Get.toNamed(AppRoutes.addService, arguments: business.id);
                  },
                  child: _buildActionButton('add_service'.tr, Icons.add_circle_outline, context),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: InkWell(
                    onTap: () {
                      if (Get.isRegistered<CreateJobController>()) {
                        Get.find<CreateJobController>().clearFields();
                      }
                      Get.toNamed(AppRoutes.createJob,arguments: business.id);
                    },
                    child: _buildActionButton('create_job'.tr, Icons.work_outline, context)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    Get.toNamed(AppRoutes.jobAnalytics);
                  },
                  child: _buildActionButton('job_analytics'.tr, Icons.analytics_outlined, context),
                ),
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
        color: Colors.grey.withOpacity(0.04), // Soft flat tint
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
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
  
  Widget _buildBottomActionBar(Business business, BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
        decoration: BoxDecoration(
          color: context.theme.cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: ElevatedButton.icon(
            onPressed: () {
              controller.launchPhone(business.user!.phone.toString());
            },
            icon: const Icon(Icons.call, size: 20),
            label: Text(
              'call_now'.tr,
              style: context.textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: context.theme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 4,
              shadowColor: context.theme.primaryColor.withOpacity(0.4),
            ),
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
        return CustomScrollView(
          physics: const ClampingScrollPhysics(),
          slivers: [
            SliverOverlapInjector(handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context)),
            SliverFillRemaining(
              child: Center(child: Text('no_products_found'.tr)),
            ),
          ],
        );
      }
      return CustomScrollView(
        physics: const ClampingScrollPhysics(),
        slivers: [
          SliverOverlapInjector(handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context)),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final product = controller.businessProducts[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: context.theme.dividerColor),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: context.theme.primaryColorLight,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: product.imagePath != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(
                                      ApiConstants.imageBaseUrl+product.imagePath!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (c, e, s) => Icon(Icons.shopping_bag_outlined, color: context.theme.primaryColor),
                                    ),
                                  )
                                : Icon(Icons.shopping_bag_outlined, color: context.theme.primaryColor),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.name ?? 'unknown_product'.tr,
                                  style: context.textTheme.titleLarge,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                if (product.cost != null)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: context.theme.primaryColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      '₹${product.cost}',
                                      style: context.textTheme.bodyMedium?.copyWith(
                                        color: context.theme.primaryColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                if (product.description != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 6),
                                    child: Text(
                                      product.description!,
                                      style: context.textTheme.bodyMedium,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                childCount: controller.businessProducts.length,
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildServicesTab(BuildContext context) {
    return Obx(() {
      if (controller.isDetailsLoading.isTrue) {
        return _buildShimmerList(context);
      }
      if (controller.businessServices.isEmpty) {
        return CustomScrollView(
          physics: const ClampingScrollPhysics(),
          slivers: [
            SliverOverlapInjector(handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context)),
            SliverFillRemaining(
              child: Center(child: Text('no_services_found'.tr)),
            ),
          ],
        );
      }
      return CustomScrollView(
        physics: const ClampingScrollPhysics(),
        slivers: [
          SliverOverlapInjector(handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context)),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final service = controller.businessServices[index];
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
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: service.imagePath != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.network(ApiConstants.imageBaseUrl+service.imagePath!, fit: BoxFit.cover, errorBuilder: (c, e, s) => Icon(Icons.medical_services, color: context.theme.primaryColor)),
                                      )
                                    : Icon(Icons.medical_services, color: context.theme.primaryColor),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(service.name ?? 'unknown_service'.tr, style: context.textTheme.titleLarge, maxLines: 1, overflow: TextOverflow.ellipsis),
                                    Text('₹${service.cost ?? '0.00'}', style: context.textTheme.titleMedium?.copyWith(color: context.theme.primaryColor)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          if (service.description != null)
                            Padding(
                              padding: const EdgeInsets.only(left: 10, top: 10),
                              child: Text(service.description!, style: context.textTheme.bodyMedium, maxLines: 2, overflow: TextOverflow.ellipsis),
                            ),
                        ],
                      ),
                    ),
                  );
                },
                childCount: controller.businessServices.length,
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildJobsTab(BuildContext context) {
    return Obx(() {
    final authService = Get.find<AuthService>();
    final currentUser = authService.currentUser.value;
    final business = controller.selectedBusiness.value ?? argBusiness;
    final isOwner = currentUser?.id == business.userId;

      if (controller.isDetailsLoading.isTrue) {
        return _buildShimmerList(context);
      }
      
      final displayedJobs = isOwner 
          ? controller.businessJobs 
          : controller.businessJobs.where((job) => job.status != 'pending').toList();
      
      if (displayedJobs.isEmpty) {
         return CustomScrollView(
           physics: const ClampingScrollPhysics(),
           slivers: [
             SliverOverlapInjector(handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context)),
             SliverFillRemaining(
               child: Center(
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
             ),
           ],
         );
      }

      return CustomScrollView(
        physics: const ClampingScrollPhysics(),
        slivers: [
          SliverOverlapInjector(handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context)),
          SliverPadding(
            padding: const EdgeInsets.only(right: 16,left: 16,top: 16,bottom: 50),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                if (isOwner)
                Row(
                  children: [
                   /* Expanded(
                      child: CustomButton(
                        title: "job_analytics".tr,
                        height: 40,
                        borderRadius: 12,
                        onPressed: () => Get.toNamed(AppRoutes.jobAnalytics),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomButton(
                        title: "applied_jobs".tr,
                        height: 40,
                        borderRadius: 12,
                        onPressed: () => Get.toNamed(AppRoutes.appliedJobList),
                      ),
                    ),*/
                  ],
                ),
                const SizedBox(height: 16),
                ...displayedJobs.map((job) {
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
                                width: 45, height: 45,
                                decoration: BoxDecoration(color: context.theme.primaryColorLight, borderRadius: BorderRadius.circular(12)),
                                child: Icon(Icons.work_outline, color: context.theme.primaryColor),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(child: Text(job.title ?? 'no_title'.tr, style: context.textTheme.titleLarge)),
                                        const SizedBox(width: 8),
                                        _buildJobStatusBadge(job, context),
                                      ],
                                    ),
                                    Text(job.salaryRange ?? 'salary_not_specified'.tr, style: context.textTheme.titleMedium?.copyWith(color: context.theme.primaryColor)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10, top: 10),
                            child: Text(job.description ?? '', style: context.textTheme.bodyMedium),
                          ),
                          const SizedBox(height: 16),
                          Row(children: [Icon(Icons.location_on, size: 16, color: context.theme.primaryColor), const SizedBox(width: 4), Expanded(child: Text(job.location ?? 'unknown'.tr, style: context.textTheme.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis))]),
                          const SizedBox(height: 8),
                          Row(children: [Icon(Icons.business_rounded, size: 16, color: context.theme.primaryColor), const SizedBox(width: 4), Expanded(child: Text(job.jobType ?? 'not_specified'.tr, style: context.textTheme.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis))]),
                          const SizedBox(height: 8),
                          Row(children: [Icon(Icons.alarm, size: 16, color: context.theme.primaryColor), const SizedBox(width: 4), Expanded(child: Text(job.employmentType ?? 'full_time'.tr, style: context.textTheme.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis))]),
                          const SizedBox(height: 10),
                          if (job.status == 'pending')
                            CustomButton(title: "waiting_for_approval".tr, backgroundColor: Colors.orange, borderRadius: 12, height: 40, onPressed: () {}),
                          const SizedBox(height: 10),
                          CustomButton(
                            backgroundColor: context.theme.primaryColor,
                            title: "view_details".tr,
                            borderRadius: 12,
                            height: 40,
                            onPressed: () => Get.toNamed(AppRoutes.jobDetails, arguments: job),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ]),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildBusinessInfoTab(Business business, BuildContext context) {
    return Obx(() {
      if (controller.isDetailsLoading.isTrue) {
        return _buildShimmerInfo(context);
      }
      final b = controller.selectedBusiness.value ?? business;
      return CustomScrollView(
        physics: const ClampingScrollPhysics(),
        slivers: [
          SliverOverlapInjector(handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context)),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildInfoCard('business_details'.tr, [
                  _buildInfoRow(Icons.business, 'name'.tr, b.businessName ?? 'N/A', context),
                  _buildInfoRow(Icons.category, 'category'.tr, b.category?.name ?? 'N/A', context),
                  _buildInfoRow(Icons.verified, 'verification_status'.tr, (b.verificationStatus ?? 'pending').toTitleCase(), context, isGreen: b.verificationStatus == 'approved'),
                  _buildInfoRow(Icons.stacked_bar_chart_sharp, 'business_status'.tr, (b.verificationStatus ?? 'active').toTitleCase(), context),
                  _buildInfoRow(Icons.description, 'description'.tr, b.description ?? 'No description available', context, maxLines: 5),
                  _buildInfoRow(Icons.access_time_filled_rounded, 'business_hours'.tr, "${_formatTimeString(b.opening_time)} - ${_formatTimeString(b.closing_time)}", context),
                ], context),
                const SizedBox(height: 16),
                _buildInfoCard('contact_info'.tr, [
                  _buildInfoRow(Icons.phone, 'phone'.tr, b.contactPhone ?? 'N/A', context),
                  _buildInfoRow(Icons.email, 'email'.tr, b.contactEmail ?? 'N/A', context),
                  _buildInfoRow(Icons.language, 'website'.tr, b.website ?? 'N/A', context),
                ], context),
                const SizedBox(height: 16),
                _buildInfoCard('address_info'.tr, [
                  // business.state,
                  // business.district,
                  // business.city,
                  // business.pincode,
                  _buildInfoRow(Icons.location_city, 'state'.tr, b.state ?? 'N/A', context),
                  _buildInfoRow(Icons.location_city, 'district'.tr, b.district ?? 'N/A', context),
                  _buildInfoRow(Icons.location_on_outlined, 'city'.tr, b.city ?? 'N/A', context),
                  _buildInfoRow(Icons.pin, 'pincode'.tr, b.pincode ?? 'N/A', context),
                ], context),
                const SizedBox(height: 16),
                _buildInfoCard('additional_information'.tr, [
                //  _buildInfoRow(Icons.calendar_today, 'created_at'.tr, b.createdAt != null ? b.createdAt!.split('T')[0] : 'N/A', context),
                //  _buildInfoRow(Icons.update, 'last_updated'.tr, b.updatedAt != null ? b.updatedAt!.split('T')[0] : 'N/A', context),
                  _buildInfoRow(Icons.shopping_bag_outlined, 'total_products'.tr, '${b.products?.length ?? 0}', context),
                  _buildInfoRow(Icons.design_services_outlined, 'total_services'.tr, '${b.services?.length ?? 0}', context),
                  _buildInfoRow(Icons.work_outline, 'active_jobs'.tr, '${controller.businessJobs.where((j) => j.status != 'pending').length}', context),
                ], context),
                const SizedBox(height: 20),
              ]),
            ),
          ),
        ],
      );
    });
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
    return CustomScrollView(
      physics: const ClampingScrollPhysics(),
      slivers: [
        SliverOverlapInjector(handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context)),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
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
              childCount: 6,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildShimmerInfo(BuildContext context) {
    return CustomScrollView(
      physics: const ClampingScrollPhysics(),
      slivers: [
        SliverOverlapInjector(handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context)),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              Shimmer.fromColors(
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
            ]),
          ),
        ),
      ],
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

  String _formatTimeString(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return "N/A";
    try {
      // Input is 24-hour format HH:mm
      DateTime dateTime = DateTime.parse("2000-01-01 $timeStr");
      // Output is localized AM/PM
      return DateFormat('hh:mm a').format(dateTime);
    } catch (e) {
      return timeStr;
    }
  }

  bool _isOpen(String? open, String? close) {
    if (open == null || close == null || open.isEmpty || close.isEmpty) return false;
    try {
      final now = DateTime.now();
      final openParts = open.split(':');
      final closeParts = close.split(':');
      
      final nowMin = now.hour * 60 + now.minute;
      final openMin = int.parse(openParts[0]) * 60 + int.parse(openParts[1]);
      final closeMin = int.parse(closeParts[0]) * 60 + int.parse(closeParts[1]);

      if (closeMin < openMin) {
        // Closes past midnight (e.g. 10 PM to 2 AM)
        return nowMin >= openMin || nowMin <= closeMin;
      }
      return nowMin >= openMin && nowMin <= closeMin;
    } catch(e) {
      return false; 
    }
  }

  Widget _buildTimingHighlight(Business business, BuildContext context) {
    final openTime = _formatTimeString(business.opening_time);
    final closeTime = _formatTimeString(business.closing_time);
    final bool isOpen = _isOpen(business.opening_time, business.closing_time);

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: context.theme.primaryColor.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: context.theme.primaryColor.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.access_time_filled_rounded,
              size: 16,
              color: context.theme.primaryColor,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                "$openTime - $closeTime",
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.theme.primaryColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: isOpen ? Colors.green : Colors.red,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              isOpen ? "Open" : "Closed",
              style: context.textTheme.bodySmall?.copyWith(
                color: isOpen ? Colors.green[700] : Colors.red[700],
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
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
}