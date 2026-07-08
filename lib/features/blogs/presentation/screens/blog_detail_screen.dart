import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
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

class BlogDetailScreen extends StatefulWidget {
  final int blogId;
  const BlogDetailScreen({super.key, required this.blogId});

  @override
  State<BlogDetailScreen> createState() => _BlogDetailScreenState();
}

class _BlogDetailScreenState extends State<BlogDetailScreen> {
  final BlogController controller = Get.find<BlogController>();

  int _calculateReadingTime(String? text) {
    if (text == null || text.isEmpty) return 1;
    final wordCount = text.split(RegExp(r'\s+')).length;
    return (wordCount / 200).ceil().clamp(1, 60);
  }

  @override
  void initState() {
    super.initState();
    // Fetch details when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchBlogDetail(widget.blogId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFFC0227B);

    // Provide a localized dismiss for keyboard
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: AnnotatedRegion<SystemUiOverlayStyle>(
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

            String categoryName = '';
            if (blog.category != null && blog.category!.name != null) {
              categoryName = blog.category!.name!;
            } else if (blog.blogType != null && blog.blogType!.isNotEmpty) {
              try {
                final cat = controller.categories.firstWhere((c) => c.id?.toString() == blog.blogType);
                categoryName = cat.name ?? blog.blogType!;
              } catch (e) {
                categoryName = blog.blogType!; // fallback to ID
              }
            }

            final String title = blog.title ?? 'No Title';
            final String author = blog.user?.name ?? 'Unknown Author';
            final String date = _formatDate(blog.createdAt);
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
                      if (categoryName.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Text(
                            categoryName,
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
                      Row(
                        children: [
                          Container(width: 3, height: 18, decoration: BoxDecoration(color: primaryColor, borderRadius: BorderRadius.circular(2))),
                          const SizedBox(width: 8),
                          const Text(
                            'Full Content',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color(0xFF1D1D1D),
                              fontFamily: 'Nunito-Bold',
                            ),
                          ),
                        ],
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

                      // Comments Section
                      _buildCommentsSection(context, primaryColor, blog, controller),
                      const SizedBox(height: 28),

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
              final isThisVideo = _isVideoFile(path);
              
              if (isThisVideo) {
                return Center(
                  child: FullScreenVideoItem(
                    videoUrl: url,
                    autoPlay: true,
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
              // Row(
              //   children: [
              //     Container(
              //       width: 38,
              //       height: 38,
              //       decoration: const BoxDecoration(
              //         color: Colors.white,
              //         shape: BoxShape.circle,
              //       ),
              //       child: const Icon(Icons.more_vert_rounded, color: Color(0xFF1D1D1D), size: 20),
              //     ),
              //   ],
              // ),
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

    Widget buildButton(IconData icon, String label, VoidCallback onTap, {Color? iconColor}) {
      return Expanded(
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: primaryColor.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 18, color: iconColor ?? primaryColor),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        Row(
          children: [
            // Like Button
            buildButton(
              blog.isLiked == true ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
              '${blog.likesCount ?? 0} Likes',
              () => controller.toggleLike(blog.id ?? 0),
              iconColor: blog.isLiked == true ? Colors.redAccent : primaryColor,
            ),
            const SizedBox(width: 8),
            // Share Button
            buildButton(
              Icons.share_outlined,
              'Share',
              () {
                // Using an https URL so it's clickable in WhatsApp/social media.
                // Deep link handling will open the app if installed.
                final String shareLink = 'https://malisetu.com/blog/${blog.id}';
                final String playStoreLink = 'https://play.google.com/store/apps/details?id=com.malisetu.app';
                Share.share("${blog.title ?? 'Check out this blog!'}\n\nRead more: $shareLink\n\nDownload our app: $playStoreLink");
              },
            ),
            const SizedBox(width: 8),
            // Comment Button
            buildButton(
              CupertinoIcons.chat_bubble_text,
              'Comment',
              () {
                _showCommentBottomSheet(context, blog, primaryColor, controller);
              },
            ),
          ],
        ),
        if (isMyBlog) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              buildButton(
                Icons.edit_outlined,
                'Edit',
                () => Get.to(() => CreateBlogScreen(blog: blog)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Get.dialog(
                      AlertDialog(
                        title: const Text("Delete Blog", style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Nunito-Bold')),
                        content: const Text("Are you sure you want to delete this blog?"),
                        actions: [
                          TextButton(onPressed: () => Get.back(), child: const Text("Cancel")),
                          TextButton(
                            onPressed: () async {
                              Get.back();
                              final deleted = await controller.deleteBlog(blog.id ?? 0);
                              if (deleted && context.mounted) {
                                Navigator.of(context).pop();
                              }
                            },
                            child: const Text("Delete", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.withOpacity(0.2)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.red),
                        const SizedBox(width: 6),
                        const Text(
                          "Delete",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ]
      ],
    );
  }

  Widget _buildTagsList(Color primaryColor, List<String> tags) {
    return Wrap(
      spacing: 8,
      runSpacing: 10,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        const Padding(
          padding: EdgeInsets.only(right: 4.0),
          child: Text(
            'Tags:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color(0xFF1D1D1D),
            ),
          ),
        ),
        ...tags.map((tag) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: primaryColor.withOpacity(0.3)),
          ),
          child: Text(
            tag,
            style: TextStyle(
              fontSize: 12,
              color: primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        )).toList(),
      ],
    );
  }

  String _timeAgo(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try {
      final date = DateTime.parse(dateStr).toLocal();
      final diff = DateTime.now().difference(date);
      if (diff.inDays > 365) return '${(diff.inDays / 365).floor()} years ago';
      if (diff.inDays > 30) return '${(diff.inDays / 30).floor()} months ago';
      if (diff.inDays > 0) return '${diff.inDays} days ago';
      if (diff.inHours > 0) return '${diff.inHours} hours ago';
      if (diff.inMinutes > 0) return '${diff.inMinutes} minutes ago';
      return 'Just now';
    } catch (e) {
      return dateStr.split('T').first;
    }
  }

  void _showCommentBottomSheet(BuildContext context, Blog blog, Color primaryColor, BlogController controller) {
    final authService = Get.isRegistered<AuthService>() ? Get.find<AuthService>() : null;
    final currentUser = authService?.currentUser.value;
    final userName = currentUser?.name ?? '';
    final userInitial = userName.isNotEmpty ? userName[0].toUpperCase() : 'U';

    Get.bottomSheet(
      Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          top: 24,
          left: 16,
          right: 16,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add a Comment',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                fontFamily: 'Nunito-Bold',
              ),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey.shade600,
                  backgroundImage: currentUser?.profileImage != null
                      ? NetworkImage("${ApiConstants.imageBaseUrl}${currentUser!.profileImage}")
                      : null,
                  child: currentUser?.profileImage == null
                      ? Text(userInitial, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (userName.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6, left: 4),
                          child: Text(
                            userName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Color(0xFF1D1D1D),
                            ),
                          ),
                        ),
                      Container(
                        constraints: const BoxConstraints(minHeight: 48),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: TextField(
                          controller: controller.commentTextController,
                          maxLines: null,
                          autofocus: true,
                          decoration: const InputDecoration(
                            hintText: 'Write your comment...',
                            hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Obx(() => ElevatedButton.icon(
                          onPressed: controller.isCommentPosting.value
                              ? null
                              : () async {
                                  await controller.postComment(blog.id ?? 0);
                                  if (Get.isBottomSheetOpen == true) {
                                    Get.back();
                                  }
                                },
                          icon: controller.isCommentPosting.value
                              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Icon(Icons.send_rounded, size: 16, color: Colors.white),
                          label: const Text('Publish', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          ),
                        )),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Widget _buildCommentsSection(BuildContext context, Color primaryColor, Blog blog, BlogController controller) {
    final comments = blog.comments ?? [];
    final authService = Get.isRegistered<AuthService>() ? Get.find<AuthService>() : null;
    final currentUser = authService?.currentUser.value;
    final userName = currentUser?.name ?? '';
    final userInitial = userName.isNotEmpty ? userName[0].toUpperCase() : 'U';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(width: 3, height: 18, decoration: BoxDecoration(color: primaryColor, borderRadius: BorderRadius.circular(2))),
            const SizedBox(width: 8),
            const Text(
              'Comments',
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

        
        // Comments List
        Obx(() {
          final isShowingAll = controller.showAllComments.value;
          final visibleComments = isShowingAll ? comments : comments.take(5).toList();

          if (comments.isEmpty) {
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 32),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  Icon(Icons.chat_bubble_outline_rounded, size: 48, color: Colors.grey.shade400),
                  const SizedBox(height: 12),
                  Text(
                    'No comments yet',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Be the first to share your thoughts!',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () => _showCommentBottomSheet(context, blog, primaryColor, controller),
                    icon: Icon(Icons.add_comment_rounded, size: 18, color: primaryColor),
                    label: Text('Add Comment', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: primaryColor),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    ),
                  ),
                ],
              ),
            );
          }
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...visibleComments.map((comment) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildCommentItem(
                  context: context,
                  primaryColor: primaryColor,
                  comment: comment,
                  controller: controller,
                  blog: blog,
                ),
              )).toList(),
              
              if (comments.length > 5)
                Center(
                  child: TextButton(
                    onPressed: () => controller.showAllComments.value = !controller.showAllComments.value,
                    child: Text(
                      isShowingAll ? 'Show less' : 'View more comments',
                      style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildCommentItem({
    required BuildContext context,
    required Color primaryColor,
    required BlogComment comment,
    required BlogController controller,
    required Blog blog,
    bool isReply = false,
  }) {
    final authorName = comment.user?.name ?? 'Unknown User';
    final avatarLetter = authorName.isNotEmpty ? authorName[0].toUpperCase() : 'U';
    final authService = Get.isRegistered<AuthService>() ? Get.find<AuthService>() : null;
    final currentUserId = authService?.currentUser.value?.id;
    final isMyComment = comment.userId != null && comment.userId.toString() == currentUserId?.toString();
    final isBlogOwner = currentUserId?.toString() == blog.userId?.toString();
    final hasActions = isBlogOwner || isMyComment;
    
    // Parse timeAgo
    String timeAgo = _timeAgo(comment.createdAt);

    return Obx(() {
      final isReplyingToThis = controller.replyToComment.value?.id == comment.id;
      
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isReply)
                Container(
                  width: 24,
                  height: 34,
                  margin: const EdgeInsets.only(left: 18), // Aligns with center of parent avatar
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(color: Colors.grey.shade400, width: 2),
                      bottom: BorderSide(color: Colors.grey.shade400, width: 2),
                    ),
                    borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(12)),
                  ),
                ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isReply ? Colors.white : const Color(0xFFF9FAFB),
                    border: isReply ? Border.all(color: Colors.grey.shade200) : null,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header: Avatar, Name, Time
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: isReply ? 14 : 18,
                      backgroundColor: Colors.grey.shade600,
                      backgroundImage: comment.user?.photo != null
                          ? NetworkImage("${ApiConstants.imageBaseUrl}${comment.user!.photo}")
                          : null,
                      child: comment.user?.photo == null 
                          ? Text(avatarLetter, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold))
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(authorName, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1D1D1D), fontSize: 14)),
                          const SizedBox(height: 6),
                          Text(comment.comment ?? '', style: const TextStyle(color: Color(0xFF333333), fontSize: 14, height: 1.4)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(timeAgo, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                  ],
                ),
                if (hasActions) ...[
                  const SizedBox(height: 12),
                  // Actions: Reply & Delete
                  Padding(
                    padding: EdgeInsets.only(left: isReply ? 40 : 48),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        // Reply Button (Only for blog owner and not a nested reply)
                        if (isBlogOwner && !isReply)
                          InkWell(
                            onTap: () {
                              // Toggle reply mode
                              if (isReplyingToThis) {
                                controller.setReplyTo(null);
                              } else {
                                controller.setReplyTo(comment);
                              }
                            },
                            borderRadius: BorderRadius.circular(4),
                            child: Padding(
                              padding: const EdgeInsets.only(top: 4, bottom: 4, right: 20),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(isReplyingToThis ? Icons.close : Icons.reply_rounded, size: 16, color: primaryColor),
                                  const SizedBox(width: 4),
                                  Text(isReplyingToThis ? 'Cancel' : 'Reply', style: TextStyle(color: primaryColor, fontSize: 13, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ),
                        
                        // Delete Button
                        if (isMyComment)
                          InkWell(
                            onTap: () {
                              Get.dialog(
                                AlertDialog(
                                  title: const Text("Delete Comment"),
                                  content: const Text("Are you sure you want to delete this comment?"),
                                  actions: [
                                    TextButton(onPressed: () => Get.back(), child: const Text("Cancel")),
                                    TextButton(
                                      onPressed: () {
                                        Get.back();
                                        controller.deleteComment(comment.id ?? 0, blog.id ?? 0);
                                      },
                                      child: const Text("Delete", style: TextStyle(color: Colors.red)),
                                    ),
                                  ],
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(4),
                            child: Padding(
                              padding: const EdgeInsets.only(top: 4, bottom: 4, right: 16),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(Icons.delete_rounded, size: 16, color: Colors.red),
                                  SizedBox(width: 4),
                                  Text('Delete', style: TextStyle(color: Colors.red, fontSize: 13, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
                
                // Reply Input Section
                if (isReplyingToThis) ...[
                  const SizedBox(height: 16),
                  Padding(
                    padding: EdgeInsets.only(left: isReply ? 40 : 48),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: TextField(
                              controller: controller.commentTextController,
                              decoration: const InputDecoration(
                                hintText: 'Write a reply...',
                                hintStyle: TextStyle(color: Colors.grey, fontSize: 13),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                                isDense: true,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Loading / Send Button
                        GestureDetector(
                          onTap: controller.isCommentPosting.value 
                              ? null 
                              : () => controller.postComment(blog.id ?? 0),
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: primaryColor,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: controller.isCommentPosting.value
                                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                  : const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                
                // Nested Replies (Box inside a box)
                if (comment.replies != null && comment.replies!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Column(
                      children: comment.replies!.map((reply) => Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: _buildCommentItem(
                          context: context,
                          primaryColor: primaryColor,
                          comment: reply,
                          controller: controller,
                          blog: blog,
                          isReply: true,
                        ),
                      )).toList(),
                    ),
                  ),
              ],
            ),
          ),
        ), // Close Expanded
      ],
    ), // Close Row
  ],
);
    });
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
            ? Container(
                padding: const EdgeInsets.symmetric(vertical: 32),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    Icon(Icons.article_outlined, size: 48, color: Colors.grey.shade400),
                    const SizedBox(height: 12),
                    Text(
                      'No related blogs found',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Check back later for more content.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
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
    final String? firstMedia = blog.mediaPaths != null && blog.mediaPaths!.isNotEmpty
        ? blog.mediaPaths!.first
        : blog.mediaPath;
    final bool isVideo = firstMedia != null &&
        (firstMedia.toLowerCase().endsWith('.mp4') ||
            firstMedia.toLowerCase().endsWith('.mov') ||
            firstMedia.toLowerCase().endsWith('.avi') ||
            firstMedia.toLowerCase().endsWith('.mkv') ||
            firstMedia.toLowerCase().endsWith('.webm') ||
            firstMedia.toLowerCase().endsWith('.3gp') ||
            firstMedia.toLowerCase().endsWith('.m4v'));
    final Widget mediaWidget = isVideo
    ? Stack(
        alignment: Alignment.center,
        children: [
          Image.network(
            "${ApiConstants.imageBaseUrl}$firstMedia",
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          const Icon(Icons.play_circle_fill, color: Colors.white70, size: 40),
        ],
      )
    : Image.network(
        "${ApiConstants.imageBaseUrl}$firstMedia",
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          color: Colors.grey[100],
          child: Center(
            child: Icon(Icons.image_outlined, size: 24, color: primaryColor.withOpacity(0.3)),
          ),
        ),
      );
    return GestureDetector(
      onTap: () => Get.to(() => BlogDetailScreen(blogId: blog.id ?? 0),
          preventDuplicates: false),
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
                child: mediaWidget,
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
              final isThisVideo = _isVideoFile(path);

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
          showControls: false,
          customControls: const SizedBox.shrink(),
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

