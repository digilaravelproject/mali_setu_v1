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
              Text(
                  "Volunteer",
                  style: context.textTheme.headlineMedium
              ),
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
                   title: "My Volunteer Profile", onPressed: (){
                 Get.toNamed(AppRoutes.volunteerProfile);
               }),
             ),
           )
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
            Text(
              "Volunteer",
              style: context.textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Button
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

            // Volunteer List Header


            // Volunteer List
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            //   child: ListView.builder(
            //     shrinkWrap: true,
            //     physics: NeverScrollableScrollPhysics(),
            //     itemCount: controller.allVolunteerList.length,
            //     itemBuilder: (context, index) {
            //       return VolunteerCard(
            //         volunteer: controller.allVolunteerList[index],
            //         onTap: () {
            //           // Navigate to volunteer details
            //         },
            //       );
            //     },
            //   ),
            // ),
            Obx(() {
              if (controller.isLoading.value) {
                return Center(child: CircularProgressIndicator());
              }

              if (controller.allVolunteerList.isEmpty) {
                return Center(child: Text("No Volunteers Available"));
              }

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Available Volunteers",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            controller.allVolunteerList.length.toString(),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue[800],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: controller.allVolunteerList.length,
                    itemBuilder: (context, index) {
                      return VolunteerCard(
                        volunteer: controller.allVolunteerList[index], // ✅ DATA SET
                        onTap: () {
                          Get.toNamed(
                            AppRoutes.volunteerOpportunityDetails,
                            arguments: controller.allVolunteerList[index].id,
                          );
                        },
                      );
                    },
                  ),
                ],
              );
            })

          ],
        ),
      ),
    );
  }
}

// Volunteer Card Widget
class VolunteerCard extends StatelessWidget {
  final Volunteer volunteer;
  final VoidCallback onTap;

