import 'package:edu_cluezer/core/routes/app_routes.dart';
import 'package:edu_cluezer/widgets/custom_buttons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_utils/src/extensions/context_extensions.dart';

/*class MyBusinessScreen extends StatelessWidget {
  const MyBusinessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            elevation: 2,
            pinned: true,
            centerTitle: false,
            title: Text(
              'My Businesses',
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 22,
              ),
            ),

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
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: context.theme.dividerColor),
                ),
                child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12,vertical: 8),
                  child: Column(
                    children: [
                      Text("Grow Your Profile",style: context.textTheme.titleLarge,),
                      SizedBox(height: 10,),
                      Text("Add another Business to expand your reach",style: context.textTheme.bodyMedium,),
                      SizedBox(height: 10,),
                      CustomButton(title: "Register Your Business", height: 40, onPressed: (){
                        Get.toNamed(AppRoutes.regBusiness);
                      }),
                    ],
                  ),
              ),
              ),
            ),
          )
        ],
      ),
    );
  }
}*/



class MyBusinessScreen extends StatelessWidget {
  MyBusinessScreen({super.key});

  // Sample business data
  final List<Map<String, dynamic>> businesses = [
    {
      'id': 1,
      'name': 'Tech Solutions Pvt Ltd',
      'category': 'IT Services',
      'image': 'https://via.placeholder.com/100',
      'products': 24,
      'services': 8,
      'revenue': '₹2.5L',
      'phone': '+91 98765 43210',
      'email': 'contact@techsolutions.com',
      'website': 'www.techsolutions.com',
      'createdAt': '2023-05-15',
      'status': 'Active',
      'rating': 4.5,
      'reviews': 128,
    },
    {
      'id': 2,
      'name': 'Urban Cafe & Restaurant',
      'category': 'Food & Beverage',
      'image': 'https://via.placeholder.com/100',
      'products': 45,
      'services': 12,
      'revenue': '₹1.8L',
      'phone': '+91 98765 43211',
      'email': 'info@urbancafe.com',
      'website': 'www.urbancafe.com',
      'createdAt': '2022-11-20',
      'status': 'Active',
      'rating': 4.2,
      'reviews': 89,
    },
    {
      'id': 3,
      'name': 'FitLife Gym & Wellness',
      'category': 'Health & Fitness',
      'image': 'https://via.placeholder.com/100',
      'products': 18,
      'services': 6,
      'revenue': '₹1.2L',
      'phone': '+91 98765 43212',
      'email': 'support@fitlife.com',
      'website': 'www.fitlifegym.com',
      'createdAt': '2024-01-10',
      'status': 'Active',
      'rating': 4.8,
      'reviews': 56,
    },
    {
      'id': 4,
      'name': 'GreenLeaf Organic Store',
      'category': 'Retail',
      'image': 'https://via.placeholder.com/100',
      'products': 120,
      'services': 3,
      'revenue': '₹3.1L',
      'phone': '+91 98765 43213',
      'email': 'organic@greenleaf.com',
      'website': 'www.greenleaforganic.com',
      'createdAt': '2021-08-05',
      'status': 'Active',
      'rating': 4.6,
      'reviews': 210,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            elevation: 2,
            pinned: true,
            centerTitle: false,
            title: Text(
              'My Businesses',
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 22,
              ),
            ),

            leading: InkWell(
              onTap: () => Navigator.of(context).pop(),
              child: Icon(
                Icons.arrow_back_ios,
                color: context.iconColor,
                size: 18,
              ),
            ),
          ),

