import 'package:edu_cluezer/core/constent/api_constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/model/res_all_business_model.dart';
import '../controller/business_controller.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../../../core/widgets/custom_confirm_dialog.dart';

class JobApplicationsPage extends StatefulWidget {
  const JobApplicationsPage({super.key});

  @override
  State<JobApplicationsPage> createState() => _JobApplicationsPageState();
}

class _JobApplicationsPageState extends State<JobApplicationsPage> {
  final BusinessController controller = Get.find<BusinessController>();
  final Job job = Get.arguments ?? Job();

  @override
  void initState() {
    super.initState();
    if (job.id != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.fetchJobApplications(job.id!);
      });
    }
  }

  void _handleStatusUpdate(JobApplication application, String status) {
    if (application.id == null || job.id == null) return;
    
    String actionText;
    Color actionColor;
    
    switch (status) {
      case 'accepted':
        actionText = "Accept";
        actionColor = Colors.green;
        break;
      case 'rejected':
        actionText = "Reject";
        actionColor = Colors.redAccent;
        break;
      case 'reviewed':
        actionText = "Mark as Reviewed";
        actionColor = Colors.blue;
        break;
      default:
        actionText = "Update Status";
        actionColor = Colors.grey;
    }

    CustomConfirmDialog.show(
      title: "$actionText Application",
      message: "Are you sure you want to change the status to '$status' for ${application.user?.name ?? 'this user'}?",
      confirmText: actionText,
      confirmColor: actionColor,
      onConfirm: () {
        controller.updateApplicationStatus(application.id!, status, job.id!);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: InkWell(
          onTap: () => Navigator.of(context).pop(),
          child: Icon(
            Icons.arrow_back_ios,
            color: context.iconColor,
            size: 18,
          ),
        ),
        title: Text(job.title ?? "Job Title", style: context.textTheme.headlineMedium),

        // Column(
        //   crossAxisAlignment: CrossAxisAlignment.start,
        //   children: [
        //     const Text("Job Applications", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        //     Text(job.title ?? "Job Title", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal)),
        //   ],
        // ),
        elevation: 0,
        backgroundColor: context.theme.scaffoldBackgroundColor,
        foregroundColor: context.theme.textTheme.bodyLarge?.color,
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.selectedJobApplications.isEmpty) {
          return _buildShimmerLoading();
        }

        if (controller.selectedJobApplications.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people_outline, size: 64, color: Colors.grey[300]),
                const SizedBox(height: 16),
                const Text("No applications yet", style: TextStyle(color: Colors.grey, fontSize: 16)),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.fetchJobApplications(job.id!),
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: controller.selectedJobApplications.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final application = controller.selectedJobApplications[index];
              return _buildApplicationCard(application);
            },
          ),
        );
      }),
    );
  }

  Widget _buildApplicationCard(JobApplication application) {
    final user = application.user;
    final status = application.status?.toLowerCase() ?? 'pending';
    
    Color statusColor;
    switch (status) {
      case 'accepted': statusColor = Colors.green; break;
      case 'rejected': statusColor = Colors.red; break;
      case 'reviewed': statusColor = Colors.blue; break;
      default: statusColor = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
        border: Border.all(color: context.theme.dividerColor.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: context.theme.primaryColor.withOpacity(0.1),
                child: Text(
                  (user?.name ?? "?").substring(0, 1).toUpperCase(),
                  style: TextStyle(color: context.theme.primaryColor, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user?.name ?? "Unknown Applicant", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 2),
                    Text(user?.email ?? "No email", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          if (user != null) ...[
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 14, color: Colors.blue),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    "${user.city ?? 'N/A'}, ${user.district ?? 'N/A'} → ${user.destination ?? 'N/A'}",
                    style: TextStyle(color: Colors.blue[700], fontSize: 13),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
          if (application.coverLetter != null && application.coverLetter!.isNotEmpty) ...[
            const Text("Cover Letter", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 4),
            Text(
              application.coverLetter!,
              style: TextStyle(color: Colors.grey[700], fontSize: 13, height: 1.4),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.access_time, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    "Applied on ${application.appliedAt?.split('T').first ?? 'N/A'}",
                    style: const TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                ],
              ),
              if (application.resumeUrl != null && application.resumeUrl!.isNotEmpty)
                TextButton.icon(
                  onPressed: () {
                    // Since url_launcher is not available, we show the URL
                    Get.defaultDialog(
                      title: "Resume Link",
                      content: Column(
                        children: [
                          const Text("You can view the resume at:"),
                          const SizedBox(height: 8),
                          SelectableText(ApiConstants.imageBaseUrl+application.resumeUrl!, style: const TextStyle(color: Colors.blue)),
                        ],
                      ),
                      confirm: ElevatedButton(
                        onPressed: () => Get.back(),
                        child: const Text("OK"),
                      ),
                    );
                  },
                  icon: const Icon(Icons.description_outlined, size: 16),
                  label: const Text("View Resume", style: TextStyle(fontSize: 12)),
                  style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                )
              else
                const Text(
                  "Resume not uploaded",
                  style: TextStyle(color: Colors.redAccent, fontSize: 11, fontStyle: FontStyle.italic),
                ),
            ],
          ),
          const SizedBox(height: 16),
          // Action Buttons: Review, Accept, Reject
          Row(
            children: [
              // Review Button
              Expanded(
                child: OutlinedButton(
                  onPressed: status == 'reviewed' 
                    ? null 
                    : () => _handleStatusUpdate(application, 'reviewed'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.blue,
                    side: const BorderSide(color: Colors.blue),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text("Review", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 8),
              // Reject Button
              Expanded(
                child: OutlinedButton(
                  onPressed: status == 'rejected' 
                    ? null 
                    : () => _handleStatusUpdate(application, 'rejected'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                    side: const BorderSide(color: Colors.redAccent),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text("Reject", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 8),
              // Accept Button
              Expanded(
                child: ElevatedButton(
                  onPressed: status == 'accepted' 
                    ? null 
                    : () => _handleStatusUpdate(application, 'accepted'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                  child: const Text("Accept", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (_, __) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: ShimmerLoading.rounded(height: 180),
      ),
    );
  }
}
