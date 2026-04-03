import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
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
    final topPadding = MediaQuery.of(context).padding.top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: const Color(0xFFF5F5F5),
        body: RefreshIndicator(
          color: primaryColor,
          onRefresh: () => controller.fetchBlogs(refresh: true),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: Container(
                  padding: EdgeInsets.only(top: topPadding + 12, bottom: 12, left: 16, right: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.pink.shade50,
                        const Color(0xFFF5F5F5),
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Blogs',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                              fontFamily: 'Nunito-Bold',
                            ),
                          ),
                          _buildCreateBlogButton(primaryColor),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildSearchBar(controller),
                      const SizedBox(height: 12),
                      _buildCategoryTabs(controller, primaryColor),
                    ],
                  ),
                ),
              ),

              // Blog list
              Obx(() {
                if (controller.isLoading.value && controller.blogs.isEmpty) {
                  return SliverPadding(
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 20),
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
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final blog = controller.filteredBlogs[index];
                        return blog.mediaType == 'video'
                            ? _buildVideoBlogCard(context, blog, primaryColor, controller)
                            : _buildImageBlogCard(context, blog, primaryColor, controller);
                      },
                      childCount: controller.filteredBlogs.length,
                    ),
                  ),
                );
              }),
            ],
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
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image placeholder
            Container(
              height: 170,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 14, width: 200, color: Colors.white),
                  const SizedBox(height: 8),
                  Container(height: 11, width: 130, color: Colors.white),
                  const SizedBox(height: 8),
                  Container(height: 11, width: double.infinity, color: Colors.white),
                  const SizedBox(height: 4),
                  Container(height: 11, width: 160, color: Colors.white),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Container(height: 11, width: 60, color: Colors.white),
                      const Spacer(),
                      Container(height: 11, width: 70, color: Colors.white),
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

  Widget _buildCreateBlogButton(Color primaryColor) {
    try {
      if (!Get.isRegistered<AuthService>()) return const SizedBox.shrink();
      final authService = Get.find<AuthService>();
      return Obx(() {
        final user = authService.currentUser.value;
        final hasBlogAccess = user?.blogAccess ?? false;
        if (!hasBlogAccess) return const SizedBox.shrink();
        return GestureDetector(
          onTap: () => Get.to(() => const CreateBlogScreen()),
          child: Container(
            height: 34,
            width: 34,
            decoration: BoxDecoration(
              color: primaryColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: primaryColor.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3)),
              ],
            ),
            child: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
          ),
        );
      });
    } catch (e) {
      return const SizedBox.shrink();
    }
  }

  Widget _buildSearchBar(BlogController controller) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Icon(Icons.search_rounded, color: Colors.grey[400], size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller.searchTextController,
              onChanged: (value) => controller.searchBlogs(value),
              decoration: InputDecoration(
                hintText: 'Search blogs...',
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: true,
                fillColor: Colors.transparent,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              style: const TextStyle(color: Colors.black87, fontSize: 13),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs(BlogController controller, Color primaryColor) {
    return SizedBox(
      height: 32,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: controller.categories.length,
        itemBuilder: (context, index) {
          final category = controller.categories[index];
          return Obx(() {
            final isSelected = controller.selectedCategory.value == category;
            return GestureDetector(
              onTap: () => controller.filterByCategory(category),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected ? primaryColor : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isSelected ? primaryColor : Colors.grey.shade300),
                  boxShadow: isSelected
                      ? [BoxShadow(color: primaryColor.withOpacity(0.25), blurRadius: 6, offset: const Offset(0, 2))]
                      : [],
                ),
                child: Text(
                  category,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey[700],
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            );
          });
        },
      ),
    );
  }

  Widget _buildImageBlogCard(
      BuildContext context, Blog blog, Color primaryColor, BlogController controller) {
    final String? imageUrl =
        blog.mediaPath != null ? "${ApiConstants.imageBaseUrl}${blog.mediaPath}" : null;

    return GestureDetector(
      onTap: () => Get.to(() => BlogDetailScreen(blogId: blog.id ?? 0)),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 3))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
              child: SizedBox(
                height: 170,
                width: double.infinity,
                child: imageUrl != null
                    ? Image.network(imageUrl, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _blogPlaceholder(primaryColor, isVideo: false))
                    : _blogPlaceholder(primaryColor, isVideo: false),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    blog.title ?? 'No Title',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1A1A1A)),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.person_outline_rounded, size: 13, color: Colors.grey[400]),
                      const SizedBox(width: 3),
                      Text(blog.user?.name ?? 'Unknown', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                      const SizedBox(width: 10),
                      Icon(Icons.calendar_today_outlined, size: 12, color: Colors.grey[400]),
                      const SizedBox(width: 3),
                      Text(blog.createdAt?.split('T')[0] ?? '', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                    ],
                  ),
                  if (blog.description != null && blog.description!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(blog.description!, style: TextStyle(fontSize: 12, color: Colors.grey[600], height: 1.4), maxLines: 2, overflow: TextOverflow.ellipsis),
                  ],
                  if (blog.tags != null && blog.tags!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 5, runSpacing: 4,
                      children: blog.tags!.map((tag) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: primaryColor.withOpacity(0.08), borderRadius: BorderRadius.circular(20)),
                        child: Text('#$tag', style: TextStyle(fontSize: 10, color: primaryColor, fontWeight: FontWeight.w600)),
                      )).toList(),
                    ),
                  ],
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => controller.toggleLike(blog.id ?? 0),
                        child: Row(
                          children: [
                            Icon(blog.isLiked == true ? Icons.favorite : Icons.favorite_border_rounded, size: 16, color: blog.isLiked == true ? primaryColor : Colors.grey[400]),
                            const SizedBox(width: 4),
                            Text('${blog.likesCount ?? 0} likes', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Text('Read More', style: TextStyle(fontSize: 12, color: primaryColor, fontWeight: FontWeight.w700)),
                          const SizedBox(width: 3),
                          Icon(Icons.arrow_forward_ios_rounded, size: 11, color: primaryColor),
                        ],
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

  Widget _buildVideoBlogCard(
      BuildContext context, Blog blog, Color primaryColor, BlogController controller) {
    final String? imageUrl =
        blog.mediaPath != null ? "${ApiConstants.imageBaseUrl}${blog.mediaPath}" : null;

    return GestureDetector(
      onTap: () => Get.to(() => BlogDetailScreen(blogId: blog.id ?? 0)),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 3))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
              child: Stack(
                children: [
                  SizedBox(
                    height: 170, width: double.infinity,
                    child: imageUrl != null
                        ? Image.network(imageUrl, fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _blogPlaceholder(primaryColor, isVideo: true))
                        : _blogPlaceholder(primaryColor, isVideo: true),
                  ),
                  Positioned.fill(
                    child: Center(
                      child: Container(
                        width: 48, height: 48,
                        decoration: BoxDecoration(color: primaryColor, shape: BoxShape.circle,
                            boxShadow: [BoxShadow(color: primaryColor.withOpacity(0.4), blurRadius: 12)]),
                        child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 28),
                      ),
                    ),
                  ),
                  Positioned(bottom: 8, right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: primaryColor, borderRadius: BorderRadius.circular(16)),
                      child: const Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.play_arrow_rounded, color: Colors.white, size: 12),
                        SizedBox(width: 2),
                        Text('Video', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(blog.title ?? 'No Title', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1A1A1A)), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 6),
                  Row(children: [
                    Icon(Icons.person_outline_rounded, size: 13, color: Colors.grey[400]),
                    const SizedBox(width: 3),
                    Text(blog.user?.name ?? 'Unknown', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                    const SizedBox(width: 10),
                    Icon(Icons.calendar_today_outlined, size: 12, color: Colors.grey[400]),
                    const SizedBox(width: 3),
                    Text(blog.createdAt?.split('T')[0] ?? '', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                  ]),
                  const SizedBox(height: 10),
                  Row(children: [
                    GestureDetector(
                      onTap: () => controller.toggleLike(blog.id ?? 0),
                      child: Row(children: [
                        Icon(blog.isLiked == true ? Icons.favorite : Icons.favorite_border_rounded, size: 16, color: blog.isLiked == true ? primaryColor : Colors.grey[400]),
                        const SizedBox(width: 4),
                        Text('${blog.likesCount ?? 0} likes', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                      ]),
                    ),
                    const Spacer(),
                    Row(children: [
                      Text('Watch Now', style: TextStyle(fontSize: 12, color: primaryColor, fontWeight: FontWeight.w700)),
                      const SizedBox(width: 3),
                      Icon(Icons.arrow_forward_ios_rounded, size: 11, color: primaryColor),
                    ]),
                  ]),
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
        Icons.image_outlined,
        size: 40,
        color: primaryColor.withOpacity(0.3),
      ),
    ),
  );
}
