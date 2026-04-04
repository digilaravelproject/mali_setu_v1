import 'package:edu_cluezer/common/widgets/bg_gradient_border.dart';
import 'package:edu_cluezer/widgets/basic_text_field.dart';
import 'package:edu_cluezer/widgets/custom_buttons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/styles/app_decoration.dart';
import '../../../../core/utils/app_assets.dart';
import '../controller/filter_controller.dart';

class FilterBottomSheet extends GetWidget<FilterController> {
  const FilterBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppDecorations.bottomSheetDecoration(context),
      height: Get.height * 0.9,
      padding: EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              height: 4,
              width: 60,
              decoration: BoxDecoration(
                color: context.theme.dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ).marginOnly(bottom: 16),
          ),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GetBuilder<FilterController>(
                  builder: (ctrl) {
                    return Text(
                        "${'filters'.tr}${ctrl.activeFilterCount > 0 ? " (${ctrl.activeFilterCount})" : ""}",
                        style: context.textTheme.headlineSmall
                    );
                  }
              ),
              TextButton(
                onPressed: controller.resetFilters,
                child: Text(
                  'reset'.tr,
                  style: TextStyle(color: context.theme.primaryColor),
                ),
              ),
            ],
          ).marginSymmetric(horizontal: 8),

          SizedBox(height: 10),

          // Filter Content
          // Filter Content
          Expanded(
            child: GetBuilder<FilterController>(
              builder: (ctrl) => FilterCriteriaSection(controller: ctrl),
            ),
          ),
        ],
      ),
    );
  }

  static Future<dynamic> show() {
    return Get.bottomSheet(
      const FilterBottomSheet(),
      isScrollControlled: true,
      persistent: false,
      backgroundColor: Colors.transparent,
    );
  }
}

class FilterScreen extends GetWidget<FilterController> {
  const FilterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('filters'.tr, style: context.textTheme.headlineSmall),
          actions: [
            TextButton(
              onPressed: controller.resetFilters,
              child: Text(
                'reset'.tr,
                style: TextStyle(color: context.theme.primaryColor),
              ),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PreferredSize(
                preferredSize: const Size.fromHeight(40),
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    color: context.theme.colorScheme.surface.withValues(
                      alpha: 0.12,
                    ),
                  ),
                  child: TabBar(
                    dividerHeight: 0,
                    padding: EdgeInsets.zero,
                    physics: const NeverScrollableScrollPhysics(),
                    tabAlignment: TabAlignment.fill,
                    indicator: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: context.theme.primaryColor,
                          width: 2,
                        ),
                      ),
                    ),
                    indicatorSize: TabBarIndicatorSize.label,
                    labelColor: context.theme.colorScheme.primary,
                    unselectedLabelColor: context.theme.colorScheme.onSurface,
                    tabs: [
                      Tab(text: 'by_criteria'.tr),
                      Tab(text: 'by_profile_id'.tr),
                      Tab(text: 'saved_search'.tr),
                    ],
                  ),
                ),
              ),

              Expanded(
                child: TabBarView(
                  children: [
                    _buildCriteriaSection(),
                    _buildByProfileIdSection(),
                    _buildSaveSearchSection(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget _buildCriteriaSection(BuildContext context) {
  //   return Column(
  //     children: [
  //       Flexible(
  //         child: Column(
  //           children: [],
  //         ),
  //       ),
  //       SafeArea(
  //         child: SizedBox(
  //           width: double.infinity,
  //           height: 50,
  //           child: ElevatedButton(
  //             onPressed: controller.applyFilters,
  //             style: ElevatedButton.styleFrom(
  //               backgroundColor: context.theme.primaryColor,
  //               shape: RoundedRectangleBorder(
  //                 borderRadius: BorderRadius.circular(12),
  //               ),
  //             ),
  //             child: Text(
  //               "Apply Filters",
  //               style: context.textTheme.titleMedium?.copyWith(
  //                 color: Colors.white,
  //                 fontWeight: FontWeight.bold,
  //               ),
  //             ),
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }
  Widget _buildCriteriaSection() {
    return FilterCriteriaSection(controller: controller);
  }

  Widget _buildByProfileIdSection() {
    return Column(
      spacing: 16,
      children: [
        AppInputTextField(
          hintText: "Eg. MMS939290",
          label: 'matrimony_id'.tr,
          iconData: CupertinoIcons.search,
        ),
        CustomButton(title: 'view_profile'.tr, onPressed: () {}),
      ],
    ).marginAll(12);
  }

  Widget _buildSaveSearchSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'your_saved_search'.tr,
                style: context.textTheme.titleMedium,
              ),
              Text(
                "${'total'.tr} (75)",
                style: context.textTheme.titleMedium?.copyWith(
                  color: context.theme.primaryColor,
                ),
              ),
            ],
          ),
        ),
        Flexible(
          child: ListView.separated(
            itemCount: 8,
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              return Container(
                decoration: AppDecorations.cardDecoration(context),
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'search_title'.tr,
                          style: context.textTheme.labelMedium,
                        ),
                        Icon(
                          Icons.delete,
                          size: 20,
                          color: context.theme.primaryColor,
                        ),
                      ],
                    ),
                    Text(
                      "${index * 7} ${'matches'.tr}",
                      style: context.textTheme.titleLarge,
                    ),
                    Center(
                      child: BgGradientBorder(
                        child:
                        Text(
                          'show_matches'.tr,
                          style: context.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: context.theme.primaryColor,
                          ),
                        ).marginSymmetric(
                          horizontal: Get.width * 0.1,
                          vertical: 8,
                        ),
                      ),
                    ).marginOnly(top: 12),
                  ],
                ),
              ).marginSymmetric(horizontal: 4);
            },
          ),
        ),
      ],
    );
  }
}

