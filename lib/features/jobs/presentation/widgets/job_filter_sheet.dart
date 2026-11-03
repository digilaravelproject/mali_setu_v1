import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../core/styles/app_colors.dart';
import '../controller/jobs_controller.dart';

class JobFilterSheet extends StatefulWidget {
  final JobsController controller;

  const JobFilterSheet({Key? key, required this.controller}) : super(key: key);

  static void show(BuildContext context, JobsController controller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => JobFilterSheet(controller: controller),
    );
  }

  @override
  State<JobFilterSheet> createState() => _JobFilterSheetState();
}

class _JobFilterSheetState extends State<JobFilterSheet> {
  // Local state for filters so user can tweak and then tap "Apply Filters" or "Reset"
  late Set<String> _selectedLocations;
  late Set<String> _selectedCategories;
  late Set<String> _selectedJobTypes;

  // Search & custom input controllers
  final TextEditingController _locationSearchController = TextEditingController();
  final TextEditingController _categorySearchController = TextEditingController();

  String _locationSearchQuery = '';
  String _categorySearchQuery = '';
  bool _isLocationExpanded = false;

  // Pre-defined locations matching user mockup
  final List<Map<String, dynamic>> _allLocations = [
    {'name': 'Pune', 'count': 120},
    {'name': 'Kolhapur', 'count': 32},
    {'name': 'Mumbai', 'count': 95},
    {'name': 'Satara', 'count': 28},
    {'name': 'Nashik', 'count': 45},
    {'name': 'Other', 'count': 200},
    // Extra locations shown on "View More"
    {'name': 'Aurangabad', 'count': 18},
    {'name': 'Solapur', 'count': 15},
    {'name': 'Nagpur', 'count': 22},
    {'name': 'Thane', 'count': 35},
    {'name': 'Sangli', 'count': 12},
    {'name': 'Ahmednagar', 'count': 14},
  ];

  // Pre-defined categories matching user mockup
  final List<Map<String, dynamic>> _categories = [
    {'name': 'IT & Software', 'count': 125},
    {'name': 'Sales & Marketing', 'count': 84},
    {'name': 'Education', 'count': 56},
    {'name': 'Healthcare', 'count': 42},
    {'name': 'Finance & Accounts', 'count': 39},
    {'name': 'Others', 'count': 120},
  ];

  final List<String> _jobTypesCol1 = [
    'Full Time',
    'Part Time',
    'Contract',
  ];

  final List<String> _jobTypesCol2 = [
    'Freelance',
    'Internship',
    'Remote',
  ];

  @override
  void initState() {
    super.initState();
    _selectedLocations = Set<String>.from(widget.controller.selectedLocations);
    _selectedCategories = Set<String>.from(widget.controller.selectedCategories);
    _selectedJobTypes = Set<String>.from(widget.controller.selectedJobTypes);

    // Merge locations from server filters if available
    for (var loc in widget.controller.locations) {
      final trimmed = loc.trim();
      if (trimmed.isNotEmpty &&
          !_allLocations.any((item) => (item['name'] as String).toLowerCase() == trimmed.toLowerCase())) {
        _allLocations.insert(0, {'name': trimmed, 'count': null});
      }
    }

    // Merge categories from server filters if available
    for (var cat in widget.controller.categories) {
      final trimmed = cat.trim();
      if (trimmed.isNotEmpty &&
          !_categories.any((item) => (item['name'] as String).toLowerCase() == trimmed.toLowerCase())) {
        _categories.insert(0, {'name': trimmed, 'count': null});
      }
    }
  }

  @override
  void dispose() {
    _locationSearchController.dispose();
    _categorySearchController.dispose();
    super.dispose();
  }

  void _onReset() {
    HapticFeedback.lightImpact();
    setState(() {
      _selectedLocations.clear();
      _selectedCategories.clear();
      _selectedJobTypes.clear();
      _locationSearchController.clear();
      _categorySearchController.clear();
      _locationSearchQuery = '';
      _categorySearchQuery = '';
    });
    widget.controller.resetSheetFilters();
    Navigator.of(context).pop();
  }

