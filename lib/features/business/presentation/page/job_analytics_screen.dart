import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:percent_indicator/percent_indicator.dart';

import 'package:edu_cluezer/features/business/data/model/res_all_business_model.dart';
import 'package:edu_cluezer/features/business/presentation/controller/business_controller.dart';

class JobAnalysisPage extends StatefulWidget {
  const JobAnalysisPage({super.key});

  @override
  State<JobAnalysisPage> createState() => _JobAnalysisPageState();
}

class _JobAnalysisPageState extends State<JobAnalysisPage> {
  final BusinessController controller = Get.find<BusinessController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = Get.arguments ?? {};
      final int businessId = args["business_id"] ?? 0;
      controller.fetchJobAnalytics(businessId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        final analytics = controller.jobAnalytics.value;
        
        if (controller.isLoading.value && analytics == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            /// App Bar
            SliverAppBar(
              elevation: 2,
              pinned: true,
              centerTitle: false,
              title: Text(
                'job_analysis_dashboard'.tr,
                style: context.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 22,
                ),
              ),
              leading: InkWell(
                onTap: () => Get.back(),
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
                  'job_statistics'.tr,
                  style: context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)
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
                            title: 'total_jobs'.tr,
                            count: analytics?.totalJobs ?? 0,
                            color: Colors.blue,
                            icon: Icons.work_outline
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: statCard(
                            context: context,
                            title: 'active_jobs'.tr,
                            count: analytics?.activeJobs ?? 0,
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
                            title: 'pending_jobs'.tr,
                            count: analytics?.pendingJobs ?? 0,
                            color: Colors.orange,
                            icon: Icons.pending_actions,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: statCard(
                            context: context,
                            title: 'total_applications'.tr,
                            count: analytics?.totalApplications ?? 0,
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
                            title: 'pending_applications'.tr,
                            count: analytics?.pendingApplications ?? 0,
                            color: Colors.red,
                            icon: Icons.hourglass_empty,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: statCard(
                            context: context,
                            title: 'accepted_applications'.tr,
                            count: analytics?.acceptedApplications ?? 0,
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
                  'application_progress'.tr,
                  style: context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)
                ),
              ),
            ),

            SliverToBoxAdapter(child: _buildProgressSection(context: context, analytics: analytics)),

            // Recent Applications
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'recent_applications'.tr,
                      style: context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)
                    ),
                    // TextButton(
                    //   onPressed: () {},
                    //   child: Text(
                    //     'view_all'.tr,
                    //     style: context.textTheme.titleMedium?.copyWith(color: Colors.blue)
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),

            // Applications List
            if (analytics?.recentApplications == null || analytics!.recentApplications!.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Center(child: Text("no_recent_applications".tr)),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildApplicationCard(analytics.recentApplications![index]),
                  childCount: analytics.recentApplications!.length,
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),
          ],
        );
      }),
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  "$count",
                  style: context.textTheme.titleLarge?.copyWith(
                    color: color, // Use individual color for count
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              title,
              style: context.textTheme.bodyMedium?.copyWith(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressSection({required BuildContext context, JobAnalyticsData? analytics}) {
    final double successRate = (analytics?.totalApplications ?? 0) > 0 
        ? (analytics!.acceptedApplications! / analytics.totalApplications!) 
        : 0;
        
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
                'application_status_distribution'.tr,
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
                  'lifetime'.tr,
                  style: context.textTheme.bodyMedium?.copyWith(color: Colors.blue.shade700, fontSize: 10)
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
                percent: successRate,
                center: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${(successRate * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.green.shade700,
                      ),
                    ),
                    Text(
                      'success'.tr,
                      style: context.textTheme.bodyMedium?.copyWith(fontSize: 10),
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
                    _buildLegendItem('accepted'.tr, analytics?.acceptedApplications ?? 0, Colors.teal, context: context),
                    _buildLegendItem('pending'.tr, analytics?.pendingApplications ?? 0, Colors.orange, context: context),
                    _buildLegendItem('total'.tr, analytics?.totalApplications ?? 0, Colors.blue, context: context),
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
              style: context.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500, fontSize: 12)
            ),
          ),
          Text(
            '$count',
            style: context.textTheme.titleSmall?.copyWith(fontSize: 12)
          ),
        ],
      ),
    );
  }

  Widget _buildApplicationCard(dynamic application) {
    // Assuming application structure from API or placeholder
    final String name = application['user']['name'] ?? 'Unknown Applicant';
    final String jobTitle = application['user']['company_name'] ?? 'Job Application';
    final String status = application['status'] ?? 'Pending';
    final String time = application['user']['address'] ?? 'Address';
    final String avatarText = name.isNotEmpty ? name.substring(0, 1).toUpperCase() : 'A';
    
    Color statusColor = Colors.orange;
    if (status.toLowerCase().contains('accept')) {
      statusColor = Colors.green;
    } else if (status.toLowerCase().contains('reject')) {
      statusColor = Colors.red;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8, right: 16, left: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.theme.dividerColor)
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
                avatarText,
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
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  jobTitle,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          // Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: statusColor,
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
