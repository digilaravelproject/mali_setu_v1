import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:percent_indicator/percent_indicator.dart';

class JobAnalysisPage extends StatelessWidget {
  JobAnalysisPage({super.key});

  final List<Map<String, dynamic>> recentApplications = [
    {
      'name': 'Rahul Sharma',
      'job': 'Senior Flutter Developer',
      'status': 'Pending',
      'time': '2 hours ago',
      'avatar': 'RS',
      'statusColor': Colors.orange,
    },
    {
      'name': 'Priya Patel',
      'job': 'UI/UX Designer',
      'status': 'Accepted',
      'time': '1 day ago',
      'avatar': 'PP',
      'statusColor': Colors.green,
    },
    {
      'name': 'Amit Verma',
      'job': 'Backend Developer',
      'status': 'Rejected',
      'time': '2 days ago',
      'avatar': 'AV',
      'statusColor': Colors.red,
    },
    {
      'name': 'Neha Singh',
      'job': 'Product Manager',
      'status': 'Pending',
      'time': '3 days ago',
      'avatar': 'NS',
      'statusColor': Colors.orange,
    },
    {
      'name': 'Suresh Kumar',
      'job': 'DevOps Engineer',
      'status': 'Accepted',
      'time': '4 days ago',
      'avatar': 'SK',
      'statusColor': Colors.green,
    },
    {
      'name': 'Anjali Gupta',
      'job': 'Mobile Developer',
      'status': 'Under Review',
      'time': '5 days ago',
      'avatar': 'AG',
      'statusColor': Colors.blue,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          /// App Bar
          SliverAppBar(
            elevation: 2,
            pinned: true,
            centerTitle: false,
            title: Text(
              'Job Analysis Dashboard',
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

          /// Stats Grid
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Job Statistics',
                  style:context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: statCard(
                          context: context,
                          title: 'Total Jobs',
                          count: 124,
                          color: Colors.blue,
                          icon: Icons.work_outline
                        ),
                      ),
                      SizedBox(width: 12,),

                      // Active Jobs
                      Expanded(
                        child: statCard(
                          context: context,
                          title: 'Active Jobs',
                          count: 89,
                          color: Colors.green,
                          icon: Icons.work,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: statCard(
                          context: context,
                          title: 'Pending Jobs',
                          count: 15,
                          color: Colors.orange,
                          icon: Icons.pending_actions,
                        ),
                      ),
                      SizedBox(width: 12,),
                      // Total Applications
                      Expanded(
                        child: statCard(
                          context: context,
                          title: 'Total Applications',
                          count: 456,
                          color: Colors.purple,
                          icon: Icons.people_outline,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: statCard(
                          context: context,
                          title: 'Pending Applications',
                          count: 78,
                          color: Colors.red,
                          icon: Icons.hourglass_empty,
                        ),
                      ),
                      SizedBox(width: 12,),
                      // Accepted Applications
                      Expanded(
                        child: statCard(
                          context: context,
                          title: 'Accepted Applications',
                          count: 245,
                          color: Colors.teal,
                          icon: Icons.check_circle_outline,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Application Progress',
                  style:context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)
              ),
            ),
          ),

          SliverToBoxAdapter(child: _buildProgressSection(context :context)),

          // Recent Applications
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Applications',
                    style:context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'View All',
                      style: context.textTheme.titleMedium?.copyWith(color: Colors.blue)
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Applications List
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) =>
                  _buildApplicationCard(recentApplications[index]),
              childCount: recentApplications.length,
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),

    );
  }

  Widget statCard({
    required BuildContext context,
    required String title,
    required int count,
    required Color color,
    required IconData icon,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: context.theme.dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12,vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 35,
                  height: 35,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                  ),
                ),
                SizedBox(width: 10),

                Text(
                  "$count",
                  style: context.textTheme.titleLarge?.copyWith(
                    color: context.theme.primaryColor,
                  ),
                ),
              ],
            ),
            SizedBox(height: 5,),
            Text(
              title,
              style: context.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressSection({required BuildContext context}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.theme.dividerColor)
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Application Status Distribution',
                style: context.textTheme.titleMedium
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'This Month',
                  style: context.textTheme.bodyMedium?.copyWith( color: Colors.blue.shade700, )
                  // TextStyle(
                  //   color: Colors.blue.shade700,
                  //   fontWeight: FontWeight.w600,
                  //   fontSize: 12,
                  // ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // Circular Progress
              CircularPercentIndicator(
                radius: 60,
                lineWidth: 12,
                percent: 0.75,
                center: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '75%',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.green.shade700,
                      ),
                    ),
                    Text(
                      'Success',
                      style: context.textTheme.bodyMedium,
                    ),
                  ],
                ),
                progressColor: Colors.green,
                backgroundColor: Colors.green.shade100,
                circularStrokeCap: CircularStrokeCap.round,
              ),
              const SizedBox(width: 30),
              // Legend
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLegendItem('Accepted', 245, Colors.green,context : context),
                    _buildLegendItem('Pending', 78, Colors.orange,context : context),
                    _buildLegendItem('Rejected', 42, Colors.red,context : context),
                    _buildLegendItem('Under Review', 91, Colors.blue,context : context),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String title, int count, Color color, {required BuildContext context}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style:context.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)
            ),
          ),
          Text(
            '$count',
            style: context.textTheme.titleSmall
          ),
        ],
      ),
    );
  }

  Widget _buildApplicationCard(Map<String, dynamic> application) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8,right: 16,left: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey)
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                application['avatar'],
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.blue.shade700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  application['name'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  application['job'],
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Text(
                  application['time'],
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          // Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: application['statusColor'].withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              application['status'],
              style: TextStyle(
                color: application['statusColor'],
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
