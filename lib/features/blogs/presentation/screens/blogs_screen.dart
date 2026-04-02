import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constent/api_constants.dart';
import '../controller/blog_controller.dart';
import '../../data/model/blog_model.dart';
import 'blog_detail_screen.dart';
import 'create_blogs.dart';
import '../../../Auth/service/auth_service.dart';

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
        actions: [
          _buildCreateBlogButton(primaryColor),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: _buildSearchBar(controller),
          ),
          
          // Category tabs
          _buildCategoryTabs(controller, primaryColor),
          
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

 /* Widget _buildCreateBlogButton(Color primaryColor) {
    try {
      if (!Get.isRegistered<AuthService>()) {
        return const SizedBox.shrink();
      }
      
      final authService = Get.find<AuthService>();
      
      return Obx(() {
        final user = authService.currentUser.value;
        final hasBlogAccess = user?.blogAccess == 'true' || user?.blogAccess == true.toString();
        
       // if (!hasBlogAccess) return const SizedBox.shrink();
        
        return Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: GestureDetector(
            onTap: () {
              Get.to(() => const CreateBlogScreen());
            },
            child: Container(
              height: 30,
              width: 30,
              decoration: BoxDecoration(
                color: primaryColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(
                Icons.add,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        );
      });
    } catch (e) {
      return const SizedBox.shrink();
    }
  }*/


  Widget _buildCreateBlogButton(Color primaryColor) {
    try {
      if (!Get.isRegistered<AuthService>()) {
        return const SizedBox.shrink();
      }

      final authService = Get.find<AuthService>();

      return Obx(() {
        final user = authService.currentUser.value;

        // Direct boolean check
        final hasBlogAccess = user?.blogAccess ?? false;

        if (!hasBlogAccess) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: GestureDetector(
            onTap: () {
              Get.to(() => const CreateBlogScreen());
            },
            child: Container(
              height: 30,
              width: 30,
              decoration: BoxDecoration(
                color: primaryColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(
                Icons.add,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        );
      });
    } catch (e) {
      return const SizedBox.shrink();
    }
  }





  Widget _buildSearchBar(BlogController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 1.0, vertical: 2),
      child: Container(
        height: 45,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          children: [
            const SizedBox(width: 16),
            SvgPicture.string(
              '''<svg width="20" height="20" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                <path d="M11 19C15.4183 19 19 15.4183 19 11C19 6.58172 15.4183 3 11 3C6.58172 3 3 6.58172 3 11C3 15.4183 6.58172 19 11 19Z" stroke="black" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                <path d="M21 21L16.65 16.65" stroke="black" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
              </svg>''',
              width: 20,
              height: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: controller.searchTextController,
                onChanged: (value) => controller.searchBlogs(value),
                decoration: InputDecoration(
                  hintText: 'Search blogs...',
                  hintStyle: GoogleFonts.poppins(
                    color: Colors.grey[500],
                    fontSize: 14,
                    backgroundColor: Colors.transparent,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  filled: true,
                  fillColor: Colors.transparent,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                ),
                style: GoogleFonts.poppins(color: Colors.black, fontSize: 13),
              ),
            ),
            const SizedBox(width: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryTabs(BlogController controller, Color primaryColor) {
    return Container(
      height: 35,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: controller.categories.length,
        itemBuilder: (context, index) {
          final category = controller.categories[index];
          
          return Container(
            margin: const EdgeInsets.only(right: 12),
            child: Obx(() {
              final isSelected = controller.selectedCategory.value == category;
              
              return GestureDetector(
                onTap: () => controller.filterByCategory(category),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? primaryColor : Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: isSelected ? primaryColor : Colors.grey[300]!,
                      width: 1,
                    ),
                    boxShadow: isSelected ? [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ] : [],
                  ),
                  child: Center(
                    child: Text(
                      category,
                      style: GoogleFonts.poppins(
                        color: isSelected ? Colors.white : Colors.grey[700],
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }


/*
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
*/

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
                      _buildDummyImagePlaceholder(primaryColor))
                  : _buildDummyImagePlaceholder(primaryColor),
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
                          _buildDummyVideoPlaceholder(primaryColor))
                      : _buildDummyVideoPlaceholder(primaryColor),
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

Widget _buildDummyImagePlaceholder(Color primaryColor) {
  return Container(
    color: Colors.grey[100],
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.image_outlined,
              size: 60,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No image',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildDummyVideoPlaceholder(Color primaryColor) {
  return Container(
    color: Colors.grey[200],
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.videocam_outlined,
              size: 60,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No video',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    ),
  );
}

