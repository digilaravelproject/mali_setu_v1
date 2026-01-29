import 'package:edu_cluezer/core/constent/api_constants.dart';
import 'package:edu_cluezer/features/matrimony/data/model/search_matrimony_response.dart';
import 'package:edu_cluezer/features/matrimony/presentation/controller/matrimony_details_controller.dart';
import 'package:edu_cluezer/widgets/custom_image_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MatrimonyProfileScreen extends GetView<MatrimonyDetailsController> {
  const MatrimonyProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.profile.value == null) {
          return const Center(child: Text("Profile not found"));
        }

        final profile = controller.profile.value!;
        return Stack(
          children: [
            CustomScrollView(
              slivers: [
                _buildProfileHeader(context, profile),
                _buildProfileContent(context, profile),
                const SliverToBoxAdapter(child: SizedBox(height: 100)), // Space for bottom bar
              ],
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildBottomBar(context, profile),
            ),
          ],
        );
      }),
    );
  }

  SliverAppBar _buildProfileHeader(BuildContext context, MatrimonyProfile profile) {
    final images = profile.personalDetails?.photos ?? [];
    return SliverAppBar(
      expandedHeight: 450,
      pinned: true,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (images.isNotEmpty)
              PageView.builder(
                itemCount: images.length,
                itemBuilder: (context, index) {
                  return CustomImageView(
                    url: "${ApiConstants.imageBaseUrl}${images[index]}",
                    fit: BoxFit.cover,
                  );
                },
              )
            else
              Container(
                color: Colors.grey[300],
                child: const Icon(Icons.person, size: 100, color: Colors.grey),
              ),
            // Gradient Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.transparent,
                    Colors.black.withOpacity(0.8),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
            // Header Info
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${profile.personalDetails?.name ?? 'Unknown'}, ${profile.age ?? ''}',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                      if (profile.status == 'active')
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.check_circle, color: Colors.white, size: 14),
                              SizedBox(width: 4),
                              Text(
                                "Verified",
                                style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    profile.professionalDetails?.jobTitle ?? 'Designation Not Added',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: Colors.white70),
                      const SizedBox(width: 4),
                      Text(
                        "${profile.locationDetails?.city ?? ''}, ${profile.locationDetails?.state ?? ''}",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  SliverList _buildProfileContent(BuildContext context, MatrimonyProfile profile) {
    return SliverList(
      delegate: SliverChildListDelegate([
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildSectionCard(
                context,
                title: 'Basic Information',
                icon: Icons.person_outline,
                children: [
                  _buildInfoRow('Marital Status', profile.personalDetails?.maritalStatus ?? '-'),
                  _buildInfoRow('Religion', (profile.personalDetails?.religion ?? []).join(", ")),
                  _buildInfoRow('Caste', "General"), // Example: Add caste field if available
                  _buildInfoRow('Height', profile.height ?? '-'),
                  _buildInfoRow('Weight', profile.weight ?? '-'),
                  _buildInfoRow('Complexion', profile.complexion ?? '-'),
                ],
              ),
              const SizedBox(height: 16),
              _buildSectionCard(
                context,
                title: 'Professional Details',
                icon: Icons.work_outline,
                children: [
                  _buildInfoRow('Occupation', profile.personalDetails?.occupation ?? '-'),
                  _buildInfoRow('Employer', profile.professionalDetails?.company ?? '-'), // Added Company
                  _buildInfoRow('Annual Income', "₹ ${profile.personalDetails?.annualIncome ?? '-'}"),
                ],
              ),
              const SizedBox(height: 16),
              _buildSectionCard(
                context,
                title: 'Education',
                icon: Icons.school_outlined,
                children: [
                  _buildInfoRow('Highest Degree', profile.educationDetails?.highestQualification ?? '-'),
                  _buildInfoRow('College/University', profile.educationDetails?.college ?? '-'), // Added College
                ],
              ),
              const SizedBox(height: 16),
              _buildSectionCard(
                context,
                title: 'Family Details',
                icon: Icons.family_restroom,
                children: [
                  _buildInfoRow('Father', profile.familyDetails?.father ?? '-'),
                  _buildInfoRow('Mother', profile.familyDetails?.mother ?? '-'),
                  _buildInfoRow('Family Type', profile.personalDetails?.familyType ?? '-'),
                  _buildInfoRow('Family Value', profile.familyDetails?.familyValue ?? '-'),
                  _buildInfoRow('Family Status', profile.familyDetails?.familyClass ?? '-'), // Added Family Class
                ],
              ),
              const SizedBox(height: 16),
              _buildSectionCard(
                context,
                title: 'Lifestyle',
                icon: Icons.local_dining,
                children: [
                  _buildInfoRow('Diet', profile.lifestyleDetails?.diet ?? '-'),
                  _buildInfoRow('Smoking', profile.lifestyleDetails?.smoking ?? '-'),
                  _buildInfoRow('Drinking', profile.lifestyleDetails?.drinking ?? '-'), // Added Drinking
                ],
              ),
              const SizedBox(height: 16),
              if (profile.partnerPreferences != null)
                _buildSectionCard(
                  context,
                  title: 'Partner Preferences',
                  icon: Icons.favorite_border,
                  children: [
                    _buildInfoRow('Age Range', profile.partnerPreferences?.ageRange ?? '-'),
                    _buildInfoRow('Education', profile.partnerPreferences?.education ?? '-'),
                    _buildInfoRow('Location', profile.partnerPreferences?.location ?? '-'),
                  ],
                ),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _buildSectionCard(BuildContext context, {required String title, required IconData icon, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: Colors.purple, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, MatrimonyProfile profile) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          // Expanded(
          //   child: OutlinedButton(
          //     onPressed: () {},
          //     style: OutlinedButton.styleFrom(
          //       padding: const EdgeInsets.symmetric(vertical: 16),
          //       side: const BorderSide(color: Colors.purple),
          //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          //     ),
          //     child: const Text("Shortlist", style: TextStyle(color: Colors.purple, fontWeight: FontWeight.bold)),
          //   ),
          // ),
          // const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: Obx(() {
              final status = profile.connectionStatus?.toLowerCase();
              String buttonText = "Send Connection Request";
              bool isActionable = true;
              Color buttonColor = Colors.purple;
              VoidCallback? onPressed = controller.sendRequest;

              if (status == "pending") {
                buttonText = "Request Sent";
                isActionable = false;
                buttonColor = Colors.grey;
                onPressed = null;
              } else if (status == "accepted") {
                buttonText = "Start Chat";
                isActionable = true;
                buttonColor = Colors.green;
                onPressed = () {
                   Get.snackbar("Chat", "Chat feature is coming soon!");
                };
              }

              return ElevatedButton(
                onPressed: controller.isLoading.value ? null : onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: controller.isLoading.value
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : Text(buttonText, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              );
            }),
          ),
        ],
      ),
    );
  }
}