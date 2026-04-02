import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import '../../data/data_source/blog_data_source.dart';
import '../../data/model/blog_model.dart';
import '../../../../core/constent/api_constants.dart';

class BlogController extends GetxController {
  final BlogRepository _repository = BlogRepository();

  final RxList<Blog> blogs = <Blog>[].obs;
  final RxList<Blog> filteredBlogs = <Blog>[].obs;
  final RxBool isLoading = false.obs;
  final RxInt currentPage = 1.obs;
  final RxBool hasMore = true.obs;
  final RxString searchQuery = ''.obs;
  final searchTextController = TextEditingController();
  final RxString selectedCategory = 'All'.obs;

  // Category list
  final List<String> categories = [
    'All',
    'Investment Guidance',
    'Legal Guidance', 
    'Job opportunity',
    'Farming made easy',
    'Education Guidance / Competitive Exams Guidance',
    'How Become an Entrepreneur / Opportunities'
  ];

  // Detail State
  final Rxn<Blog> selectedBlog = Rxn<Blog>();
  final RxList<Blog> relatedBlogs = <Blog>[].obs;
  final RxBool isDetailLoading = false.obs;

  // Video State for detail screen
  final Rxn<VideoPlayerController> detailVideoController = Rxn<VideoPlayerController>();
  final RxBool isVideoInitialized = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchBlogs();
    
    // Debounce search query changes
    debounce(searchQuery, (query) {
      if (query.isEmpty) {
        filteredBlogs.assignAll(blogs);
      } else {
        _performSearch(query);
      }
    }, time: const Duration(milliseconds: 500));
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
    final response = await _repository.getBlogs(page: currentPage.value);

    if (response != null && response.success == true && response.data != null) {
      final newBlogs = response.data?.data ?? [];
      
      if (newBlogs.isEmpty) {
        hasMore.value = false;
      } else {
        blogs.addAll(newBlogs);
        filteredBlogs.assignAll(blogs);
        currentPage.value++;
      }
    }

    isLoading.value = false;
  }

  void searchBlogs(String query) {
    searchQuery.value = query;
  }

  void clearSearch() {
    searchTextController.clear();
    searchQuery.value = '';
    filteredBlogs.assignAll(blogs);
  }

  void filterByCategory(String category) {
    selectedCategory.value = category;
    searchTextController.clear();
    searchQuery.value = '';
    
    if (category == 'All') {
      filteredBlogs.assignAll(blogs);
    } else {
      filteredBlogs.assignAll(
        blogs.where((blog) => blog.blogType == category).toList(),
      );
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
    filteredBlogs[filteredBlogs.indexWhere((b) => b.id == blogId)] = updatedBlog;
    
    // Update selection if it matches
    if (selectedBlog.value?.id == blogId) {
      selectedBlog.value = updatedBlog;
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
      filteredBlogs[filteredBlogs.indexWhere((b) => b.id == blogId)] = finalBlog;
      if (selectedBlog.value?.id == blogId) {
        selectedBlog.value = finalBlog;
      }
    } else {
      // Revert on failure
      blogs[index] = blog;
      filteredBlogs[filteredBlogs.indexWhere((b) => b.id == blogId)] = blog;
      if (selectedBlog.value?.id == blogId) {
        selectedBlog.value = blog;
      }
    }
  }

  Future<void> fetchBlogDetail(int id) async {
    isDetailLoading.value = true;
    selectedBlog.value = null;
    relatedBlogs.clear();

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
      final controller = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
      detailVideoController.value = controller;
      
      controller.initialize().then((_) {
        isVideoInitialized.value = true;
        controller.play();
        controller.setLooping(true);
      });
    }
  }

  void _disposeVideo() {
    detailVideoController.value?.dispose();
    detailVideoController.value = null;
    isVideoInitialized.value = false;
  }

  @override
  void onClose() {
    _disposeVideo();
    super.onClose();
  }
}
