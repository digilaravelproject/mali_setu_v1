import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:edu_cluezer/features/business/presentation/controller/business_controller.dart';
import 'package:edu_cluezer/features/business/binding/business_binding.dart';
import 'package:edu_cluezer/features/business/data/model/res_all_business_model.dart';
import 'package:edu_cluezer/core/widgets/shimmer_loading.dart';
import 'package:edu_cluezer/core/constent/api_constants.dart';
import 'package:edu_cluezer/core/widgets/whatsapp_support_fab.dart';

class AppliedJobsScreen extends StatefulWidget {
  @override
  _AppliedJobsScreenState createState() => _AppliedJobsScreenState();
}

class _AppliedJobsScreenState extends State<AppliedJobsScreen> {
  BusinessController get controller {
    if (!Get.isRegistered<BusinessController>()) {
      BusinessBinding().dependencies();
    }
    return Get.find<BusinessController>();
  }

  @override
  void initState() {
    super.initState();
    if (controller.myApplications.isEmpty) {
      controller.isMyApplicationsLoading.value = true;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchMyApplications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: const WhatsAppSupportFab(bottomPadding: 16),
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
        if (controller.isMyApplicationsLoading.value && controller.myApplications.isEmpty) {
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

  Widget _buildApplicationCard(JobApplication application) {
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
      margin: const EdgeInsets.only(bottom: 12),
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
          onTap: () => _showApplicationDetail(application),
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

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'reviewed':
        color = const Color(0xFF2563EB);
        break;
      case 'shortlisted':
        color = const Color(0xFF7C3AED);
        break;
      case 'accepted':
      case 'approved':
      case 'selected':
      case 'hired':
        color = const Color(0xFF059669);
        break;
      case 'rejected':
      case 'declined':
        color = const Color(0xFFDC2626);
        break;
      default:
        color = const Color(0xFFD97706);
    }

    final rawStatus = status.toLowerCase();
    final localized = rawStatus.tr;
    final displayText = (localized.isNotEmpty && localized != rawStatus)
        ? localized
        : (rawStatus.isNotEmpty ? rawStatus[0].toUpperCase() + rawStatus.substring(1) : 'Pending');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        displayText,
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
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
      Material(
        color: context.theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(24),
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
                if (application.resumeUrl != null && application.resumeUrl!.isNotEmpty) ...[
                  _buildDetailItem("resume".tr, "available_online".tr),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        try {
                          final resumeUrl = application.resumeUrl!;
                          final isUrlAbsolute = resumeUrl.startsWith('http');
                          final fullUrl = isUrlAbsolute ? resumeUrl : ApiConstants.imageBaseUrl + resumeUrl;
                          await controller.viewResume(fullUrl, applicantName: application.jobPosting?.title);
                        } catch (e) {
                          Get.snackbar("Error", "Could not open resume");
                        }
                      },
                      icon: const Icon(Icons.remove_red_eye_outlined),
                      label: Text("view_resume".tr),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.theme.primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
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
