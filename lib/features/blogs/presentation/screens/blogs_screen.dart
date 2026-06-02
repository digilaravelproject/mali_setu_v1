import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/constent/api_constants.dart';
import '../controller/blog_controller.dart';
import '../../data/model/blog_model.dart';
import 'blog_detail_screen.dart';
import 'create_blogs.dart';
import '../widgets/video_thumbnail_widget.dart';
import '../../../Auth/service/auth_service.dart';
import 'package:flutter/cupertino.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../notification/presentation/controller/notification_controller.dart';

String _formatDate(String? dateStr) {
  if (dateStr == null || dateStr.isEmpty) return '';
  try {
    final date = DateTime.parse(dateStr);
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  } catch (e) {
    return dateStr.split('T').first;
  }
}

class BlogsScreen extends StatelessWidget {
  const BlogsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(BlogController());
    final primaryColor = context.theme.primaryColor;
    final topPadding = MediaQuery.of(context).padding.top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF9FAFB), // Extremely clean cool grey background
        body: RefreshIndicator(
          color: primaryColor,
          onRefresh: () {
            if (controller.selectedTab.value == 'Mine') {
              return controller.fetchMyBlogs();
            }
            return controller.fetchBlogs(refresh: true);
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // Clean Header (No pink gradient, simple & premium)
              SliverToBoxAdapter(
                child: Container(
                  padding: EdgeInsets.only(top: topPadding + 16, bottom: 8, left: 16, right: 16),
                  color: Colors.white, // Solid pure white for top header
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Professional Custom App Bar
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Icon(Icons.menu_rounded, color: const Color(0xFF374151), size: 24),
                          Text(
                            'blogs'.tr,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: primaryColor,
                              fontFamily: 'Nunito-Bold',
                              letterSpacing: -0.5,
                            ),
                          ),
                          Obx(() {
                            int count = 0;
                            try {
                              final notificationController = Get.find<NotificationController>();
                              count = notificationController.unreadCount.value;
                            } catch (e) { count = 0; }
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: InkWell(
                                onTap: () => Get.toNamed(AppRoutes.notification),
                                child: Badge(
                                  label: Text(count > 99 ? '99+' : count.toString()),
                                  isLabelVisible: count > 0,
                                  backgroundColor: Colors.redAccent,
                                  child: const Icon(CupertinoIcons.bell, color: Colors.black87, size: 24),
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Search Bar
                      _buildSearchBar(controller, primaryColor),
                    ],
                  ),
                ),
              ),

              // Horizontal Category chips list (Floating just below top header)
              SliverToBoxAdapter(
                child: Obx(() => controller.selectedTab.value == 'Mine'
                    ? const SizedBox.shrink()
                    : Container(
                        color: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: _buildCategoryTabs(controller, primaryColor),
                      )),
              ),

              // Blog list
              Obx(() {
                final isMine = controller.selectedTab.value == 'Mine';
                final loading = isMine ? controller.isMyBlogsLoading.value : controller.isLoading.value;
                final empty = isMine ? controller.myBlogs.isEmpty : controller.blogs.isEmpty;

                if (loading && empty) {
                  return SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                            (context, index) => _buildShimmerCard(),
                        childCount: 4,
                      ),
                    ),
                  );
                }

                if (controller.filteredBlogs.isEmpty) {
                  return SliverFillRemaining(
                    child: _buildEmptyState(primaryColor),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (context, index) {
                        final blog = controller.filteredBlogs[index];
                        return _buildBlogCard(context, blog, primaryColor, controller);
                      },
                      childCount: controller.filteredBlogs.length,
                    ),
                  ),
                );
              }),
            ],
          ),
        ),

        // Sleek Extended FAB [ + Write Blog ] which looks extremely professional
        floatingActionButton: Obx(() {
          if (!Get.isRegistered<AuthService>()) return const SizedBox.shrink();
          final authService = Get.find<AuthService>();
          final user = authService.currentUser.value;
          final isBlogger = user?.userType?.toLowerCase().trim() == 'bloger';
          if (!isBlogger) return const SizedBox.shrink();

          return GestureDetector(
            onTap: () => Get.to(() => const CreateBlogScreen()),
            child: Container(
              height: 56,
              width: 56,
              margin: const EdgeInsets.only(bottom: 100), // Lift above bottom navigation bar
              decoration: BoxDecoration(
                color: primaryColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(Icons.add_rounded, color: Colors.white, size: 30),
            ),
          );
        }),
      ),
    );
  }

  // Premium, corporate underlined tab bar matching clean guidelines
