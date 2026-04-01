import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
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

    // Fetch detail on build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchBlogDetail(blogId);
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(() {
        if (controller.isDetailLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final blog = controller.selectedBlog.value;
        if (blog == null) {
          return const Center(child: Text('Blog not found or error loading.'));
        }

        final String title = blog.title ?? 'No Title';
        final String author = blog.user?.name ?? 'Unknown Author';
        final String date = blog.createdAt?.split('T')[0] ?? '';
        final int likes = blog.likesCount ?? 0;
        final List<String> tags = blog.tags ?? [];
        final String description =
            blog.description ?? 'No description available.';
        final String avatarLetter = author.isNotEmpty
            ? author[0].toUpperCase()
            : 'A';

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Top Media Section (Image or Video)
              _buildMediaSection(context, blog, primaryColor, controller),

              // ── Content Section
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      title,
                      style: context.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        color: Colors.grey[900],
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      blog.blogType?? "",
                      style: context.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.grey[900],
                        height: 1.3,
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Author row
                    _buildAuthorRow(
                      context,
                      primaryColor,
                      avatarLetter,
                      author,
                      date,
                      likes,
                      controller,
                    ),
                    const SizedBox(height: 14),

                    // Tags
                    _buildTags(primaryColor, tags),
                    const SizedBox(height: 16),

                    // Description
                    _buildDescription(context, primaryColor, description),
                    const SizedBox(height: 24),

                    // Related Blogs
                    _buildRelatedBlogs(context, primaryColor, controller),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // MEDIA SECTION (IMAGE OR VIDEO)
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildMediaSection(
      BuildContext context,
      Blog blog,
      Color primaryColor,
      BlogController controller,
      ) {
    final hasImage = blog.mediaType == 'image';
    final mediaPath = blog.mediaPath;
    final imageUrl = mediaPath != null
        ? "${ApiConstants.imageBaseUrl}$mediaPath"
        : null;

    if (hasImage) {
      return Stack(
        children: [
          GestureDetector(
            onTap: imageUrl != null ? () {
              Get.to(() => FullImageScreen(imageUrl: imageUrl));
            } : null,
            child: Container(
              height: 280,
              width: double.infinity,
              color: Colors.grey[200],
              child: imageUrl != null
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildDummyImage(primaryColor),
                    )
                  : _buildDummyImage(primaryColor),
            ),
          ),
          _buildTopBarActions(),
          if (imageUrl != null)
            Positioned(
              bottom: 12,
              right: 12,
              child: GestureDetector(
                onTap: () {
                  Get.to(() => FullImageScreen(imageUrl: imageUrl));
                },
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.fullscreen_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ),
        ],
      );
    }

    // Handle Video
    return _buildVideoPlayer(context, blog, primaryColor, controller);
  }

  Widget _buildDummyImage(Color primaryColor) {
    return Container(
      color: Colors.grey[100],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.image_outlined,
                size: 80,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Image not available',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBarActions() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _videoIconButton(
                Icons.arrow_back_ios_new_rounded,
                    () => Get.back(),
              ),
              Row(
                children: [
                  // _videoIconButton(Icons.bookmark_border_rounded, () {}),
                  // const SizedBox(width: 6),
                  // _videoIconButton(Icons.share_outlined, () {}),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideoPlayer(
      BuildContext context,
      Blog blog,
      Color primaryColor,
      BlogController controller,
      ) {
    final String? imageUrl = blog.mediaPath != null ? "${ApiConstants.imageBaseUrl}${blog.mediaPath}" : null;
    
    return Stack(
      children: [
        // Video frame / Thumbnail
        GestureDetector(
          onTap: () {
            if (blog.mediaPath != null) {
              final videoUrl = "${ApiConstants.imageBaseUrl}${blog.mediaPath}";
              Get.to(() => FullVideoScreen(videoUrl: videoUrl));
            }
          },
          child: Container(
            height: 280,
            width: double.infinity,
            color: Colors.black,
            child: imageUrl != null
                ? Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        _buildDummyVideoThumbnail(primaryColor),
                  )
                : _buildDummyVideoThumbnail(primaryColor),
          ),
        ),

        // Dark gradient overlay
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

        _buildTopBarActions(),

        // Play button center
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
      ],
    );
  }

  Widget _buildDummyVideoThumbnail(Color primaryColor) {
    return Container(
      color: Colors.grey[900],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.videocam_outlined,
                size: 80,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Video not available',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _videoIconButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration:  BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }

  Widget _buildRelatedDummyImage(Color primaryColor) {
    return Container(
      color: Colors.grey[100],
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: primaryColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.image_outlined,
            size: 30,
            color: primaryColor,
          ),
        ),
      ),
    );
  }

  Widget _buildAuthorRow(
      BuildContext context,
      Color primaryColor,
      String avatarLetter,
      String author,
      String date,
      int likes,
      BlogController controller,
      ) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: primaryColor.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              avatarLetter,
              style: TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                author,
                style: context.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Colors.grey[850],
                ),
              ),
              const SizedBox(height: 3),

              /*Row(
                children: [
                  Icon(Icons.calendar_today_outlined, size: 13, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Text(date, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  const SizedBox(width: 14),
                  GestureDetector(
                    onTap: () => controller.toggleLike(controller.selectedBlog.value?.id ?? 0),
                    child: Icon(
                      controller.selectedBlog.value?.isLiked == true ? Icons.favorite : Icons.favorite_border,
                      size: 16,
                      color: controller.selectedBlog.value?.isLiked == true ? primaryColor : Colors.grey[500],
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text('${controller.selectedBlog.value?.likesCount ?? likes}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                ],
              ),*/
              Row(
                children: [
                  // LEFT SIDE
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 13,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        date,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),

                  const Spacer(), // pushes like to right
                  // RIGHT SIDE (LIKE)
                  GestureDetector(
                    onTap: () => controller.toggleLike(
                      controller.selectedBlog.value?.id ?? 0,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          controller.selectedBlog.value?.isLiked == true
                              ? Icons.favorite
                              : Icons.favorite_border,
                          size: 22, // 🔥 increased size
                          color: controller.selectedBlog.value?.isLiked == true
                              ? primaryColor
                              : Colors.grey[500],
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${controller.selectedBlog.value?.likesCount ?? likes}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
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
    );
  }

  Widget _buildTags(Color primaryColor, List<String> tags) {
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: tags.map((tag) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: primaryColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: primaryColor.withValues(alpha: 0.15)),
          ),
          child: Text(
            tag,
            style: TextStyle(
              fontSize: 13,
              color: primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDescription(
      BuildContext context,
      Color primaryColor,
      String description,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          description,
          style: context.textTheme.bodyMedium?.copyWith(
            color: Colors.grey[700],
            height: 1.7,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildRelatedBlogs(
      BuildContext context,
      Color primaryColor,
      BlogController controller,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Related Blogs',
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.grey[850],
          ),
        ),
        const SizedBox(height: 12),
        controller.relatedBlogs.isEmpty
            ? const Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Center(
            child: Text(
              'No related data',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        )
            : SizedBox(
          height: 160,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: controller.relatedBlogs.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final blog = controller.relatedBlogs[index];
              return _buildRelatedCard(context, primaryColor, blog);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRelatedCard(
      BuildContext context,
      Color primaryColor,
      Blog blog,
      ) {
    final String? imageUrl = blog.mediaPath != null
        ? "${ApiConstants.imageBaseUrl}${blog.mediaPath}"
        : null;

    return GestureDetector(
      onTap: () {
        Get.to(
              () => BlogDetailScreen(blogId: blog.id ?? 0),
          preventDuplicates: false,
        );
      },
      child: SizedBox(
        width: 140,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                height: 100,
                width: 140,
                color: Colors.grey[100],
                child: imageUrl != null
                    ? Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                  _buildRelatedDummyImage(primaryColor),
                )
                    : _buildRelatedDummyImage(primaryColor),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              blog.title ?? 'No Title',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey[850],
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.favorite, size: 13, color: primaryColor),
                const SizedBox(width: 3),
                Text(
                  '${blog.likesCount ?? 0}',
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
