import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:edu_cluezer/features/business/data/model/res_all_business_model.dart';
import 'package:edu_cluezer/features/business/domain/usecase/get_business_categories_paginated_usecase.dart';
import 'package:edu_cluezer/widgets/custom_image_view.dart';
import 'package:edu_cluezer/core/helper/string_extensions.dart';

import '../core/widgets/shimmer_loading.dart';

class CategoryPaginatedBottomSheet extends StatefulWidget {
  final Function(Category) onCategorySelected;
  final bool isRegistrationMode;
  
  const CategoryPaginatedBottomSheet({
    Key? key,
    required this.onCategorySelected,
    this.isRegistrationMode = false,
  }) : super(key: key);

  @override
  State<CategoryPaginatedBottomSheet> createState() => _CategoryPaginatedBottomSheetState();
}

class _CategoryPaginatedBottomSheetState extends State<CategoryPaginatedBottomSheet> {
  late final GetBusinessCategoriesPaginatedUseCase _useCase;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  
  List<Category> _categories = [];
  bool _isLoadingInitial = true;
  bool _isLoadingMore = false;
  bool _hasMoreData = true;
  int _currentPage = 1;
  String? _error;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<GetBusinessCategoriesPaginatedUseCase>()) {
      Get.put(GetBusinessCategoriesPaginatedUseCase(repository: Get.find()));
    }
    _useCase = Get.find<GetBusinessCategoriesPaginatedUseCase>();
    _fetchCategories();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoadingMore && _hasMoreData && _searchQuery.isEmpty) {
        _fetchCategories(loadMore: true);
      }
    }
  }

  Future<void> _fetchCategories({bool loadMore = false}) async {
    if (loadMore) {
      setState(() => _isLoadingMore = true);
    } else {
      setState(() {
        _isLoadingInitial = true;
        _error = null;
      });
    }

    try {
      final response = await _useCase(page: _currentPage);
      
      if (response.success == true && response.data != null && response.data!.data != null) {
        final newCategories = response.data!.data!;
        
        setState(() {
          if (loadMore) {
            _categories.addAll(newCategories);
          } else {
            _categories = newCategories;
          }
          
          if (response.data!.nextPageUrl != null) {
            _currentPage++;
            _hasMoreData = true;
          } else {
            _hasMoreData = false;
          }
        });
      } else {
        setState(() => _hasMoreData = false);
      }
    } catch (e) {
      setState(() {
        if (!loadMore) _error = 'Failed to load categories';
      });
    } finally {
      setState(() {
        _isLoadingInitial = false;
        _isLoadingMore = false;
      });
    }
  }

  String _capitalizeText(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Get.height * 0.85, // Take 85% of screen height
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Header with Drag Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          
          // Title
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'all_categories'.tr,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
          ),

          // Instruction text
          if (widget.isRegistrationMode)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0, left: 24.0, right: 24.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'If your category is not listed, please select "Other"',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),

          // Search Bar
          /* Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search Category...',
                prefixIcon: const Icon(Icons.search, color: Colors.black54, size: 20),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 1),
                ),
              ),
            ),
          ), */
          
          // Custom Category Option (Only in Registration Mode)
          /* if (widget.isRegistrationMode) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
              child: InkWell(
                onTap: () {
                  Get.back();
                  widget.onCategorySelected(Category(id: -1, name: "Other"));
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.add_circle_outline, color: Theme.of(context).primaryColor),
                      const SizedBox(width: 12),
                      Text(
                        'add_custom_category'.tr,
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Divider(height: 1),
          ], */
          
          // List content
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoadingInitial) {
      return ListView.builder(
        itemCount: 10,
        padding: const EdgeInsets.all(20),
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Row(
              children: [
                const ShimmerLoading.rounded(width: 50, height: 50),
                const SizedBox(width: 16),
                ShimmerLoading.rounded(width: Get.width * 0.5, height: 20),
              ],
            ),
          );
        },
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(_error!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _fetchCategories(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final filteredCategories = _categories.where((category) {
      final catName = category.name?.toLowerCase() ?? '';
      return catName.contains(_searchQuery.toLowerCase());
    }).toList();

    if (filteredCategories.isEmpty) {
      return const Center(child: Text('No categories found'));
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: filteredCategories.length + (_hasMoreData && _searchQuery.isEmpty ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == filteredCategories.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final category = filteredCategories[index];
        return InkWell(
          onTap: () {
            Get.back();
            widget.onCategorySelected(category);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: CustomImageView(
                    url: category.photo != null && category.photo!.isNotEmpty
                        ? category.photo
                        : "https://cdn-icons-png.freepik.com/512/10416/10416308.png",
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    category.name ?? "",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
          ),
        );
      },
    );
  }
}
