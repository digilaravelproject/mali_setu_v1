import 'package:edu_cluezer/core/routes/app_routes.dart';
import 'package:edu_cluezer/core/constent/api_constants.dart';
import 'package:edu_cluezer/core/styles/app_colors.dart';
import 'package:edu_cluezer/features/matrimony/data/model/search_matrimony_response.dart';
import 'package:edu_cluezer/features/matrimony/presentation/controller/matrimony_details_controller.dart';
import 'package:edu_cluezer/features/matrimony/presentation/controller/matrimony_controller.dart';
import 'package:edu_cluezer/features/matrimony/presentation/controller/matrimony_members_controller.dart';
import 'package:edu_cluezer/features/matrimony/presentation/controller/matrimony_requests_controller.dart';
import 'package:edu_cluezer/widgets/custom_image_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:edu_cluezer/features/Auth/service/auth_service.dart';
import 'package:edu_cluezer/core/widgets/whatsapp_support_fab.dart';
import 'package:edu_cluezer/widgets/custom_snack_bar.dart';

class MatrimonyProfileScreen extends StatefulWidget {
  final int? profileId;
  const MatrimonyProfileScreen({super.key, this.profileId});

  @override
  State<MatrimonyProfileScreen> createState() => _MatrimonyProfileScreenState();
}

class _MatrimonyProfileScreenState extends State<MatrimonyProfileScreen> {
  late final MatrimonyDetailsController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<MatrimonyDetailsController>()
        ? Get.find<MatrimonyDetailsController>()
        : Get.put(MatrimonyDetailsController());

    final args = Get.arguments;
    final int? targetId = widget.profileId ??
        (args is Map
            ? (args['id'] is int ? args['id'] as int : int.tryParse(args['id']?.toString() ?? ''))
            : (args is int ? args : null));