/*  Widget _buildUnderlineTabs(BlogController controller, Color primaryColor) {
    return Obx(() {
      final selected = controller.selectedTab.value;
      return Container(
        height: 44,
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1.5),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: _buildTabItem(
                title: "other_blogs".tr,
                isSelected: selected == 'Others',
                onTap: () => controller.filterByTab('Others'),
                primaryColor: primaryColor,
              ),
            ),
            Expanded(
              child: _buildTabItem(
                title: "my_blogs".tr,
                isSelected: selected == 'Mine',
                onTap: () => controller.filterByTab('Mine'),
                primaryColor: primaryColor,
              ),
            ),
          ],
        ),
      );
    });
  }*/


  Widget _buildUnderlineTabs(BlogController controller, Color primaryColor) {
    bool showBlogTabs = false;

    if (Get.isRegistered<AuthService>()) {
      final authService = Get.find<AuthService>();
      final user = authService.currentUser.value;

      final isBlogger = user?.userType?.toLowerCase().trim() == 'bloger';

      showBlogTabs = isBlogger;
    }

    if (!showBlogTabs) {
      if (controller.selectedTab.value == 'Mine') {
        controller.filterByTab('Others');
      }
      return const SizedBox.shrink();
    }

    return Obx(() {
      final selected = controller.selectedTab.value;

      return Container(
        height: 44,
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Color(0xFFE5E7EB),
              width: 1.5,
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: _buildTabItem(
                title: "other_blogs".tr,
                isSelected: selected == 'Others',
                onTap: () => controller.filterByTab('Others'),
                primaryColor: primaryColor,
              ),
            ),
            Expanded(
              child: _buildTabItem(
                title: "my_blogs".tr,
                isSelected: selected == 'Mine',
                onTap: () => controller.filterByTab('Mine'),
                primaryColor: primaryColor,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildTabItem({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
    required Color primaryColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          color: Colors.transparent, // Ensures entire area of the Expanded tab is tappable
          border: Border(
            bottom: BorderSide(
              color: isSelected ? primaryColor : Colors.transparent,
              width: 3.0,
            ),
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? const Color(0xFF111827) : const Color(0xFF9CA3AF),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            fontSize: 15,
            letterSpacing: -0.1,
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerCard() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade100,
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 180,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 16, width: double.infinity, color: Colors.white),
                  const SizedBox(height: 8),
                  Container(height: 16, width: 200, color: Colors.white),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(height: 32, width: 32, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
                      const SizedBox(width: 8),
                      Container(height: 12, width: 100, color: Colors.white),
                      const Spacer(),
                      Container(height: 24, width: 60, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12))),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar1(BlogController controller, Color primaryColor) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6), // Professional light grey background
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          const Icon(Icons.search_rounded, color: Color(0xFF9CA3AF), size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller.searchTextController,
              onChanged: (value) => controller.searchBlogs(value),
              decoration:  InputDecoration(
                hintText: 'search_blogs'.tr,
                hintStyle: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              style: const TextStyle(color: Color(0xFF1F2937), fontSize: 14),
            ),
          ),
          // Container(
          //   width: 32,
          //   height: 32,
          //   margin: const EdgeInsets.only(right: 8),
          // //   decoration: BoxDecoration(
          // //     color: Colors.white,
          // //     borderRadius: BorderRadius.circular(8),
          // //     border: Border.all(color: const Color(0xFFE5E7EB)),
          // //   ),
          // //   child: Icon(Icons.tune_rounded, color: primaryColor, size: 18),
          //  ),
        ],
      ),
    );
  }



  Widget _buildSearchBar(BlogController controller, Color primaryColor) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: primaryColor.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(
            Icons.search_rounded,
            color: Color(0xFF9CA3AF),
            size: 22,
          ),

          const SizedBox(width: 10),

          Expanded(
            child: TextField(
              controller: controller.searchTextController,
              onChanged: (value) {
                controller.searchBlogs(value);
              },
              decoration:  InputDecoration(
                hintText: 'search_blogs'.tr,
                hintStyle: const TextStyle(
                  color: Color(0xFF9CA3AF),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isDense: true,
              ),
              style: const TextStyle(
                color: Color(0xFF1F2937),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              cursorColor: primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  // Highly professional categories: simple outlines and solid subtle highlights
  Widget _buildCategoryTabs(BlogController controller, Color primaryColor) {
    return SizedBox(
      height: 32,
      child: Obx(() {
        // Access the value synchronously so Obx tracks the dependency
        final selectedId = controller.selectedCategory.value.id?.toString();
        
        return ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: controller.categories.length,
          itemBuilder: (context, index) {
            final category = controller.categories[index];
            final isSelected = selectedId == category.id?.toString();
            return GestureDetector(
              onTap: () => controller.filterByCategory(category),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected ? primaryColor : primaryColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(24),
                ),
                alignment: Alignment.center,
                child: Text(
                  category.name ?? '',
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF4B5563),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildBlogCard(
      BuildContext context, Blog blog, Color primaryColor, BlogController controller) {
    final String? imageUrl =
    blog.mediaPath != null ? "${ApiConstants.imageBaseUrl}${blog.mediaPath}" : null;
    final String? firstMedia = (blog.mediaPaths != null && blog.mediaPaths!.isNotEmpty) ? blog.mediaPaths!.first : blog.mediaPath;
    final bool isVideoFirst = firstMedia != null && (
        firstMedia.toLowerCase().endsWith('.mp4') ||
            firstMedia.toLowerCase().endsWith('.mov') ||
            firstMedia.toLowerCase().endsWith('.avi') ||
            firstMedia.toLowerCase().endsWith('.mkv') ||
            firstMedia.toLowerCase().endsWith('.webm') ||
            firstMedia.toLowerCase().endsWith('.3gp') ||
            firstMedia.toLowerCase().endsWith('.m4v'));

    String? categoryName;
    if (blog.category != null) {
      categoryName = blog.category!.name;
    } else if (blog.blogType != null && blog.blogType!.isNotEmpty) {
      try {
        final cat = controller.categories.firstWhere((c) => c.id?.toString() == blog.blogType);
        categoryName = cat.name;
      } catch (e) {
        categoryName = blog.blogType; // fallback to ID
      }
    }

    return GestureDetector(
      onTap: () => Get.to(() => BlogDetailScreen(blogId: blog.id ?? 0)),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 12,
              offset: const Offset(0, 4),
            )
          ],
          border: Border.all(color: const Color(0xFFF3F4F6)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Media Header with tags
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                  child: SizedBox(
                    height: 180,
                    width: double.infinity,
                    child: firstMedia != null
                        ? (isVideoFirst
                        ? VideoThumbnailWidget(
                      key: ValueKey(firstMedia),
                      videoUrl: "${ApiConstants.imageBaseUrl}$firstMedia",
                      height: 180,
                      width: double.infinity,
                      placeholder: _blogPlaceholder(primaryColor, isVideo: true),
                    )
                        : Image.network(
                      "${ApiConstants.imageBaseUrl}$firstMedia",
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _blogPlaceholder(primaryColor, isVideo: false),
                    ))
                        : _blogPlaceholder(primaryColor, isVideo: false),
                  ),
                ),
                // Category tag top-left
                if (categoryName != null && categoryName.isNotEmpty)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Text(
                        categoryName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            // Card Body
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    blog.title ?? 'No Title',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF111827),
                      fontFamily: 'Nunito-Bold',
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 14),
                  // Author Info Row
                  Row(
                    children: [
                      // Avatar
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: primaryColor.withOpacity(0.1),
                        backgroundImage: blog.user?.photo != null
                            ? NetworkImage("${ApiConstants.imageBaseUrl}${blog.user!.photo}")
                            : null,
                        child: blog.user?.photo == null
                            ? Text(
                          blog.user?.name?.isNotEmpty == true
                              ? blog.user!.name![0].toUpperCase()
                              : 'U',
                          style: TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        )
                            : null,
                      ),
                      const SizedBox(width: 8),
                      // Author Name
                      Expanded(
                        child: Text(
                          'By ${blog.user?.name ?? 'Unknown'}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[700],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Date
                      Text(
                        _formatDate(blog.createdAt),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[500],
                        ),
                      ),
                      const SizedBox(width: 14),
                      // Like Action
                      GestureDetector(
                        onTap: () => controller.toggleLike(blog.id ?? 0),
                        child: Row(
                          children: [
                            Icon(
                              blog.isLiked == true ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                              size: 18,
                              color: blog.isLiked == true ? Colors.redAccent : Colors.grey[500],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${blog.likesCount ?? 0}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[800],
                              ),
                            ),
                          ],
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
    );
    /* padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    blog.title ?? 'No Title',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF111827),
                      fontFamily: 'Nunito-Bold',
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 14),
                  
                  // Author Info Row
                  Row(
                    children: [
                      // Avatar
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: primaryColor.withOpacity(0.1),
                        backgroundImage: blog.user?.photo != null
                            ? NetworkImage("${ApiConstants.imageBaseUrl}${blog.user!.photo}")
                            : null,
                        child: blog.user?.photo == null
                            ? Text(
                                blog.user?.name?.isNotEmpty == true
                                    ? blog.user!.name![0].toUpperCase()
                                    : 'U',
                                style: TextStyle(
                                  color: primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 8),
                      
                      // Author Name & Date
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'By ${blog.user?.name ?? 'Unknown'}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF374151),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              blog.createdAt?.split('T')[0] ?? '',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Like Action
                      GestureDetector(
                        onTap: () => controller.toggleLike(blog.id ?? 0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: blog.isLiked == true
                                ? primaryColor.withOpacity(0.08)
                                : const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                blog.isLiked == true ? Icons.favorite : Icons.favorite_border_rounded,
                                size: 16,
                                color: blog.isLiked == true ? primaryColor : Colors.grey[400],
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${blog.likesCount ?? 0}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: blog.isLiked == true ? primaryColor : Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
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
    );*/

  }

  Widget _buildEmptyState(Color primaryColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: primaryColor.withOpacity(0.08), shape: BoxShape.circle),
            child: Icon(Icons.article_outlined, size: 48, color: primaryColor.withOpacity(0.5)),
          ),
          const SizedBox(height: 16),
          Text('No blogs found', style: TextStyle(fontSize: 15, color: Colors.grey[600], fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text('Pull down to refresh', style: TextStyle(fontSize: 12, color: Colors.grey[400])),
        ],
      ),
    );
  }
}

Widget _blogPlaceholder(Color primaryColor, {required bool isVideo}) {
  return Container(
    color: Colors.grey[100],
    child: Center(
      child: Icon(
        isVideo ? Icons.videocam_outlined : Icons.image_outlined,
        size: 40,
        color: primaryColor.withOpacity(0.3),
      ),
    ),
  );
}
