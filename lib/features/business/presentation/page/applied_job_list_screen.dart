import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:edu_cluezer/features/business/presentation/controller/business_controller.dart';
import 'package:edu_cluezer/features/business/data/model/res_all_business_model.dart';
import 'package:edu_cluezer/core/widgets/shimmer_loading.dart';

class AppliedJobsScreen extends StatefulWidget {
  @override
  _AppliedJobsScreenState createState() => _AppliedJobsScreenState();
}

class _AppliedJobsScreenState extends State<AppliedJobsScreen> {
  final BusinessController controller = Get.find<BusinessController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchMyApplications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back_ios_new, color: context.textTheme.bodyLarge?.color),
        ),
        title: Text(
          "applied_jobs".tr,
          style: context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.myApplications.isEmpty) {
          return _buildShimmerLoading();
        }

        if (controller.myApplications.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: controller.fetchMyApplications,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: controller.myApplications.length,
            itemBuilder: (context, index) {
              final application = controller.myApplications[index];
              return _buildApplicationCard(application);
            },
          ),
        );
      }),
    );
  }

  Widget _buildApplicationCard(JobApplication application) {
    final job = application.jobPosting;
    final business = job?.business;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: context.theme.dividerColor.withOpacity(0.5)),
      ),
      child: InkWell(
        onTap: () => _showApplicationDetail(application),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Business Logo Placeholder
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: context.theme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.business, color: context.theme.primaryColor),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job?.title ?? "unknown_position".tr,
                          style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          business?.businessName ?? "unknown_business".tr,
                          style: context.textTheme.bodyMedium?.copyWith(color: Colors.grey),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  _buildStatusBadge(application.status ?? "pending"),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildInfoItem(Icons.location_on_outlined, job?.location ?? "na".tr),
                  const SizedBox(width: 16),
                  _buildInfoItem(Icons.calendar_today_outlined, _formatDate(application.appliedAt)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                   _buildInfoItem(Icons.work_outline, job?.jobType ?? "na".tr),
                   const SizedBox(width: 16),
                   _buildInfoItem(Icons.payments_outlined, job?.salaryRange ?? "na".tr),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'accepted':
      case 'approved':
        color = Colors.green;
        break;
      case 'rejected':
      case 'declined':
        color = Colors.red;
        break;
      default:
        color = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.toLowerCase().tr,
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: context.textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return "na".tr;
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (_) {
      return dateStr;
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            "no_applications".tr,
            style: context.textTheme.titleLarge?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text("explore_jobs".tr),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Get.back(),
            child: Text("go_back".tr),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) {
        return const Padding(
          padding: EdgeInsets.only(bottom: 16),
          child: ShimmerLoading.rounded(height: 140),
        );
      },
    );
  }

  void _showApplicationDetail(JobApplication application) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: context.theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "application_details".tr,
                  style: context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                _buildStatusBadge(application.status ?? "pending"),
              ],
            ),
            const Divider(height: 32),
            _buildDetailItem("cover_letter".tr, application.coverLetter ?? "no_cover_letter".tr),
            const SizedBox(height: 16),
            if (application.additionalInfo != null && application.additionalInfo!.isNotEmpty) ...[
              _buildDetailItem("additional_info".tr, application.additionalInfo!),
              const SizedBox(height: 16),
            ],
            if (application.resumeUrl != null) ...[
              _buildDetailItem("resume".tr, "available_online".tr),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: () {
                   // Logic to view resume
                },
                icon: const Icon(Icons.remove_red_eye_outlined),
                label:  Text("view_resume".tr),
              ),
              const SizedBox(height: 16),
            ],
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Get.back(),
                child:  Text("close".tr),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: context.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold, color: context.theme.primaryColor),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: context.textTheme.bodyMedium,
        ),
      ],
    );
  }
}