    if (targetId != null) {
      if (controller.profile.value == null ||
          (controller.profile.value!.userId != targetId && controller.profile.value!.id != targetId)) {
        controller.fetchProfileDetails(targetId);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      floatingActionButton: const WhatsAppSupportFab(bottomPadding: 75),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.profile.value == null) {
          return  Center(child: Text("profile_not_found".tr));
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
      expandedHeight: 350,
      pinned: true,
      backgroundColor: Colors.transparent,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CircleAvatar(
          backgroundColor: Colors.black.withOpacity(0.4),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
            padding: EdgeInsets.zero,
            onPressed: () => Get.back(),
          ),
        ),
      ),
      actions: [
        if (images.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Center(
              child: GestureDetector(
                onTap: () {
                  final List<String> imageUrls = images.map((img) {
                    if (img.startsWith("http")) return img;
                    return "${ApiConstants.imageBaseUrl}$img";
                  }).toList();

                  Get.to(() => ImageFvScreen(
                    imageUrls: imageUrls,
                    initialIndex: controller.currentImageIndex.value,
                  ));
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.45),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.35),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.fullscreen_rounded, color: Colors.white, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        "full_view".tr,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.only(right: 6),
          child: Center(
            child: CircleAvatar(
              backgroundColor: Colors.black.withOpacity(0.45),
              radius: 17,
              child: IconButton(
                icon: const Icon(Icons.flag_outlined, color: Colors.white, size: 18),
                tooltip: 'report_profile'.tr,
                padding: EdgeInsets.zero,
                onPressed: () => _showReportBottomSheet(context, profile),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Center(
            child: CircleAvatar(
              backgroundColor: Colors.black.withOpacity(0.45),
              radius: 17,
              child: IconButton(
                icon: const Icon(Icons.block_outlined, color: Colors.white, size: 18),
                tooltip: 'block_user'.tr,
                padding: EdgeInsets.zero,
                onPressed: () => _showBlockDialog(context, profile),
              ),
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (images.isNotEmpty)
              PageView.builder(
                controller: controller.pageController,
                itemCount: images.length,
                onPageChanged: (index) {
                  controller.currentImageIndex.value = index;
                },
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      final List<String> imageUrls = images.map((img) {
                        if (img.startsWith("http")) return img;
                        return "${ApiConstants.imageBaseUrl}$img";
                      }).toList();

                      Get.to(() => ImageFvScreen(
                        imageUrls: imageUrls,
                        initialIndex: index,
                      ));
                    },
                    child: CustomImageView(
                      url: images[index],
                      fit: BoxFit.cover,
                    ),
                  );
                },
              )
            else
              Container(
                color: Colors.grey[300],
                child: const Icon(Icons.person, size: 100, color: Colors.grey),
              ),
            // Gradient Overlay
            IgnorePointer(
              child: Container(
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
            ),



            if (images.length > 1)
              Positioned(
                bottom: 120,
                left: 0,
                right: 0,
                child: Obx(() => Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(images.length, (index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: controller.currentImageIndex.value == index
                            ? Colors.white
                            : Colors.white.withOpacity(0.4),
                      ),
                    );
                  }),
                )),
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
                          child:  Row(
                            children: [
                              Icon(Icons.check_circle, color: Colors.white, size: 14),
                              SizedBox(width: 4),
                              Text(
                                "verified".tr,
                                style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    profile.professionalDetails?.jobTitle ?? 'designation_not_added'.tr,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: Colors.white70),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          "${profile.locationDetails?.city ?? ''}, ${profile.locationDetails?.state ?? ''}",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
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
                title: 'basic_information'.tr,
                icon: Icons.person_outline,
                children: [
                  _buildInfoRow('marital_status'.tr, profile.personalDetails?.maritalStatus ?? '-'),
                  _buildInfoRow('religion'.tr, (profile.personalDetails?.religion ?? []).join(", ")),
                //  _buildInfoRow('Caste', "General"), // Example: Add caste field if available
                  _buildInfoRow('height'.tr, profile.height ?? '-'),
                  _buildInfoRow('weight'.tr, profile.weight ?? '-'),
                  _buildInfoRow('complexion'.tr, profile.complexion ?? '-'),
                ],
              ),
              const SizedBox(height: 16),
              _buildSectionCard(
                context,
                title: 'professional_details'.tr,
                icon: Icons.work_outline,
                children: [
                  _buildInfoRow('occupation'.tr, profile.personalDetails?.occupation ?? '-'),
                  _buildInfoRow('company_name'.tr, profile.professionalDetails?.company ?? '-'), // Added Company
                  _buildInfoRow('annual_income'.tr, " ${profile.personalDetails?.annualIncome ?? '-'} Lac"),
                ],
              ),
              const SizedBox(height: 16),
              _buildSectionCard(
                context,
                title: 'education'.tr,
                icon: Icons.school_outlined,
                children: [
                  _buildInfoRow('highest_qualification'.tr, profile.educationDetails?.highestQualification ?? '-'),
                  _buildInfoRow('college'.tr, profile.educationDetails?.college ?? '-'), // Added College
                ],
              ),
              const SizedBox(height: 16),
              _buildSectionCard(
                context,
                title: 'family_details'.tr,
                icon: Icons.family_restroom,
                children: [
                  _buildInfoRow('father'.tr, profile.familyDetails?.father ?? '-'),
                  _buildInfoRow('mother'.tr, profile.familyDetails?.mother ?? '-'),
                  _buildInfoRow('family_type'.tr, profile.personalDetails?.familyType ?? '-'),
                  _buildInfoRow('family_value'.tr, profile.familyDetails?.familyValue ?? '-'),
                  _buildInfoRow('family_class'.tr, profile.familyDetails?.familyClass ?? '-'), // Added Family Class
                ],
              ),
              const SizedBox(height: 16),
              _buildSectionCard(
                context,
                title: 'lifestyle'.tr,
                icon: Icons.local_dining,
                children: [
                  _buildInfoRow('diet'.tr, profile.lifestyleDetails?.diet ?? '-'),
                  _buildInfoRow('smoking'.tr, profile.lifestyleDetails?.smoking ?? '-'),
                  _buildInfoRow('drinking'.tr, profile.lifestyleDetails?.drinking ?? '-'), // Added Drinking
                ],
              ),
              const SizedBox(height: 16),
              if (profile.partnerPreferences != null || profile.personalDetails?.dob != null)
                _buildSectionCard(
                  context,
                  title: 'partner_preferences'.tr,
                  icon: Icons.favorite_border,
                  children: [
                    _buildInfoRow(
                      'date_of_birth'.tr,
                      _formatDob(profile.personalDetails?.dob?.isNotEmpty == true
                          ? profile.personalDetails!.dob
                          : profile.user?.dob),
                    ),
                    _buildInfoRow(
                      'education_career'.tr,
                      profile.educationDetails?.highestQualification?.isNotEmpty == true
                          ? profile.educationDetails!.highestQualification!
                          : (profile.partnerPreferences?.education ?? '-'),
                    ),
                  //  _buildInfoRow('Location', profile.partnerPreferences?.location ?? '-'),
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

  String _formatDob(String? dob) {
    if (dob == null || dob.trim().isEmpty) return '-';
    try {
      final trimmed = dob.trim();
      if (trimmed.contains('/')) {
        return trimmed;
      }
      final parsed = DateTime.tryParse(trimmed);
      if (parsed != null) {
        return "${parsed.day.toString().padLeft(2, '0')}/${parsed.month.toString().padLeft(2, '0')}/${parsed.year}";
      }
      return trimmed;
    } catch (_) {
      return dob;
    }
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
    return Obx(() {
      final authService = Get.find<AuthService>();
      final currentUser = authService.currentUser.value;
      final isOwnProfile = profile.user?.id == currentUser?.id || profile.userId == currentUser?.id;
      final isSending = controller.isSendingRequest.value;
      final currentProfile = controller.profile.value ?? profile;

      return SafeArea(
        top: false, // only care about bottom
        child: Container(
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
              Expanded(
                flex: 2,
                child: isOwnProfile
                    ? ElevatedButton(
                        onPressed: () {
                          Get.toNamed(AppRoutes.regMatrimony, arguments: true);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          "edit_profile".tr,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      )
                    : () {
                        final status = currentProfile.connectionStatus?.toLowerCase();
                        String buttonText = "send_connection_request".tr;
                        Color buttonColor = Colors.purple;
                        VoidCallback? onPressed = controller.sendRequest;

                        if (status == "pending") {
                          buttonText = "request_sent".tr;
                          buttonColor = Colors.grey;
                          onPressed = null;
                        } else if (status == "accepted") {
                          buttonText = "start_chat".tr;
                          buttonColor = Colors.green;
                          onPressed = () {
                            Get.toNamed(AppRoutes.matrimonyChat, arguments: {
                              'conversation_id': currentProfile.conversationId,
                              'other_user_id': currentProfile.user?.id ?? currentProfile.userId,
                              'user_name': currentProfile.personalDetails?.name?.toString() ?? '',
                            });
                          };
                        }

                        return ElevatedButton(
                          onPressed: (isSending || status == "pending") ? null : onPressed,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: buttonColor,
                            disabledBackgroundColor: isSending ? buttonColor : Colors.grey.shade400,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: isSending
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : Text(
                                  buttonText,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                        );
                      }(),
              ),
            ],
          ),
        ),
      );
    });
  }

  void _showReportBottomSheet(BuildContext context, MatrimonyProfile profile) {
    final reasons = [
      {'key': 'fake_profile', 'title': 'report_reason_fake'.tr},
      {'key': 'inappropriate_content', 'title': 'report_reason_inappropriate'.tr},
      {'key': 'harassment', 'title': 'report_reason_harassment'.tr},
      {'key': 'spam', 'title': 'report_reason_spam'.tr},
      {'key': 'other', 'title': 'report_reason_other'.tr},
    ];
    String selectedReasonKey = 'fake_profile';
    final detailsController = TextEditingController();
    bool isSubmitting = false;

    Get.bottomSheet(
      StatefulBuilder(
        builder: (sheetContext, setSheetState) {
          return Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.flag_rounded, color: Colors.red, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          profile.personalDetails?.name != null
                              ? '${'report_profile'.tr} (${profile.personalDetails!.name})'
                              : 'report_profile'.tr,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.grey),
                        onPressed: isSubmitting ? null : () => Navigator.of(sheetContext).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'report_reason_prompt'.tr,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...reasons.map((item) {
                    final isSelected = selectedReasonKey == item['key'];
                    return InkWell(
                      onTap: isSubmitting ? null : () {
                        setSheetState(() {
                          selectedReasonKey = item['key']!;
                        });
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                        child: Row(
                          children: [
                            Icon(
                              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                              color: isSelected ? Colors.red : Colors.grey.shade400,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                item['title']!,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                  color: isSelected ? Colors.black87 : Colors.grey.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 14),
                  TextField(
                    controller: detailsController,
                    enabled: !isSubmitting,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: 'report_details_optional'.tr,
                      hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.red),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: isSubmitting
                          ? null
                          : () async {
                              final targetId = profile.userId ?? profile.user?.id ?? profile.id;
                              if (targetId == null) {
                                CustomSnackBar.showError(message: "User ID not found");
                                return;
                              }
                              setSheetState(() => isSubmitting = true);
                              final success = await controller.reportUser(
                                reportedUserId: targetId,
                                reasonKey: selectedReasonKey,
                                details: detailsController.text.trim(),
                              );
                              setSheetState(() => isSubmitting = false);
                              if (success) {
                                Navigator.of(sheetContext).pop();
                                if (Get.isRegistered<MatrimonyController>()) {
                                  Get.find<MatrimonyController>().removeProfileById(targetId);
                                }
                                if (Get.isRegistered<MatrimonyMembersController>()) {
                                  Get.find<MatrimonyMembersController>().removeMemberByUserId(targetId);
                                }
                                if (Get.isRegistered<MatrimonyRequestsController>()) {
                                  Get.find<MatrimonyRequestsController>().removeRequestByUserId(targetId);
                                }
                                Navigator.of(context).pop({'reported': true, 'userId': targetId});
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: isSubmitting
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              'submit_report'.tr,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      isScrollControlled: true,
    );
  }

  void _showBlockDialog(BuildContext context, MatrimonyProfile profile) {
    final titleText = profile.personalDetails?.name?.trim() ?? "User";
    final targetId = profile.userId ?? profile.user?.id ?? profile.id;
    if (targetId == null) {
      CustomSnackBar.showError(message: "User ID not found");
      return;
    }
    bool isSubmitting = false;

    Get.dialog(
      StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.block_rounded, color: Colors.red, size: 36),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "${'block_user'.tr} - $titleText",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'block_confirm_message'.tr,
                    style: TextStyle(
                      fontSize: 13.5,
                      color: Colors.grey.shade600,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: isSubmitting ? null : () => Navigator.of(dialogContext).pop(),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            side: BorderSide(color: Colors.grey.shade300),
                          ),
                          child: Text(
                            'cancel'.tr,
                            style: const TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: isSubmitting
                              ? null
                              : () async {
                                  setDialogState(() => isSubmitting = true);
                                  final success = await controller.blockUser(targetId);
                                  setDialogState(() => isSubmitting = false);
                                  if (success) {
                                    Navigator.of(dialogContext).pop();
                                    Navigator.of(context).pop({'blocked': true, 'userId': targetId});
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                          ),
                          child: isSubmitting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  'block_user'.tr,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}