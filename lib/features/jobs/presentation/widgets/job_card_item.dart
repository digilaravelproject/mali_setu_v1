import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
        return '${diff.inHours} ${diff.inHours == 1 ? 'hour' : 'hours'} ago';
      } else if (diff.inMinutes > 0) {
        return '${diff.inMinutes} ${diff.inMinutes == 1 ? 'min' : 'mins'} ago';
      } else {
        return 'Just now';
      }
    } catch (_) {
      return dateStr;
    }
  }

  Color _getTypeBackgroundColor(String type) {
    final t = type.toLowerCase();
    if (t.contains('full')) {
      return const Color(0xFFECFDF5); // Light mint green
    } else if (t.contains('part')) {
      return const Color(0xFFFFF7ED); // Light warm orange
    } else if (t.contains('remote')) {
      return const Color(0xFFEFF6FF); // Light blue
    } else if (t.contains('contract')) {
      return const Color(0xFFFAF5FF); // Light purple
    } else {
      return const Color(0xFFF3F4F6); // Neutral grey
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
    } else if (t.contains('contract')) {
      return const Color(0xFF7C3AED); // Purple
    } else {
      return const Color(0xFF4B5563);
    }
  }

  @override
  Widget build(BuildContext context) {
    final companyName = job.business?.businessName ?? 'Company';
    final location = job.location ?? (job.business?.city != null ? "${job.business?.city}, ${job.business?.state ?? ''}" : 'Maharashtra');
    final employmentType = job.employmentType ?? job.jobType ?? 'Full Time';
    final salary = job.salaryRange ?? 'Best in Industry';
    final logoUrl = job.business?.photo;

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
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          splashColor: Colors.black.withOpacity(0.04),
          highlightColor: Colors.black.withOpacity(0.02),
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Row: Logo, Info (Title, Company, Location), Heart
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Company Logo Container
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
                                placeholder: (context, url) => Container(
                                  color: const Color(0xFFF3F4F6),
                                  child: const Center(
                                    child: CupertinoActivityIndicator(radius: 8),
                                  ),
                                ),
                                errorWidget: (context, url, error) => _buildFallbackLogo(companyName),
                              )
                            : _buildFallbackLogo(companyName),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Job Title, Company, Location
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

                    // Heart / Favorite Icon
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: onFavoriteTap,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 6, bottom: 6),
                        child: Icon(
                          isFavorite ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                          size: 21,
                          color: isFavorite ? const Color(0xFFE11D48) : const Color(0xFF9CA3AF),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Bottom Row: Salary, Badge, Posted Time
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Salary
                    Text(
                      salary.startsWith('₹') ? salary : '₹ $salary',
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1F2937),
                        letterSpacing: -0.1,
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Job Type Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                      decoration: BoxDecoration(
                        color: _getTypeBackgroundColor(employmentType),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        employmentType,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: _getTypeTextColor(employmentType),
                        ),
                      ),
                    ),

                    const Spacer(),

                    // Posted Time
                    Text(
                      _formatTimeAgo(job.createdAt),
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF9CA3AF),
                      ),
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

  Widget _buildFallbackLogo(String company) {
    final initial = company.trim().isNotEmpty ? company.trim()[0].toUpperCase() : 'M';
    return Container(
      color: const Color(0xFFF3F4F6),
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4B5563),
          ),
        ),
      ),
    );
  }
}

