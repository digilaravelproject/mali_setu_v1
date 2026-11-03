import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../core/constent/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../business/data/model/res_all_business_model.dart';
import '../../../business/presentation/controller/business_controller.dart';

class JobsController extends GetxController {
  final ApiClient _apiClient = Get.isRegistered<ApiClient>()
      ? Get.find<ApiClient>()
      : ApiClient();

  final RxList<Job> jobs = <Job>[].obs;
  final RxList<Job> allJobsList = <Job>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isMoreLoading = false.obs;
  final RxString selectedFilter = 'All'.obs;
  final RxString searchQuery = ''.obs;
  final RxSet<int> favoriteJobIds = <int>{}.obs;
  final RxInt totalJobsCount = 0.obs;

  // Main screen tabs (0: All Jobs, 1: My Applied Jobs)
  final RxInt selectedMainTab = 0.obs;
  final RxList<JobApplication> myApplications = <JobApplication>[].obs;
  final RxBool isMyApplicationsLoading = false.obs;

  final TextEditingController searchController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  Timer? _debounce;

  int _currentPage = 1;
  int _lastPage = 1;
  bool _hasMore = false;

  // Filter lists from API
  final RxList<String> categories = <String>[].obs;
  final RxList<String> locations = <String>[].obs;
  final RxList<String> experienceLevels = <String>[].obs;
  final RxList<String> employmentTypes = <String>[].obs;

  // Filter selections in modal sheet
  final RxSet<String> selectedLocations = <String>{}.obs;
  final RxSet<String> selectedCategories = <String>{}.obs;
  final RxSet<String> selectedJobTypes = <String>{}.obs;
  final RxString selectedCategory = ''.obs;
  final RxString selectedLocation = ''.obs;
  final RxString selectedExperience = ''.obs;

