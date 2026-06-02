import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../../data/data_source/blog_data_source.dart';
import '../../data/model/blog_model.dart';
import '../../../../core/constent/api_constants.dart';
import '../../../Auth/service/auth_service.dart';
import '../../../../widgets/custom_snack_bar.dart';

class BlogController extends GetxController {
  final BlogRepository _repository = BlogRepository();

  final RxList<Blog> blogs = <Blog>[].obs;
  final RxList<Blog> myBlogs = <Blog>[].obs;  // logged-in user's blogs only
  final RxList<Blog> filteredBlogs = <Blog>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isMyBlogsLoading = false.obs;
  final RxInt currentPage = 1.obs;
  final RxBool hasMore = true.obs;
  final RxString searchQuery = ''.obs;
  final searchTextController = TextEditingController();
  final RxString selectedTab = 'Others'.obs; // 'Mine' or 'Others'

  final BlogCategory allCategory = BlogCategory(id: null, name: 'All');
  final RxList<BlogCategory> categories = <BlogCategory>[].obs;
  final Rx<BlogCategory> selectedCategory = BlogCategory(id: null, name: 'All').obs;

  // Detail State
  final Rxn<Blog> selectedBlog = Rxn<Blog>();
  final RxList<Blog> relatedBlogs = <Blog>[].obs;
  final RxBool isDetailLoading = false.obs;

  // Video State for detail screen
  final Rxn<VideoPlayerController> detailVideoController = Rxn<VideoPlayerController>();
  final Rxn<ChewieController> chewieController = Rxn<ChewieController>();
  final RxBool isVideoInitialized = false.obs;

  // Comment State
  final commentTextController = TextEditingController();
  final RxBool isCommentPosting = false.obs;
  final Rxn<BlogComment> replyToComment = Rxn<BlogComment>();
  final RxBool showAllComments = false.obs;

  @override
  void onInit() {
    super.onInit();
    categories.assignAll([allCategory]);
    fetchCategories();
    fetchBlogs();
    fetchMyBlogs(); // Pre-load my blogs in parallel
    
    // Debounce search query changes
    debounce(searchQuery, (query) {
      if (query.isEmpty) {
        _applyFilter();
      } else {
        _performSearch(query);
      }
    }, time: const Duration(milliseconds: 500));
  }

  Future<void> fetchCategories() async {
    final response = await _repository.getBlogCategories();
    if (response != null && response.success == true && response.data != null) {
      final List<BlogCategory> fetchedCategories = response.data!;
      categories.assignAll([allCategory, ...fetchedCategories]);
    }
  }

  /// Returns the logged-in user's id, or null if not available.
  int? _currentUserId() {
    try {
      if (Get.isRegistered<AuthService>()) {
        return Get.find<AuthService>().currentUser.value?.id;
      }
    } catch (_) {}
    return null;
  }

  void _applyFilter() {
    try {
      final myId = _currentUserId();
      List<Blog> list;

      if (selectedTab.value == 'Mine') {
        // Show only the logged-in user's blogs
        list = myBlogs.toList();
      } else {
        // "Others" tab → all blogs EXCEPT the logged-in user's
        list = blogs.toList();
        if (myId != null) {
          list = list.where((b) => b.userId?.toString() != myId.toString()).toList();
        }
      }

      // Category Filter (local filtering, though we also filter via API)
      if (selectedCategory.value.name != 'All' && selectedCategory.value.id != null) {
        list = list.where((b) => 
          b.blogType == selectedCategory.value.id?.toString() || 
          (b.category != null && b.category!.id == selectedCategory.value.id)
        ).toList();
      }

      filteredBlogs.assignAll(list);
    } catch (e) {
      debugPrint("Error in _applyFilter: $e");
      filteredBlogs.assignAll(blogs);
    }
  }

