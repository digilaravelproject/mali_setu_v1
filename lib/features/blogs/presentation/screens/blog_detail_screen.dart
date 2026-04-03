import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../core/constent/api_constants.dart';
import '../../data/model/blog_model.dart';
import '../controller/blog_controller.dart';
import 'full_image_screen.dart';
import 'full_video_screen.dart';

class BlogDetailScreen extends StatelessWidget {
  final int blogId;
  const BlogDetailScreen({super.key, required this.blogId});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BlogController>();
    final primaryColor = context.theme.primaryColor;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchBlogDetail(blogId);
    });

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F6F6),
        body: Obx(() {
          if (controller.isDetailLoading.value) {
            return Center(child: CircularProgressIndicator(color: primaryColor));
          }

          final blog = controller.selectedBlog.value;
          if (blog == null) {
            return const Center(child: Text('Blog not found.'));
          }

          final String title = blog.title ?? 'No Title';
          final String author = blog.user?.name ?? 'Unknown Author';
          final String date = blog.createdAt?.split('T')[0] ?? '';
          final List<String> tags = blog.tags ?? [];
          final String description = blog.description ?? 'No description available.';
          final String avatarLetter = author.isNotEmpty ? author[0].toUpperCase() : 'A';

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Media
                _buildMediaSection(context, blog, primaryColor, controller),

                // Content
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category chip
                      if ((blog.blogType ?? '').isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            blog.blogType!,
                            style: TextStyle(fontSize: 11, color: primaryColor, fontWeight: FontWeight.w600),
                          ),
                        ),
                      const SizedBox(height: 10),

                      // Title
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          color: Color(0xFF1A1A1A),
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Author card
                      _buildAuthorCard(context, primaryColor, avatarLetter, author, date, controller),
                      const SizedBox(height: 16),

                      // Tags
                      if (tags.isNotEmpty) ...[
                        _buildTags(primaryColor, tags),
                        const SizedBox(height: 16),
                      ],

                      // Divider
                      Divider(color: Colors.grey.shade200, thickness: 1),
                      const SizedBox(height: 14),

                      // Description
                      Text(
                        description,
                        style: TextStyle(
                          color: Colors.grey[700],
                          height: 1.75,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Related Blogs
                      _buildRelatedBlogs(context, primaryColor, controller),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildMediaSection(
      BuildContext context, Blog blog, Color primaryColor, BlogController controller) {
    final hasImage = blog.mediaType == 'image';
    final mediaPath = blog.mediaPath;
    final imageUrl = mediaPath != null ? "${ApiConstants.imageBaseUrl}$mediaPath" : null;

    if (hasImage) {
      return Stack(
        children: [
          GestureDetector(
            onTap: imageUrl != null ? () => Get.to(() => FullImageScreen(imageUrl: imageUrl)) : null,
            child: Container(
              height: 280,
              width: double.infinity,
              color: Colors.grey[200],
              child: imageUrl != null
                  ? Image.network(imageUrl, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _dummyImage(primaryColor))
                  : _dummyImage(primaryColor),
            ),
          ),
          _buildTopBar(),
          if (imageUrl != null)
            Positioned(
              bottom: 12,
              right: 12,
              child: GestureDetector(
                onTap: () => Get.to(() => FullImageScreen(imageUrl: imageUrl)),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: Colors.black.withOpacity(0.5), shape: BoxShape.circle),
                  child: const Icon(Icons.fullscreen_rounded, color: Colors.white, size: 20),
                ),
              ),
            ),
        ],
      );
    }

    return _buildVideoPlayer(context, blog, primaryColor, controller);
  }

  Widget _buildTopBar() {
    return Positioned(
      top: 0, left: 0, right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(color: Colors.black.withOpacity(0.45), shape: BoxShape.circle),
                  child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideoPlayer(
      BuildContext context, Blog blog, Color primaryColor, BlogController controller) {
    final String? imageUrl = blog.mediaPath != null
        ? "${ApiConstants.imageBaseUrl}${blog.mediaPath}"
        : null;

    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            if (blog.mediaPath != null) {
              Get.to(() => FullVideoScreen(videoUrl: "${ApiConstants.imageBaseUrl}${blog.mediaPath}"));
            }
          },
          child: Container(
            height: 280,
            width: double.infinity,
            color: Colors.black,
            child: imageUrl != null
                ? Image.network(imageUrl, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _dummyVideo())
                : _dummyVideo(),
          ),
        ),
        Container(
          height: 280,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0x88000000), Color(0x00000000), Color(0x88000000)],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
        ),
        _buildTopBar(),
        Positioned.fill(
          child: Center(
            child: Container(
              width: 56, height: 56,
              decoration: BoxDecoration(
                color: primaryColor,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: primaryColor.withOpacity(0.4), blurRadius: 12)],
              ),
              child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 32),
            ),
          ),
        ),
      ],
    );
  }

  Widget _dummyImage(Color primaryColor) {
    return Container(
      color: Colors.grey[100],
      child: Center(
        child: Icon(Icons.image_outlined, size: 60, color: primaryColor.withOpacity(0.3)),
      ),
    );
  }

  Widget _dummyVideo() {
    return Container(
      color: Colors.grey[100],
      child: const Center(
        child: Icon(Icons.image_outlined, size: 60, color: Color(0x4D9E9E9E)),
      ),
    );
  }

  Widget _buildAuthorCard(
      BuildContext context, Color primaryColor, String avatarLetter, String author, String date, BlogController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(color: primaryColor.withOpacity(0.12), shape: BoxShape.circle),
            child: Center(
              child: Text(
                avatarLetter,
                style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(author, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFF1A1A1A))),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.calendar_today_outlined, size: 11, color: Colors.grey[400]),
                    const SizedBox(width: 4),
                    Text(date, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                  ],
                ),
              ],
            ),
          ),
          Obx(() => GestureDetector(
            onTap: () => controller.toggleLike(controller.selectedBlog.value?.id ?? 0),
            child: Row(
              children: [
                Icon(
                  controller.selectedBlog.value?.isLiked == true ? Icons.favorite : Icons.favorite_border_rounded,
                  size: 20,
                  color: controller.selectedBlog.value?.isLiked == true ? primaryColor : Colors.grey[400],
                ),
                const SizedBox(width: 4),
                Text(
                  '${controller.selectedBlog.value?.likesCount ?? 0}',
                  style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildTags(Color primaryColor, List<String> tags) {
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: tags.map((tag) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: primaryColor.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: primaryColor.withOpacity(0.2)),
        ),
        child: Text(
          '#$tag',
          style: TextStyle(fontSize: 12, color: primaryColor, fontWeight: FontWeight.w600),
        ),
      )).toList(),
    );
  }

  Widget _buildRelatedBlogs(BuildContext context, Color primaryColor, BlogController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(width: 3, height: 18, decoration: BoxDecoration(color: primaryColor, borderRadius: BorderRadius.circular(2))),
            const SizedBox(width: 8),
            const Text('Related Blogs', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1A1A1A))),
          ],
        ),
        const SizedBox(height: 12),
        controller.relatedBlogs.isEmpty
            ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(child: Text('No related blogs', style: TextStyle(color: Colors.grey[400], fontSize: 13))),
              )
            : SizedBox(
                height: 165,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: controller.relatedBlogs.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    return _buildRelatedCard(context, primaryColor, controller.relatedBlogs[index]);
                  },
                ),
              ),
      ],
    );
  }

  Widget _buildRelatedCard(BuildContext context, Color primaryColor, Blog blog) {
    final String? imageUrl = blog.mediaPath != null
        ? "${ApiConstants.imageBaseUrl}${blog.mediaPath}"
        : null;

    return GestureDetector(
      onTap: () => Get.to(() => BlogDetailScreen(blogId: blog.id ?? 0), preventDuplicates: false),
      child: Container(
        width: 140,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: SizedBox(
                height: 95,
                width: double.infinity,
                child: imageUrl != null
                    ? Image.network(imageUrl, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.grey[100],
                          child: Center(child: Icon(Icons.image_outlined, size: 28, color: primaryColor.withOpacity(0.3))),
                        ))
                    : Container(
                        color: Colors.grey[100],
                        child: Center(child: Icon(Icons.image_outlined, size: 28, color: primaryColor.withOpacity(0.3))),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    blog.title ?? 'No Title',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A)),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Icon(Icons.favorite, size: 12, color: primaryColor),
                      const SizedBox(width: 3),
                      Text('${blog.likesCount ?? 0}', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
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
}
