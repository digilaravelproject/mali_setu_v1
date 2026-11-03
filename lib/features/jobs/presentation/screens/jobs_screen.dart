import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../core/constent/api_constants.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/whatsapp_support_fab.dart';
import '../../../business/data/model/res_all_business_model.dart';
import '../controller/jobs_controller.dart';
import '../widgets/job_card_item.dart';
import '../widgets/job_filter_sheet.dart';

class JobsScreen extends StatelessWidget {
  const JobsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<JobsController>()
        ? Get.find<JobsController>()
        : Get.put(JobsController());

    final theme = Theme.of(context);
    final topPadding = MediaQuery.of(context).padding.top;
    final canPop = Navigator.of(context).canPop();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF9FAFB),
        floatingActionButton: canPop
            ? const WhatsAppSupportFab(bottomPadding: 16)
            : null,
        body: Column(
          children: [
            SizedBox(height: topPadding + 8),

            // 1. App Bar Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(
                children: [
                  if (canPop) ...[
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Color(0xFF1F2937)),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => Get.back(),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Text(
                      'jobs'.tr,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111827),
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),

                  // Actions: Filter icon for All Jobs, Refresh icon for Applied Jobs
                  Obx(() {
                    if (controller.selectedMainTab.value == 0) {
                      final hasFilter = controller.activeFiltersCount > 0;
                      return IconButton(
                        icon: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Icon(
                              Icons.tune_rounded,
                              size: 22,
                              color: hasFilter ? theme.primaryColor : const Color(0xFF374151),
                            ),
                            if (hasFilter)
                              Positioned(
                                top: -2,
                                right: -2,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: theme.primaryColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () => _showFilterSheet(context, controller),
                      );
                    } else {
                      return IconButton(
                        icon: const Icon(Icons.refresh_rounded, size: 22, color: Color(0xFF374151)),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () => controller.fetchMyApplications(isRefresh: true),
                      );
                    }
                  }),
                ],
              ),
            ),

            const SizedBox(height: 6),

            // 2. Search Field Bar + Filter Button (At the top below Header)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 46,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFE5E7EB),
                          width: 1.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: controller.searchController,
                        onChanged: controller.onSearchChanged,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF1F2937),
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search jobs, company or keyword...',
                          hintStyle: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF9CA3AF),
                          ),
                          prefixIcon: const Icon(
                            CupertinoIcons.search,
                            size: 19,
                            color: Color(0xFF9CA3AF),
                          ),
                          suffixIcon: Obx(() {
                            if (controller.searchQuery.value.isNotEmpty) {
                              return GestureDetector(
                                onTap: controller.clearSearch,
                                child: const Icon(
                                  Icons.close_rounded,
                                  size: 18,
                                  color: Color(0xFF9CA3AF),
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          }),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          filled: false,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Filter Button beside search
                  InkWell(
                    onTap: () => _showFilterSheet(context, controller),
                    borderRadius: BorderRadius.circular(12),
                    child: Obx(() {
                      final hasFilter = controller.activeFiltersCount > 0;
                      return Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: hasFilter ? theme.primaryColor.withOpacity(0.08) : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: hasFilter ? theme.primaryColor : const Color(0xFFE5E7EB),
                            width: 1.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Icon(
                              Icons.filter_list_rounded,
                              size: 22,
                              color: hasFilter ? theme.primaryColor : const Color(0xFF374151),
                            ),
                            if (hasFilter)
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  width: 7,
                                  height: 7,
                                  decoration: BoxDecoration(
                                    color: theme.primaryColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // 3. Primary Tabs (Below Search Bar): "All Jobs" & "Applied Jobs"
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Obx(() {
                final selectedTab = controller.selectedMainTab.value;
                final totalCount = controller.totalJobsCount.value;
                final allJobsLabel = totalCount > 0 ? 'All Jobs ($totalCount)' : 'All Jobs';
                final appliedCount = controller.myApplications.length;
                final appliedLabel = appliedCount > 0 ? 'Applied Jobs ($appliedCount)' : 'Applied Jobs';

                return Container(
                  height: 44,
                  padding: const EdgeInsets.all(3.5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      // All Jobs Tab
                      Expanded(
                        child: InkWell(
                          onTap: () => controller.changeMainTab(0),
                          borderRadius: BorderRadius.circular(9),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: selectedTab == 0 ? Colors.white : Colors.transparent,
                              borderRadius: BorderRadius.circular(9),
                              boxShadow: selectedTab == 0
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.06),
                                        blurRadius: 4,
                                        offset: const Offset(0, 1),
                                      ),
                                    ]
                                  : null,
                            ),
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  CupertinoIcons.briefcase,
                                  size: 16,
                                  color: selectedTab == 0 ? theme.primaryColor : const Color(0xFF6B7280),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  allJobsLabel,
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: selectedTab == 0 ? FontWeight.w700 : FontWeight.w500,
                                    color: selectedTab == 0 ? theme.primaryColor : const Color(0xFF6B7280),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Applied Jobs Tab
                      Expanded(
                        child: InkWell(
                          onTap: () => controller.changeMainTab(1),
                          borderRadius: BorderRadius.circular(9),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: selectedTab == 1 ? Colors.white : Colors.transparent,
                              borderRadius: BorderRadius.circular(9),
                              boxShadow: selectedTab == 1
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.06),
                                        blurRadius: 4,
                                        offset: const Offset(0, 1),
                                      ),
                                    ]
                                  : null,
                            ),
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  CupertinoIcons.checkmark_seal,
                                  size: 16,
                                  color: selectedTab == 1 ? theme.primaryColor : const Color(0xFF6B7280),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  appliedLabel,
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: selectedTab == 1 ? FontWeight.w700 : FontWeight.w500,
                                    color: selectedTab == 1 ? theme.primaryColor : const Color(0xFF6B7280),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),

            const SizedBox(height: 10),

            // 4. Job List Body (Directly below Tabs)
            Expanded(
              child: Obx(() {
                if (controller.selectedMainTab.value == 0) {
                  return _buildAllJobsView(context, controller, theme);
                } else {
                  return _buildMyAppliedJobsView(context, controller, theme);
                }
              }),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // ALL JOBS VIEW
  // =========================================================================
  Widget _buildAllJobsView(BuildContext context, JobsController controller, ThemeData theme) {
    return Obx(() {
      if (controller.isLoading.value && controller.jobs.isEmpty) {
        return _buildShimmerLoading();
      }

      if (controller.jobs.isEmpty) {
        return _buildEmptyState(context, controller);
      }

      return RefreshIndicator(
        color: theme.primaryColor,
        onRefresh: () => controller.fetchJobs(isRefresh: true),
        child: ListView.builder(
          controller: controller.scrollController,
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: const EdgeInsets.only(top: 4, bottom: 85),
          itemCount: controller.jobs.length + (controller.isMoreLoading.value ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == controller.jobs.length) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: CupertinoActivityIndicator(),
                ),
              );
            }

            final job = controller.jobs[index];
            final isFav = controller.favoriteJobIds.contains(job.id);

            return JobCardItem(
              job: job,
              isFavorite: isFav,
              onFavoriteTap: () => controller.toggleFavorite(job.id),
              onTap: () {
                Get.toNamed(
                  AppRoutes.jobDetails,
                  arguments: job,
                );
              },
            );
          },
        ),
      );
    });
  }

  // =========================================================================
  // MY APPLIED JOBS VIEW
  // =========================================================================
  Widget _buildMyAppliedJobsView(BuildContext context, JobsController controller, ThemeData theme) {
    return Obx(() {
      if (controller.isMyApplicationsLoading.value && controller.myApplications.isEmpty) {
        return _buildShimmerLoading();
      }

      if (controller.myApplications.isEmpty) {
        return _buildEmptyAppliedState(context, controller);
      }

      return RefreshIndicator(
        color: theme.primaryColor,
        onRefresh: () => controller.fetchMyApplications(isRefresh: true),
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: const EdgeInsets.only(top: 4, bottom: 85),
          itemCount: controller.myApplications.length,
          itemBuilder: (context, index) {
            final application = controller.myApplications[index];
            return _buildAppliedJobCard(context, application, theme);
          },
        ),
      );
    });
  }

  Widget _buildAppliedJobCard(BuildContext context, JobApplication application, ThemeData theme) {
    final job = application.jobPosting;
    final business = job?.business;
    final companyName = business?.businessName ?? 'Company';
    final location = job?.location ?? (business?.city != null ? "${business?.city}, ${business?.state ?? ''}" : 'Maharashtra');
    final salary = job?.salaryRange ?? '';
    final employmentType = job?.employmentType ?? job?.jobType ?? 'Full Time';
    final logoUrl = business?.photo;
    final status = (application.status ?? 'pending').toLowerCase();

    Color statusColor;
    Color statusBgColor;
    String statusText;
    switch (status) {
      case 'approved':
      case 'accepted':
      case 'shortlisted':
        statusColor = const Color(0xFF059669);
        statusBgColor = const Color(0xFFECFDF5);
        statusText = 'Shortlisted';
        break;
      case 'rejected':
      case 'declined':
        statusColor = const Color(0xFFDC2626);
        statusBgColor = const Color(0xFFFEF2F2);
        statusText = 'Rejected';
        break;
      default:
        statusColor = const Color(0xFFD97706);
        statusBgColor = const Color(0xFFFFFBEB);
        statusText = 'Pending';
        break;
    }

    String appliedDateFormatted = '';
    if (application.appliedAt != null) {
      try {
        final date = DateTime.parse(application.appliedAt!);
        appliedDateFormatted = DateFormat('dd MMM yyyy').format(date);
      } catch (_) {
        appliedDateFormatted = application.appliedAt ?? '';
      }
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFF1F2F4),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () {
            if (job != null) {
              Get.toNamed(AppRoutes.jobDetails, arguments: job);
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Company Logo
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFE5E7EB),
                          width: 1.0,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: (logoUrl != null && logoUrl.isNotEmpty)
                            ? CachedNetworkImage(
                                imageUrl: logoUrl.startsWith('http')
                                    ? logoUrl
                                    : "${ApiConstants.imageBaseUrl}$logoUrl",
                                fit: BoxFit.cover,
                                errorWidget: (_, __, ___) => _buildFallbackLogo(companyName),
                              )
                            : _buildFallbackLogo(companyName),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Job Title & Company
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            job?.title ?? 'Applied Job',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF111827),
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            companyName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF4B5563),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                CupertinoIcons.location_solid,
                                size: 12.5,
                                color: Color(0xFF6B7280),
                              ),
                              const SizedBox(width: 3),
                              Expanded(
                                child: Text(
                                  location,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusBgColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Bottom Row: Salary / Type & Applied Date
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        if (salary.isNotEmpty) ...[
                          Text(
                            salary.startsWith('₹') ? salary : '₹ $salary',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            employmentType,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF4B5563),
                            ),
                          ),
                        ),
                      ],
                    ),

                    if (appliedDateFormatted.isNotEmpty)
                      Row(
                        children: [
                          const Icon(
                            CupertinoIcons.clock,
                            size: 12,
                            color: Color(0xFF9CA3AF),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Applied $appliedDateFormatted',
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyAppliedState(BuildContext context, JobsController controller) {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                CupertinoIcons.doc_text_search,
                size: 38,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'No Applied Jobs',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'You have not applied for any jobs yet. Browse available jobs and submit your application!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.5,
                color: Color(0xFF6B7280),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => controller.changeMainTab(0),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Explore Jobs',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF1F2F4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(width: 140, height: 14, color: Colors.grey[200]),
                        const SizedBox(height: 6),
                        Container(width: 90, height: 12, color: Colors.grey[200]),
                        const SizedBox(height: 6),
                        Container(width: 110, height: 10, color: Colors.grey[200]),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(width: 80, height: 14, color: Colors.grey[200]),
                  Container(width: 60, height: 14, color: Colors.grey[200]),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, JobsController controller) {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                CupertinoIcons.briefcase,
                size: 38,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'No Jobs Found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Try searching with different keywords or adjust your filters.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.5,
                color: Color(0xFF6B7280),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                controller.clearSearch();
                controller.setFilter('All');
                controller.resetSheetFilters();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Reset Filters',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackLogo(String companyName) {
    final initial = companyName.trim().isNotEmpty ? companyName.trim()[0].toUpperCase() : 'C';
    return Container(
      color: const Color(0xFFF3F4F6),
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4B5563),
          ),
        ),
      ),
    );
  }

  void _showFilterSheet(BuildContext context, JobsController controller) {
    JobFilterSheet.show(context, controller);
  }
}