// ExpandableFilterSection Widget
class ExpandableFilterSection extends StatefulWidget {
  final String title;
  final Widget content;
  final IconData icon;
  final bool initiallyExpanded;

  const ExpandableFilterSection({
    Key? key,
    required this.title,
    required this.content,
    this.icon = Icons.filter_list,
    this.initiallyExpanded = false,
  }) : super(key: key);

  @override
  _ExpandableFilterSectionState createState() =>
      _ExpandableFilterSectionState();
}

class _ExpandableFilterSectionState extends State<ExpandableFilterSection> {
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    return
      //Card(
      // margin: EdgeInsets.only(bottom: 12),
      // elevation: 1,
      // shape: RoundedRectangleBorder(
      //   borderRadius: BorderRadius.circular(12),
      // ),
      // child:
      ExpansionTile(
        tilePadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        initiallyExpanded: _isExpanded,
        onExpansionChanged: (expanded) {
          setState(() {
            _isExpanded = expanded;
          });
        },
        leading: Icon(widget.icon, color: context.theme.primaryColor),
        title: Text(
          widget.title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        trailing: Icon(
          _isExpanded ? Icons.expand_less : Icons.expand_more,
          color: context.theme.primaryColor,
        ),
        children: [
          //  Divider(height: 1, thickness: 1, color: Colors.grey[200]),
          Padding(padding: EdgeInsets.all(16), child: widget.content),
        ],
      );
    // );
  }

/* @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      childrenPadding: EdgeInsets.zero,
      initiallyExpanded: _isExpanded,
      onExpansionChanged: (expanded) {
        setState(() {
          _isExpanded = expanded;
        });
      },

      title: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: _isExpanded
            ? BoxDecoration(
          color: context.theme.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        )
            : null,
        child: Row(
          children: [
            // Leading icon
            Icon(
              widget.icon,
              color: _isExpanded
                  ? context.theme.primaryColor
                  : Colors.grey[800],
            ),
           const SizedBox(width: 12),

            // Title text
            Expanded(
              child: Text(
                widget.title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _isExpanded
                      ? context.theme.primaryColor
                      : Colors.grey[800],
                ),
              ),
            ),

            const Spacer(),
            Icon(
              _isExpanded ? Icons.expand_less : Icons.expand_more,
              color: context.theme.primaryColor,
            ),
          ],
        ),
      ),

      // Remove trailing from ExpansionTile since we added it in title
      trailing: const SizedBox.shrink(),

      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: widget.content,
        ),
      ],
    );
  }*/
}

// Complete Criteria Section with All Expandable Sections
class FilterCriteriaSection extends StatefulWidget {
  final FilterController controller;

  const FilterCriteriaSection({Key? key, required this.controller})
      : super(key: key);

  @override
  _FilterCriteriaSectionState createState() => _FilterCriteriaSectionState();
}

class _FilterCriteriaSectionState extends State<FilterCriteriaSection> {
  int _selectedIndex = 0;

  final List<String> _categories = [
    "Brand",
    "RAM",
    "Deliver At",
    "Network Type",
    "Internal Storage",
    "Type",
    "Processor Brand",
    "Clock Speed",
    "Operating System",
    "Battery Capacity",
    "Resolution Type",
  ];

  // Mapping old categories to new names based on image or keeping old names?
  // The user image shows "Brand", "RAM" etc which are for PHONES.
  // BUT the app is Matrimony. The user likely wants the LAYOUT, not the content.
  // I should keep the EXISTING categories ("Basic Details", "Professional Details" etc) but use the NEW layout.

