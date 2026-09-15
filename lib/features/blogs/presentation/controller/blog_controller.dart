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
  final RxList<Blog> myBlogs = <Blog>[].obs; // logged-in user's blogs only
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
  final Rx<BlogCategory> selectedCategory = BlogCategory(
    id: null,
    name: 'All',
  ).obs;

  // Detail State
  final Rxn<Blog> selectedBlog = Rxn<Blog>();
  final RxList<Blog> relatedBlogs = <Blog>[].obs;
  final RxBool isDetailLoading = false.obs;

  // Video State for detail screen
  final Rxn<VideoPlayerController> detailVideoController =
      Rxn<VideoPlayerController>();
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
        // Fallback: If myBlogs is empty but main blogs list contains the user's blogs
        if (list.isEmpty && myId != null) {
          list = blogs
              .where((b) => b.userId?.toString() == myId.toString())
              .toList();
        }
      } else {
        // General Blogs feed: Show ALL blogs (do NOT exclude the user's own blogs)
        list = blogs.toList();
      }

      // Category Filter (safe string comparison)
      if (selectedCategory.value.name != 'All' &&
          selectedCategory.value.id != null) {
        final catId = selectedCategory.value.id.toString();
        list = list
            .where(
              (b) =>
                  b.blogType?.toString() == catId ||
                  (b.category != null &&
                      b.category!.id?.toString() == catId),
            )
            .toList();
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
    try {
      final response = await _repository.getBlogs(
        page: currentPage.value,
        categoryId: selectedCategory.value.id,
      );

      if (response != null &&
          response.success == true &&
          response.data != null) {
        final newBlogs = response.data?.data ?? [];

        if (newBlogs.isEmpty) {
          hasMore.value = false;
        } else {
          blogs.addAll(newBlogs);
          currentPage.value++;
        }
      }
    } catch (e) {
      debugPrint("fetchBlogs error: $e");
    } finally {
      _applyFilter();
      isLoading.value = false;
    }
  }

  /// Fetch the current user's blogs.
  /// Always does client-side userId filter as a fallback.
  Future<void> fetchMyBlogs() async {
    if (isMyBlogsLoading.value) return;
    isMyBlogsLoading.value = true;
    try {
      final response = await _repository.getMyBlogs();
      if (response != null &&
          response.success == true &&
          response.data != null) {
        final fetched = response.data?.data ?? [];
        final myId = _currentUserId();

        if (myId != null) {
          final userBlogs = fetched
              .where((b) => b.userId?.toString() == myId.toString())
              .toList();
          myBlogs.assignAll(userBlogs.isNotEmpty ? userBlogs : fetched);
        } else {
          myBlogs.assignAll(fetched);
        }
      }
    } catch (e) {
      debugPrint('fetchMyBlogs error: $e');
    } finally {
      if (selectedTab.value == 'Mine') _applyFilter();
      isMyBlogsLoading.value = false;
    }
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
    if (tab == 'Mine') {
      if (myBlogs.isEmpty && !isMyBlogsLoading.value) {
        fetchMyBlogs();
      } else {
        _applyFilter();
      }
    } else {
      if (blogs.isEmpty && !isLoading.value) {
        fetchBlogs();
      } else {
        _applyFilter();
      }
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

  final Set<int> _likingBlogIds = <int>{};

  void _updateBlogInAllLists(Blog updated) {
    final id = updated.id;
    if (id == null) return;

    final bIdx = blogs.indexWhere((b) => b.id == id);
    if (bIdx != -1) blogs[bIdx] = updated;

    final fIdx = filteredBlogs.indexWhere((b) => b.id == id);
    if (fIdx != -1) filteredBlogs[fIdx] = updated;

    final mIdx = myBlogs.indexWhere((b) => b.id == id);
    if (mIdx != -1) myBlogs[mIdx] = updated;

    final rIdx = relatedBlogs.indexWhere((b) => b.id == id);
    if (rIdx != -1) relatedBlogs[rIdx] = updated;

    if (selectedBlog.value?.id == id) {
      selectedBlog.value = selectedBlog.value!.copyWith(
        isLiked: updated.isLiked,
        likesCount: updated.likesCount,
      );
    }
  }

  Future<void> toggleLike(int blogId) async {
    if (blogId <= 0 || _likingBlogIds.contains(blogId)) return;
    _likingBlogIds.add(blogId);

    // 1. Locate the blog from whichever list contains it
    Blog? targetBlog;
    if (selectedBlog.value?.id == blogId) {
      targetBlog = selectedBlog.value;
    }
    if (targetBlog == null) {
      final fIdx = filteredBlogs.indexWhere((b) => b.id == blogId);
      if (fIdx != -1) targetBlog = filteredBlogs[fIdx];
    }
    if (targetBlog == null) {
      final bIdx = blogs.indexWhere((b) => b.id == blogId);
      if (bIdx != -1) targetBlog = blogs[bIdx];
    }
    if (targetBlog == null) {
      final mIdx = myBlogs.indexWhere((b) => b.id == blogId);
      if (mIdx != -1) targetBlog = myBlogs[mIdx];
    }
    if (targetBlog == null) {
      final rIdx = relatedBlogs.indexWhere((b) => b.id == blogId);
      if (rIdx != -1) targetBlog = relatedBlogs[rIdx];
    }

    if (targetBlog == null) {
      _likingBlogIds.remove(blogId);
      return;
    }

    final bool currentLiked = targetBlog.isLiked ?? false;
    final int currentCount = targetBlog.likesCount ?? 0;
    final bool optimisticLiked = !currentLiked;
    final int optimisticCount = optimisticLiked
        ? currentCount + 1
        : (currentCount > 0 ? currentCount - 1 : 0);

    // 2. Optimistic Update across all lists
    final updatedBlog = targetBlog.copyWith(
      isLiked: optimisticLiked,
      likesCount: optimisticCount,
    );
    _updateBlogInAllLists(updatedBlog);

    try {
      final response = await _repository.toggleLike(blogId);

      bool isSuccess = false;
      bool? serverLiked;
      int? serverLikesCount;

      if (response != null) {
        isSuccess = response['success'] == true ||
            response['success'] == 1 ||
            response['status'] == true ||
            response['status'] == 200;

        final dynamic data = response['data'] ?? response;
        if (data is Map) {
          if (data.containsKey('liked')) {
            serverLiked = data['liked'] == true || data['liked'] == 1;
          } else if (data.containsKey('is_liked')) {
            serverLiked = data['is_liked'] == true || data['is_liked'] == 1;
          }

          if (data.containsKey('likes_count')) {
            serverLikesCount = int.tryParse(data['likes_count'].toString());
          } else if (data.containsKey('like_count')) {
            serverLikesCount = int.tryParse(data['like_count'].toString());
          }
        }
      }

      if (isSuccess) {
        // Sync with verified server values
        final finalBlog = targetBlog.copyWith(
          isLiked: serverLiked ?? optimisticLiked,
          likesCount: serverLikesCount ?? optimisticCount,
        );
        _updateBlogInAllLists(finalBlog);
      } else {
        // Revert on actual server failure
        _updateBlogInAllLists(targetBlog);
      }
    } catch (e) {
      debugPrint("toggleLike error: $e");
      // Revert on exception
      _updateBlogInAllLists(targetBlog);
    } finally {
      _likingBlogIds.remove(blogId);
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
      final videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(videoUrl),
      );
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

    final response = await _repository.addComment(
      blogId,
      text,
      parentId: parentId,
    );
    if (response != null && response['success'] == true) {
      CustomSnackBar.showSuccess(
        message: response['message'] ?? 'Comment posted',
      );
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
