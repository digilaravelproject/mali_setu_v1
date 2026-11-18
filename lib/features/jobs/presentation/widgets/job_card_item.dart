import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constent/api_constants.dart';
import '../../../business/data/model/res_all_business_model.dart';

class JobCardItem extends StatelessWidget {
  final Job job;
  final bool isFavorite;
  final VoidCallback? onFavoriteTap;
  final VoidCallback? onTap;

  const JobCardItem({
    Key? key,
    required this.job,
    this.isFavorite = false,
    this.onFavoriteTap,
    this.onTap,
  }) : super(key: key);

  static const List<Color> _avatarColors = [
    Color(0xFF2563EB), // Royal Blue
    Color(0xFF7C3AED), // Purple
    Color(0xFF059669), // Emerald
    Color(0xFFD97706), // Amber
    Color(0xFFDB2777), // Pink
    Color(0xFF0284C7), // Sky Blue
    Color(0xFF4F46E5), // Indigo
  ];

  String _formatTimeAgo(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'Recent';
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final diff = now.difference(date);
      if (diff.inDays > 30) {
        final months = (diff.inDays / 30).floor();
        return '$months ${months == 1 ? 'month' : 'months'} ago';
      } else if (diff.inDays > 0) {
        return '${diff.inDays} ${diff.inDays == 1 ? 'day' : 'days'} ago';
      } else if (diff.inHours > 0) {
        return '${diff.inHours} ${diff.inHours == 1 ? 'hr' : 'hrs'} ago';
      } else if (diff.inMinutes > 0) {
        return '${diff.inMinutes} ${diff.inMinutes == 1 ? 'min' : 'mins'} ago';
      } else {
        return 'Just now';
      }
    } catch (_) {
      return dateStr;
    }
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
      return const Color(0xFFECFDF5); // Light mint green
    } else if (t.contains('part')) {
      return const Color(0xFFFFFBEB); // Light amber
    } else if (t.contains('remote')) {
      return const Color(0xFFEFF6FF); // Light blue
    } else if (t.contains('intern')) {
      return const Color(0xFFEEF2FF); // Light indigo
    } else if (t.contains('contract') || t.contains('freelance')) {
      return const Color(0xFFFAF5FF); // Light purple
    } else {
      return const Color(0xFFF1F5F9); // Slate grey
    }
  }

  Color _getTypeTextColor(String type) {
    final t = type.toLowerCase();
    if (t.contains('full')) {
      return const Color(0xFF059669); // Forest green
    } else if (t.contains('part')) {
      return const Color(0xFFD97706); // Amber
    } else if (t.contains('remote')) {
      return const Color(0xFF2563EB); // Royal blue
    } else if (t.contains('intern')) {
      return const Color(0xFF4F46E5); // Indigo
    } else if (t.contains('contract') || t.contains('freelance')) {
      return const Color(0xFF7C3AED); // Purple
    } else {
      return const Color(0xFF475569);
    }
  }

  @override
  Widget build(BuildContext context) {
    final companyName = (job.business?.businessName?.trim().isNotEmpty == true)
        ? job.business!.businessName!.trim()
        : 'Company';

    final location = (job.location?.trim().isNotEmpty == true)
        ? job.location!.trim()
        : (job.business?.city != null
            ? "${job.business?.city}${job.business?.state != null ? ', ${job.business?.state}' : ''}"
            : 'India');

    final employmentType = job.employmentType ?? job.jobType ?? 'Full Time';
    final workplaceType = (job.jobType != null && job.jobType != employmentType) ? job.jobType : null;
    final expLevel = job.experienceLevel;
    final salary = _formatSalary(job.salaryRange);
    final logoUrl = job.business?.photo?.trim();

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
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          splashColor: Colors.black.withOpacity(0.03),
          highlightColor: Colors.black.withOpacity(0.015),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Header Row: Logo, Job Title & Company/Location, Heart/Closed
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
                            job.title ?? 'Job Title',
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

                    // Status Badge (if expired) & Favorite Icon
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (job.isExpired) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                            margin: const EdgeInsets.only(right: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF2F2),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: const Color(0xFFFECACA),
                                width: 0.9,
                              ),
                            ),
                            child: const Text(
                              'Closed',
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFDC2626),
                                letterSpacing: 0.1,
                              ),
                            ),
                          ),
                        ],
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: onFavoriteTap,
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Icon(
                              isFavorite ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                              size: 20,
                              color: isFavorite ? const Color(0xFFE11D48) : const Color(0xFF94A3B8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Tags Row: Employment Type, Workplace Type, Experience Level
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    // Employment Type Badge (Full-time, Part-time, etc.)
                    _buildTagChip(
                      label: employmentType,
                      bgColor: _getTypeBackgroundColor(employmentType),
                      textColor: _getTypeTextColor(employmentType),
                    ),

                    // Workplace Type (Remote, On-site, Hybrid)
                    if (workplaceType != null && workplaceType.isNotEmpty)
                      _buildTagChip(
                        label: workplaceType,
                        bgColor: const Color(0xFFEFF6FF),
                        textColor: const Color(0xFF2563EB),
                      ),

                    // Experience Level
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

                // Bottom Row: Salary & Posted Time
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

                    // Posted Time
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.access_time_rounded,
                          size: 13,
                          color: Color(0xFF94A3B8),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatTimeAgo(job.createdAt),
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF94A3B8),
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

  Widget _buildFallbackLogo(String company) {
    final initial = company.trim().isNotEmpty ? company.trim()[0].toUpperCase() : 'M';
    final color = _avatarColors[company.hashCode.abs() % _avatarColors.length];
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
}
