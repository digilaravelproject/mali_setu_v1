import 'package:edu_cluezer/features/business/presentation/page/single_business_details.dart';
import 'package:edu_cluezer/widgets/custom_scaffold.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../../../../common/widgets/bg_gradient_border.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../widgets/custom_buttons.dart';
import '../controller/business_controller.dart';
import 'add_product_screen.dart';

class BusinessPage extends GetWidget<BusinessController> {
  const BusinessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(body: Column(children: []));
  }
}

// Business Model
class Business {
  final String id;
  final String name;
  final String category;
  final String established;
  final String address;
  final bool isActive;
  final String revenue;

  Business({
    required this.id,
    required this.name,
    required this.category,
    required this.established,
    required this.address,
    required this.isActive,
    required this.revenue,
  });
}

// Sample Data
final List<Business> businesses = [
  Business(
    id: '1',
    name: 'Raj Electronics',
    category: 'Electronics',
    established: '2020',
    address: 'Hazratganj, Lucknow',
    isActive: true,
    revenue: '₹45L/month',
  ),
  Business(
    id: '2',
    name: 'Sharma Sweets',
    category: 'Food & Beverages',
    established: '2018',
    address: 'Aminabad, Lucknow',
    isActive: true,
    revenue: '₹32L/month',
  ),
  Business(
    id: '3',
    name: 'Fashion Hub',
    category: 'Clothing',
    established: '2022',
    address: 'Gomti Nagar, Lucknow',
    isActive: true,
    revenue: '₹28L/month',
  ),
  Business(
    id: '4',
    name: 'Tech Solutions',
    category: 'IT Services',
    established: '2019',
    address: 'Indira Nagar, Lucknow',
    isActive: false,
    revenue: '₹55L/month',
  ),
  Business(
    id: '5',
    name: 'Green Garden',
    category: 'Agriculture',
    established: '2021',
    address: 'Alambagh, Lucknow',
    isActive: true,
    revenue: '₹20L/month',
  ),
  Business(
    id: '6',
    name: 'Book Palace',
    category: 'Books & Stationery',
    established: '2017',
    address: 'Chowk, Lucknow',
    isActive: true,
    revenue: '₹15L/month',
  ),
];

// Dashboard Screen
class BusinessScreen extends StatelessWidget {
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
      body: Container(
        decoration: BoxDecoration(
          color: context.theme.colorScheme.onPrimary,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

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
                          color: context.theme.colorScheme.primary.withOpacity(
                            0.3,
                          ),
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
                                      businesses[0].name,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      businesses[0].category,
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
                      // style: TextStyle(
                      //   fontSize: 24,
                      //   fontWeight: FontWeight.bold,
                      //   color: Color(0xFF424242),
                      // ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AllBusinessesScreen(),
                          ),
                        );
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
                  itemCount: businesses.length > 6 ? 6 : businesses.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: BusinessListCard(business: businesses[index]),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Business Card Widget
class BusinessCard extends StatelessWidget {
  final Business business;

  const BusinessCard({Key? key, required this.business}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BusinessDetailScreen(),
            //(business: business),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFCE4EC),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.business,
                    color: Color(0xFFE91E63),
                    size: 24,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: business.isActive
                        ? const Color(0xFFE8F5E9)
                        : const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    business.isActive ? 'Active' : 'Inactive',
                    style: TextStyle(
                      color: business.isActive
                          ? const Color(0xFF4CAF50)
                          : const Color(0xFF9E9E9E),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              business.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF424242),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              business.category,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFFE91E63),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.location_on,
                  size: 14,
                  color: Color(0xFFE91E63),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    business.address,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF757575),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: 14,
                  color: Color(0xFFE91E63),
                ),
                const SizedBox(width: 4),
                Text(
                  'Est. ${business.established}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF757575),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(
                  Icons.trending_up,
                  size: 14,
                  color: Color(0xFFE91E63),
                ),
                const SizedBox(width: 4),
                Text(
                  business.revenue,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF424242),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// All Businesses Screen
class AllBusinessesScreen extends StatelessWidget {
  const AllBusinessesScreen({Key? key}) : super(key: key);

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
              "All Businesses",
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 24,
              ),
            ),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: context.theme.cardColor,
          // gradient: LinearGradient(
          //   begin: Alignment.topLeft,
          //   end: Alignment.bottomRight,
          //   colors: [Color(0xFFFCE4EC), Color(0xFFF3E5F5)],
          // ),
        ),
        child: SafeArea(
          // top: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 10, left: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // GestureDetector(
                    //   onTap: () => Navigator.pop(context),
                    //   child: Row(
                    //     children: const [
                    //       Icon(
                    //         Icons.chevron_left,
                    //         color: Color(0xFFE91E63),
                    //         size: 28,
                    //       ),
                    //       Text(
                    //         'Back',
                    //         style: TextStyle(
                    //           color: Color(0xFFE91E63),
                    //           fontWeight: FontWeight.w600,
                    //           fontSize: 16,
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    // const SizedBox(height: 24),
                    // const Text(
                    //   'All Businesses',
                    //   style: TextStyle(
                    //     fontSize: 32,
                    //     fontWeight: FontWeight.bold,
                    //     color: Color(0xFF424242),
                    //   ),
                    // ),
                    // const SizedBox(height: 8),
                    Text(
                      '${businesses.length} Businesses Available',
                      style: context.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: context.theme.primaryColor,
                        // style: const TextStyle(
                        //   fontSize: 16,
                        //   color: Color(0xFF757575),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: businesses.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: BusinessListCard(business: businesses[index]),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Business List Card
class BusinessListCard extends StatelessWidget {
  final Business business;

  const BusinessListCard({Key? key, required this.business}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BusinessDetailScreen(),
            //(business: business),
          ),
        );
      },
      child: BgGradientBorder(
        // decoration: BoxDecoration(
        //   color: Colors.white,
        //   borderRadius: BorderRadius.circular(16),
        //   boxShadow: [
        //     BoxShadow(
        //       color: Colors.grey.withOpacity(0.1),
        //       blurRadius: 10,
        //       offset: const Offset(0, 4),
        //     ),
        //   ],
        // ),
        // padding: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFCE4EC),
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
                            business.name,
                            style: context.textTheme.titleMedium,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: business.isActive
                                ? const Color(0xFFE8F5E9)
                                : const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            business.isActive ? 'Active' : 'Inactive',
                            style: TextStyle(
                              color: business.isActive
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
                      business.category,
                      style: TextStyle(
                        fontSize: 14,
                        color: context.theme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 14,
                          color: Color(0xFF757575),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            business.address,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF757575),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.trending_up,
                          size: 14,
                          color: Color(0xFF757575),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          business.revenue,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF424242),
                            fontWeight: FontWeight.w600,
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


// Detail Card Widget
class DetailCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const DetailCard({
    Key? key,
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF757575),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF424242),
                  ),
                ),
              ],
            ),
          ),
        ],
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
              child: Image.network(
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