  const VolunteerCard({
    Key? key,
    required this.volunteer,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Volunteer Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Image
                  // Container(
                  //   width: 60,
                  //   height: 60,
                  //   decoration: BoxDecoration(
                  //     shape: BoxShape.circle,
                  //     image: DecorationImage(
                  //       image: NetworkImage(volunteer.profileImage),
                  //       fit: BoxFit.cover,
                  //     ),
                  //     border: Border.all(
                  //       color: Colors.blue[100]!,
                  //       width: 2,
                  //     ),
                  //   ),
                  // ),
                  SizedBox(width: 16),

                  // Volunteer Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              volunteer.contactPerson.toString(),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getAvailabilityColor(volunteer.status.toString()),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                volunteer.status.toString(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Text(
                          volunteer.contactEmail.toString(),
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          volunteer.organization.toString(),
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: 8),

                        // Rating and Experience
                        // Wrap(
                        //   crossAxisAlignment: WrapCrossAlignment.center,
                        //   spacing: 8,
                        //   runSpacing: 4,
                        //   children: [
                        //     Row(
                        //       mainAxisSize: MainAxisSize.min,
                        //       children: [
                        //         Icon(Icons.star, size: 16, color: Colors.amber),
                        //         SizedBox(width: 4),
                        //         // Text(
                        //         //   '${volunteer.rating} (${volunteer.totalReviews})',
                        //         //   style: TextStyle(fontSize: 13),
                        //         // ),
                        //       ],
                        //     ),
                        //     Row(
                        //       mainAxisSize: MainAxisSize.min,
                        //       children: [
                        //         Icon(Icons.work_history,
                        //             size: 16, color: Colors.blue),
                        //         SizedBox(width: 4),
                        //         Text(
                        //           '${volunteer.experience} experience',
                        //           style: TextStyle(fontSize: 13),
                        //         ),
                        //       ],
                        //     ),
                        //   ],
                        // ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 16),

              // Skills
              // Wrap(
              //   spacing: 8,
              //   runSpacing: 8,
              //   children: volunteer.skills
              //       .take(4)
              //       .map((skill) => Container(
              //     padding: EdgeInsets.symmetric(
              //       horizontal: 10,
              //       vertical: 5,
              //     ),
              //     decoration: BoxDecoration(
              //       color: Colors.grey[100],
              //       borderRadius: BorderRadius.circular(20),
              //     ),
              //     child: Text(
              //       skill,
              //       style: TextStyle(
              //         fontSize: 12,
              //         color: Colors.grey[800],
              //       ),
              //     ),
              //   ))
              //       .toList(),
              // ),

             // SizedBox(height: 16),

              // Footer with Location and Hours
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                      SizedBox(width: 4),
                      Text(
                        volunteer.location.toString(),
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  // Row(
                  //   children: [
                  //     Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                  //     SizedBox(width: 4),
                  //     // Text(
                  //     //   '${volunteer.volunteerHours} hours',
                  //     //   style: TextStyle(
                  //     //     fontSize: 13,
                  //     //     color: Colors.grey[600],
                  //     //   ),
                  //     // ),
                  //   ],
                  // ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getAvailabilityColor(String availability) {
    switch (availability.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'busy':
        return Colors.orange;
      case 'offline':
        return Colors.grey;
      case 'limited':
        return Colors.blue;
      default:
        return Colors.grey;
    }
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
      appBar: AppBar(
        leading: GestureDetector(
          onTap: Get.back,
          child: Icon(Icons.arrow_back_ios_rounded, color: context.iconColor),
        ),
        actions: [
          InkWell(
            onTap: (){
              Get.toNamed(AppRoutes.volunteerCreateProfile, arguments: {'isEdit': true});
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(Icons.edit, size: 20, color: colorScheme.primary),
            ),
          ),
        ],
        title: Text("Volunteer Profile", style: context.textTheme.headlineLarge),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final profile = controller.profileData.value;

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // Profile Header
              // _buildProfileHeader(theme, colorScheme),
              //
              // // Stats Cards
              // _buildStatsCards(colorScheme),

              // All Sections
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // About Me
                    _buildSection(
                      title: 'Bio',
                      icon: Icons.person_outline,
                      colorScheme: colorScheme,
                      child: _buildAboutMeSection(textTheme),
                    ),

                    const SizedBox(height: 16),

                    // Skills
                    _buildSection(
                      title: 'Skills',
                      icon: Icons.star_outline,
                      colorScheme: colorScheme,
                      child: _buildSkillsSection(),
                    ),

                    const SizedBox(height: 16),

                    Container(
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildAvailabilityRow(
                              label: 'Experience',
                              value: profile?.experience ?? "Not specified",
                              icon: Icons.work_outline,
                            ),
                            const SizedBox(height: 8),
                            _buildAvailabilityRow(
                              label: 'Availability',
                              value: profile?.availability ?? "Not specified",
                              icon: Icons.calendar_today_rounded,
                            ),
                            const SizedBox(height: 8),
                            _buildAvailabilityRow(
                              label: 'Location',
                              value: profile?.location ?? "Not specified",
                              icon: Icons.location_on_outlined,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Interests
                    _buildSection(
                      title: 'Interests',
                      icon: Icons.favorite_outline,
                      colorScheme: colorScheme,
                      child: _buildInterestsSection(),
                    ),

                    const SizedBox(height: 16),

                    // Profile Status
                    _buildProfileStatusSection(colorScheme, textTheme),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildProfileHeader(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
      ),
      child: Column(
        children: [
          // Profile Image and Status
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colorScheme.primary,
                    width: 3,
                  ),
                  image: DecorationImage(
                    image: NetworkImage(controller.volunteerData['profileImage']!),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: controller.getStatusColor(),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(
                  Icons.check,
                  size: 14,
                  color: Colors.white,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Name and Role
          Text(
            controller.volunteerData['name']!,
            style: Get.theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            controller.volunteerData['role']!,
            style: Get.textTheme.titleMedium?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 8),

          InkWell(
            onTap: (){
              Get.toNamed(AppRoutes.volunteerCreateProfile, arguments: {'isEdit': true});
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: colorScheme.primary.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.edit_outlined, size: 16, color: colorScheme.primary),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () {
                      // Navigate to Edit Profile Screen

                    },
                    child: Text(
                      'Edit Profile',
                      style: Get.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.calendar_month_outlined,
                  size: 16, color: colorScheme.onSurface.withOpacity(0.6)),
              const SizedBox(width: 6),
              Text(
                'Member since ${controller.volunteerData['joinDate']!}',
                style: Get.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(color: Colors.grey.shade200),
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: [
          _buildStatCard(
            title: 'Total Hours',
            value: controller.volunteerData['totalHours']!,
            icon: Icons.access_time,
            color: colorScheme.primary,
          ),
          const SizedBox(width: 12),
          _buildStatCard(
            title: 'Projects',
            value: controller.volunteerData['completedProjects']!,
            icon: Icons.assignment_turned_in,
            color: Colors.green,
          ),
          const SizedBox(width: 12),
          _buildStatCard(
            title: 'Rating',
            value: controller.volunteerData['rating']!,
            icon: Icons.star,
            color: Colors.amber,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 18, color: color),
                const SizedBox(width: 6),
                Text(
                  value,
                  style: Get.theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Get.theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required ColorScheme colorScheme,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, size: 20, color: colorScheme.primary),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: Get.theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),

          // Divider
          Container(
            height: 1,
            color: Colors.grey.shade200,
          ),

          // Section Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildAboutMeSection(TextTheme textTheme) {
    return Text(
      controller.aboutMe,
      style: textTheme.bodyLarge?.copyWith(
        color: Get.theme.colorScheme.onSurface.withOpacity(0.8),
        height: 1.6,
      ),
    );
  }

  Widget _buildSkillsSection() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: controller.skillList.map((skill) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Get.theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Get.theme.colorScheme.primary.withOpacity(0.2),
            ),
          ),
          child: Text(
            skill,
            style: Get.theme.textTheme.bodyMedium?.copyWith(
              color: Get.theme.colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildExperienceSection(TextTheme textTheme) {
    return Column(
      children: controller.experiences.map((exp) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      exp['title']!,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Get.theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  Text(
                    exp['duration']!,
                    style: textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                exp['organization']!,
                style: textTheme.bodyMedium?.copyWith(
                  color: Get.theme.colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                exp['description']!,
                style: textTheme.bodyMedium?.copyWith(
                  color: Get.theme.colorScheme.onSurface.withOpacity(0.7),
                  height: 1.5,
                ),
              ),
              if (exp != controller.experiences.last)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Divider(color: Colors.grey.shade200, height: 1),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAvailabilitySection() {
    return Column(
      children: [
        _buildAvailabilityRow(
          label: 'Weekdays',
          value: controller.availability['weekdays']!,
          icon: Icons.work_outline,
        ),
        const SizedBox(height: 12),
        _buildAvailabilityRow(
          label: 'Weekends',
          value: controller.availability['weekends']!,
          icon: Icons.weekend_outlined,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildAvailabilityRow(
                label: 'Remote Work',
                value: controller.availability['remote']!,
                icon: Icons.computer_outlined,
                compact: true,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildAvailabilityRow(
                label: 'On-site',
                value: controller.availability['onSite']!,
                icon: Icons.location_on_outlined,
                compact: true,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAvailabilityRow({
    required String label,
    required String value,
    required IconData icon,
    bool compact = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Get.theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Get.theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Get.theme.textTheme.bodyMedium?.copyWith(
                    color: Get.theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                    fontSize: compact ? 12 : 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInterestsSection() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: controller.interestList.map((interest) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.green.shade100),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.favorite_border, size: 16, color: Colors.green),
              const SizedBox(width: 6),
              Text(
                interest,
                style: Get.theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.green.shade800,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildProfileStatusSection(ColorScheme colorScheme, TextTheme textTheme) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with toggle
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.verified_outlined, size: 20, color: colorScheme.primary),
                    const SizedBox(width: 10),
                    Text(
                      'Profile Status',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: controller.toggleStatus,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: controller.getStatusColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: controller.getStatusColor().withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: controller.getStatusColor(),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'status',
                          style: textTheme.bodyMedium?.copyWith(
                            color: controller.getStatusColor(),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Divider
          Container(height: 1, color: Colors.grey.shade200),

          // Status Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Last Active
                _buildStatusDetailRow(
                  icon: Icons.timelapse_outlined,
                  label: 'Last Active',
                  value: "lastActive",
                ),
                const SizedBox(height: 12),

                // Verification Status
                _buildStatusDetailRow(
                  icon: Icons.verified_user_outlined,
                  label: 'Verification',
                  value: controller.profileStatus['verified'] != null ? 'Verified' : 'Not Verified',
                  valueColor: controller.profileStatus['verified']!=null ? Colors.green : Colors.orange,
                ),
                const SizedBox(height: 16),

                // Badges
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Badges & Achievements',
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),

                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusDetailRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: Get.theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: Get.theme.textTheme.bodyMedium?.copyWith(
            color: valueColor ?? Get.theme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
