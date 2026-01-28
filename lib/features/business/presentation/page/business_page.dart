import 'package:edu_cluezer/features/business/presentation/page/single_business_details.dart';
import 'package:edu_cluezer/widgets/custom_scaffold.dart';
import 'package:edu_cluezer/core/helper/string_extensions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../../../../common/widgets/bg_gradient_border.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../widgets/custom_buttons.dart';
import '../controller/business_controller.dart';
import '../../data/model/res_all_business_model.dart' as model;
import 'add_product_screen.dart';
import '../../../../core/widgets/shimmer_loading.dart';

class BusinessPage extends GetWidget<BusinessController> {
  const BusinessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const BusinessScreen();
  }
}

// Dashboard Screen
class BusinessScreen extends GetView<BusinessController> {
  const BusinessScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: context.theme.primaryColorLight,
        centerTitle: false,
        titleSpacing: 20,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Business Dashboard",
              style: context.textTheme.headlineMedium
            ),
          ],
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildShimmerLoading(context);
        }

        return Container(
          decoration: BoxDecoration(
            color: context.theme.colorScheme.onPrimary,
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
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
                              context.theme.colorScheme.primary,
                              context.theme.colorScheme.primary,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: context.theme.colorScheme.primary.withOpacity(0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.business_center,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'My Business',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        'View your business details',
                                        style: TextStyle(
                                          color: Color(0xFFFCE4EC),
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.chevron_right,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
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
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          controller.myBusiness.value?.category?.name ?? '',
                                          style: const TextStyle(
                                            color: Color(0xFFFCE4EC),
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
                              context.theme.colorScheme.primary,
                              context.theme.colorScheme.primary,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: context.theme.colorScheme.primary.withOpacity(0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.add_business_rounded,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Register Your Business',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        'Start growing your business today',
                                        style: TextStyle(
                                          color: Color(0xFFFCE4EC),
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.chevron_right,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Register Now',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          'Build your digital profile',
                                          style: TextStyle(
                                            color: Color(0xFFFCE4EC),
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
                    ),
                  
                  const SizedBox(height: 32),

                  // Header with View All
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Featured Businesses',
                        style: context.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Get.to(() => const AllBusinessesScreen());
                        },
                        child: Row(
                          children: [
                            Text(
                              'View All',
                              style: TextStyle(
                                color: context.theme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.chevron_right,
                              color: context.theme.colorScheme.primary,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Business List
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: controller.businesses.length > 6 ? 6 : controller.businesses.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: BusinessListCard(business: controller.businesses[index]),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}


// All Businesses Screen
class AllBusinessesScreen extends GetWidget<BusinessController> {
  const AllBusinessesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true, // Show back button
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Get.back(),
        ),
        elevation: 0,
        backgroundColor: context.theme.primaryColorLight,
        centerTitle: false,
        titleSpacing: 0, // Adjusted for custom leading
        title: Text(
          "All Businesses",
          style: context.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 24,
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildShimmerLoading(context);
        }

        if (controller.businesses.isEmpty) {
          return const Center(child: Text("No Businesses Found"));
        }
        return Container(
          decoration: BoxDecoration(
            color: context.theme.cardColor,
          ),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 10, left: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${controller.businesses.length} Businesses Available',
                        style: context.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: context.theme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: controller.businesses.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: BusinessListCard(business: controller.businesses[index]),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

// Business List Card
class BusinessListCard extends StatelessWidget {
  final model.Business business;

  const BusinessListCard({Key? key, required this.business}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String address = [
      business.user?.city,
      business.user?.district,
    ].where((e) => e != null && e.isNotEmpty).join(", ");

    return GestureDetector(
      onTap: () {
        Get.to(() => const BusinessDetailScreen(), arguments: business);
      },
      child: BgGradientBorder(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: context.theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.business,
                  color: context.theme.colorScheme.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            business.businessName ?? '',
                            style: context.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: business.status == 'active'
                                ? const Color(0xFFE8F5E9)
                                : const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            (business.status ?? 'unknown').toTitleCase(),
                            style: TextStyle(
                              color: business.status == 'active'
                                  ? const Color(0xFF4CAF50)
                                  : const Color(0xFF9E9E9E),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      business.category?.name ?? 'General',
                      style: TextStyle(
                        fontSize: 14,
                        color: context.theme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (address.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 16,
                            color: Color(0xFF757575),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              address,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF757575),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.shopping_bag_outlined,
                          size: 16,
                          color: Color(0xFF757575),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${business.products?.length ?? 0} Products',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF424242),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Icon(
                          Icons.settings_outlined,
                          size: 16,
                          color: Color(0xFF757575),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${business.services?.length ?? 0} Services',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF424242),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
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
