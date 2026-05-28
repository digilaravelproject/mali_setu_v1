import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/constent/api_constants.dart';
import '../../data/model/blog_model.dart';
import '../controller/blog_controller.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../../../Auth/service/auth_service.dart';
import 'create_blogs.dart';

class BlogDetailScreen extends StatelessWidget {
  final int blogId;
  const BlogDetailScreen({super.key, required this.blogId});

  int _calculateReadingTime(String? text) {
    if (text == null || text.isEmpty) return 1;
    final wordCount = text.split(RegExp(r'\s+')).length;
    return (wordCount / 200).ceil().clamp(1, 60);
  }

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
        backgroundColor: Colors.white,
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
          final readTime = _calculateReadingTime(description);

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Media Section with Overlay Controls & Indicators
                _buildMediaSection(context, blog, primaryColor, controller),

                // Content Details
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category Tag Pill
                      if ((blog.blogType ?? '').isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            blog.blogType!,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      const SizedBox(height: 12),

                      // Title
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          color: Color(0xFF1D1D1D),
                          fontFamily: 'Nunito-Bold',
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Author Info Row with circular avatar, verified badge and read time
                      _buildAuthorInfoRow(primaryColor, avatarLetter, author, date, readTime, blog),
                      const SizedBox(height: 18),

                      // Interaction Row (Likes, Share, Save)
                      _buildInteractionRow(context, blog, primaryColor, controller),
                      const SizedBox(height: 20),

                      // Divider
                      Divider(color: Colors.grey.shade100, thickness: 1),
                      const SizedBox(height: 16),

                      // Full Content Header
                      const Text(
                        'Full Content',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF1D1D1D),
                          fontFamily: 'Nunito-Bold',
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Blog content
                      Text(
                        description,
                        style: TextStyle(
                          color: Colors.grey[800],
                          height: 1.65,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Tags List
                      if (tags.isNotEmpty) ...[
                        _buildTagsList(primaryColor, tags),
                        const SizedBox(height: 28),
                      ],

                      // Related Blogs
                      _buildRelatedBlogs(context, primaryColor, controller),
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

  bool _isVideoFile(String path) {
    final lowercasePath = path.toLowerCase();
    return lowercasePath.endsWith('.mp4') ||
        lowercasePath.endsWith('.mov') ||
        lowercasePath.endsWith('.avi') ||
        lowercasePath.endsWith('.mkv') ||
        lowercasePath.endsWith('.webm') ||
        lowercasePath.endsWith('.3gp') ||
        lowercasePath.endsWith('.m4v');
  }

  Widget _buildMediaSection(
      BuildContext context, Blog blog, Color primaryColor, BlogController controller) {
    final mediaList = blog.mediaPaths ?? [];
    final mediaType = blog.mediaType;
    
    final RxInt activeIndex = 0.obs;
    final PageController pageController = PageController();

    if (mediaList.isEmpty) {
      final isVideo = mediaType == 'video';
      return Stack(
        children: [
          Container(
            height: 280,
            width: double.infinity,
            color: Colors.black,
            child: isVideo ? _dummyVideo() : _dummyImage(primaryColor),
          ),
          _buildTopBar(primaryColor),
        ],
      );
    }

    return Stack(
      children: [
        // PageView Carousel
        SizedBox(
          height: 280,
          width: double.infinity,
          child: PageView.builder(
            controller: pageController,
            onPageChanged: (index) => activeIndex.value = index,
            itemCount: mediaList.length,
            itemBuilder: (context, index) {
              final path = mediaList[index];
              final url = "${ApiConstants.imageBaseUrl}$path";
              final isThisVideo = (mediaType == 'video') || _isVideoFile(path);
              
              if (isThisVideo) {
                return Center(
                  child: FullScreenVideoItem(
                    videoUrl: url,
                    autoPlay: false,
                  ),
                );
              }
              
              return GestureDetector(
                onTap: () {
                  Get.to(() => FullMediaGalleryScreen(
                        mediaList: mediaList,
                        initialIndex: index,
                        mediaType: mediaType ?? 'image',
                      ));
                },
                child: Container(
                  color: Colors.black,
                  child: Image.network(
                    url,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _dummyImage(primaryColor),
                  ),
                ),
              );
            },
          ),
        ),
        
        // Navigation & Menu Overlay
        _buildTopBar(primaryColor),

        // Carousel Dot Indicators
        if (mediaList.length > 1)
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Obx(() {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(mediaList.length, (index) {
                  final isActive = activeIndex.value == index;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: isActive ? 12 : 6,
                    height: 6,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      color: isActive ? Colors.white : Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                }),
              );
            }),
          ),

        // Full Screen button overlay
        Positioned(
          bottom: 12,
          right: 12,
          child: GestureDetector(
            onTap: () {
              Get.to(() => FullMediaGalleryScreen(
                    mediaList: mediaList,
                    initialIndex: activeIndex.value,
                    mediaType: mediaType ?? 'image',
                  ));
            },
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

  Widget _buildTopBar(Color primaryColor) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1D1D1D), size: 16),
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.more_vert_rounded, color: Color(0xFF1D1D1D), size: 20),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
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

  Widget _buildAuthorInfoRow(
      Color primaryColor, String avatarLetter, String author, String date, int readTime, Blog blog) {
    return Row(
      children: [
        // Circular avatar
        CircleAvatar(
          radius: 20,
          backgroundColor: primaryColor.withOpacity(0.1),
          backgroundImage: blog.user?.photo != null
              ? NetworkImage("${ApiConstants.imageBaseUrl}${blog.user!.photo}")
              : null,
          child: blog.user?.photo == null
              ? Text(
                  avatarLetter,
                  style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 16),
                )
              : null,
        ),
        const SizedBox(width: 10),
        
        // Name, checkmark and status details
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'By $author',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Color(0xFF1D1D1D),
                    ),
                  ),
                  const SizedBox(width: 4),
                  // Pink verified badge exactly like the mock!
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 8,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                '$date   •   $readTime min read',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInteractionRow(BuildContext context, Blog blog, Color primaryColor, BlogController controller) {
    final authService = Get.isRegistered<AuthService>() ? Get.find<AuthService>() : null;
    final currentUserId = authService?.currentUser.value?.id;
    final bool isMyBlog = blog.userId != null && blog.userId!.toString() == currentUserId?.toString();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Left Side: Edit & Delete Buttons (Visible only if it's my blog)
        if (isMyBlog)
          Row(
            children: [
              // Edit Button Pill
              GestureDetector(
                onTap: () => Get.to(() => CreateBlogScreen(blog: blog)),
                child: Container(
                  height: 38,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(19),
                    border: Border.all(color: primaryColor.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.edit_outlined, size: 14, color: primaryColor),
                      const SizedBox(width: 6),
                      Text(
                        "Edit",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              
              // Delete Button Pill
              GestureDetector(
                onTap: () {
                  // Show confirmation dialog before delete
                  Get.dialog(
                    AlertDialog(
                      title: const Text("Delete Blog", style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Nunito-Bold')),
                      content: const Text("Are you sure you want to delete this blog?"),
                      actions: [
                        TextButton(
                          onPressed: () => Get.back(),
                          child: const Text("Cancel"),
                        ),
                        TextButton(
                          onPressed: () async {
                            Get.back(); // Close dialog
                            final deleted = await controller.deleteBlog(blog.id ?? 0);
                            if (deleted) {
                              // Use standard Navigator to pop the screen, bypassing GetX's snackbar interception
                              if (context.mounted) {
                                Navigator.of(context).pop();
                              }
                            }
                          },
                          child: const Text("Delete", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  );
                },
                child: Container(
                  height: 38,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(19),
                    border: Border.all(color: Colors.red.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.delete_outline_rounded, size: 14, color: Colors.red),
                      const SizedBox(width: 6),
                      const Text(
                        "Delete",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          )
        else
          const SizedBox.shrink(),

        // Right Side: Like & Share Buttons
        Row(
          children: [
            // Elegant Like Pill (Heart icon & likes count)
            GestureDetector(
              onTap: () => controller.toggleLike(blog.id ?? 0),
              child: Container(
                height: 38,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: blog.isLiked == true ? primaryColor.withOpacity(0.08) : Colors.grey[50],
                  borderRadius: BorderRadius.circular(19),
                  border: Border.all(
                    color: blog.isLiked == true ? primaryColor.withOpacity(0.2) : const Color(0xFFE5E7EB),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      blog.isLiked == true ? Icons.favorite : Icons.favorite_border_rounded,
                      size: 16,
                      color: blog.isLiked == true ? primaryColor : Colors.grey[600],
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${blog.likesCount ?? 0}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: blog.isLiked == true ? primaryColor : Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Elegant Share Circle Button
            GestureDetector(
              onTap: () {
                Share.share(
                  "${blog.title ?? 'Check out this blog!'}\n\n${blog.description ?? ''}",
                );
              },
              child: Container(
                height: 38,
                width: 38,
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Icon(Icons.share_outlined, size: 16, color: Colors.grey[600]),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTagsList(Color primaryColor, List<String> tags) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: tags.map((tag) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: primaryColor.withOpacity(0.3)),
        ),
        child: Text(
          tag,
          style: TextStyle(
            fontSize: 11,
            color: primaryColor,
            fontWeight: FontWeight.bold,
          ),
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
            const Text(
              'Related Blogs',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color(0xFF1D1D1D),
                fontFamily: 'Nunito-Bold',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        controller.relatedBlogs.isEmpty
            ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(child: Text('No related blogs', style: TextStyle(color: Colors.grey[400], fontSize: 13))),
              )
            : SizedBox(
                height: 180,
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
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            )
          ],
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: SizedBox(
                height: 90,
                width: double.infinity,
                child: imageUrl != null
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.grey[100],
                          child: Center(child: Icon(Icons.image_outlined, size: 24, color: primaryColor.withOpacity(0.3))),
                        ),
                      )
                    : Container(
                        color: Colors.grey[100],
                        child: Center(child: Icon(Icons.image_outlined, size: 24, color: primaryColor.withOpacity(0.3))),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    blog.title ?? 'No Title',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1D1D1D),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.favorite, size: 12, color: primaryColor),
                      const SizedBox(width: 4),
                      Text(
                        '${blog.likesCount ?? 0}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.bold,
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
}

// 🆕 Modern fullscreen media gallery supporting pinch-to-zoom slide actions for images and auto-play videos
class FullMediaGalleryScreen extends StatelessWidget {
  final List<String> mediaList;
  final int initialIndex;
  final String mediaType;

  const FullMediaGalleryScreen({
    super.key,
    required this.mediaList,
    required this.initialIndex,
    required this.mediaType,
  });

  bool _isVideoFile(String path) {
    final lowercasePath = path.toLowerCase();
    return lowercasePath.endsWith('.mp4') ||
        lowercasePath.endsWith('.mov') ||
        lowercasePath.endsWith('.avi') ||
        lowercasePath.endsWith('.mkv') ||
        lowercasePath.endsWith('.webm') ||
        lowercasePath.endsWith('.3gp') ||
        lowercasePath.endsWith('.m4v');
  }

  @override
  Widget build(BuildContext context) {
    final RxInt activeIndex = initialIndex.obs;
    final PageController pageController = PageController(initialPage: initialIndex);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Gallery View
          PageView.builder(
            controller: pageController,
            onPageChanged: (index) => activeIndex.value = index,
            itemCount: mediaList.length,
            itemBuilder: (context, index) {
              final path = mediaList[index];
              final url = "${ApiConstants.imageBaseUrl}$path";
              final isThisVideo = (mediaType == 'video') || _isVideoFile(path);

              if (isThisVideo) {
                return Center(
                  child: FullScreenVideoItem(videoUrl: url, autoPlay: true),
                );
              }

              // Image with pinch-to-zoom support
              return InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Center(
                  child: Image.network(
                    url,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Center(
                      child: Icon(Icons.broken_image_outlined, color: Colors.white38, size: 48),
                    ),
                  ),
                ),
              );
            },
          ),

          // Close Button
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            child: GestureDetector(
              onTap: () => Get.back(),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.black45,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close_rounded, color: Colors.white, size: 22),
              ),
            ),
          ),

          // Page Indicators
          if (mediaList.length > 1)
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 20,
              left: 0,
              right: 0,
              child: Obx(() {
                return Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      "${activeIndex.value + 1} / ${mediaList.length}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }),
            ),
        ],
      ),
    );
  }
}

// 🆕 Stateful video player container that initializes dynamically and disposes cleanly
class FullScreenVideoItem extends StatefulWidget {
  final String videoUrl;
  final bool autoPlay;

  const FullScreenVideoItem({
    super.key,
    required this.videoUrl,
    this.autoPlay = true,
  });

  @override
  State<FullScreenVideoItem> createState() => _FullScreenVideoItemState();
}

class _FullScreenVideoItemState extends State<FullScreenVideoItem> {
  late VideoPlayerController _videoController;
  ChewieController? _chewieController;
  bool _initialized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  void _initializePlayer() {
    _videoController = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
    _videoController.initialize().then((_) {
      if (!mounted) return;
      setState(() {
        _chewieController = ChewieController(
          videoPlayerController: _videoController,
          autoPlay: widget.autoPlay,
          looping: true,
          aspectRatio: _videoController.value.aspectRatio,
          errorBuilder: (context, errorMessage) {
            return Center(
              child: Text(
                errorMessage,
                style: const TextStyle(color: Colors.white70),
              ),
            );
          },
        );
        _initialized = true;
      });
    }).catchError((e) {
      if (!mounted) return;
      setState(() {
        _hasError = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return const Center(
        child: Icon(Icons.error_outline_rounded, color: Colors.red, size: 40),
      );
    }

    if (!_initialized || _chewieController == null) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    return AspectRatio(
      aspectRatio: _videoController.value.aspectRatio,
      child: Chewie(controller: _chewieController!),
    );
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoController.dispose();
    super.dispose();
  }
}