  final List<Map<String, dynamic>> _sections = [
    {"title": "basic_details", "icon": Icons.person_outline},
    {"title": "professional_details", "icon": Icons.work_outline},
    {"title": "religion_details", "icon": Icons.temple_hindu_outlined},
    {"title": "family_details", "icon": Icons.family_restroom},
    {"title": "location_details", "icon": Icons.location_on_outlined},
    {"title": "lifestyle", "icon": Icons.fitness_center_outlined},
    {"title": "profile_type", "icon": Icons.category_outlined},
    {"title": "recently_created", "icon": Icons.access_time_outlined},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // LEFT SIDE - Categories
              Container(
                width: 120, // Reduced width for left menu
                decoration: BoxDecoration(
                  color: Colors.grey[50], // Lighter grey
                  border: Border(right: BorderSide(color: Colors.grey[200]!)),
                ),
                child: ListView.builder(
                  itemCount: _sections.length,
                  itemBuilder: (context, index) {
                    final isSelected = _selectedIndex == index;
                    return InkWell(
                      onTap: () => setState(() => _selectedIndex = index),
                      child: Container(
                        color: isSelected ? Colors.white : Colors.transparent,
                        padding: const EdgeInsets.symmetric(
                            vertical: 14, horizontal: 8), // Reduced padding
                        child: Row(
                          children: [
                            if (isSelected)
                              Container(
                                width: 4,
                                height: 20, // Smaller indicator
                                decoration: BoxDecoration(
                                  color: context.theme.primaryColor,
                                  borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(4),
                                    bottomRight: Radius.circular(4),
                                  ),
                                ),
                              ).marginOnly(right: 6),
                            Expanded(
                              child: Text(
                                _sections[index]['title'].toString().tr,
                                style: TextStyle(
                                  fontSize: 12, // Reduced font size
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                  color: isSelected
                                      ? context.theme.primaryColor
                                      : Colors.grey[700],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // RIGHT SIDE - Content
              Expanded(
                child: Container(
                  color: Colors.white,
                  child: Column(
                    children: [
                      // Header for the selected section
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
                        ),
                        child: Text(
                          _sections[_selectedIndex]['title'].toString().tr,
                          style: context.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      // Scrollable Content
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: _buildCurrentSection(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Footer Actions (Apply Button)

        SafeArea(
          top: false,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: widget.controller.applyFilters,
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.theme.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'apply_filters'.tr,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        )

      /*  Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: widget.controller.applyFilters,
              style: ElevatedButton.styleFrom(
                backgroundColor: context.theme.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'apply_filters'.tr,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),*/
      ],
    );
  }

  Widget _buildCurrentSection() {
    switch (_selectedIndex) {
      case 0:
        return _buildBasicDetailsSection();
      case 1:
        return _buildProfessionalDetailsSection();
      case 2:
        return _buildReligionDetailsSection();
      case 3:
        return _buildFamilyDetailsSection();
      case 4:
        return _buildLocationDetailsSection();
      case 5:
        return _buildLifestyleSection();
      case 6:
        return _buildProfileTypeSection();
      case 7:
        return _buildRecentlyCreatedSection();
      default:
        return SizedBox();
    }
  }

  Widget _buildBasicDetailsSection() {
    return Column(
      children: [
        // Age Range
        _buildRangeFilter(
          title: 'age'.tr,
          range: widget.controller.ageRange,
          min: 18,
          max: 60,
          unit: 'years'.tr,
          onChanged: (range) {
            setState(() {
              widget.controller.ageRange = range;
            });
          },
        ),

        SizedBox(height: 16),

        SingleDropdown(
          label: 'profile_created_by'.tr,
          controller: widget.controller.profileCreatedByCtrl,
          items: widget.controller.profileCreatedByList,
        ),

        SizedBox(height: 16),
        SelectableChipGroup(
          title: 'marital_status'.tr,
          items: ['any'.tr, 'divorced'.tr, 'widow'.tr, 'single'.tr, 'awaiting_divorce'.tr],
          onSelectionChanged: (selected) {
            print(selected);
          },
        ),
        SizedBox(height: 16),

        SingleDropdown(
          label: 'mother_tongue'.tr,
          controller: widget.controller.mothertangueCtrl,
          items: widget.controller.languageList,
        ),
        SizedBox(height: 16),
        // Height Range
        _buildRangeFilter(
          title: 'height'.tr,
          range: widget.controller.heightRange,
          min: 140,
          max: 200,
          unit: 'cm'.tr,
          onChanged: (range) {
            setState(() {
              widget.controller.heightRange = range;
            });
          },
        ),

        SizedBox(height: 16),
        SelectableChipGroup(
          title: 'physical_status'.tr,
          items: ['normal'.tr, 'doesnt_matter'.tr, 'physically_challenged'.tr],
          onSelectionChanged: (selected) {
            print(selected);
          },
        ),
      ],
    );
  }

  Widget _buildProfessionalDetailsSection() {
    return Column(
      children: [
        // Education
        _buildRangeFilter(
          title: 'annual_income'.tr,
          range: widget.controller.salaryRange,
          min: 0,
          max: 5000000,
          unit: "₹",
          onChanged: (range) {
            setState(() {
              widget.controller.salaryRange = range;
            });
          },
        ),

        SingleDropdown(
          controller: widget.controller.educationCtrl,
          label: 'education'.tr,
          items: widget.controller.educationList,
        ),

        SizedBox(height: 20),

        RadioCheckboxList(
          title: 'employment_type'.tr,
          items: [
            'any'.tr,
            'business_owner'.tr,
            'defence_sector'.tr,
            'government_psu'.tr,
            'private_sector'.tr,
            'self_employed'.tr,
          ],
          onSelectionChanged: (selectedList) {
            print(selectedList);
          },
        ),

        SizedBox(height: 20),

        SelectableChipGroup(
          title: 'occupation'.tr,
          items: [
            'any'.tr,
            'airline'.tr,
            'engineering'.tr,
            'it_software'.tr,
            'civil_services'.tr,
          ],
          onSelectionChanged: (selected) {
            print(selected);
          },
        ),
      ],
    );
  }

  Widget _buildReligionDetailsSection() {
    return Column(
      children: [
        Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: context.theme.dividerColor, width: 1),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Image.asset(AppAssets.imgCrown, height: 50, width: 50),
                Center(
                  child: Text(
                    'premium'.tr,
                    style: context.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    'upgrade_message'.tr,
                    style: context.textTheme.bodyMedium,
                  ),
                ),

                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'profiles_with_horoscope'.tr,
                        style: context.textTheme.titleMedium,
                      ),
                    ),
                    Icon(Icons.lock),
                  ],
                ),
                Text(
                  'matches_with_horoscope'.tr,
                  style: context.textTheme.bodyLarge,
                ),
                SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'profiles_with_horoscope'.tr,
                        style: context.textTheme.titleMedium,
                      ),
                    ),
                    Icon(Icons.lock),
                  ],
                ),
              ],
            ),
          ),
        ),
        // Religion
        SizedBox(height: 20),
        SelectableChipGroup(
          title: 'manglik'.tr,
          items: ['dont_know'.tr, 'yes'.tr, 'doesnt_matter'.tr, 'no'.tr],
          onSelectionChanged: (selected) {
            print(selected);
          },
        ),
      ],
    );
  }

  Widget _buildFamilyDetailsSection() {
    return Column(
      children: [
        SingleDropdown(
          label: 'family_status'.tr,
          controller: widget.controller.familyStatusCtrl,
          items: widget.controller.familyList,
        ),

        SizedBox(height: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('family_type'.tr, style: Get.textTheme.titleMedium),
            const SizedBox(height: 16),

            Obx(
                  () => Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.start,
                children: [
                  _buildCircleOption(
                    title: 'nuclear'.tr,
                    icon: AppAssets.imgnuclearFamily,
                    isSelected:
                    widget.controller.selectedDontShowOption.value ==
                        "ignored",
                    onTap: () {
                      widget.controller.selectedDontShowOption.value =
                      "ignored";
                    },
                  ),

                  _buildCircleOption(
                    title: 'joint'.tr,
                    icon: AppAssets.imgjointFamily,
                    isSelected:
                    widget.controller.selectedDontShowOption.value ==
                        "shortlisted",
                    onTap: () {
                      widget.controller.selectedDontShowOption.value =
                      "shortlisted";
                    },
                  ),

                  _buildCircleOption(
                    title: 'doesnt_matter'.tr,
                    icon: AppAssets.imgNull,
                    isSelected:
                    widget.controller.selectedDontShowOption.value ==
                        "viewed",
                    onTap: () {
                      widget.controller.selectedDontShowOption.value = "viewed";
                    },
                  ),

                  _buildCircleOption(
                    title: 'not_specified'.tr,
                    icon: AppAssets.imgAppLogo,
                    isSelected:
                    widget.controller.selectedDontShowOption.value ==
                        "contacted",
                    onTap: () {
                      widget.controller.selectedDontShowOption.value =
                      "contacted";
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 16),

        SelectableChipGroup(
          title: 'family_value'.tr,
          items: [
            'liberal'.tr,
            'moderate'.tr,
            'traditional'.tr,
            'doesnt_matter'.tr,
            'orthodox'.tr,
            'not_specified'.tr,
          ],
          onSelectionChanged: (selected) {
            print(selected);
          },
        ),
      ],
    );
  }

  Widget _buildCircleOption({
    required String title,
    required String icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected
                    ? Get.theme.primaryColor
                    : Get.theme.dividerColor,
                width: 2,
              ),
              color: isSelected
                  ? Get.theme.primaryColor.withOpacity(0.12)
                  : Colors.transparent,
            ),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Image.asset(
                icon,
                height: 20,
                width: 20,
                color: isSelected ? Get.theme.primaryColor : Get.iconColor,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Get.textTheme.bodyMedium?.copyWith(
              color: isSelected ? Get.theme.primaryColor : Get.theme.hintColor,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationDetailsSection() {
    List<String> selectedHobbies = [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('nearby_profiles'.tr, style: Get.textTheme.titleMedium),
                  SizedBox(height: 5),
                  Text(
                    'matches_near_location'.tr,
                    style: Get.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            Obx(
                  () => Checkbox(
                value: widget.controller.isNearbyChecked.value,
                onChanged: (bool? value) {
                  widget.controller.isNearbyChecked.value = value ?? false;
                },
              ),
            ),
          ],
        ),

        SingleDropdown(
          label: 'country'.tr,
          controller: widget.controller.countryCtrl,
          items: widget.controller.countryList,
        ),

        // State Dropdown
        SingleDropdown(
          label: 'state'.tr,
          controller: widget.controller.stateCtrl,
          items: widget.controller.stateList,
        ),

        // City Dropdown
        SingleDropdown(
          label: 'city'.tr,
          controller: widget.controller.cityCtrl,
          items: widget.controller.cityList,
        ),

        SizedBox(height: 8,),

        MultiCheckboxList(
          title: '${'citizenship'.tr}:',
          items: [
            'any'.tr,
            'Antarctica',
            'Armenia',
            'Vanuatu',
            'Turks and Caicos Islands',
            'Northern Mariana Islands',
            'Netherlands Antilles',
            'Netherlands Antilles',
          ],
          onSelectionChanged: (selected) {
            setState(() {
              selectedHobbies = selected;
            });
            print('Selected hobbies: $selected');
          },
        ),
      ],
    );
  }

  Widget _buildLifestyleSection() {
    return Column(
      children: [
        customToggleTile(
          title: 'any'.tr,
          initialValue: widget.controller.isPrivate.value,
          onChanged: (val) => widget.controller.isPrivate.value = val,
        ),

        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Divider(),
        ),

        customToggleTile(
          title: 'eggetarian'.tr,
          initialValue: widget.controller.isPrivate.value,
          onChanged: (val) => widget.controller.isPrivate.value = val,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Divider(),
        ),

        customToggleTile(
          title: 'vegetarian'.tr,
          initialValue: widget.controller.isPrivate.value,
          onChanged: (val) => widget.controller.isPrivate.value = val,
        ),

        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Divider(),
        ),
        customToggleTile(
          title: 'non_vegetarian'.tr,
          initialValue: widget.controller.isPrivate.value,
          onChanged: (val) => widget.controller.isPrivate.value = val,
        ),

        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Divider(),
        ),
        customToggleTile(
          title: 'not_specified'.tr,
          initialValue: widget.controller.isPrivate.value,
          onChanged: (val) => widget.controller.isPrivate.value = val,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Divider(),
        ),
        SingleDropdown(
          label: 'smoking_habits'.tr,
          controller: widget.controller.smokingCtrl,
          items: widget.controller.smokingHabits,
        ),

        SizedBox(height: 16),

        MultiCheckboxList(
          title: '${'drinking_habits'.tr}:',
          items: [
            'never'.tr,
            'socially'.tr,
            'regularly'.tr,
            'not_specified'.tr,
            'doesnt_matter'.tr,
          ],
          onSelectionChanged: (selected) {
            setState(() {
              //  selectedHobbies = selected;
            });
            print('Selected hobbies: $selected');
          },
        ),
      ],
    );
  }

  Widget _buildProfileTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // First Row with Checkbox
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('profile_with_photo'.tr, style: Get.textTheme.titleMedium),
                  SizedBox(height: 5),
                  Text(
                    'matches_with_photos'.tr,
                    style: Get.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 10),
            Obx(
                  () => Checkbox(
                value: widget.controller.isProfileWithPhoto.value,
                onChanged: (bool? value) {
                  widget.controller.isProfileWithPhoto.value = value ?? false;
                },
              ),
            ),
          ],
        ),

        SizedBox(height: 24),

        // Don't Show Profile Section
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('dont_show_profile'.tr, style: Get.textTheme.titleMedium),
            SizedBox(height: 12),

            // Options in a Column
            Obx(
                  () => Column(
                children: [
                  _buildProfileOption(
                    title: 'ignored'.tr,
                    subtitle: 'profiles_ignored'.tr,
                    icon: Icons.block,
                    isSelected:
                    widget.controller.selectedDontShowOption.value ==
                        "ignored",
                    onTap: () {
                      widget.controller.selectedDontShowOption.value =
                      "ignored";
                    },
                  ),
                  const SizedBox(height: 12),

                  _buildProfileOption(
                    title: 'shortlisted'.tr,
                    subtitle: 'profiles_shortlisted'.tr,
                    icon: Icons.star_border,
                    isSelected:
                    widget.controller.selectedDontShowOption.value ==
                        "shortlisted",
                    onTap: () {
                      widget.controller.selectedDontShowOption.value =
                      "shortlisted";
                    },
                  ),
                  const SizedBox(height: 12),

                  _buildProfileOption(
                    title: 'already_viewed'.tr,
                    subtitle: 'profiles_viewed'.tr,
                    icon: Icons.remove_red_eye_outlined,
                    isSelected:
                    widget.controller.selectedDontShowOption.value ==
                        "viewed",
                    onTap: () {
                      widget.controller.selectedDontShowOption.value = "viewed";
                    },
                  ),
                  const SizedBox(height: 12),

                  _buildProfileOption(
                    title: 'already_contacted'.tr,
                    subtitle: 'profiles_contacted'.tr,
                    icon: Icons.chat_bubble_outline,
                    isSelected:
                    widget.controller.selectedDontShowOption.value ==
                        "contacted",
                    onTap: () {
                      widget.controller.selectedDontShowOption.value =
                      "contacted";
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Helper Widget for each option
  Widget _buildProfileOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          //color: Get.theme
          //isSelected
          //? Colors.blue.withOpacity(0.08)
          // : Colors.transparent,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
            color: isSelected ? Get.theme.primaryColor : Get.theme.dividerColor,
            width: 1.2,
          ),
        ),
        child: Row(
          children: [
            /// Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? Get.theme.primaryColor
                    : Get.theme.dividerColor,
              ),
              child: Icon(
                icon,
                size: 20,
                color: isSelected ? Get.theme.cardColor : Get.iconColor,
              ),
            ),

            const SizedBox(width: 12),

            /// Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Get.textTheme.titleMedium?.copyWith(
                      color: isSelected
                          ? Get.theme.primaryColor
                          : Get.theme.hintColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Get.textTheme.bodyMedium,
                    //  TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentlyCreatedSection() {
    final options = {
      'all': 'all_time'.tr,
      'today': 'today'.tr,
      'last_7_days': 'last_7_days'.tr,
      'last_30_days': 'last_30_days'.tr,
      'one_week': 'one_week'.tr,
      'one_month': 'one_month'.tr,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'profile_created'.tr,
          style: context.textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        ...options.entries.map((entry) {
          return Obx(() {
            final isSelected = widget.controller.recentlyCreated.value == entry.key;
            return RadioListTile<String>(
              title: Text(entry.value),
              value: entry.key,
              groupValue: widget.controller.recentlyCreated.value,
              onChanged: (val) {
                if (val != null) {
                  widget.controller.recentlyCreated.value = val;
                }
              },
              activeColor: context.theme.primaryColor,
              contentPadding: EdgeInsets.zero,
              dense: true,
              controlAffinity: ListTileControlAffinity.trailing,
            );
          });
        }).toList(),
      ],
    );
  }

  // Helper Widgets for Filter Types

  Widget _buildRangeFilter({
    required String title,
    required RangeValues range,
    required double min,
    required double max,
    required String unit,
    required ValueChanged<RangeValues> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: context.textTheme.titleMedium,
          // TextStyle(fontWeight: FontWeight.w500),
        ),
        // SizedBox(height: 12),
        RangeSlider(
          values: range,
          min: min,
          max: max,
          divisions: (max - min).toInt(),
          labels: RangeLabels(
            "${range.start.round()} $unit",
            "${range.end.round()} $unit",
          ),
          onChanged: onChanged,
        ),
        // SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "${range.start.round()} $unit",
              style: context.textTheme.titleSmall,
            ),
            Text(
              "${range.end.round()} $unit",
              style: context.textTheme.titleSmall,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildChipFilter({
    required String title,
    required List<String> options,
    required List<String> selectedOptions,
    required ValueChanged<List<String>> onSelectionChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontWeight: FontWeight.w500)),
        SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final isSelected = selectedOptions.contains(option);
            return FilterChip(
              label: Text(option),
              selected: isSelected,
              onSelected: (selected) {
                final newSelection = List<String>.from(selectedOptions);
                if (selected) {
                  newSelection.add(option);
                } else {
                  newSelection.remove(option);
                }
                onSelectionChanged(newSelection);
              },
              backgroundColor: Colors.grey[200],
              selectedColor: context.theme.primaryColor.withOpacity(0.2),
              labelStyle: TextStyle(
                color: isSelected
                    ? context.theme.primaryColor
                    : Colors.grey[700],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget customToggleTile({
    required String title,
    required bool initialValue,
    required Function(bool) onChanged,
  }) {
    final RxBool toggle = initialValue.obs;

    return Obx(() {
      return GestureDetector(
        onTap: () {
          toggle.value = !toggle.value;
          onChanged(toggle.value);
        },
        child: Container(
          //  padding: const EdgeInsets.all(8),
          // decoration: BoxDecoration(
          //   color:Get.theme.dividerColor,
          //   borderRadius: BorderRadius.circular(10),
          // ),
          child: Row(
            children: [
              // Icon(icon, color: Colors.black, size: 22),

              //  SizedBox(width: 12),
              Text(
                title,
                style: context.textTheme.titleMedium,
                // TextStyle(
                //   color: Colors.black,
                //   fontSize: 16,
                //   fontWeight: FontWeight.w600,
                // ),
              ),

              Spacer(),

              // Toggle switch
              AnimatedContainer(
                duration: Duration(milliseconds: 200),
                width: 55,
                height: 25,
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: toggle.value
                      ? Get.theme.primaryColor
                      : Get.theme.dividerColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Align(
                  alignment: toggle.value
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: toggle.value
                          ? Get.theme.cardColor
                          : Get.theme.cardColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildMultiSelectFilter({
    required String title,
    required List<String> options,
    required List<String> selectedOptions,
    required ValueChanged<List<String>> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontWeight: FontWeight.w500)),
        SizedBox(height: 12),
        ...options.map((option) {
          final isSelected = selectedOptions.contains(option);
          return CheckboxListTile(
            title: Text(option),
            value: isSelected,
            onChanged: (value) {
              final newSelection = List<String>.from(selectedOptions);
              if (value == true) {
                newSelection.add(option);
              } else {
                newSelection.remove(option);
              }
              onChanged(newSelection);
            },
            controlAffinity: ListTileControlAffinity.leading,
            dense: true,
          );
        }).toList(),
      ],
    );
  }

  Widget _buildDropdownFilter({
    required String title,
    required String value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontWeight: FontWeight.w500)),
        SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: value,
          items: options.map((String option) {
            return DropdownMenuItem<String>(value: option, child: Text(option));
          }).toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }

  Widget _buildTextInputFilter({
    required String title,
    required String hintText,
    required String value,
    required ValueChanged<String> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontWeight: FontWeight.w500)),
        SizedBox(height: 12),
        TextField(
          decoration: InputDecoration(
            hintText: hintText,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildRadioFilter({
    required String title,
    required List<String> options,
    required String selectedValue,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontWeight: FontWeight.w500)),
        SizedBox(height: 12),
        ...options.map((option) {
          return RadioListTile<String>(
            title: Text(option),
            value: option,
            groupValue: selectedValue,
            onChanged: onChanged,
            dense: true,
          );
        }).toList(),
      ],
    );
  }
}

// Updated FilterController with all new fields

class RadioCheckboxList extends StatefulWidget {
  final String title;
  final List<String> items;
  final Function(List<String>) onSelectionChanged;

  const RadioCheckboxList({
    super.key,
    required this.title,
    required this.items,
    required this.onSelectionChanged,
  });

  @override
  State<RadioCheckboxList> createState() => _RadioCheckboxListState();
}

class _RadioCheckboxListState extends State<RadioCheckboxList> {
  final List<String> _selectedItems = [];

  void _toggleSelection(String item) {
    setState(() {
      if (_selectedItems.contains(item)) {
        _selectedItems.remove(item);
      } else {
        _selectedItems.add(item);
      }
    });

    widget.onSelectionChanged(_selectedItems);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Title
        Text(
          widget.title,
          style: context.textTheme.titleMedium,
          // const TextStyle(
          //   fontSize: 16,
          //   fontWeight: FontWeight.bold,
          // ),
        ),
        const SizedBox(height: 8),

        /// List
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.items.length,
          itemBuilder: (context, index) {
            final item = widget.items[index];
            final isSelected = _selectedItems.contains(item);

            return InkWell(
              onTap: () => _toggleSelection(item),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Icon(
                      isSelected
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : Colors.grey,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        item,
                        style: context.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        //const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class SelectableChipGroup extends StatefulWidget {
  final String title;
  final List<String> items;
  final Function(List<String>) onSelectionChanged;

  const SelectableChipGroup({
    super.key,
    required this.title,
    required this.items,
    required this.onSelectionChanged,
  });

  @override
  State<SelectableChipGroup> createState() => _SelectableChipGroupState();
}

class _SelectableChipGroupState extends State<SelectableChipGroup> {
  final List<String> _selectedItems = [];

  void _onChipTap(String item) {
    setState(() {
      if (_selectedItems.contains(item)) {
        _selectedItems.remove(item);
      } else {
        _selectedItems.add(item);
      }
    });

    widget.onSelectionChanged(_selectedItems);
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Title
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            widget.title,
            style: context.textTheme.titleMedium,
            // const TextStyle(
            //   fontSize: 16,
            //   fontWeight: FontWeight.w600,
            // ),
          ),
        ),

        const SizedBox(height: 16),

        /// Chips
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: widget.items.map((item) {
            final isSelected = _selectedItems.contains(item);

            return GestureDetector(
              onTap: () => _onChipTap(item),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? primaryColor : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(6), // 👈 thoda curve
                ),
                child: Text(
                  item,
                  style: TextStyle(
                    fontSize: 16,
                    color: isSelected ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// Family Type Enum
enum FamilyType { nuclear, joint, doesNotMatter, notSpecified }

class FamilyTypeSelectionPage extends StatefulWidget {
  @override
  _FamilyTypeSelectionPageState createState() =>
      _FamilyTypeSelectionPageState();
}

class _FamilyTypeSelectionPageState extends State<FamilyTypeSelectionPage> {
  FamilyType? _selectedFamilyType;

  // Image paths for each option (आप अपनी images से replace कर सकते हैं)
  final Map<FamilyType, String> _familyTypeImages = {
    FamilyType.nuclear: AppAssets.imgAppLogo, // छोटा परिवार
    FamilyType.joint: AppAssets.imgAppLogo, // संयुक्त परिवार
    FamilyType.doesNotMatter: AppAssets.imgAppLogo, // कोई फर्क नहीं पड़ता
    FamilyType.notSpecified: AppAssets.imgAppLogo, // निर्दिष्ट नहीं
  };

  // Labels for each option
  final Map<FamilyType, String> _familyTypeLabels = {
    FamilyType.nuclear: 'Nuclear',
    FamilyType.joint: 'Joint',
    FamilyType.doesNotMatter: "Doesn't Matter",
    FamilyType.notSpecified: 'Not Specified',
  };

  // Descriptions for each option
  final Map<FamilyType, String> _familyTypeDescriptions = {
    FamilyType.nuclear: 'Small family with parents and children',
    FamilyType.joint: 'Large family with multiple generations',
    FamilyType.doesNotMatter: 'Open to any family type',
    FamilyType.notSpecified: 'Prefer not to specify',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Select Family Type')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose your family type:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),

            // Family Type Options
            Column(
              children: FamilyType.values.map((type) {
                return _buildFamilyTypeOption(type);
              }).toList(),
            ),

            SizedBox(height: 30),

            // Selected Value Display
            if (_selectedFamilyType != null)
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    SizedBox(width: 10),
                    Text(
                      'Selected: ${_familyTypeLabels[_selectedFamilyType]}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFamilyTypeOption(FamilyType type) {
    bool isSelected = _selectedFamilyType == type;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedFamilyType = type;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue[50] : Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? Colors.blue : Colors.grey,
              width: isSelected ? 2 : 1,
            ),
          ),
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              // Circle with Image (Placeholder - आप अपनी images use करें)
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? Colors.blue : Colors.grey,
                    width: 2,
                  ),
                  image: DecorationImage(
                    image: AssetImage(
                      _familyTypeImages[type] ?? 'assets/placeholder.png',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
                // If using network images:
                // child: CircleAvatar(
                //   backgroundImage: NetworkImage('your_image_url'),
                // ),
              ),

              SizedBox(width: 16),

              // Text Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _familyTypeLabels[type] ?? '',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.blue[800] : Colors.black,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      _familyTypeDescriptions[type] ?? '',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),
              ),

              // Radio Circle
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? Colors.blue : Colors.grey,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? Center(
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.blue,
                    ),
                  ),
                )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CircularImageRadioButtons extends StatefulWidget {
  @override
  _CircularImageRadioButtonsState createState() =>
      _CircularImageRadioButtonsState();
}

class _CircularImageRadioButtonsState extends State<CircularImageRadioButtons> {
  FamilyType? _selectedType;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Family Type')),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildCircularOption(FamilyType.nuclear, Icons.home, 'Nuclear'),
            SizedBox(width: 20),
            _buildCircularOption(FamilyType.joint, Icons.people, 'Joint'),
            SizedBox(width: 20),
            _buildCircularOption(
              FamilyType.doesNotMatter,
              Icons.all_inclusive,
              "Doesn't Matter",
            ),
            SizedBox(width: 20),
            _buildCircularOption(
              FamilyType.notSpecified,
              Icons.help,
              'Not Specified',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircularOption(FamilyType type, IconData icon, String label) {
    bool isSelected = _selectedType == type;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _selectedType = type;
            });
          },
          child: Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? Colors.blue[100] : Colors.grey[200],
              border: Border.all(
                color: isSelected ? Colors.blue : Colors.transparent,
                width: 3,
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  icon,
                  size: 30,
                  color: isSelected ? Colors.blue[800] : Colors.grey[700],
                ),
                if (isSelected)
                  Positioned(
                    top: 5,
                    right: 5,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.green,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Icon(Icons.check, size: 12, color: Colors.white),
                    ),
                  ),
              ],
            ),
          ),
        ),
        SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.blue[800] : Colors.black,
          ),
        ),
      ],
    );
  }
}

class MultiCheckboxList extends StatefulWidget {
  final String title;
  final List<String> items;
  final List<String>? initiallySelected;
  final ValueChanged<List<String>>? onSelectionChanged;
  final bool showSelectAll;
  final TextStyle? titleStyle;
  final EdgeInsetsGeometry? padding;
  final Color? selectedColor;
  final Color? checkboxColor;
  final bool dense;
  final double spacing;
  final CrossAxisAlignment crossAxisAlignment;

  const MultiCheckboxList({
    Key? key,
    required this.title,
    required this.items,
    this.initiallySelected,
    this.onSelectionChanged,
    this.showSelectAll = false,
    this.titleStyle,
    this.padding,
    this.selectedColor,
    this.checkboxColor,
    this.dense = false,
    this.spacing = 0.0,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  }) : super(key: key);

  @override
  _MultiCheckboxListState createState() => _MultiCheckboxListState();
}

class _MultiCheckboxListState extends State<MultiCheckboxList> {
  late List<bool> _checkedItems;
  bool _selectAll = false;

  @override
  void initState() {
    super.initState();
    _initCheckedItems();
  }

  @override
  void didUpdateWidget(MultiCheckboxList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.items.length != oldWidget.items.length ||
        widget.items != oldWidget.items ||
        widget.initiallySelected != oldWidget.initiallySelected) {
      _initCheckedItems();
    }
  }

  void _initCheckedItems() {
    _checkedItems = List<bool>.filled(widget.items.length, false);

    if (widget.initiallySelected != null) {
      for (int i = 0; i < widget.items.length; i++) {
        if (widget.initiallySelected!.contains(widget.items[i])) {
          _checkedItems[i] = true;
        }
      }
      _updateSelectAllState();
    }
  }

  void _updateSelectAllState() {
    setState(() {
      _selectAll = _checkedItems.every((isChecked) => isChecked);
    });
  }

  void _handleItemChecked(int index, bool isChecked) {
    setState(() {
      _checkedItems[index] = isChecked;
      _updateSelectAllState();
    });

    _notifySelectionChanged();
  }

  void _handleSelectAll(bool isChecked) {
    setState(() {
      _checkedItems = List<bool>.filled(widget.items.length, isChecked);
      _selectAll = isChecked;
    });

    _notifySelectionChanged();
  }

  void _notifySelectionChanged() {
    if (widget.onSelectionChanged != null) {
      List<String> selectedItems = [];
      for (int i = 0; i < widget.items.length; i++) {
        if (_checkedItems[i]) {
          selectedItems.add(widget.items[i]);
        }
      }
      widget.onSelectionChanged!(selectedItems);
    }
  }

  List<String> getSelectedItems() {
    List<String> selected = [];
    for (int i = 0; i < widget.items.length; i++) {
      if (_checkedItems[i]) {
        selected.add(widget.items[i]);
      }
    }
    return selected;
  }

  @override
  Widget build(BuildContext context) {
    final selectedColor =
        widget.selectedColor ?? Theme.of(context).primaryColor;
    final checkboxColor = widget.checkboxColor ?? selectedColor;

    return Container(
      //padding: widget.padding ?? EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: widget.crossAxisAlignment,
        children: [
          // Title
          Text(
            widget.title,
            style: Get.textTheme.titleLarge,
            // widget.titleStyle ?? TextStyle(
            //   fontSize: 18,
            //   fontWeight: FontWeight.w600,
            //   color: Colors.grey[800],
            // ),
          ),

          SizedBox(height: widget.spacing),

          // Select All Option (Optional)
          if (widget.showSelectAll)
            Padding(
              padding: EdgeInsets.only(bottom: widget.spacing),
              child: Row(
                children: [
                  Checkbox(
                    value: _selectAll,
                    onChanged: (value) => _handleSelectAll(value ?? false),
                    activeColor: checkboxColor,
                  ),
                  Text(
                    'Select All',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),

          // Checkbox List
          ..._buildCheckboxList(selectedColor, checkboxColor),
        ],
      ),
    );
  }

  List<Widget> _buildCheckboxList(Color selectedColor, Color checkboxColor) {
    return List<Widget>.generate(
      widget.items.length,
          (index) => Padding(
        padding: EdgeInsets.only(bottom: widget.spacing),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Checkbox on left

            // Item text on right
            Expanded(
              child: Text(
                widget.items[index],
                style: TextStyle(
                  fontSize: widget.dense ? 14 : 16,
                  color: _checkedItems[index]
                      ? selectedColor
                      : Get.theme.hintColor,
                  fontWeight: _checkedItems[index]
                      ? FontWeight.w500
                      : FontWeight.normal,
                ),
              ),
            ),

            // SizedBox(width: 8),
            Checkbox(
              value: _checkedItems[index],
              onChanged: (value) => _handleItemChecked(index, value ?? false),
              activeColor: checkboxColor,
              materialTapTargetSize: widget.dense
                  ? MaterialTapTargetSize.shrinkWrap
                  : MaterialTapTargetSize.padded,
            ),
          ],
        ),
      ),
    );
  }
}