  void _onApply() {
    HapticFeedback.mediumImpact();

    // If user typed custom text in location or category but didn't tap add button, include it automatically
    final typedLocation = _locationSearchController.text.trim();
    if (typedLocation.isNotEmpty) {
      _selectedLocations.add(typedLocation);
    }

    final typedCategory = _categorySearchController.text.trim();
    if (typedCategory.isNotEmpty) {
      _selectedCategories.add(typedCategory);
    }

    widget.controller.selectedLocations.value = _selectedLocations;
    widget.controller.selectedCategories.value = _selectedCategories;
    widget.controller.selectedJobTypes.value = _selectedJobTypes;
    widget.controller.applyFilters();
    Navigator.of(context).pop();
  }

  void _addCustomLocation(String location) {
    final trimmed = location.trim();
    if (trimmed.isEmpty) return;
    HapticFeedback.selectionClick();
    setState(() {
      _selectedLocations.add(trimmed);
      _locationSearchController.clear();
      _locationSearchQuery = '';
    });
  }

  void _addCustomCategory(String category) {
    final trimmed = category.trim();
    if (trimmed.isEmpty) return;
    HapticFeedback.selectionClick();
    setState(() {
      _selectedCategories.add(trimmed);
      _categorySearchController.clear();
      _categorySearchQuery = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final maxSheetHeight = MediaQuery.of(context).size.height * 0.90;

    return Container(
      constraints: BoxConstraints(maxHeight: maxSheetHeight),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Drag Handle Bar
            const SizedBox(height: 12),
            Center(
              child: Container(
                width: 42,
                height: 4.5,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Scrollable Filter Sections
            Flexible(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 4,
                  bottom: bottomInset + 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ==========================================
                    // 1. JOB LOCATION SECTION
                    // ==========================================
                    _buildSectionHeader('Job Location'),
                    const SizedBox(height: 12),

                    // Search & Type Location Input Field
                    _buildInputField(
                      controller: _locationSearchController,
                      hintText: 'Search or enter location...',
                      query: _locationSearchQuery,
                      primaryColor: primaryColor,
                      onChanged: (val) {
                        setState(() {
                          _locationSearchQuery = val.trim().toLowerCase();
                        });
                      },
                      onClear: () {
                        _locationSearchController.clear();
                        setState(() {
                          _locationSearchQuery = '';
                        });
                      },
                    ),

                    // If user typed a custom location not in pre-defined list, show "+ Add" button
                    if (_locationSearchQuery.isNotEmpty &&
                        !_allLocations.any((loc) =>
                            (loc['name'] as String).toLowerCase() == _locationSearchQuery) &&
                        !_selectedLocations.any((loc) => loc.toLowerCase() == _locationSearchQuery))
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: InkWell(
                          onTap: () => _addCustomLocation(_locationSearchController.text),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: primaryColor.withOpacity(0.35)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.add_rounded, size: 16, color: primaryColor),
                                const SizedBox(width: 6),
                                Text(
                                  'Add "${_locationSearchController.text.trim()}"',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                    const SizedBox(height: 14),

                    // Location Checkboxes (2 Columns)
                    _buildLocationGrid(primaryColor),

                    const SizedBox(height: 10),

                    // "View More" / "View Less" Link
                    Center(
                      child: InkWell(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() {
                            _isLocationExpanded = !_isLocationExpanded;
                          });
                        },
                        borderRadius: BorderRadius.circular(6),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          child: Text(
                            _isLocationExpanded ? 'View Less' : 'View More',
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              color: primaryColor,
                              decoration: TextDecoration.underline,
                              decorationColor: primaryColor,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 22),

                    // ==========================================
                    // 2. JOB CATEGORY SECTION
                    // ==========================================
                    _buildSectionHeader('Job Category'),
                    const SizedBox(height: 12),

                    // Search & Type Category Input Field
                    _buildInputField(
                      controller: _categorySearchController,
                      hintText: 'Search or enter category...',
                      query: _categorySearchQuery,
                      primaryColor: primaryColor,
                      onChanged: (val) {
                        setState(() {
                          _categorySearchQuery = val.trim().toLowerCase();
                        });
                      },
                      onClear: () {
                        _categorySearchController.clear();
                        setState(() {
                          _categorySearchQuery = '';
                        });
                      },
                    ),

                    // If user typed a custom category not in pre-defined list, show "+ Add" button
                    if (_categorySearchQuery.isNotEmpty &&
                        !_categories.any((cat) =>
                            (cat['name'] as String).toLowerCase() == _categorySearchQuery) &&
                        !_selectedCategories.any((cat) => cat.toLowerCase() == _categorySearchQuery))
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: InkWell(
                          onTap: () => _addCustomCategory(_categorySearchController.text),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: primaryColor.withOpacity(0.35)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.add_rounded, size: 16, color: primaryColor),
                                const SizedBox(width: 6),
                                Text(
                                  'Add "${_categorySearchController.text.trim()}"',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                    const SizedBox(height: 14),

                    // Category Checkboxes (Single Column)
                    _buildCategoryList(primaryColor),

                    const SizedBox(height: 8),

                    // Thin Divider below Job Category
                    const Divider(
                      color: Color(0xFFF1F2F4),
                      thickness: 1.2,
                      height: 24,
                    ),

                    // ==========================================
                    // 3. JOB TYPE SECTION
                    // ==========================================
                    _buildSectionHeader('Job Type'),
                    const SizedBox(height: 14),

                    // Job Type Checkboxes (2 Columns)
                    _buildJobTypeGrid(primaryColor),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // ==========================================
            // 4. BOTTOM ACTION BUTTONS
            // ==========================================
            _buildBottomButtons(context, primaryColor),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16.5,
        fontWeight: FontWeight.w700,
        color: Color(0xFF111827),
        letterSpacing: -0.2,
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    required String query,
    required Color primaryColor,
    required ValueChanged<String> onChanged,
    required VoidCallback onClear,
  }) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Color(0xFF1F2937),
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
          fontSize: 13.5,
          fontWeight: FontWeight.w400,
          color: Color(0xFF9CA3AF),
        ),
        filled: true,
        fillColor: Colors.white,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 11,
        ),
        prefixIcon: const Icon(
          CupertinoIcons.search,
          size: 18,
          color: Color(0xFF9CA3AF),
        ),
        suffixIcon: query.isNotEmpty
            ? GestureDetector(
                onTap: onClear,
                child: const Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: Color(0xFF9CA3AF),
                ),
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: query.isNotEmpty ? primaryColor : const Color(0xFFE5E7EB),
            width: query.isNotEmpty ? 1.4 : 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: primaryColor, width: 1.4),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1.0),
        ),
      ),
    );
  }

  Widget _buildLocationGrid(Color primaryColor) {
    List<Map<String, dynamic>> filteredList = _allLocations;

    if (_locationSearchQuery.isNotEmpty) {
      filteredList = _allLocations
          .where((item) =>
              (item['name'] as String).toLowerCase().contains(_locationSearchQuery))
          .toList();
    } else if (!_isLocationExpanded) {
      // Top 6 matching the mockup (Pune, Kolhapur, Mumbai, Satara, Nashik, Other)
      filteredList = _allLocations.take(6).toList();
    }

    // Include custom typed locations that are selected and not in _allLocations
    final customLocations = _selectedLocations
        .where((loc) => !_allLocations.any((item) => item['name'] == loc))
        .toList();

    // Split into 2 columns
    final List<Widget> col1 = [];
    final List<Widget> col2 = [];

    // Add custom locations first if any
    int indexCounter = 0;
    for (var customLoc in customLocations) {
      final widgetItem = Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: _buildCheckboxRow(
          label: "$customLoc (Custom)",
          isChecked: true,
          primaryColor: primaryColor,
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() {
              _selectedLocations.remove(customLoc);
            });
          },
        ),
      );
      if (indexCounter % 2 == 0) {
        col1.add(widgetItem);
      } else {
        col2.add(widgetItem);
      }
      indexCounter++;
    }

    for (var loc in filteredList) {
      final name = loc['name'] as String;
      final count = loc['count'] as int?;
      final isChecked = _selectedLocations.contains(name);
      final label = count != null ? "$name ($count)" : name;

      final widgetItem = Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: _buildCheckboxRow(
          label: label,
          isChecked: isChecked,
          primaryColor: primaryColor,
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() {
              if (isChecked) {
                _selectedLocations.remove(name);
              } else {
                _selectedLocations.add(name);
              }
            });
          },
        ),
      );

      if (indexCounter % 2 == 0) {
        col1.add(widgetItem);
      } else {
        col2.add(widgetItem);
      }
      indexCounter++;
    }

    if (col1.isEmpty && col2.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Text(
          'No predefined location matching. Tap "+ Add" above to use your typed location.',
          style: TextStyle(fontSize: 12.5, color: Color(0xFF9CA3AF)),
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: col1,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: col2,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryList(Color primaryColor) {
    List<Map<String, dynamic>> filteredList = _categories;

    if (_categorySearchQuery.isNotEmpty) {
      filteredList = _categories
          .where((item) =>
              (item['name'] as String).toLowerCase().contains(_categorySearchQuery))
          .toList();
    }

    // Include custom typed categories that are selected and not in _categories
    final customCategories = _selectedCategories
        .where((cat) => !_categories.any((item) => item['name'] == cat))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Custom added categories
        ...customCategories.map((customCat) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _buildCheckboxRow(
              label: "$customCat (Custom)",
              isChecked: true,
              primaryColor: primaryColor,
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() {
                  _selectedCategories.remove(customCat);
                });
              },
            ),
          );
        }),

        // Pre-defined categories
        ...filteredList.map((cat) {
          final name = cat['name'] as String;
          final count = cat['count'] as int?;
          final isChecked = _selectedCategories.contains(name);
          final label = count != null ? "$name ($count)" : name;

          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _buildCheckboxRow(
              label: label,
              isChecked: isChecked,
              primaryColor: primaryColor,
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() {
                  if (isChecked) {
                    _selectedCategories.remove(name);
                  } else {
                    _selectedCategories.add(name);
                  }
                });
              },
            ),
          );
        }),

        if (filteredList.isEmpty && customCategories.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'No predefined category matching. Tap "+ Add" above to use your typed category.',
              style: TextStyle(fontSize: 12.5, color: Color(0xFF9CA3AF)),
            ),
          ),
      ],
    );
  }

  Widget _buildJobTypeGrid(Color primaryColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Col 1: Full Time, Part Time, Contract
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _jobTypesCol1.map((type) {
              final isChecked = _selectedJobTypes.contains(type);
              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _buildCheckboxRow(
                  label: type,
                  isChecked: isChecked,
                  primaryColor: primaryColor,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() {
                      if (isChecked) {
                        _selectedJobTypes.remove(type);
                      } else {
                        _selectedJobTypes.add(type);
                      }
                    });
                  },
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(width: 14),

        // Col 2: Freelance, Internship, Remote
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _jobTypesCol2.map((type) {
              final isChecked = _selectedJobTypes.contains(type);
              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _buildCheckboxRow(
                  label: type,
                  isChecked: isChecked,
                  primaryColor: primaryColor,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() {
                      if (isChecked) {
                        _selectedJobTypes.remove(type);
                      } else {
                        _selectedJobTypes.add(type);
                      }
                    });
                  },
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildCheckboxRow({
    required String label,
    required bool isChecked,
    required Color primaryColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Custom Checkbox
          AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: isChecked ? primaryColor : Colors.white,
              borderRadius: BorderRadius.circular(5.5),
              border: Border.all(
                color: isChecked ? primaryColor : const Color(0xFFD1D5DB),
                width: 1.5,
              ),
            ),
            child: isChecked
                ? const Icon(
                    Icons.check_rounded,
                    size: 15,
                    color: Colors.white,
                  )
                : null,
          ),
          const SizedBox(width: 10),

          // Label text
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13.8,
                fontWeight: isChecked ? FontWeight.w600 : FontWeight.w500,
                color: isChecked ? const Color(0xFF111827) : const Color(0xFF374151),
                letterSpacing: -0.1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons(BuildContext context, Color primaryColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFF3F4F6), width: 1.0),
        ),
      ),
      child: Row(
        children: [
          // Reset Button
          Expanded(
            flex: 4,
            child: SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _onReset,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF3F4F6),
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Reset',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Apply Filters Button
          Expanded(
            flex: 6,
            child: SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _onApply,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Apply Filters',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
