import 'package:edu_cluezer/core/routes/app_routes.dart';
import 'package:edu_cluezer/widgets/custom_buttons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/all_volunteer_controller.dart';
import '../controller/volunteerController.dart';
import '../data/model/res_all_volunteer_model.dart';

class VolunteerPage1 extends StatelessWidget {
  const VolunteerPage1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: context.theme.primaryColorLight,
        centerTitle: false,
        titleSpacing: 20,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Volunteer", style: context.textTheme.headlineMedium),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: CustomButton(
                  height: 45,
                  borderRadius: 14,
                  title: "My Volunteer Profile",
                  onPressed: () {
                    Get.toNamed(AppRoutes.volunteerProfile);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class VolunteerPage extends GetWidget<AllVolunteerController> {
  const VolunteerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Get.theme;

    return Scaffold(
      backgroundColor: Colors.grey[50], // Light background
      body: Column(
        children: [
          // 1. Custom Header Area
          Container(
            padding: const EdgeInsets.only(
              top: 50,
              left: 20,
              right: 20,
              bottom: 20,
            ),
            decoration: BoxDecoration(
              color: theme.primaryColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.primaryColor.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "community".tr,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "volunteers".tr,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.search, color: Colors.white),
                        onPressed: () {
                          Get.toNamed(AppRoutes.volunteerSearch);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // My Profile Banner (Embedded in Header for style)
                Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  elevation: 4,
                  shadowColor: Colors.black.withOpacity(0.1),
                  child: InkWell(
                    onTap: () => Get.toNamed(AppRoutes.volunteerProfile),
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: theme.primaryColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.person,
                              color: theme.primaryColor,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "my_volunteer_profile".tr,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.grey[800],
                                  ),
                                ),
                                Text(
                                  "manage_contributions".tr,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Colors.grey[400],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 2. List Content
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              // Show error state with retry option
              if (controller.hasError.value && controller.allVolunteerList.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 60,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "failed_to_load_volunteers".tr,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        controller.errorMessage.value,
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () => controller.fetchVolunteers(),
                        icon: const Icon(Icons.refresh),
                        label: Text("retry".tr),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              if (controller.filteredVolunteerList.isEmpty) {
                return RefreshIndicator(
                  onRefresh: () => controller.refreshVolunteers(),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.5,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.group_off_outlined,
                              size: 60,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "no_volunteers_found".tr,
                              style: TextStyle(color: Colors.grey[500]),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "pull_to_refresh".tr,
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () => controller.refreshVolunteers(),
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  itemCount:
                      controller.filteredVolunteerList.length +
                      1, // +1 for header title
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "available_volunteers".tr,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: theme.primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                "${controller.filteredVolunteerList.length} found".tr,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: theme.primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    final volunteer = controller.filteredVolunteerList[index - 1];
                    return VolunteerCard(
                      volunteer: volunteer,
                      onTap: () {
                        Get.toNamed(
                          AppRoutes.volunteerOpportunityDetails,
                          arguments: volunteer.id,
                        );
                      },
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// Volunteer Card Widget
class VolunteerCard extends StatelessWidget {
  final Volunteer volunteer;
  final VoidCallback onTap;

  const VolunteerCard({Key? key, required this.volunteer, required this.onTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                          volunteer.contactPerson
                                  ?.substring(0, 1)
                                  .toUpperCase() ??
                              "V",
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
                                  volunteer.contactPerson ?? "volunteer".tr,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              _buildStatusChip(volunteer.status ?? "offline".tr),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            volunteer.organization ?? "individual_volunteer".tr,
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
                        volunteer.location ?? "unknown_location".tr,
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.email_outlined,
                      size: 16,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        volunteer.contactEmail ?? "no_email".tr,
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
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

// Volunteer Data Model
// class Volunteer {
//   final String id;
//   final String name;
//   final String role;
//   final String profileImage;
//   final String location;
//   final double rating;
//   final int totalReviews;
//   final String experience;
//   final List<String> skills;
//   final String availability;
//   final int volunteerHours;
//   final List<String> causes;
//   final String bio;
//   final List<String> languages;
//   final DateTime joinDate;
//
//   Volunteer({
//     required this.id,
//     required this.name,
//     required this.role,
//     required this.profileImage,
//     required this.location,
//     required this.rating,
//     required this.totalReviews,
//     required this.experience,
//     required this.skills,
//     required this.availability,
//     required this.volunteerHours,
//     required this.causes,
//     required this.bio,
//     required this.languages,
//     required this.joinDate,
//   });
// }
//
// // Sample Static Data
// List<Volunteer> volunteers = [
//   Volunteer(
//     id: '1',
//     name: 'Sarah Johnson',
//     role: 'Community Organizer',
//     profileImage: 'https://randomuser.me/api/portraits/women/44.jpg',
//     location: 'New York, NY',
//     rating: 4.8,
//     totalReviews: 127,
//     experience: '3 years',
//     skills: ['Event Planning', 'Fundraising', 'Teaching', 'First Aid', 'Leadership'],
//     availability: 'Available',
//     volunteerHours: 240,
//     causes: ['Education', 'Environment', 'Healthcare'],
//     bio: 'Passionate about community service and environmental conservation.',
//     languages: ['English', 'Spanish'],
//     joinDate: DateTime(2022, 5, 15),
//   ),
//   Volunteer(
//     id: '2',
//     name: 'Michael Chen',
//     role: 'Tech Mentor',
//     profileImage: 'https://randomuser.me/api/portraits/men/32.jpg',
//     location: 'San Francisco, CA',
//     rating: 4.9,
//     totalReviews: 89,
//     experience: '5 years',
//     skills: ['Coding', 'Mentoring', 'Public Speaking', 'Python', 'Web Development'],
//     availability: 'Busy',
//     volunteerHours: 180,
//     causes: ['Education', 'Technology', 'Youth'],
//     bio: 'Helping underprivileged youth learn coding skills.',
//     languages: ['English', 'Mandarin'],
//     joinDate: DateTime(2021, 8, 22),
//   ),
//   Volunteer(
//     id: '3',
//     name: 'Priya Sharma',
//     role: 'Medical Volunteer',
//     profileImage: 'https://randomuser.me/api/portraits/women/67.jpg',
//     location: 'Chicago, IL',
//     rating: 4.7,
//     totalReviews: 56,
//     experience: '2 years',
//     skills: ['First Aid', 'Nursing', 'Counseling', 'Emergency Response'],
//     availability: 'Available',
//     volunteerHours: 320,
//     causes: ['Healthcare', 'Elderly Care', 'Disaster Relief'],
//     bio: 'Registered nurse volunteering in free health camps.',
//     languages: ['English', 'Hindi', 'Gujarati'],
//     joinDate: DateTime(2023, 1, 10),
//   ),
//   Volunteer(
//     id: '4',
//     name: 'David Wilson',
//     role: 'Animal Rescue',
//     profileImage: 'https://randomuser.me/api/portraits/men/55.jpg',
//     location: 'Austin, TX',
//     rating: 4.6,
//     totalReviews: 42,
//     experience: '4 years',
//     skills: ['Animal Care', 'Veterinary Assistance', 'Rescue Operations'],
//     availability: 'Limited',
//     volunteerHours: 150,
//     causes: ['Animal Welfare', 'Environment'],
//     bio: 'Dedicated to rescuing and rehabilitating animals.',
//     languages: ['English'],
//     joinDate: DateTime(2022, 3, 5),
//   ),
//   Volunteer(
//     id: '5',
//     name: 'Maria Garcia',
//     role: 'Food Bank Coordinator',
//     profileImage: 'https://randomuser.me/api/portraits/women/33.jpg',
//     location: 'Miami, FL',
//     rating: 4.5,
//     totalReviews: 78,
//     experience: '1 year',
//     skills: ['Logistics', 'Team Management', 'Food Safety', 'Spanish'],
//     availability: 'Available',
//     volunteerHours: 200,
//     causes: ['Hunger Relief', 'Community Development'],
//     bio: 'Organizing food distribution to families in need.',
//     languages: ['English', 'Spanish'],
//     joinDate: DateTime(2023, 6, 18),
//   ),
// ];

class VolunteerProfilePage extends GetView<VolunteerProfileController> {
  const VolunteerProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Get.theme;
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        leading: GestureDetector(
          onTap: Get.back,
          child: Icon(
            Icons.arrow_back_ios_rounded,
            color: Colors.black,
            size: 20,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          "volunteer_profile".tr,
          style: textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),

        actions: [
          Obx(() {
            return Row(
              children: [
                if (controller.profileData.value != null) ...[
                  IconButton(
                    onPressed: () {
                      Get.toNamed(
                        AppRoutes.volunteerCreateProfile,
                        arguments: {'isEdit': true},
                      );
                    },
                    icon: CircleAvatar(
                      radius: 16,
                      backgroundColor: colorScheme.primary.withOpacity(0.1),
                      child: Icon(Icons.edit, size: 16, color: colorScheme.primary),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ],
            );
          })
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final profile = controller.profileData.value;
        // Access user data from Auth Service via controller getter
        final userData = controller.volunteerData;

        if (profile == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.person_off_outlined,
                  size: 64,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 16),
                Text(
                  "profile_not_found".tr,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Get.toNamed(
                    AppRoutes.volunteerCreateProfile,
                    arguments: {'isEdit': false},
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child:  Text("create_profile".tr),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // 1. Profile Summary Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
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
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: colorScheme.primary.withOpacity(0.1),
                      child: Text(
                        userData['name']?.substring(0, 1).toUpperCase() ?? "V",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      userData['name'] ?? "volunteer".tr,
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "active_volunteer".tr,
                        style: textTheme.bodySmall?.copyWith(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 2. Info Grid (Experience, Availability, etc.)
              Row(
                children: [
                  Expanded(
                    child: _buildInfoCard(
                      label: "experience".tr,
                      value: profile.experience ?? "N/A",
                      icon: Icons.work_outline,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildInfoCard(
                      label: "availability".tr,
                      value: profile.availability ?? "N/A",
                      icon: Icons.access_time,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildLocationCard(profile.location ?? "N/A", Colors.redAccent),

              const SizedBox(height: 20),

              // 3. Bio Section
              _buildContentSection(
                title: "about_me".tr,
                icon: Icons.person_outline,
                child: Text(
                  profile.bio ?? "no_bio_added".tr,
                  style: TextStyle(
                    color: Colors.grey[700],
                    height: 1.5,
                    fontSize: 14,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 4. Skills Section
              _buildContentSection(
                title: "skills".tr,
                icon: Icons.star_outline,
                child: (profile.skills != null && profile.skills!.isNotEmpty)
                    ? Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: profile.skills!
                            .split(',')
                            .map(
                              (skill) =>
                                  _buildChip(skill.trim(), colorScheme.primary),
                            )
                            .toList(),
                      )
                    :  Text(
                        "no_skills_listed".tr,
                        style: TextStyle(color: Colors.grey),
                      ),
              ),

              const SizedBox(height: 16),

              // 5. Interests Section
              _buildContentSection(
                title: "interests".tr,
                icon: Icons.favorite_outline,
                child:
                    (profile.interests != null && profile.interests!.isNotEmpty)
                    ? Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: profile.interests!
                            .map(
                              (interest) => _buildChip(interest, Colors.pink),
                            )
                            .toList(),
                      )
                    :  Text(
                        "no_interests_listed".tr,
                        style: TextStyle(color: Colors.grey),
                      ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildInfoCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard(String location, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.location_on, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "location".tr,
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 2),
              Text(
                location,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContentSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: Colors.grey[700]),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          child,
        ],
      ),
    );
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