  int get activeFiltersCount =>
      selectedLocations.length + selectedCategories.length + selectedJobTypes.length;

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_onScroll);
    fetchJobs();
  }

  @override
  void onClose() {
    _debounce?.cancel();
    searchController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  void _onScroll() {
    if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 200 &&
        !isLoading.value &&
        !isMoreLoading.value &&
        _hasMore) {
      fetchMoreJobs();
    }
  }

  void changeMainTab(int index) {
    if (selectedMainTab.value == index) return;
    selectedMainTab.value = index;
    HapticFeedback.lightImpact();
    if (index == 1) {
      fetchMyApplications();
    } else {
      if (jobs.isEmpty) {
        fetchJobs();
      }
    }
  }

  Future<void> fetchMyApplications({bool isRefresh = false}) async {
    try {
      if (!isRefresh && myApplications.isEmpty) {
        isMyApplicationsLoading.value = true;
      }
      final response = await _apiClient.post(
        ApiConstants.myApplications,
      );

      if (response.data != null && response.data['success'] == true) {
        final dataWrapper = response.data['data'];
        final List<JobApplication> fetched = [];
        if (dataWrapper is Map && dataWrapper['data'] != null) {
          final List rawList = dataWrapper['data'];
          for (var item in rawList) {
            if (item is Map<String, dynamic>) {
              fetched.add(JobApplication.fromJson(item));
            }
          }
        }
        myApplications.value = fetched;
      }
    } catch (e) {
      debugPrint("Error fetching my applications: $e");
    } finally {
      isMyApplicationsLoading.value = false;
    }
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 450), () {
      fetchJobs(isRefresh: true);
    });
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
    fetchJobs(isRefresh: true);
  }

  void setFilter(String filter) {
    selectedFilter.value = filter;
    HapticFeedback.lightImpact();
    fetchJobs(isRefresh: true);
  }

  Future<bool> toggleFavorite(int? jobId, {bool? currentLiked}) async {
    if (jobId == null) return false;
    HapticFeedback.selectionClick();

    if (currentLiked == true && !favoriteJobIds.contains(jobId)) {
      favoriteJobIds.add(jobId);
    }

    final bool currentlyLiked = favoriteJobIds.contains(jobId);
    // Optimistic UI update
    if (currentlyLiked) {
      favoriteJobIds.remove(jobId);
    } else {
      favoriteJobIds.add(jobId);
    }

    for (var j in jobs) {
      if (j.id == jobId) {
        j.isLiked = !currentlyLiked;
      }
    }
    jobs.refresh();

    if (Get.isRegistered<BusinessController>()) {
      final bCtrl = Get.find<BusinessController>();
      for (var j in bCtrl.businessJobs) {
        if (j.id == jobId) {
          j.isLiked = !currentlyLiked;
        }
      }
      bCtrl.businessJobs.refresh();
    }

    try {
      final response = await _apiClient.post(
        ApiConstants.jobLikeToggle(jobId),
      );

      if (response.data != null && response.data['success'] == true) {
        final data = response.data['data'];
        final bool serverLiked = data is Map ? (data['is_liked'] == true) : !currentlyLiked;
        if (serverLiked) {
          favoriteJobIds.add(jobId);
        } else {
          favoriteJobIds.remove(jobId);
        }
        for (var j in jobs) {
          if (j.id == jobId) {
            j.isLiked = serverLiked;
          }
        }
        jobs.refresh();

        if (Get.isRegistered<BusinessController>()) {
          final bCtrl = Get.find<BusinessController>();
          for (var j in bCtrl.businessJobs) {
            if (j.id == jobId) {
              j.isLiked = serverLiked;
            }
          }
          bCtrl.businessJobs.refresh();
        }
        return true;
      } else {
        // Revert on failure
        if (currentlyLiked) {
          favoriteJobIds.add(jobId);
        } else {
          favoriteJobIds.remove(jobId);
        }
        for (var j in jobs) {
          if (j.id == jobId) {
            j.isLiked = currentlyLiked;
          }
        }
        jobs.refresh();

        if (Get.isRegistered<BusinessController>()) {
          final bCtrl = Get.find<BusinessController>();
          for (var j in bCtrl.businessJobs) {
            if (j.id == jobId) {
              j.isLiked = currentlyLiked;
            }
          }
          bCtrl.businessJobs.refresh();
        }
        return false;
      }
    } catch (e) {
      // Revert on error
      if (currentlyLiked) {
        favoriteJobIds.add(jobId);
      } else {
        favoriteJobIds.remove(jobId);
      }
      for (var j in jobs) {
        if (j.id == jobId) {
          j.isLiked = currentlyLiked;
        }
      }
      jobs.refresh();

      if (Get.isRegistered<BusinessController>()) {
        final bCtrl = Get.find<BusinessController>();
        for (var j in bCtrl.businessJobs) {
          if (j.id == jobId) {
            j.isLiked = currentlyLiked;
          }
        }
        bCtrl.businessJobs.refresh();
      }
      return false;
    }
  }

  Map<String, dynamic> _buildQueryParams({required int page}) {
    final Map<String, dynamic> queryParams = {
      'page': page,
    };

    // 1. Search Query
    final query = searchQuery.value.trim();
    if (query.isNotEmpty) {
      queryParams['search'] = query;
    }

    // 2. Category Filter
    if (selectedCategories.isNotEmpty) {
      queryParams['category'] = selectedCategories.join(',');
    } else if (selectedCategory.value.trim().isNotEmpty) {
      queryParams['category'] = selectedCategory.value.trim();
    }

    // 3. Location Filter
    if (selectedLocations.isNotEmpty) {
      queryParams['location'] = selectedLocations.join(',');
    } else if (selectedLocation.value.trim().isNotEmpty) {
      queryParams['location'] = selectedLocation.value.trim();
    }

    // 4. Employment Type Filter (from bottom sheet and/or horizontal tabs)
    final Set<String> activeTypes = <String>{};
    for (var t in selectedJobTypes) {
      activeTypes.add(t.toLowerCase().replaceAll(' ', '-'));
    }
    if (selectedFilter.value != 'All' && !selectedFilter.value.startsWith('All')) {
      activeTypes.add(selectedFilter.value.toLowerCase().replaceAll(' ', '-'));
    }
    if (activeTypes.isNotEmpty) {
      queryParams['employment_type'] = activeTypes.join(',');
    }

    return queryParams;
  }

  Future<void> fetchJobs({bool isRefresh = false}) async {
    if (isRefresh) {
      _currentPage = 1;
    }

    try {
      if (!isRefresh && jobs.isEmpty) {
        isLoading.value = true;
      }

      final queryParams = _buildQueryParams(page: _currentPage);

      final response = await _apiClient.get(
        ApiConstants.createJobs,
        queryParameters: queryParams,
      );

      if (response.data != null && response.data['success'] == true) {
        final dataWrapper = response.data['data'];
        final List<Job> fetchedJobs = [];

        if (dataWrapper is Map && dataWrapper['data'] != null) {
          final List rawList = dataWrapper['data'];
          for (var item in rawList) {
            if (item is Map<String, dynamic>) {
              final job = Job.fromJson(item);
              fetchedJobs.add(job);
              if (job.isLiked == true && job.id != null) {
                favoriteJobIds.add(job.id!);
              }
            }
          }
          _currentPage = dataWrapper['current_page'] ?? 1;
          _lastPage = dataWrapper['last_page'] ?? 1;
          _hasMore = _currentPage < _lastPage;
          totalJobsCount.value = dataWrapper['total'] ?? fetchedJobs.length;
        }

        // Store filters from API if available
        if (response.data['filters'] != null && response.data['filters'] is Map) {
          final f = response.data['filters'];
          if (f['categories'] is List) {
            categories.value = List<String>.from(f['categories']);
          }
          if (f['locations'] is List) {
            locations.value = List<String>.from(f['locations']);
          }
          if (f['experience_levels'] is List) {
            experienceLevels.value = List<String>.from(f['experience_levels']);
          }
          if (f['employment_types'] is List) {
            employmentTypes.value = List<String>.from(f['employment_types']);
          }
        }

        allJobsList.value = fetchedJobs;
        jobs.value = fetchedJobs;
      } else {
        // Fallback to sample jobs if initial load fails
        if (jobs.isEmpty && allJobsList.isEmpty) {
          allJobsList.value = _getSampleJobs();
          jobs.value = _getSampleJobs();
          totalJobsCount.value = 520;
        }
      }
    } catch (e) {
      // In case of network error on first launch
      if (jobs.isEmpty && allJobsList.isEmpty) {
        allJobsList.value = _getSampleJobs();
        jobs.value = _getSampleJobs();
        totalJobsCount.value = 520;
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchMoreJobs() async {
    if (_hasMore && !isMoreLoading.value) {
      isMoreLoading.value = true;
      final nextPage = _currentPage + 1;

      try {
        final queryParams = _buildQueryParams(page: nextPage);
        final response = await _apiClient.get(
          ApiConstants.createJobs,
          queryParameters: queryParams,
        );

        if (response.data != null && response.data['success'] == true) {
          final dataWrapper = response.data['data'];
          if (dataWrapper is Map && dataWrapper['data'] != null) {
            final List rawList = dataWrapper['data'];
            for (var item in rawList) {
              if (item is Map<String, dynamic>) {
                final newJob = Job.fromJson(item);
                allJobsList.add(newJob);
                jobs.add(newJob);
                if (newJob.isLiked == true && newJob.id != null) {
                  favoriteJobIds.add(newJob.id!);
                }
              }
            }
            _currentPage = dataWrapper['current_page'] ?? nextPage;
            _lastPage = dataWrapper['last_page'] ?? _lastPage;
            _hasMore = _currentPage < _lastPage;
            totalJobsCount.value = dataWrapper['total'] ?? jobs.length;
          }
        }
      } catch (_) {
      } finally {
        isMoreLoading.value = false;
      }
    }
  }

  void applyFilters() {
    fetchJobs(isRefresh: true);
  }

  void resetSheetFilters() {
    selectedLocations.clear();
    selectedCategories.clear();
    selectedJobTypes.clear();
    selectedCategory.value = '';
    selectedLocation.value = '';
    selectedExperience.value = '';
    fetchJobs(isRefresh: true);
  }

  List<Job> _getSampleJobs() {
    return [
      Job(
        id: 101,
        title: "Laravel Developer",
        salaryRange: "3 - 6 LPA",
        employmentType: "Full Time",
        jobType: "Full Time",
        location: "Pune, Maharashtra",
        category: "Software Development",
        experienceLevel: "Mid Level (2-4 Years)",
        description: "Looking for an experienced Laravel Backend Developer proficient in REST APIs, MySQL, and Vue/Blade.",
        requirements: "2+ years of experience with Laravel, PHP, REST APIs, and Git.",
        createdAt: DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
        business: Business(
          id: 1,
          businessName: "Tech Solutions Pvt. Ltd.",
          city: "Pune",
          state: "Maharashtra",
        ),
      ),
      Job(
        id: 102,
        title: "Marketing Executive",
        salaryRange: "2.5 - 4 LPA",
        employmentType: "Full Time",
        jobType: "Full Time",
        location: "Mumbai, Maharashtra",
        category: "Marketing",
        experienceLevel: "Junior Level",
        description: "Responsible for community outreach, digital branding, social media campaigns, and event management.",
        requirements: "Strong communication skills, digital marketing knowledge, and passion for community development.",
        createdAt: DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
        business: Business(
          id: 2,
          businessName: "Mali Setu Foundation",
          city: "Mumbai",
          state: "Maharashtra",
        ),
      ),
      Job(
        id: 103,
        title: "Accountant",
        salaryRange: "2 - 4 LPA",
        employmentType: "Full Time",
        jobType: "Full Time",
        location: "Nashik, Maharashtra",
        category: "Finance & Accounting",
        experienceLevel: "1-3 Years",
        description: "Handling GST filing, Tally ERP 9, invoicing, bank reconciliation, and daily accounts ledger.",
        requirements: "B.Com / M.Com with proficiency in Tally and MS Excel.",
        createdAt: DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
        business: Business(
          id: 3,
          businessName: "Shree Construction",
          city: "Nashik",
          state: "Maharashtra",
        ),
      ),
      Job(
        id: 104,
        title: "Sales Manager",
        salaryRange: "4 - 8 LPA",
        employmentType: "Full Time",
        jobType: "Full Time",
        location: "Kolhapur, Maharashtra",
        category: "Sales & Distribution",
        experienceLevel: "Senior Level (3-5 Years)",
        description: "Lead agricultural sales operations, partner with local vendors, and expand dealer networks.",
        requirements: "Proven track record in B2B or FMCG sales. Team leadership capabilities.",
        createdAt: DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
        business: Business(
          id: 4,
          businessName: "Agri Services",
          city: "Kolhapur",
          state: "Maharashtra",
        ),
      ),
      Job(
        id: 105,
        title: "Flutter Developer",
        salaryRange: "4 - 7 LPA",
        employmentType: "Remote",
        jobType: "Remote",
        location: "Pune, Maharashtra (Remote)",
        category: "Mobile Development",
        experienceLevel: "Mid Level",
        description: "Build high performance mobile apps in Flutter with GetX, REST APIs, and modern responsive UI.",
        requirements: "2+ years Flutter experience, state management, offline persistence, and deployment experience.",
        createdAt: DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        business: Business(
          id: 5,
          businessName: "Digital Craft Studio",
          city: "Pune",
          state: "Maharashtra",
        ),
      ),
      Job(
        id: 106,
        title: "Customer Support Executive",
        salaryRange: "1.8 - 2.8 LPA",
        employmentType: "Part Time",
        jobType: "Part Time",
        location: "Nashik, Maharashtra",
        category: "Support & Operations",
        experienceLevel: "Entry Level",
        description: "Handle incoming customer queries via phone, WhatsApp, and email with quick turnaround time.",
        requirements: "Fluency in Marathi, Hindi, and English. Friendly telephone etiquette.",
        createdAt: DateTime.now().subtract(const Duration(days: 4)).toIso8601String(),
        business: Business(
          id: 6,
          businessName: "Mali Setu Service Hub",
          city: "Nashik",
          state: "Maharashtra",
        ),
      ),
    ];
  }
}

