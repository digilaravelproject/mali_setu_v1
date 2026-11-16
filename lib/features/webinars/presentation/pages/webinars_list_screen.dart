import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/styles/app_colors.dart';
import '../controllers/webinars_controller.dart';
import '../widgets/webinar_card.dart';
import '../widgets/webinar_notice_dialog.dart';
import 'webinar_details_screen.dart';
import 'webinar_live_screen.dart';

class WebinarsListScreen extends StatelessWidget {
  const WebinarsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<WebinarsController>()
        ? Get.find<WebinarsController>()
        : Get.put(WebinarsController());

    final categories = ['All', 'Business', 'Matrimony', 'Other'];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: const Center(
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 18,
              color: AppColors.lightTextPrimary,
            ),
          ),
        ),
        titleSpacing: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Webinars & Video Sessions",
              style: TextStyle(
                fontSize: 17.5,
                fontWeight: FontWeight.w800,
                color: AppColors.lightTextPrimary,
                letterSpacing: -0.2,
              ),
            ),
            SizedBox(height: 1),
            Text(
              "Live sessions, expert talks and community discussions",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.lightTextSecondary,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Category Filter Tabs
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: categories.map((cat) {
                return Obx(() {
                  final isSelected = controller.selectedCategory.value == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: GestureDetector(
                      onTap: () => controller.setCategory(cat),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected ? AppColors.primary : AppColors.lightBorder,
                            width: 1.0,
                          ),
                        ),
                        child: Text(
                          cat,
                          style: TextStyle(
                            color: isSelected ? Colors.white : AppColors.lightTextSecondary,
                            fontSize: 12.5,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  );
                });
              }).toList(),
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: SizedBox(
              height: 44,
              child: TextField(
                controller: controller.searchController,
                onChanged: controller.onSearchChanged,
                onSubmitted: controller.onSearchSubmitted,
                style: const TextStyle(
                  fontSize: 13.5,
                  color: AppColors.lightTextPrimary,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: "Search webinars...",
                  hintStyle: const TextStyle(
                    fontSize: 13,
                    color: AppColors.lightTextDisabled,
                  ),
                  prefixIcon: const Icon(
                    CupertinoIcons.search,
                    size: 17,
                    color: AppColors.lightTextDisabled,
                  ),
                  suffixIcon: Obx(() {
                    if (controller.searchQuery.value.isNotEmpty) {
                      return GestureDetector(
                        onTap: controller.clearSearch,
                        child: const Icon(Icons.clear_rounded, size: 16, color: Colors.grey),
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.lightBorder, width: 1.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.lightBorder, width: 1.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
            ),
          ),

          const Divider(height: 1, thickness: 0.8, color: AppColors.lightDivider),

          // Webinar Cards List with Pull-to-Refresh & Pagination
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.webinars.isEmpty) {
                return const Center(
                  child: CupertinoActivityIndicator(radius: 14),
                );
              }

              final list = controller.filteredWebinars;

              if (list.isEmpty) {
                return RefreshIndicator(
                  onRefresh: () => controller.fetchWebinars(isRefresh: true),
                  color: AppColors.primary,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(height: Get.height * 0.18),
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: const BoxDecoration(
                                color: AppColors.primaryLight,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.video_library_outlined,
                                size: 38,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              "No Webinars Found",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.lightTextPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              "Try a different search or filter category",
                              style: TextStyle(
                                fontSize: 12.5,
                                color: AppColors.lightTextSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () => controller.fetchWebinars(isRefresh: true),
                color: AppColors.primary,
                child: ListView.builder(
                  controller: controller.scrollController,
                  padding: const EdgeInsets.only(top: 8, bottom: 24),
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  itemCount: list.length + (controller.isLoadingMore.value ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == list.length) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: CupertinoActivityIndicator(),
                        ),
                      );
                    }

                    final webinar = list[index];
                    return WebinarCard(
                      webinar: webinar,
                      onTap: () {
                        controller.selectWebinar(webinar);
                        Get.to(
                          () => WebinarDetailsScreen(webinar: webinar),
                          transition: Transition.cupertino,
                        );
                      },
                      onRegisterTap: () {
                        controller.selectWebinar(webinar);
                        final isReg = controller.isWebinarRegistered(webinar.id) || webinar.isRegistered;
                        final needsRegistration = webinar.requireRegistration && !isReg;

                        if (webinar.isCompleted) {
                          Get.to(
                            () => WebinarDetailsScreen(webinar: webinar),
                            transition: Transition.cupertino,
                          );
                        } else if (needsRegistration) {
                          // Direct register on click!
                          controller.registerForWebinar(webinar.id);
                        } else if (webinar.isLiveSession) {
                          Get.to(
                            () => WebinarLiveScreen(webinar: webinar),
                            transition: Transition.fadeIn,
                          );
                        } else {
                          // Already registered & Upcoming: session has not started yet
                          WebinarNoticeDialog.showUpcoming(
                            context: context,
                            dateString: webinar.dateString,
                            timeString: webinar.timeString,
                          );
                        }
                      },
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