  Future<void> fetchBlogs({bool refresh = false}) async {
    if (isLoading.value) return;

    if (refresh) {
      currentPage.value = 1;
      blogs.clear();
      hasMore.value = true;
    }

    if (!hasMore.value) return;

    isLoading.value = true;
    final response = await _repository.getBlogs(
      page: currentPage.value, 
      categoryId: selectedCategory.value.id
    );

    if (response != null && response.success == true && response.data != null) {
      final newBlogs = response.data?.data ?? [];
      
      if (newBlogs.isEmpty) {
        hasMore.value = false;
      } else {
        blogs.addAll(newBlogs);
        _applyFilter();
        currentPage.value++;
      }
    }

    isLoading.value = false;
  }

  /// Fetch the current user's blogs.
  /// Always does client-side userId filter as a fallback.
  Future<void> fetchMyBlogs() async {
    if (isMyBlogsLoading.value) return;
    isMyBlogsLoading.value = true;
    try {
      final response = await _repository.getMyBlogs();
      if (response != null && response.success == true && response.data != null) {
        final fetched = response.data?.data ?? [];
        final myId = _currentUserId();

        if (myId != null) {
          // Always filter by userId — works whether server filtered or not
          myBlogs.assignAll(
            fetched.where((b) => b.userId?.toString() == myId.toString()).toList(),
          );
        } else {
          // AuthService not ready yet — store full list, will re-filter when needed
          myBlogs.assignAll(fetched);
        }

        // Refresh view if Mine tab is active
        if (selectedTab.value == 'Mine') _applyFilter();
      }
    } catch (e) {
      debugPrint('fetchMyBlogs error: $e');
    }
    isMyBlogsLoading.value = false;
  }

  void searchBlogs(String query) {
    searchQuery.value = query;
  }

  void clearSearch() {
    searchTextController.clear();
    searchQuery.value = '';
    _applyFilter();
  }

  void filterByCategory(BlogCategory category) {
    selectedCategory.value = category;
    selectedCategory.refresh();
    searchTextController.clear();
    searchQuery.value = '';
    fetchBlogs(refresh: true);
  }

  void filterByTab(String tab) {
    selectedTab.value = tab;
    searchTextController.clear();
    searchQuery.value = '';
    // If switching to Mine tab and myBlogs is empty, fetch them
    if (tab == 'Mine' && myBlogs.isEmpty && !isMyBlogsLoading.value) {
      fetchMyBlogs();
    } else {
      _applyFilter();
    }
  }

  Future<void> _performSearch(String query) async {
    isLoading.value = true;
    final response = await _repository.searchBlogs(query);
    
    if (response != null && response.success == true && response.data != null) {
      filteredBlogs.assignAll(response.data?.data ?? []);
    } else {
      filteredBlogs.clear();
    }
    isLoading.value = false;
  }

  Future<void> toggleLike(int blogId) async {
    final index = blogs.indexWhere((b) => b.id == blogId);
    if (index == -1) return;

    final blog = blogs[index];
    final bool currentLiked = blog.isLiked ?? false;
    final int currentCount = blog.likesCount ?? 0;

    // Optimistic Update
    final updatedBlog = blog.copyWith(
      isLiked: !currentLiked,
      likesCount: currentLiked ? currentCount - 1 : currentCount + 1,
    );
    
    // Update main list
    blogs[index] = updatedBlog;
    final filteredIndex = filteredBlogs.indexWhere((b) => b.id == blogId);
    if (filteredIndex != -1) filteredBlogs[filteredIndex] = updatedBlog;
    
    // Update selection if it matches (preserve detail-only fields like comments)
    if (selectedBlog.value?.id == blogId) {
      selectedBlog.value = selectedBlog.value!.copyWith(
        isLiked: !currentLiked,
        likesCount: currentLiked ? currentCount - 1 : currentCount + 1,
      );
    }

    final response = await _repository.toggleLike(blogId);

    if (response != null && response['success'] == true) {
      final data = response['data'];
      final finalBlog = blog.copyWith(
        isLiked: data['liked'],
        likesCount: data['likes_count'],
      );
      
      // Sync with final server state
      blogs[index] = finalBlog;
      if (filteredIndex != -1) filteredBlogs[filteredIndex] = finalBlog;
      
      if (selectedBlog.value?.id == blogId) {
        selectedBlog.value = selectedBlog.value!.copyWith(
          isLiked: data['liked'],
          likesCount: data['likes_count'],
        );
      }
    } else {
      // Revert on failure
      blogs[index] = blog;
      if (filteredIndex != -1) filteredBlogs[filteredIndex] = blog;
      
      if (selectedBlog.value?.id == blogId) {
        selectedBlog.value = selectedBlog.value!.copyWith(
          isLiked: currentLiked,
          likesCount: currentCount,
        );
      }
    }
  }

