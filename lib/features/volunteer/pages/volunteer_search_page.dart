import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:edu_cluezer/features/volunteer/controller/all_volunteer_controller.dart';
import 'package:edu_cluezer/features/volunteer/pages/volunteer_page.dart';
import 'package:edu_cluezer/features/volunteer/data/model/volunteer_profile_model.dart';

import '../data/model/res_all_volunteer_model.dart';

class VolunteerSearchPage extends StatelessWidget {
  const VolunteerSearchPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    
    return GetBuilder<AllVolunteerController>(
      init: Get.find<AllVolunteerController>(),
      builder: (controller) {
        // Clear search text when entering this page
        WidgetsBinding.instance.addPostFrameCallback((_) {
          controller.searchText.value = "";
          controller.searchResults.clear();
        });

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Get.back(),
            ),
            title: Row(
              children: [
                Expanded(
                  child: TextField(
                    autofocus: true,
                    onChanged: (value) => controller.searchText.value = value,
                    decoration: InputDecoration(
                      hintText: "search_volunteers".tr,
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      border: InputBorder.none,
                    ),
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                Obx(() => controller.isSearching.value
                    ? Container(
                        margin: const EdgeInsets.only(left: 8),
                        width: 16,
                        height: 16,
                        child: const CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const SizedBox.shrink()),
              ],
            ),
            actions: [
              Obx(() => controller.searchText.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.black, size: 20),
                      onPressed: () {
                        controller.searchText.value = "";
                        controller.searchResults.clear();
                      },
                    )
                  : const SizedBox.shrink()),
            ],
          ),
          body: Obx(() {
            // Show loading state only when initially loading (not during search)
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            // Determine which list to show
            List<dynamic> displayList;
            if (controller.searchText.isEmpty) {
              // Show all volunteers when no search text
              displayList = controller.allVolunteerList;
            } else {
              // Show search results when searching
              displayList = controller.searchResults;
            }

            if (displayList.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      controller.searchText.isEmpty ? Icons.people_outline : Icons.search_off,
                      size: 64,
                      color: Colors.grey[300],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      controller.searchText.isEmpty
                          ? "no_volunteers_available".tr
                          : "no_volunteers_found".tr,
                      style: TextStyle(color: Colors.grey[500], fontSize: 16),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: displayList.length,
              itemBuilder: (context, index) {
                final item = displayList[index];
                
                // Check if it's a search result (VolunteerSearchProfile) or regular volunteer (Volunteer)
                if (controller.searchText.isEmpty) {
                  // Show regular volunteer opportunities
                  final volunteer = item as Volunteer;
                  return VolunteerCard(
                    volunteer: volunteer,
                    onTap: () {
                      Get.toNamed('/volunteerOpportunityDetails', arguments: volunteer);
                    },
                  );
                } else {
                  // Show volunteer search profiles
                  final volunteerProfile = item as VolunteerSearchProfile;
                  return VolunteerProfileCard(
                    volunteerProfile: volunteerProfile,
                    onTap: () {
                      // Navigate to volunteer profile details
                      // You can implement this navigation as needed
                    },
                  );
                }
              },
            );
          }),
        );
      },
    );
  }
}

// New card widget for volunteer search profiles
class VolunteerProfileCard extends StatelessWidget {
  final VolunteerSearchProfile volunteerProfile;
  final VoidCallback onTap;

  const VolunteerProfileCard({
    Key? key,
    required this.volunteerProfile,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = volunteerProfile.user;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          user?.name?.substring(0, 1).toUpperCase() ?? "V",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: theme.primaryColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  user?.name ?? "Volunteer",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              _buildStatusChip(volunteerProfile.status ?? "active"),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user?.occupation ?? "Volunteer",
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                if (volunteerProfile.bio != null && volunteerProfile.bio!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    volunteerProfile.bio!,
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1),
                ),

                // Details Row
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        volunteerProfile.location ?? "Unknown location",
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.work_outline,
                      size: 16,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        volunteerProfile.experience ?? "No experience",
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                if (volunteerProfile.skills != null && volunteerProfile.skills!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: volunteerProfile.skills!
                        .split(',')
                        .take(3)
                        .map((skill) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: theme.primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                skill.trim(),
                                style: TextStyle(
                                  color: theme.primaryColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'active':
        color = Colors.green;
        break;
      case 'busy':
        color = Colors.orange;
        break;
      case 'offline':
        color = Colors.grey;
        break;
      default:
        color = Colors.blue;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
