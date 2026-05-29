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
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF111827), // Neutral dark charcoal title
                              fontFamily: 'Nunito-Bold',
                              letterSpacing: -0.5,
                            ),
                          ),
                          // Stack(
                          //   children: [
                          //     Icon(Icons.notifications_none_rounded, color: const Color(0xFF374151), size: 24),
                          //     Positioned(
                          //       right: 2,
                          //       top: 2,
                          //       child: Container(
                          //         width: 8,
                          //         height: 8,
                          //         decoration: BoxDecoration(
                          //           color: primaryColor,
                          //           shape: BoxShape.circle,
                          //         ),
                          //       ),
                          //     ),
                          //   ],
                          // ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Search Bar
                      _buildSearchBar(controller),
                      const SizedBox(height: 16),
                      
                      // Ultra-Professional Underlined Tabs
                      _buildUnderlineTabs(controller, primaryColor),
                    ],
                  ),
                ),
              ),

              // Horizontal Category chips list (Floating just below top header)
              SliverToBoxAdapter(
                child: Container(
                  color: const Color(0xFFF9FAFB),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: _buildCategoryTabs(controller, primaryColor),
                ),
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
          final hasBlogAccess = user?.blogAccess ?? false;
          final isBlogger = user?.userType?.toLowerCase().trim() == 'bloger';
          if (!hasBlogAccess && !isBlogger) return const SizedBox.shrink();
          
          return GestureDetector(
            onTap: () => Get.to(() => const CreateBlogScreen()),
            child: Container(
              height: 48,
              margin: const EdgeInsets.only(bottom: 100), // Lift above bottom navigation bar
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child:  Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add_rounded, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'write_blog'.tr,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      letterSpacing: 0.1,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  // Premium, corporate underlined tab bar matching clean guidelines
  Widget _buildUnderlineTabs(BlogController controller, Color primaryColor) {
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



  Widget _buildSearchBar(BlogController controller) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFE8E8E8),
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
                hintStyle: TextStyle(
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
              cursorColor: Colors.pink,
            ),
          ),
        ],
      ),
    );
  }

  // Highly professional categories: simple outlines and solid subtle highlights
  Widget _buildCategoryTabs(BlogController controller, Color primaryColor) {
    return SizedBox(
      height: 38,
      child: Obx(() {
        return ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: controller.categories.length,
          itemBuilder: (context, index) {
            final category = controller.categories[index];
            final isSelected = controller.selectedCategory.value == category;
            return GestureDetector(
              onTap: () => controller.filterByCategory(category),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? primaryColor.withOpacity(0.08) : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? primaryColor : const Color(0xFFE5E7EB),
                    width: isSelected ? 1.5 : 1.0,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  category,
                  style: TextStyle(
                    color: isSelected ? primaryColor : const Color(0xFF4B5563),
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
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
    final isVideo = blog.mediaType == 'video';

    return GestureDetector(
      onTap: () => Get.to(() => BlogDetailScreen(blogId: blog.id ?? 0)),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
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
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: SizedBox(
                    height: 180,
                    width: double.infinity,
                    child: isVideo
                        ? (imageUrl != null
                            ? VideoThumbnailWidget(
                                key: ValueKey(imageUrl),
                                videoUrl: imageUrl,
                                height: 180,
                                width: double.infinity,
                                placeholder: _blogPlaceholder(primaryColor, isVideo: true),
                              )
                            : _blogPlaceholder(primaryColor, isVideo: true))
                        : (imageUrl != null
                            ? Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => _blogPlaceholder(primaryColor, isVideo: false),
                              )
                            : _blogPlaceholder(primaryColor, isVideo: false)),
                  ),
                ),
                
                // Play Button for Video
                if (isVideo)
                  Positioned.fill(
                    child: Center(
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: primaryColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withOpacity(0.4),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 28),
                      ),
                    ),
                  ),

                // Category tag top-left
                if (blog.blogType != null && blog.blogType!.isNotEmpty)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.65),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        blog.blogType!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                // Bookmark icon top-right
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.bookmark_border_rounded,
                      color: primaryColor,
                      size: 18,
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
    );
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