  Future<void> fetchBlogDetail(int id) async {
    isDetailLoading.value = true;
    selectedBlog.value = null;
    relatedBlogs.clear();
    showAllComments.value = false;

    final response = await _repository.getBlogDetail(id);

    if (response != null && response.success == true && response.data != null) {
      selectedBlog.value = response.data?.blog;
      relatedBlogs.assignAll(response.data?.related ?? []);
      
      _initializeDetailVideo();
    }

    isDetailLoading.value = false;
  }

  void _initializeDetailVideo() {
    _disposeVideo();
    final blog = selectedBlog.value;
    if (blog != null && blog.mediaType == 'video' && blog.mediaPath != null) {
      final videoUrl = "${ApiConstants.imageBaseUrl}${blog.mediaPath}";
      final videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
      detailVideoController.value = videoPlayerController;
      
      videoPlayerController.initialize().then((_) {
        chewieController.value = ChewieController(
          videoPlayerController: videoPlayerController,
          autoPlay: false,
          looping: true,
          aspectRatio: videoPlayerController.value.aspectRatio,
          errorBuilder: (context, errorMessage) {
            return Center(
              child: Text(
                errorMessage,
                style: const TextStyle(color: Colors.white),
              ),
            );
          },
        );
        isVideoInitialized.value = true;
      });
    }
  }

  void _disposeVideo() {
    chewieController.value?.dispose();
    chewieController.value = null;
    detailVideoController.value?.dispose();
    detailVideoController.value = null;
    isVideoInitialized.value = false;
  }

  Future<bool> deleteBlog(int id) async {
    isLoading.value = true;
    final success = await _repository.deleteBlog(id);
    if (success) {
      // Remove from locally loaded lists
      blogs.removeWhere((b) => b.id == id);
      myBlogs.removeWhere((b) => b.id == id); // Also remove from My Blogs tab
      filteredBlogs.removeWhere((b) => b.id == id);
      _applyFilter();
      CustomSnackBar.showSuccess(message: "Blog deleted successfully");
      isLoading.value = false;
      return true;
    } else {
      CustomSnackBar.showError(message: "Failed to delete blog");
      isLoading.value = false;
      return false;
    }
  }

  void setReplyTo(BlogComment? comment) {
    replyToComment.value = comment;
  }

  Future<void> postComment(int blogId) async {
    final text = commentTextController.text.trim();
    if (text.isEmpty) return;
    
    isCommentPosting.value = true;
    final parentId = replyToComment.value?.id;
    
    final response = await _repository.addComment(blogId, text, parentId: parentId);
    if (response != null && response['success'] == true) {
      CustomSnackBar.showSuccess(message: response['message'] ?? 'Comment posted');
      commentTextController.clear();
      replyToComment.value = null;
      // Refresh the blog details to get updated comments
      fetchBlogDetail(blogId);
    } else {
      CustomSnackBar.showError(message: 'Failed to post comment');
    }
    isCommentPosting.value = false;
  }

  Future<void> deleteComment(int commentId, int blogId) async {
    final success = await _repository.deleteComment(commentId);
    if (success) {
      CustomSnackBar.showSuccess(message: 'Comment deleted');
      fetchBlogDetail(blogId);
    } else {
      CustomSnackBar.showError(message: 'Failed to delete comment');
    }
  }

  @override
  void onClose() {
    _disposeVideo();
    commentTextController.dispose();
    super.onClose();
  }
}
