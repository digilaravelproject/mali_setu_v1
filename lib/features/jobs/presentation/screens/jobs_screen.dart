import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/whatsapp_support_fab.dart';
import '../controller/jobs_controller.dart';
import '../widgets/job_card_item.dart';

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
                  // Filter icon in header
                  IconButton(
                    icon: const Icon(Icons.tune_rounded, size: 22, color: Color(0xFF374151)),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => _showFilterSheet(context, controller),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 6),

            // 2. Search Field Bar
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
                    child: Container(
                      width: 46,
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
                      child: const Center(
                        child: Icon(
                          Icons.filter_list_rounded,
                          size: 22,
                          color: Color(0xFF374151),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // 3. Quick Filter Chips (Horizontal Scroll)
            SizedBox(
              height: 36,
              child: Obx(() {
                final totalCount = controller.totalJobsCount.value;
                final allLabel = totalCount > 0 ? 'All ($totalCount)' : 'All';
                final chips = [
                  allLabel,
                  'Full Time',
                  'Part Time',
                  'Remote',
                  'Contract',
                  'Internship',
                ];

                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: chips.length,
                  itemBuilder: (context, index) {
                    final chip = chips[index];
                    final isSelected = (index == 0 && (controller.selectedFilter.value == 'All' || controller.selectedFilter.value.startsWith('All'))) ||
                        controller.selectedFilter.value == chip;

                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: InkWell(
                        onTap: () {
                          if (index == 0) {
                            controller.setFilter('All');
                          } else {
                            controller.setFilter(chip);
                          }
                        },
                        borderRadius: BorderRadius.circular(10),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? theme.primaryColor.withOpacity(0.06)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected
                                  ? theme.primaryColor
                                  : const Color(0xFFE5E7EB),
                              width: isSelected ? 1.5 : 1.0,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            chip,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected ? theme.primaryColor : const Color(0xFF4B5563),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),
            ),

            const SizedBox(height: 10),

            // 4. Job List Body
            Expanded(
              child: Obx(() {
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
              }),
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

  void _showFilterSheet(BuildContext context, JobsController controller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            top: 16,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sheet Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title and Reset
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Filter Jobs',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF111827),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      controller.resetSheetFilters();
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Reset All',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 20),

              // Employment Type Selection
              const Text(
                'Employment Type',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF374151),
                ),
              ),
              const SizedBox(height: 10),
              Obx(() {
                final types = ['All', 'Full Time', 'Part Time', 'Remote', 'Contract', 'Internship'];
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: types.map((type) {
                    final isSel = (type == 'All' && (controller.selectedFilter.value == 'All' || controller.selectedFilter.value.startsWith('All'))) ||
                        controller.selectedFilter.value == type;
                    return ChoiceChip(
                      label: Text(type),
                      selected: isSel,
                      selectedColor: Theme.of(context).primaryColor.withOpacity(0.12),
                      backgroundColor: const Color(0xFFF3F4F6),
                      labelStyle: TextStyle(
                        fontSize: 12.5,
                        fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                        color: isSel ? Theme.of(context).primaryColor : const Color(0xFF374151),
                      ),
                      onSelected: (val) {
                        controller.setFilter(type);
                      },
                    );
                  }).toList(),
                );
              }),

              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: const BorderSide(color: Color(0xFFD1D5DB)),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF4B5563),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        controller.applyFilters();
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Apply Filters',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