          // Promotion Card
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [context.theme.primaryColorLight,context.theme.primaryColorLight ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: context.theme.primaryColor.withOpacity(0.4),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.rocket_launch,
                              color: context.theme.cardColor,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "Expand Your Business Network",
                              style: context.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Add another business to increase your reach and connect with more customers",
                        style: context.textTheme.bodyMedium?.copyWith(
                          //color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      const SizedBox(height: 16),
                      CustomButton(title: "Add New Business",
                          height: 40,borderRadius: 12,
                          onPressed: (){
                        Get.toNamed(AppRoutes.regBusiness);
                      }),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Business Count
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "My Businesses (${businesses.length})",
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  /*Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.sort, size: 16, color: Colors.blue.shade700),
                        const SizedBox(width: 6),
                        Text(
                          'Recent',
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),*/
                ],
              ),
            ),
          ),

          // Business List
          SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildBusinessCard(businesses[index],context : context),
              childCount: businesses.length,
            ),
          ),

          // Bottom Padding
          const SliverToBoxAdapter(
            child: SizedBox(height: 30),
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessCard(Map<String, dynamic> business, {required BuildContext context}) {
    // final date = DateFormat('dd MMM yyyy').format(
    //   DateTime.parse(business['createdAt']),
    // );

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
       border: Border.all(color:context.theme.dividerColor )
      ),
      child: Column(
        children: [
          // Business Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Business Image
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: context.theme.dividerColor),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      business['image'],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[200],
                          child: Icon(
                            Icons.business,
                            size: 30,
                            color: Colors.grey[400],
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Business Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              business['name'],
                              style: context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              business['status'],
                              style: context.textTheme.bodyMedium?.copyWith( color: Colors.green.shade700,)
                              // TextStyle(
                              //   color: Colors.green.shade700,
                              //   fontSize: 12,
                              //   fontWeight: FontWeight.w600,
                              // ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        business['category'],
                        style: context.textTheme.bodyMedium
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '${business['rating']}',
                            style: context.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '(${business['reviews']} reviews)',
                              style: context.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)
                          ),
                          const Spacer(),
                          //Icon(Icons.calendar_today, size: 14, color: Colors.grey[500]),
                          const SizedBox(width: 4),
                          Text(
                            '2 year',
                              style: context.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Divider
          Divider(height: 1, color: context.theme.dividerColor),

          // Stats Row
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  context:context,
                  icon: Icons.inventory,
                  label: 'Products',
                  value: '${business['products']}',
                  color: Colors.blue,
                ),
                _buildStatItem(
                  context:context,
                  icon: Icons.design_services,
                  label: 'Services',
                  value: '${business['services']}',
                  color: Colors.purple,
                ),
                _buildStatItem(
                  context:context,
                  icon: Icons.currency_rupee,
                  label: 'Revenue',
                  value: business['revenue'],
                  color: Colors.green,
                ),
              ],
            ),
          ),

          // Divider
          Divider(height: 1, color: context.theme.dividerColor),

          // Contact Info & Actions
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Contact Info
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.phone, size: 16, color: Colors.blue.shade600),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              business['phone'],
                              style: context.textTheme.bodyMedium
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.email, size: 16, color: Colors.blue.shade600),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              business['email'],
                              style: context.textTheme.bodyMedium
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.language, size: 16, color: Colors.blue.shade600),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              business['website'],
                              style: context.textTheme.bodyMedium
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // Action Buttons Row (Icon-based)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // View Details
                      _buildIconActionButton(
                        context : context,
                        icon: Icons.visibility_outlined,
                        label: 'View',
                        color: Colors.blue.shade600,
                        onPressed: () {
                          Get.toNamed(AppRoutes.businessDetails);
                        },
                      ),

                      // Edit Business
                      _buildIconActionButton(
                        context : context,
                        icon: Icons.edit_outlined,
                        label: 'Edit',
                        color: Colors.green.shade600,
                        onPressed: () {
                          Get.toNamed(AppRoutes.regBusiness);
                        },
                      ),

                      // Delete Business
                      _buildIconActionButton(
                        context : context,
                        icon: Icons.delete_outline,
                        label: 'Delete',
                        color: Colors.red.shade600,
                        onPressed: () {
                          // Delete business
                        },
                      ),

                      // More Options
                      // PopupMenuButton<String>(
                      //   icon: Container(
                      //     width: 36,
                      //     height: 36,
                      //     decoration: BoxDecoration(
                      //       color: Colors.grey[200],
                      //       shape: BoxShape.circle,
                      //     ),
                      //     child: Icon(Icons.more_vert, color: Colors.grey[600], size: 20),
                      //   ),
                      //   onSelected: (value) {
                      //     if (value == 'share') {
                      //       // Share business
                      //     } else if (value == 'analytics') {
                      //       // View analytics
                      //     } else if (value == 'duplicate') {
                      //       // Duplicate business
                      //     }
                      //   },
                      //   itemBuilder: (context) => [
                      //     PopupMenuItem(
                      //       value: 'share',
                      //       child: Row(
                      //         children: [
                      //           Icon(Icons.share, size: 18, color: Colors.grey[700]),
                      //           const SizedBox(width: 8),
                      //           const Text('Share Business'),
                      //         ],
                      //       ),
                      //     ),
                      //     PopupMenuItem(
                      //       value: 'analytics',
                      //       child: Row(
                      //         children: [
                      //           Icon(Icons.analytics_outlined, size: 18, color: Colors.grey[700]),
                      //           const SizedBox(width: 8),
                      //           const Text('Analytics'),
                      //         ],
                      //       ),
                      //     ),
                      //     PopupMenuItem(
                      //       value: 'duplicate',
                      //       child: Row(
                      //         children: [
                      //           Icon(Icons.content_copy, size: 18, color: Colors.grey[700]),
                      //           const SizedBox(width: 8),
                      //           const Text('Duplicate'),
                      //         ],
                      //       ),
                      //     ),
                      //   ],
                      // ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required BuildContext context,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: context.textTheme.titleMedium?.copyWith(color: color,fontWeight: FontWeight.w700,)
          // TextStyle(
          //   fontSize: 18,
          //   fontWeight: FontWeight.w700,
          //   color: color,
          // ),
        ),
        Text(
          label,
          style: context.textTheme.bodyMedium
        ),
      ],
    );
  }

  Widget _buildIconActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
    required BuildContext context,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: context.textTheme.titleSmall?.copyWith(color: color)
          // TextStyle(
          //   color: color,
          //   fontSize: 12,
          //   fontWeight: FontWeight.w600,
          // ),
        ),
      ],
    );
  }
}
