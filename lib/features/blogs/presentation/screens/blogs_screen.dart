import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constent/api_constants.dart';
import '../controller/blog_controller.dart';
import '../../data/model/blog_model.dart';
import 'blog_detail_screen.dart';

class BlogsScreen extends StatelessWidget {
  const BlogsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(BlogController());
    final primaryColor = context.theme.primaryColor;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFCE4EC),
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(
          'Blogs',
          style: context.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: primaryColor,
            fontSize: 22,
          ),
        ),
      ),
      body: Column(
        children: [
          // Pink header background for search bar
          Container(
            color: const Color(0xFFFCE4EC),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: _buildSearchBar(context, controller, primaryColor),
          ),
          // Blog list
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.blogs.isEmpty) {
                return _buildLoadingState(primaryColor);
              }

              if (controller.filteredBlogs.isEmpty) {
                return _buildEmptyState(primaryColor);
              }

              return RefreshIndicator(
                onRefresh: () => controller.fetchBlogs(refresh: true),
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                  itemCount: controller.filteredBlogs.length,
                  itemBuilder: (context, index) {
                    final blog = controller.filteredBlogs[index];
                    return blog.mediaType == 'video'
                        ? _buildVideoBlogCard(context, blog, primaryColor, controller)
                        : _buildImageBlogCard(context, blog, primaryColor, controller);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(Color primaryColor) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildSearchBar(BuildContext context, BlogController controller, Color primaryColor) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller.searchTextController,
        onChanged: (value) => controller.searchBlogs(value),
        decoration: InputDecoration(
          hintText: 'Search blogs...',
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
          prefixIcon: Icon(Icons.search_rounded, color: Colors.grey[500], size: 22),
          suffixIcon: IconButton(
            icon: const Icon(Icons.clear_rounded, size: 20),
            color: Colors.grey[500],
            onPressed: () => controller.clearSearch(),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildImageBlogCard(
      BuildContext context, Blog blog, Color primaryColor, BlogController controller) {
    final String? imageUrl = blog.mediaPath != null
        ? "${ApiConstants.imageBaseUrl}${blog.mediaPath}"
        : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Container(
              height: 190,
              width: double.infinity,
              color: const Color(0xFFE8F5E9),
              child: imageUrl != null
                  ? Image.network(imageUrl, fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.image_not_supported, size: 50, color: Colors.grey))
                  : Center(
                      child: Icon(
                        Icons.image_outlined,
                        size: 60,
                        color: Colors.grey[300],
                      ),
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  blog.title ?? 'No Title',
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                    color: Colors.grey[850],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.person_outline_rounded, size: 14, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text(
                      blog.user?.name ?? 'Unknown Author',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.calendar_today_outlined, size: 13, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text(
                      blog.createdAt?.split('T')[0] ?? '',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  blog.description ?? '',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                if (blog.tags != null && blog.tags!.isNotEmpty)
                  Wrap(
                    spacing: 6,
                    children: blog.tags!
                        .map(
                          (tag) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: primaryColor.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '#$tag',
                              style: TextStyle(
                                fontSize: 11,
                                color: primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => controller.toggleLike(blog.id ?? 0),
                      child: Row(
                        children: [
                          Icon(
                            blog.isLiked == true ? Icons.favorite : Icons.favorite_border,
                            size: 18,
                            color: blog.isLiked == true ? primaryColor : Colors.grey[500],
                          ),
                          const SizedBox(width: 5),
                          Text(
                            '${blog.likesCount ?? 0} likes',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                              fontWeight: blog.isLiked == true ? FontWeight.w600 : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        Get.to(() => BlogDetailScreen(blogId: blog.id ?? 0));
                      },
                      child: Row(
                        children: [
                          Text(
                            'Read More',
                            style: TextStyle(
                              fontSize: 13,
                              color: primaryColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(Icons.arrow_forward_rounded, size: 15, color: primaryColor),
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
    );
  }

  Widget _buildVideoBlogCard(
      BuildContext context, Blog blog, Color primaryColor, BlogController controller) {
    final String? imageUrl = blog.mediaPath != null
        ? "${ApiConstants.imageBaseUrl}${blog.mediaPath}"
        : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Stack(
              children: [
                Container(
                  height: 190,
                  width: double.infinity,
                  color: const Color(0xFFEEEEEE),
                  child: imageUrl != null
                      ? Image.network(imageUrl, fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.videocam_off, size: 50, color: Colors.grey))
                      : const SizedBox(),
                ),
                Positioned.fill(
                  child: Center(
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: primaryColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withValues(alpha: 0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 32),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.play_arrow_rounded, color: Colors.white, size: 14),
                        SizedBox(width: 3),
                        Text(
                          'Video',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  blog.title ?? 'No Title',
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                    color: Colors.grey[850],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.person_outline_rounded, size: 14, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text(
                      blog.user?.name ?? 'Unknown Author',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.calendar_today_outlined, size: 13, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text(
                      blog.createdAt?.split('T')[0] ?? '',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  blog.description ?? '',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                if (blog.tags != null && blog.tags!.isNotEmpty)
                  Wrap(
                    spacing: 6,
                    children: blog.tags!
                        .map(
                          (tag) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: primaryColor.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '#$tag',
                              style: TextStyle(
                                fontSize: 11,
                                color: primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => controller.toggleLike(blog.id ?? 0),
                      child: Row(
                        children: [
                          Icon(
                            blog.isLiked == true ? Icons.favorite : Icons.favorite_border,
                            size: 18,
                            color: blog.isLiked == true ? primaryColor : Colors.grey[500],
                          ),
                          const SizedBox(width: 5),
                          Text(
                            '${blog.likesCount ?? 0} likes',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                              fontWeight: blog.isLiked == true ? FontWeight.w600 : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        Get.to(() => BlogDetailScreen(blogId: blog.id ?? 0));
                      },
                      child: Row(
                        children: [
                          Text(
                            'Read More',
                            style: TextStyle(
                              fontSize: 13,
                              color: primaryColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(Icons.arrow_forward_rounded, size: 15, color: primaryColor),
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
    );
  }

  Widget _buildEmptyState(Color primaryColor) {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.article_outlined, size: 72, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'No blogs found',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[500],
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Try a different search term or pull down to refresh',
              style: TextStyle(fontSize: 13, color: Colors.grey[400]),
            ),
          ],
        ),
      ),
    );
  }
}
