import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../core/constent/api_constants.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/whatsapp_support_fab.dart';
import '../../../../core/widgets/profile_app_bar_button.dart';
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

                  // Action in Top Bar: Refresh for Applied Jobs
                  Obx(() {
                    if (controller.selectedMainTab.value == 1) {
                      return IconButton(
                        icon: const Icon(Icons.refresh_rounded, size: 22, color: Color(0xFF374151)),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () => controller.fetchMyApplications(isRefresh: true),
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                  const SizedBox(width: 14),
                  const ProfileAppBarButton(),
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
                            if (controller.isLoading.value) {
                              return Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CupertinoActivityIndicator(
                                    radius: 8,
                                    color: theme.primaryColor,
                                  ),
                                ),
                              );
                            }
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
                      final count = controller.activeFiltersCount;
                      final hasFilter = count > 0;
                      return Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: hasFilter ? theme.primaryColor.withOpacity(0.09) : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: hasFilter ? theme.primaryColor : const Color(0xFFE2E8F0),
                            width: 1.0,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x08000000),
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Icon(
                              Icons.tune_rounded,
                              size: 21,
                              color: hasFilter ? theme.primaryColor : const Color(0xFF374151),
                            ),
                            if (hasFilter)
                              Positioned(
                                top: 5,
                                right: 5,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: theme.primaryColor,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 16,
                                    minHeight: 16,
                                  ),
                                  child: Text(
                                    '$count',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                      height: 1,
                                    ),
                                    textAlign: TextAlign.center,
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
    return RefreshIndicator(
      color: theme.primaryColor,
      onRefresh: () => controller.fetchJobs(isRefresh: true),
      child: Obx(() {
        if (controller.isLoading.value && controller.jobs.isEmpty) {
          return _buildShimmerLoading();
        }

        if (controller.jobs.isEmpty) {
          return _buildEmptyState(context, controller);
        }

        return Stack(
          children: [
            ListView.builder(
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
            if (controller.isLoading.value)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: LinearProgressIndicator(
                  minHeight: 2.5,
                  color: theme.primaryColor,
                  backgroundColor: theme.primaryColor.withOpacity(0.12),
                ),
              ),
          ],
        );
      }),
    );
  }

  // =========================================================================
  // MY APPLIED JOBS VIEW
  // =========================================================================
  Widget _buildMyAppliedJobsView(BuildContext context, JobsController controller, ThemeData theme) {
    return RefreshIndicator(
      color: theme.primaryColor,
      onRefresh: () => controller.fetchMyApplications(isRefresh: true),
      child: Obx(() {
        if (controller.isMyApplicationsLoading.value && controller.myApplications.isEmpty) {
          return _buildShimmerLoading();
        }

        if (controller.myApplications.isEmpty) {
          return _buildEmptyAppliedState(context, controller);
        }

        return ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: const EdgeInsets.only(top: 4, bottom: 85),
          itemCount: controller.myApplications.length,
          itemBuilder: (context, index) {
            final application = controller.myApplications[index];
            return _buildAppliedJobCard(context, application, theme);
          },
        );
      }),
    );
  }

  Widget _buildAppliedJobCard(BuildContext context, JobApplication application, ThemeData theme) {
    final job = application.jobPosting;
    final business = job?.business;
    final companyName = (business?.businessName?.trim().isNotEmpty == true)
        ? business!.businessName!.trim()
        : 'Company';
    final location = (job?.location?.trim().isNotEmpty == true)
        ? job!.location!.trim()
        : (business?.city != null
            ? "${business?.city}${business?.state != null ? ', ${business?.state}' : ''}"
            : 'India');
    final employmentType = job?.employmentType ?? job?.jobType ?? 'Full Time';
    final workplaceType = (job?.jobType != null && job?.jobType != employmentType) ? job!.jobType : null;
    final expLevel = job?.experienceLevel;
    final salary = _formatSalary(job?.salaryRange);
    final logoUrl = business?.photo?.trim();
    final status = (application.status ?? 'pending').toLowerCase();

    Color statusColor;
    Color statusBgColor;
    String statusText;
    switch (status) {
      case 'reviewed':
        statusColor = const Color(0xFF2563EB);
        statusBgColor = const Color(0xFFEFF6FF);
        statusText = 'reviewed'.tr.isNotEmpty && 'reviewed'.tr != 'reviewed'
            ? 'reviewed'.tr
            : 'Reviewed';
        break;
      case 'shortlisted':
        statusColor = const Color(0xFF7C3AED);
        statusBgColor = const Color(0xFFF5F3FF);
        statusText = 'shortlisted'.tr.isNotEmpty && 'shortlisted'.tr != 'shortlisted'
            ? 'shortlisted'.tr
            : 'Shortlisted';
        break;
      case 'approved':
      case 'accepted':
      case 'selected':
      case 'hired':
        statusColor = const Color(0xFF059669);
        statusBgColor = const Color(0xFFECFDF5);
        statusText = 'accepted'.tr.isNotEmpty && 'accepted'.tr != 'accepted'
            ? 'accepted'.tr
            : 'Accepted';
        break;
      case 'rejected':
      case 'declined':
        statusColor = const Color(0xFFDC2626);
        statusBgColor = const Color(0xFFFEF2F2);
        statusText = 'rejected'.tr.isNotEmpty && 'rejected'.tr != 'rejected'
            ? 'rejected'.tr
            : 'Rejected';
        break;
      case 'pending':
      case 'submitted':
      default:
        statusColor = const Color(0xFFD97706);
        statusBgColor = const Color(0xFFFFFBEB);
        statusText = 'pending'.tr.isNotEmpty && 'pending'.tr != 'pending'
            ? 'pending'.tr
            : (status.isNotEmpty ? status[0].toUpperCase() + status.substring(1) : 'Pending');
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
          color: const Color(0xFFE2E8F0),
          width: 1.0,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
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
          splashColor: Colors.black.withOpacity(0.03),
          highlightColor: Colors.black.withOpacity(0.015),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Header Row: Logo, Job Title & Company/Location, Status Badge
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Company Monogram / Logo
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFE2E8F0),
                          width: 1.0,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(11),
                        child: (logoUrl != null &&
                                logoUrl.isNotEmpty &&
                                !logoUrl.contains('null'))
                            ? CachedNetworkImage(
                                imageUrl: logoUrl.startsWith('http')
                                    ? logoUrl
                                    : "${ApiConstants.imageBaseUrl}$logoUrl",
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color: const Color(0xFFF8FAFC),
                                  child: const Center(
                                    child: CupertinoActivityIndicator(radius: 8),
                                  ),
                                ),
                                errorWidget: (context, url, error) =>
                                    _buildFallbackLogo(companyName),
                              )
                            : _buildFallbackLogo(companyName),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Job Title & Company Name
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
                              color: Color(0xFF0F172A),
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  companyName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF475569),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 5),
                              const Text(
                                "•",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF94A3B8),
                                ),
                              ),
                              const SizedBox(width: 5),
                              const Icon(
                                CupertinoIcons.location_solid,
                                size: 12,
                                color: Color(0xFF64748B),
                              ),
                              const SizedBox(width: 2),
                              Flexible(
                                child: Text(
                                  location,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xFF64748B),
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
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                      decoration: BoxDecoration(
                        color: statusBgColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: statusColor,
                          letterSpacing: 0.1,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Tags Row: Employment Type, Workplace Type, Experience Level
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _buildTagChip(
                      label: employmentType,
                      bgColor: _getTypeBackgroundColor(employmentType),
                      textColor: _getTypeTextColor(employmentType),
                    ),
                    if (workplaceType != null && workplaceType.isNotEmpty)
                      _buildTagChip(
                        label: workplaceType,
                        bgColor: const Color(0xFFEFF6FF),
                        textColor: const Color(0xFF2563EB),
                      ),
                    if (expLevel != null && expLevel.isNotEmpty)
                      _buildTagChip(
                        label: expLevel,
                        bgColor: const Color(0xFFF1F5F9),
                        textColor: const Color(0xFF475569),
                      ),
                  ],
                ),

                const SizedBox(height: 12),
                const Divider(color: Color(0xFFF1F5F9), height: 1, thickness: 1),
                const SizedBox(height: 10),

                // Bottom Row: Salary & Applied Date
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Salary
                    Expanded(
                      child: Text(
                        salary,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                          letterSpacing: -0.1,
                        ),
                      ),
                    ),

                    // Applied Date
                    if (appliedDateFormatted.isNotEmpty)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.calendar_today_rounded,
                            size: 12,
                            color: Color(0xFF94A3B8),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Applied $appliedDateFormatted',
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF64748B),
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

  String _formatSalary(String? raw) {
    if (raw == null || raw.trim().isEmpty) return 'Best in Industry';
    var s = raw.trim();
    s = s.replaceAll('₹', '').replaceAll('Rs.', '').replaceAll('Rs', '').replaceAll('INR', '').trim();

    final indianFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    if (s.contains('-')) {
      final parts = s.split('-');
      if (parts.length == 2) {
        final n1 = int.tryParse(parts[0].trim().replaceAll(',', ''));
        final n2 = int.tryParse(parts[1].trim().replaceAll(',', ''));
        if (n1 != null && n2 != null) {
          return '${indianFormat.format(n1)} - ${indianFormat.format(n2)}';
        }
      }
    } else {
      final n = int.tryParse(s.replaceAll(',', ''));
      if (n != null) {
        return indianFormat.format(n);
      }
    }

    return raw.startsWith('₹') ? raw : '₹$raw';
  }

  Color _getTypeBackgroundColor(String type) {
    final t = type.toLowerCase();
    if (t.contains('full')) {
      return const Color(0xFFECFDF5);
    } else if (t.contains('part')) {
      return const Color(0xFFFFFBEB);
    } else if (t.contains('remote')) {
      return const Color(0xFFEFF6FF);
    } else if (t.contains('intern')) {
      return const Color(0xFFEEF2FF);
    } else if (t.contains('contract') || t.contains('freelance')) {
      return const Color(0xFFFAF5FF);
    } else {
      return const Color(0xFFF1F5F9);
    }
  }

  Color _getTypeTextColor(String type) {
    final t = type.toLowerCase();
    if (t.contains('full')) {
      return const Color(0xFF059669);
    } else if (t.contains('part')) {
      return const Color(0xFFD97706);
    } else if (t.contains('remote')) {
      return const Color(0xFF2563EB);
    } else if (t.contains('intern')) {
      return const Color(0xFF4F46E5);
    } else if (t.contains('contract') || t.contains('freelance')) {
      return const Color(0xFF7C3AED);
    } else {
      return const Color(0xFF475569);
    }
  }

  Widget _buildTagChip({
    required String label,
    required Color bgColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor,
          letterSpacing: 0.1,
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
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
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

  static const List<Color> _avatarColors = [
    Color(0xFF2563EB),
    Color(0xFF7C3AED),
    Color(0xFF059669),
    Color(0xFFD97706),
    Color(0xFFDB2777),
    Color(0xFF0284C7),
    Color(0xFF4F46E5),
  ];

  Widget _buildFallbackLogo(String companyName) {
    final initial = companyName.trim().isNotEmpty ? companyName.trim()[0].toUpperCase() : 'C';
    final color = _avatarColors[companyName.hashCode.abs() % _avatarColors.length];
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Center(
        child: Text(
          initial,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ),
    );
  }

  void _showFilterSheet(BuildContext context, JobsController controller) {
    JobFilterSheet.show(context, controller);
  }
}
