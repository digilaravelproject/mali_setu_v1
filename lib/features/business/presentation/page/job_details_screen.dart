import 'package:edu_cluezer/widgets/custom_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:edu_cluezer/features/business/data/model/res_all_business_model.dart';
import 'package:edu_cluezer/features/business/presentation/controller/business_controller.dart';
import 'package:edu_cluezer/features/business/presentation/controller/create_job_controller.dart';
import 'package:edu_cluezer/core/routes/app_routes.dart';
import 'package:edu_cluezer/core/widgets/shimmer_loading.dart';
import 'package:edu_cluezer/core/widgets/custom_confirm_dialog.dart';
import 'package:edu_cluezer/features/business/presentation/widget/job_apply_form.dart';

class JobDetailsScreen extends StatefulWidget {
  const JobDetailsScreen({super.key});

  @override
  State<JobDetailsScreen> createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends State<JobDetailsScreen> {
  final BusinessController controller = Get.find<BusinessController>();
  final Job initialJob = Get.arguments ?? Job();

  @override
  void initState() {
    super.initState();
    if (initialJob.id != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.fetchJobDetails(initialJob.id!);
      });
    }
  }

  void _handleEdit(Job job) {
    if (Get.isRegistered<CreateJobController>()) {
      final createJobCtrl = Get.find<CreateJobController>();
      createJobCtrl.populateFields(job);
      Get.toNamed(AppRoutes.createJob);
    } else {
      CustomSnackBar.showError(message: "Could not initialize job editor. Please try again.");
    }
  }

  void _handleDelete(int? jobId) {
    if (jobId == null) return;
    CustomConfirmDialog.show(
      title: "Delete Job Posting",
      message: "Are you sure you want to delete this job? This action cannot be undone.",
      confirmText: "Delete",
      confirmColor: Colors.redAccent,
      icon: Icons.delete_forever_outlined,
      onConfirm: () {
        controller.deleteJob(jobId);
      },
    );
  }

  void _handleToggleStatus(Job job) {
    if (job.id == null) return;
    final bool currentlyActive = job.isActive ?? false;
    CustomConfirmDialog.show(
      title: currentlyActive ? "Deactivate Job" : "Activate Job",
      message: currentlyActive 
          ? "Are you sure you want to deactivate this job posting? It will no longer be visible to applicants."
          : "Are you sure you want to activate this job posting? It will become visible to applicants.",
      confirmText: currentlyActive ? "Deactivate" : "Activate",
      confirmColor: currentlyActive ? Colors.redAccent : Colors.green,
      onConfirm: () {
        controller.toggleJobStatus(job.id!);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final Job job = controller.selectedJobDetail.value?.job ?? initialJob;
      final bool hasApplied = controller.selectedJobDetail.value?.hasApplied ?? false;
      final List<Job> similarJobs = controller.selectedJobDetail.value?.similarJobs ?? [];
      final bool isMyJob = controller.myBusinesses.any((b) => b.id != null && b.id == (job.businessId ?? job.business?.id));

      debugPrint("isMyJob value: $isMyJob, JobBusinessID: ${job.businessId ?? job.business?.id}");

      if (controller.isLoading.value && controller.selectedJobDetail.value == null) {
        return Scaffold(
          body: _buildShimmerLoading(context),
        );
      }

      return Scaffold(
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Premium App Bar with Background
            SliverAppBar(
              expandedHeight: 240,
              pinned: true,
              elevation: 0,
              backgroundColor: context.theme.primaryColor,
              leading: IconButton(
                onPressed: () => Get.back(),
                icon:
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.white),
                ),
              ),
              actions: [
                if (isMyJob)
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') _handleEdit(job);
                      if (value == 'delete') _handleDelete(job.id);
                      if (value == 'toggle') _handleToggleStatus(job);
                    },
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.more_vert, size: 18, color: Colors.white),
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 20, color: Colors.blue),
                            SizedBox(width: 12),
                            Text("Edit Job"),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'toggle',
                        child: Row(
                          children: [
                            Icon(Icons.visibility_off, size: 20, color: Colors.orange),
                            SizedBox(width: 12),
                            Text("Toggle Visibility"),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline, size: 20, color: Colors.red),
                            SizedBox(width: 12),
                            Text("Delete Job"),
                          ],
                        ),
                      ),
                    ],
                  ),
                
                // Share Action
                // IconButton(
                //   onPressed: () {},
                //   icon: Container(
                //     padding: const EdgeInsets.all(8),
                //     decoration: BoxDecoration(
                //       color: Colors.white.withOpacity(0.3),
                //       shape: BoxShape.circle,
                //     ),
                //     child: const Icon(Icons.share, size: 18, color: Colors.white),
                //   ),
                // ),
                const SizedBox(width: 8),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Background Image or Gradient
                    if (job.business?.photo != null)
                      Image.network(
                        job.business!.photo!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildFallbackHeader(),
                      )
                    else
                      _buildFallbackHeader(),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.4),
                            Colors.black.withOpacity(0.8),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 20,
                      left: 20,
                      right: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (job.category != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                job.category!.toUpperCase(),
                                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
                              ),
                            ),
                          const SizedBox(height: 8),
                          Text(
                            job.title ?? 'No Title',
                            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.business, color: Colors.white70, size: 16),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  job.business?.businessName ?? 'Unknown Company',
                                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                                  overflow: TextOverflow.ellipsis,
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

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Quick Stats Row
                    Row(
                      children: [
                        _buildStatCard(context, Icons.currency_rupee, "Salary", job.salaryRange ?? "N/A"),
                        const SizedBox(width: 12),
                        _buildStatCard(context, Icons.work_outline, "Type", job.jobType ?? "N/A"),
                        const SizedBox(width: 12),
                        _buildStatCard(context, Icons.groups_outlined, "Level", job.experienceLevel ?? "Entry"),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Section: Overview
                    _buildSectionHeader(context, "Overview"),
                    const SizedBox(height: 12),
                    Text(
                      job.description ?? "No description available.",
                      style: context.textTheme.bodyMedium?.copyWith(height: 1.5, color: context.textTheme.bodyMedium?.color?.withOpacity(0.8)),
                    ),
                    const SizedBox(height: 24),

                    // Section: Requirements
                    if (job.requirements != null && job.requirements!.isNotEmpty) ...[
                      _buildSectionHeader(context, "Requirements"),
                      const SizedBox(height: 12),
                      Text(
                        job.requirements!,
                        style: context.textTheme.bodyMedium?.copyWith(height: 1.5),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Section: Skills
                    if (job.skillsRequired != null && job.skillsRequired!.isNotEmpty) ...[
                      _buildSectionHeader(context, "Required Skills"),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: job.skillsRequired!.map((skill) => _buildChip(context, skill, Colors.blue)).toList(),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Section: Benefits
                    if (job.benefits != null && job.benefits!.isNotEmpty) ...[
                      _buildSectionHeader(context, "Benefits"),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: job.benefits!.map((benefit) => _buildChip(context, benefit, Colors.green)).toList(),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Section: About Business
                    if (job.business != null) ...[
                      _buildSectionHeader(context, "About ${job.business?.businessName}"),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: context.theme.cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: context.theme.dividerColor),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              job.business?.description ?? "No company information provided.",
                              style: context.textTheme.bodySmall,
                            ),
                            const Divider(height: 24),
                            _buildBusinessInfo(Icons.language, "Website", job.business?.website ?? "N/A"),
                            const SizedBox(height: 8),
                            _buildBusinessInfo(Icons.email_outlined, "Email", job.business?.contactEmail ?? "N/A"),
                            const SizedBox(height: 8),
                            _buildBusinessInfo(Icons.phone_outlined, "Phone", job.business?.contactPhone ?? "N/A"),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Section: Similar Jobs
                    if (similarJobs.isNotEmpty) ...[
                      _buildSectionHeader(context, "Similar Jobs"),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 140,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          itemCount: similarJobs.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 12),
                          itemBuilder: (context, index) {
                            final sJob = similarJobs[index];
                            return _buildSimilarJobCard(context, sJob);
                          },
                        ),
                      ),
                    ],
                    const SizedBox(height: 100), // Spacing for bottom action
                  ],
                ),
              ),
            ),
          ],
        ),
        bottomSheet: _buildBottomAction(context, hasApplied, job, isMyJob),
      );
    });
  }

  Widget _buildShimmerLoading(BuildContext context) {
    return CustomScrollView(
      physics: const NeverScrollableScrollPhysics(),
      slivers: [
        SliverAppBar(
          expandedHeight: 240,
          backgroundColor: Colors.grey[200],
          flexibleSpace: const ShimmerLoading.rectangular(height: 240),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: ShimmerLoading.rounded(height: 70)),
                    const SizedBox(width: 12),
                    Expanded(child: ShimmerLoading.rounded(height: 70)),
                    const SizedBox(width: 12),
                    Expanded(child: ShimmerLoading.rounded(height: 70)),
                  ],
                ),
                const SizedBox(height: 24),
                const ShimmerLoading.rounded(height: 20, width: 120),
                const SizedBox(height: 12),
                const ShimmerLoading.rounded(height: 80),
                const SizedBox(height: 24),
                const ShimmerLoading.rounded(height: 20, width: 120),
                const SizedBox(height: 12),
                const ShimmerLoading.rounded(height: 120),
                const SizedBox(height: 24),
                const ShimmerLoading.rounded(height: 20, width: 120),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const ShimmerLoading.rounded(height: 30, width: 80),
                    const SizedBox(width: 8),
                    const ShimmerLoading.rounded(height: 30, width: 80),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFallbackHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue.shade900, Colors.blue.shade400],
        ),
      ),
      child: const Center(
        child: Icon(Icons.business, color: Colors.white24, size: 80),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, IconData icon, String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: context.theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.theme.dividerColor),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: context.theme.primaryColor),
            const SizedBox(height: 4),
            Text(label, style: context.textTheme.bodySmall?.copyWith(fontSize: 10)),
            const SizedBox(height: 2),
            Text(value, style: context.textTheme.titleSmall?.copyWith(fontSize: 12, fontWeight: FontWeight.bold), textAlign: TextAlign.center, maxLines: 1),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, letterSpacing: 0.5),
    );
  }

  Widget _buildChip(BuildContext context, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildBusinessInfo(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        Text("$label: ", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis)),
      ],
    );
  }

  Widget _buildSimilarJobCard(BuildContext context, Job job) {
    return InkWell(
      onTap: () {
        Get.back();
        Get.toNamed(Get.currentRoute, arguments: job, preventDuplicates: false);
      },
      child: Container(
        width: 220,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: context.theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.theme.dividerColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(job.title ?? "Job Title", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Text(job.business?.businessName ?? "Company", style: const TextStyle(fontSize: 12, color: Colors.grey), maxLines: 1),
            const Spacer(),
            Row(
              children: [
                const Icon(Icons.currency_rupee, size: 12, color: Colors.green),
                Text(job.salaryRange ?? "N/A", style: const TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 12, color: Colors.blue),
                Expanded(child: Text(job.location ?? "N/A", style: const TextStyle(fontSize: 11, color: Colors.blue), maxLines: 1, overflow: TextOverflow.ellipsis)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomAction(BuildContext context, bool hasApplied, Job job, bool isMyJob) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.theme.scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5)),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: isMyJob 
                  ? () => Get.toNamed(AppRoutes.jobAppliers, arguments: job)
                  : (hasApplied ? null : () {
                      if (job.id != null) {
                        Get.bottomSheet(
                          JobApplyForm(jobId: job.id!),
                          isScrollControlled: true,
                        );
                      }
                    }),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isMyJob ? Colors.orange : context.theme.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: Text(
                  isMyJob ? "View Appliers" : (hasApplied ? "Applied" : "Apply Now"),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
            // if (!isMyJob) ...[
            //   const SizedBox(width: 12),
            //   Container(
            //     decoration: BoxDecoration(
            //       color: context.theme.primaryColor.withOpacity(0.1),
            //       borderRadius: BorderRadius.circular(12),
            //     ),
            //     child: IconButton(
            //       onPressed: () {},
            //       icon: Icon(Icons.bookmark_border, color: context.theme.primaryColor),
            //     ),
            //   ),
            // ],
          ],
        ),
      ),
    );
  }
}