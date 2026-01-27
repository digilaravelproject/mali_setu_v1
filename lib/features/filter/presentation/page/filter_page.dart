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
    return DefaultTabController(
      length: 3,
      child: Container(
        // decoration: AppDecorations.bottomSheetDecoration(context),
        //height: Get.height * 0.9,
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
                Text("Filters", style: context.textTheme.headlineSmall),
                TextButton(
                  onPressed: controller.resetFilters,
                  child: Text(
                    "Reset",
                    style: TextStyle(color: context.theme.primaryColor),
                  ),
                ),
              ],
            ).marginSymmetric(horizontal: 8),

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
                  tabs: const [
                    Tab(text: "By Criteria"),
                    Tab(text: "By Profile Id"),
                    Tab(text: "Saved Search"),
                  ],
                ),
              ),
            ),

            // Scrollable content
            Expanded(
              child: TabBarView(
                children: [
                  _buildCriteriaSection(context),
                  _buildByProfileIdSection(),
                  _buildSaveSearchSection(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static show() {
    Get.bottomSheet(
      const FilterBottomSheet(),
      isScrollControlled: true,
      persistent: false,
      backgroundColor: Colors.transparent,
    );
  }

  Widget _buildCriteriaSection(BuildContext context) {
    return Column(
      children: [
        Flexible(child: Column(children: [])),
        SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: controller.applyFilters,
              style: ElevatedButton.styleFrom(
                backgroundColor: context.theme.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                "Apply Filters",
                style: context.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildByProfileIdSection() {
    return Column(
      spacing: 16,
      children: [
        AppInputTextField(
          hintText: "Eg. MMS939290",
          label: "Matrimony Id",
          iconData: CupertinoIcons.search,
        ),

        CustomButton(title: "View Profile", onPressed: () {}),
      ],
    ).marginAll(12);
  }

  Widget _buildSaveSearchSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Your Saved Search...",
                style: context.textTheme.titleMedium,
              ),
              Text(
                "Total (75)",
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
            separatorBuilder: (context, index) {
              return SizedBox(height: 14);
            },
            itemBuilder: (context, index) {
              return Container(
                decoration: AppDecorations.cardDecoration(context),
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Search Title",
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
                      "${index * 7} Matches",
                      style: context.textTheme.titleLarge,
                    ),
                    Center(
                      child: BgGradientBorder(
                        child:
                            Text(
                              "Show Matches",
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

class FilterScreen extends GetWidget<FilterController> {
  const FilterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Filters", style: context.textTheme.headlineSmall),
          actions: [
            TextButton(
              onPressed: controller.resetFilters,
              child: Text(
                "Reset",
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
                    tabs: const [
                      Tab(text: "By Criteria"),
                      Tab(text: "By Profile Id"),
                      Tab(text: "Saved Search"),
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
    return SingleChildScrollView(
      //  padding: EdgeInsets.all(8),
      child: FilterCriteriaSection(controller: controller),
    );
  }

  Widget _buildByProfileIdSection() {
    return Column(
      spacing: 16,
      children: [
        AppInputTextField(
          hintText: "Eg. MMS939290",
          label: "Matrimony Id",
          iconData: CupertinoIcons.search,
        ),
        CustomButton(title: "View Profile", onPressed: () {}),
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
                "Your Saved Search...",
                style: context.textTheme.titleMedium,
              ),
              Text(
                "Total (75)",
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
                          "Search Title",
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
                      "${index * 7} Matches",
                      style: context.textTheme.titleLarge,
                    ),
                    Center(
                      child: BgGradientBorder(
                        child:
                            Text(
                              "Show Matches",
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
  final List<bool> _sectionExpansionStates = List.generate(8, (index) => false);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Basic Details Section
        ExpandableFilterSection(
          title: "Basic Details",
          icon: Icons.person_outline,
          initiallyExpanded: _sectionExpansionStates[0],
          content: _buildBasicDetailsSection(),
        ),
        Divider(),

        // Professional Details
        ExpandableFilterSection(
          title: "Professional Details",
          icon: Icons.work_outline,
          initiallyExpanded: _sectionExpansionStates[1],
          content:
              // ProfessionalDetailsSection()
              _buildProfessionalDetailsSection(),
        ),
        Divider(),
        // Religion Details
        ExpandableFilterSection(
          title: "Religion Details",
          icon: Icons.temple_hindu_outlined,
          initiallyExpanded: _sectionExpansionStates[2],
          content: _buildReligionDetailsSection(),
        ),
        Divider(),

        // Family Details
        ExpandableFilterSection(
          title: "Family Details",
          icon: Icons.family_restroom,
          initiallyExpanded: _sectionExpansionStates[3],
          content: _buildFamilyDetailsSection(),
        ),
        Divider(),

        // Location Details
        ExpandableFilterSection(
          title: "Location Details",
          icon: Icons.location_on_outlined,
          initiallyExpanded: _sectionExpansionStates[4],
          content: _buildLocationDetailsSection(),
        ),
        Divider(),

        // Lifestyle
        ExpandableFilterSection(
          title: "Lifestyle",
          icon: Icons.fitness_center_outlined,
          initiallyExpanded: _sectionExpansionStates[5],
          content: _buildLifestyleSection(),
        ),
        Divider(),

        // Profile Type
        ExpandableFilterSection(
          title: "Profile Type",
          icon: Icons.category_outlined,
          initiallyExpanded: _sectionExpansionStates[6],
          content: _buildProfileTypeSection(),
        ),
        Divider(),

        // Recently Created Profiles
        ExpandableFilterSection(
          title: "Recently Created Profiles",
          icon: Icons.access_time_outlined,
          initiallyExpanded: _sectionExpansionStates[7],
          content: _buildRecentlyCreatedSection(),
        ),

        SizedBox(height: 20),

        // Apply Button
        SizedBox(
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
              "Apply Filters",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBasicDetailsSection() {
    return Column(
      children: [
        // Age Range
        _buildRangeFilter(
          title: "Age",
          range: widget.controller.ageRange,
          min: 18,
          max: 60,
          unit: "years",
          onChanged: (range) {
            setState(() {
              widget.controller.ageRange = range;
            });
          },
        ),

        SizedBox(height: 16),

        SingleDropdown(
          label: "Profile Created by",
          controller: widget.controller.profileCreatedByCtrl,
          items: widget.controller.profileCreatedByList,
        ),

        SizedBox(height: 16),
        SelectableChipGroup(
          title: "Maritial  Status ",
          items: ["Any", "Divorced", "Widow", "Single", "Awaiting Divorce"],
          onSelectionChanged: (selected) {
            print(selected);
          },
        ),
        SizedBox(height: 16),

        SingleDropdown(
          label: "Mother Tongue",
          controller: widget.controller.mothertangueCtrl,
          items: widget.controller.languageList,
        ),
        SizedBox(height: 16),
        // Height Range
        _buildRangeFilter(
          title: "Height",
          range: widget.controller.heightRange,
          min: 140,
          max: 200,
          unit: "cm",
          onChanged: (range) {
            setState(() {
              widget.controller.heightRange = range;
            });
          },
        ),

        SizedBox(height: 16),
        SelectableChipGroup(
          title: "Physical  Status ",
          items: ["Normal", "Doesn't Matter", "Physically Challenged"],
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
          title: "Annual Income",
          range: widget.controller.ageRange,
          min: 20,
          max: 60,
          unit: "₹",
          onChanged: (range) {
            setState(() {
              widget.controller.ageRange = range;
            });
          },
        ),

        // _buildMultiSelectFilter(
        //   title: "Education",
        //   options: [
        //     'High School',
        //     'Bachelor\'s Degree',
        //     'Master\'s Degree',
        //     'PhD',
        //     'Diploma',
        //     'CA/CS/ICWA',
        //     'MBA',
        //     'Other'
        //   ],
        //   selectedOptions: widget.controller.education,
        //   onChanged: (selected) {
        //     setState(() {
        //       widget.controller.education = selected;
        //     });
        //   },
        // ),
        SingleDropdown(
          controller: widget.controller.educationCtrl,
          label: "Education",
          items: widget.controller.educationList,
        ),

        SizedBox(height: 20),

        RadioCheckboxList(
          title: "Employement Type",
          items: [
            "Any",
            "Business Owner",
            "Defence Sector",
            "Government / PSU,",
            "Private Sector",
            "Self Employed",
          ],
          onSelectionChanged: (selectedList) {
            print(selectedList);
          },
        ),

        SizedBox(height: 20),

        SelectableChipGroup(
          title: "Occupation",
          items: [
            "Any",
            "Airline",
            "Engineering",
            "IT & Software",
            "Civil Services",
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
                    "PREMIUM",
                    style: context.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    "To access these premium filters, UPGRADE NOW",
                    style: context.textTheme.bodyMedium,
                  ),
                ),

                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Profiles with horoscope",
                      style: context.textTheme.titleMedium,
                    ),
                    Icon(Icons.lock),
                  ],
                ),
                Text(
                  "Matches who have added horoscope",
                  style: context.textTheme.bodyLarge,
                ),
                SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Profiles with horoscope",
                      style: context.textTheme.titleMedium,
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
          title: "Manglik",
          items: ["Don't Know", "Yes", "Doesn't Matter", "No"],
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
          label: "Family Status",
          controller: widget.controller.familyStatusCtrl,
          items: widget.controller.familyList,
        ),

        SizedBox(height: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Family Type", style: Get.textTheme.titleMedium),
            const SizedBox(height: 16),

            Obx(
              () => Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                // () => GridView.count(
                //   crossAxisCount: 4,
                //   shrinkWrap: true,
                //   physics: const NeverScrollableScrollPhysics(),
                //   mainAxisSpacing: 16,
                //   childAspectRatio: 0.95,
                //   crossAxisSpacing: 12,
                children: [
                  _buildCircleOption(
                    title: "Nuclear",
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
                    title: "Joint",
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
                    title: "Doesn't matter",
                    icon: AppAssets.imgNull,
                    isSelected:
                        widget.controller.selectedDontShowOption.value ==
                        "viewed",
                    onTap: () {
                      widget.controller.selectedDontShowOption.value = "viewed";
                    },
                  ),

                  _buildCircleOption(
                    title: "Not Specified",
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
          title: "Family Value ",
          items: [
            "Liberal",
            "Moderate",
            "Traditional",
            "Doesn't Matter ",
            "Otherdox",
            "Not Specified",
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Nearby Profiles", style: Get.textTheme.titleMedium),
                SizedBox(height: 5),
                Text(
                  "Matches Near your location",
                  style: Get.textTheme.bodyMedium,
                ),
              ],
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
          label: "Country",
          controller: widget.controller.countryCtrl,
          items: widget.controller.countryList,
        ),
        SizedBox(height: 16),

        MultiCheckboxList(
          title: 'Citizenship:',
          items: [
            'Any',
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
          title: "Any",
          initialValue: widget.controller.isPrivate.value,
          onChanged: (val) => widget.controller.isPrivate.value = val,
        ),

        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Divider(),
        ),

        customToggleTile(
          title: "Eggetarian",
          initialValue: widget.controller.isPrivate.value,
          onChanged: (val) => widget.controller.isPrivate.value = val,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Divider(),
        ),

        customToggleTile(
          title: "Vegetarian",
          initialValue: widget.controller.isPrivate.value,
          onChanged: (val) => widget.controller.isPrivate.value = val,
        ),

        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Divider(),
        ),
        customToggleTile(
          title: "Non-Vegetarian",
          initialValue: widget.controller.isPrivate.value,
          onChanged: (val) => widget.controller.isPrivate.value = val,
        ),

        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Divider(),
        ),
        customToggleTile(
          title: "Not Specified",
          initialValue: widget.controller.isPrivate.value,
          onChanged: (val) => widget.controller.isPrivate.value = val,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Divider(),
        ),
        SingleDropdown(
          label: "Smoking Habits",
          controller: widget.controller.smokingCtrl,
          items: widget.controller.smokingHabits,
        ),

        SizedBox(height: 16),

        MultiCheckboxList(
          title: 'Drinking Habits:',
          items: [
            'Never',
            'Socially',
            'Regularly',
            'Not-Specified',
            "Dosen't Matter",
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
                  Text("Profile with Photo", style: Get.textTheme.titleMedium),
                  SizedBox(height: 5),
                  Text(
                    "Matches who have added photos",
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
            Text("Don't Show Profile", style: Get.textTheme.titleMedium),
            SizedBox(height: 12),

            // Options in a Column
            Obx(
              () => Column(
                children: [
                  _buildProfileOption(
                    title: "Ignored",
                    subtitle: "Profiles you have ignored",
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
                    title: "Shortlisted",
                    subtitle: "Profiles you have shortlisted",
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
                    title: "Already Viewed",
                    subtitle: "Profiles you have already seen",
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
                    title: "Already Contacted",
                    subtitle: "Profiles you have contacted",
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
    return Column(
      children: [
        // Created In Last
        SelectableChipGroup(
          title: "Profile Created",
          items: ["All", "Today", "Last 3 days", "One Week", "One month"],
          onSelectionChanged: (selected) {
            print(selected);
          },
        ),
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
