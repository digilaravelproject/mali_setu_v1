import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
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
  // Local state for all 8 job filter fields
  late Set<String> _selectedLocations;
  late Set<String> _selectedCategories;
  late Set<String> _selectedJobTypes; // Workplace: On-site, Remote, Hybrid
  late Set<String> _selectedEmploymentTypes; // Full-time, Part-time, Internship, Freelance, Contract
  late Set<String> _selectedExperienceLevels; // Entry, Mid, Senior, Expert
  late Set<String> _selectedSkills; // Skills Required
  late Set<String> _selectedBenefits; // Benefits & Perks
  late RangeValues _salaryRange;

  // Search & custom input controllers
  final TextEditingController _locationSearchController = TextEditingController();
  final TextEditingController _categorySearchController = TextEditingController();
  final TextEditingController _skillInputController = TextEditingController();
  final TextEditingController _benefitInputController = TextEditingController();

  String _locationSearchQuery = '';
  String _categorySearchQuery = '';
  bool _isLocationExpanded = false;

  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  // Pre-defined locations matching mockup and database
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

  // Pre-defined categories matching job creation
  final List<Map<String, dynamic>> _categories = [
    {'name': 'Software Development', 'count': 125},
    {'name': 'Marketing', 'count': 84},
    {'name': 'Sales', 'count': 56},
    {'name': 'Design', 'count': 42},
    {'name': 'Finance', 'count': 39},
    {'name': 'Human Resources', 'count': 28},
    {'name': 'Other', 'count': 120},
  ];

  // 1. Workplace Type options (matches create job dropdown)
  final List<String> _workplaceJobTypes = [
    'On-site',
    'Remote',
    'Hybrid',
  ];

  // 2. Employment Type options (matches create job dropdown)
  final List<String> _employmentTypes = [
    'Full-time',
    'Part-time',
    'Internship',
    'Freelance',
    'Contract',
  ];

  // 3. Experience Level options (matches create job dropdown)
  final List<String> _experienceLevels = [
    'Entry',
    'Mid',
    'Senior',
    'Expert',
  ];

  // 4. Popular skills (matches create job post page)
  final List<String> _popularSkills = [
    'PHP',
    'Laravel',
    'MySQL',
    'REST API',
    'Flutter',
    'Dart',
    'Android',
    'React Native',
    'Java',
    'Python',
    'Node.js',
    'UI/UX Design',
  ];

  // 5. Popular benefits (matches create job post page)
  final List<String> _popularBenefits = [
    'Health Insurance',
    'Flexible Working Hours',
    'Paid Time Off',
    'Remote Work Options',
    'Professional Development',
    'Stock Options',
    'Performance Bonus',
    'Gym Membership',
    'Free Meals',
  ];

  @override
  void initState() {
    super.initState();
    _selectedLocations = Set<String>.from(widget.controller.selectedLocations);
    _selectedCategories = Set<String>.from(widget.controller.selectedCategories);
    _selectedJobTypes = Set<String>.from(widget.controller.selectedJobTypes);
    _selectedEmploymentTypes = Set<String>.from(widget.controller.selectedEmploymentTypes);
    _selectedExperienceLevels = Set<String>.from(widget.controller.selectedExperienceLevels);
    _selectedSkills = Set<String>.from(widget.controller.selectedSkills);
    _selectedBenefits = Set<String>.from(widget.controller.selectedBenefits);
    _salaryRange = widget.controller.selectedSalaryRange.value;

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
    _skillInputController.dispose();
    _benefitInputController.dispose();
    super.dispose();
  }

  int get _currentActiveCount {
    int count = 0;
    count += _selectedLocations.length;
    count += _selectedCategories.length;
    count += _selectedJobTypes.length;
    count += _selectedEmploymentTypes.length;
    count += _selectedExperienceLevels.length;
    count += _selectedSkills.length;
    count += _selectedBenefits.length;
    if (_salaryRange.start > 0 || _salaryRange.end < 200000) {
      count += 1;
    }
    return count;
  }

  void _onReset() {
    HapticFeedback.lightImpact();
    setState(() {
      _selectedLocations.clear();
      _selectedCategories.clear();
      _selectedJobTypes.clear();
      _selectedEmploymentTypes.clear();
      _selectedExperienceLevels.clear();
      _selectedSkills.clear();
      _selectedBenefits.clear();
      _salaryRange = const RangeValues(0, 200000);
      _locationSearchController.clear();
      _categorySearchController.clear();
      _skillInputController.clear();
      _benefitInputController.clear();
      _locationSearchQuery = '';
      _categorySearchQuery = '';
    });
    widget.controller.resetSheetFilters();
    Navigator.of(context).pop();
  }

  void _onApply() {
    HapticFeedback.mediumImpact();

    // Auto-include typed query if user forgot to tap add
    final typedLocation = _locationSearchController.text.trim();
    if (typedLocation.isNotEmpty) {
      _selectedLocations.add(typedLocation);
    }

    final typedCategory = _categorySearchController.text.trim();
    if (typedCategory.isNotEmpty) {
      _selectedCategories.add(typedCategory);
    }

    final typedSkill = _skillInputController.text.trim();
    if (typedSkill.isNotEmpty) {
      _selectedSkills.add(typedSkill);
    }

    final typedBenefit = _benefitInputController.text.trim();
    if (typedBenefit.isNotEmpty) {
      _selectedBenefits.add(typedBenefit);
    }

    widget.controller.selectedLocations
      ..clear()
      ..addAll(_selectedLocations);
    widget.controller.selectedCategories
      ..clear()
      ..addAll(_selectedCategories);
    widget.controller.selectedJobTypes
      ..clear()
      ..addAll(_selectedJobTypes);
    widget.controller.selectedEmploymentTypes
      ..clear()
      ..addAll(_selectedEmploymentTypes);
    widget.controller.selectedExperienceLevels
      ..clear()
      ..addAll(_selectedExperienceLevels);
    widget.controller.selectedSkills
      ..clear()
      ..addAll(_selectedSkills);
    widget.controller.selectedBenefits
      ..clear()
      ..addAll(_selectedBenefits);
    widget.controller.selectedSalaryRange.value = _salaryRange;

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

  void _addCustomSkill() {
    final skill = _skillInputController.text.trim();
    if (skill.isEmpty) return;
    HapticFeedback.selectionClick();
    setState(() {
      _selectedSkills.add(skill);
      _skillInputController.clear();
    });
  }

  void _addCustomBenefit() {
    final benefit = _benefitInputController.text.trim();
    if (benefit.isEmpty) return;
    HapticFeedback.selectionClick();
    setState(() {
      _selectedBenefits.add(benefit);
      _benefitInputController.clear();
    });
  }

  String _formatCurrency(double val) {
    final rounded = val.round();
    if (rounded >= 200000) return '₹2,00,000+';
    return _currencyFormat.format(rounded);
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
            const SizedBox(height: 8),

            // Sheet Header with Title & Reset Link
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  const Text(
                    'Filters',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                      letterSpacing: -0.3,
                    ),
                  ),
                  if (_currentActiveCount > 0) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$_currentActiveCount',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: primaryColor,
                        ),
                      ),
                    ),
                  ],
                  const Spacer(),
                  GestureDetector(
                    onTap: _onReset,
                    child: Text(
                      'Reset',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: Color(0xFFF3F4F6), height: 1, thickness: 1),

            // Scrollable Filter Sections
            Flexible(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 14,
                  bottom: bottomInset + 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ==========================================
                    // 1. JOB LOCATION
                    // ==========================================
                    _buildSectionHeader('Job Location', 'Filter by location or city'),
                    const SizedBox(height: 12),

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
                    _buildLocationGrid(primaryColor),

                    const SizedBox(height: 10),
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
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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

                    _buildSectionDivider(),

                    // ==========================================
                    // 2. JOB CATEGORY
                    // ==========================================
                    _buildSectionHeader('Job Category', 'Select relevant industries or departments'),
                    const SizedBox(height: 12),

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
                    _buildCategoryList(primaryColor),

                    _buildSectionDivider(),

                    // ==========================================
                    // 3. WORKPLACE / JOB TYPE (On-site, Remote, Hybrid)
                    // ==========================================
                    _buildSectionHeader('Workplace Type', 'On-site, Remote, or Hybrid'),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _workplaceJobTypes.map((type) {
                        final isSelected = _selectedJobTypes.contains(type);
                        return FilterChip(
                          label: Text(type),
                          selected: isSelected,
                          selectedColor: primaryColor.withOpacity(0.16),
                          checkmarkColor: primaryColor,
                          labelStyle: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            color: isSelected ? primaryColor : const Color(0xFF374151),
                          ),
                          backgroundColor: const Color(0xFFF9FAFB),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isSelected ? primaryColor : const Color(0xFFE5E7EB),
                              width: isSelected ? 1.4 : 1.0,
                            ),
                          ),
                          onSelected: (selected) {
                            HapticFeedback.selectionClick();
                            setState(() {
                              if (selected) {
                                _selectedJobTypes.add(type);
                              } else {
                                _selectedJobTypes.remove(type);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),

                    _buildSectionDivider(),

                    // ==========================================
                    // 4. EMPLOYMENT TYPE (Full-time, Part-time, Internship, etc.)
                    // ==========================================
                    _buildSectionHeader('Employment Type', 'Full-time, Part-time, Internship, Freelance, Contract'),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _employmentTypes.map((type) {
                        final isSelected = _selectedEmploymentTypes.contains(type);
                        return FilterChip(
                          label: Text(type),
                          selected: isSelected,
                          selectedColor: primaryColor.withOpacity(0.16),
                          checkmarkColor: primaryColor,
                          labelStyle: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            color: isSelected ? primaryColor : const Color(0xFF374151),
                          ),
                          backgroundColor: const Color(0xFFF9FAFB),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isSelected ? primaryColor : const Color(0xFFE5E7EB),
                              width: isSelected ? 1.4 : 1.0,
                            ),
                          ),
                          onSelected: (selected) {
                            HapticFeedback.selectionClick();
                            setState(() {
                              if (selected) {
                                _selectedEmploymentTypes.add(type);
                              } else {
                                _selectedEmploymentTypes.remove(type);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),

                    _buildSectionDivider(),

                    // ==========================================
                    // 5. EXPERIENCE LEVEL (Entry, Mid, Senior, Expert)
                    // ==========================================
                    _buildSectionHeader('Experience Level', 'Entry, Mid level, Senior, or Expert'),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _experienceLevels.map((exp) {
                        final isSelected = _selectedExperienceLevels.contains(exp);
                        return FilterChip(
                          label: Text(exp),
                          selected: isSelected,
                          selectedColor: primaryColor.withOpacity(0.16),
                          checkmarkColor: primaryColor,
                          labelStyle: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            color: isSelected ? primaryColor : const Color(0xFF374151),
                          ),
                          backgroundColor: const Color(0xFFF9FAFB),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isSelected ? primaryColor : const Color(0xFFE5E7EB),
                              width: isSelected ? 1.4 : 1.0,
                            ),
                          ),
                          onSelected: (selected) {
                            HapticFeedback.selectionClick();
                            setState(() {
                              if (selected) {
                                _selectedExperienceLevels.add(exp);
                              } else {
                                _selectedExperienceLevels.remove(exp);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),

                    _buildSectionDivider(),

                    // ==========================================
                    // 6. SALARY RANGE (₹ Min - ₹ Max)
                    // ==========================================
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSectionHeader('Salary Range', 'Monthly / Annual Compensation'),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: primaryColor.withOpacity(0.25)),
                          ),
                          child: Text(
                            '${_formatCurrency(_salaryRange.start)} - ${_formatCurrency(_salaryRange.end)}',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    RangeSlider(
                      values: _salaryRange,
                      min: 0,
                      max: 200000,
                      divisions: 40,
                      activeColor: primaryColor,
                      inactiveColor: const Color(0xFFE5E7EB),
                      labels: RangeLabels(
                        _formatCurrency(_salaryRange.start),
                        _formatCurrency(_salaryRange.end),
                      ),
                      onChanged: (RangeValues newValues) {
                        setState(() {
                          _salaryRange = newValues;
                        });
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text('₹0', style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
                          Text('₹1,00,000', style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
                          Text('₹2,00,000+', style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
                        ],
                      ),
                    ),

                    _buildSectionDivider(),

                    // ==========================================
                    // 7. SKILLS REQUIRED (Chips + Custom Add)
                    // ==========================================
                    _buildSectionHeader('Skills Required', 'Technical and professional skills'),
                    const SizedBox(height: 12),

                    // Add custom skill input
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _skillInputController,
                            style: const TextStyle(fontSize: 13.5, color: Color(0xFF1F2937)),
                            decoration: InputDecoration(
                              hintText: 'Add skill (e.g. Flutter, SEO, Sales)...',
                              hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
                              filled: true,
                              fillColor: Colors.white,
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: primaryColor, width: 1.4),
                              ),
                            ),
                            onSubmitted: (_) => _addCustomSkill(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          height: 42,
                          width: 44,
                          child: ElevatedButton(
                            onPressed: _addCustomSkill,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              padding: EdgeInsets.zero,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: const Icon(Icons.add, color: Colors.white, size: 22),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Popular skills chips
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _popularSkills.map((skill) {
                        final isSelected = _selectedSkills.contains(skill);
                        return FilterChip(
                          label: Text(skill),
                          selected: isSelected,
                          selectedColor: primaryColor.withOpacity(0.16),
                          checkmarkColor: primaryColor,
                          labelStyle: TextStyle(
                            fontSize: 12.5,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            color: isSelected ? primaryColor : const Color(0xFF374151),
                          ),
                          backgroundColor: const Color(0xFFF9FAFB),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isSelected ? primaryColor : const Color(0xFFE5E7EB),
                              width: isSelected ? 1.4 : 1.0,
                            ),
                          ),
                          onSelected: (selected) {
                            HapticFeedback.selectionClick();
                            setState(() {
                              if (selected) {
                                _selectedSkills.add(skill);
                              } else {
                                _selectedSkills.remove(skill);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),

                    // Selected custom skills (if any not in popular list)
                    if (_selectedSkills.any((s) => !_popularSkills.contains(s))) ...[
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _selectedSkills
                            .where((s) => !_popularSkills.contains(s))
                            .map((customSkill) {
                          return Chip(
                            label: Text(
                              customSkill,
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: primaryColor,
                              ),
                            ),
                            backgroundColor: primaryColor.withOpacity(0.12),
                            deleteIcon: Icon(Icons.close_rounded, size: 16, color: primaryColor),
                            onDeleted: () {
                              HapticFeedback.selectionClick();
                              setState(() {
                                _selectedSkills.remove(customSkill);
                              });
                            },
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(color: primaryColor.withOpacity(0.4)),
                            ),
                          );
                        }).toList(),
                      ),
                    ],

                    _buildSectionDivider(),

                    // ==========================================
                    // 8. BENEFITS & PERKS (Chips + Custom Add)
                    // ==========================================
                    _buildSectionHeader('Benefits & Perks', 'Work amenities, perks, and incentives'),
                    const SizedBox(height: 12),

                    // Add custom benefit input
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _benefitInputController,
                            style: const TextStyle(fontSize: 13.5, color: Color(0xFF1F2937)),
                            decoration: InputDecoration(
                              hintText: 'Add benefit (e.g. Free Meals, Gym)...',
                              hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
                              filled: true,
                              fillColor: Colors.white,
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: primaryColor, width: 1.4),
                              ),
                            ),
                            onSubmitted: (_) => _addCustomBenefit(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          height: 42,
                          width: 44,
                          child: ElevatedButton(
                            onPressed: _addCustomBenefit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              padding: EdgeInsets.zero,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: const Icon(Icons.add, color: Colors.white, size: 22),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Popular benefits chips
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _popularBenefits.map((benefit) {
                        final isSelected = _selectedBenefits.contains(benefit);
                        return FilterChip(
                          label: Text(benefit),
                          selected: isSelected,
                          selectedColor: primaryColor.withOpacity(0.16),
                          checkmarkColor: primaryColor,
                          labelStyle: TextStyle(
                            fontSize: 12.5,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            color: isSelected ? primaryColor : const Color(0xFF374151),
                          ),
                          backgroundColor: const Color(0xFFF9FAFB),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isSelected ? primaryColor : const Color(0xFFE5E7EB),
                              width: isSelected ? 1.4 : 1.0,
                            ),
                          ),
                          onSelected: (selected) {
                            HapticFeedback.selectionClick();
                            setState(() {
                              if (selected) {
                                _selectedBenefits.add(benefit);
                              } else {
                                _selectedBenefits.remove(benefit);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),

                    // Selected custom benefits (if any not in popular list)
                    if (_selectedBenefits.any((b) => !_popularBenefits.contains(b))) ...[
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _selectedBenefits
                            .where((b) => !_popularBenefits.contains(b))
                            .map((customBenefit) {
                          return Chip(
                            label: Text(
                              customBenefit,
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: primaryColor,
                              ),
                            ),
                            backgroundColor: primaryColor.withOpacity(0.12),
                            deleteIcon: Icon(Icons.close_rounded, size: 16, color: primaryColor),
                            onDeleted: () {
                              HapticFeedback.selectionClick();
                              setState(() {
                                _selectedBenefits.remove(customBenefit);
                              });
                            },
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(color: primaryColor.withOpacity(0.4)),
                            ),
                          );
                        }).toList(),
                      ),
                    ],

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // ==========================================
            // BOTTOM ACTION BUTTONS
            // ==========================================
            _buildBottomButtons(context, primaryColor),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 18),
      child: Divider(
        color: Color(0xFFF3F4F6),
        thickness: 1.2,
        height: 1.2,
      ),
    );
  }

  Widget _buildSectionHeader(String title, [String? subtitle]) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF111827),
            letterSpacing: -0.2,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ],
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
      filteredList = _allLocations.take(6).toList();
    }

    final customLocations = _selectedLocations
        .where((loc) => !_allLocations.any((item) => item['name'] == loc))
        .toList();

    final List<Widget> col1 = [];
    final List<Widget> col2 = [];

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

    final customCategories = _selectedCategories
        .where((cat) => !_categories.any((item) => item['name'] == cat))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                child: Text(
                  _currentActiveCount > 0
                      ? 'Apply Filters ($_currentActiveCount)'
                      : 'Apply Filters',
                  style: const TextStyle(
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
