import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../widgets/custom_snack_bar.dart';
import '../../data/models/webinar_model.dart';
import '../controllers/webinars_controller.dart';
import 'webinar_confirmation_dialog.dart';

class WebinarRegistrationSheet extends StatelessWidget {
  final Webinar webinar;

  const WebinarRegistrationSheet({
    super.key,
    required this.webinar,
  });

  static Future<void> show(BuildContext context, Webinar webinar) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => WebinarRegistrationSheet(webinar: webinar),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<WebinarsController>();
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top pull handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 10, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 16,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "Register for Webinar",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFF1F5F9)),

            // Mini Card Preview
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: CachedNetworkImage(
                      imageUrl: webinar.bannerUrl,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => Container(
                        width: 60,
                        height: 60,
                        color: AppColors.primaryLight,
                        child: Icon(Icons.video_library_rounded, color: AppColors.primary),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          webinar.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              CupertinoIcons.calendar,
                              size: 11,
                              color: Color(0xFF64748B),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "${webinar.dateString} • ${webinar.timeString.split('-').first.trim()}",
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF64748B),
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

            // Form Fields
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Full Name
                  _buildInputLabel("Full Name", isRequired: true),
                  const SizedBox(height: 6),
                  _buildTextField(
                    controller: controller.regNameController,
                    hint: "Enter your full name",
                    icon: CupertinoIcons.person,
                  ),
                  const SizedBox(height: 14),

                  // Email Address
                  _buildInputLabel("Email Address", isRequired: true),
                  const SizedBox(height: 6),
                  _buildTextField(
                    controller: controller.regEmailController,
                    hint: "Enter your email address",
                    keyboardType: TextInputType.emailAddress,
                    icon: CupertinoIcons.mail,
                  ),
                  const SizedBox(height: 14),

                  // Phone Number
                  _buildInputLabel("Phone Number", isRequired: true),
                  const SizedBox(height: 6),
                  _buildTextField(
                    controller: controller.regPhoneController,
                    hint: "Enter 10-digit mobile number",
                    keyboardType: TextInputType.phone,
                    icon: CupertinoIcons.phone,
                  ),
                  const SizedBox(height: 16),

                  // Checkboxes
                  Obx(
                    () => _buildCheckbox(
                      value: controller.isApprovedUserAccepted.value,
                      onChanged: (val) => controller.isApprovedUserAccepted.value = val ?? false,
                      text: "I am a registered and approved user of Mali Setu",
                    ),
                  ),
                  const SizedBox(height: 8),
                  Obx(
                    () => _buildCheckbox(
                      value: controller.isUpdatesAccepted.value,
                      onChanged: (val) => controller.isUpdatesAccepted.value = val ?? false,
                      text: "I agree to receive updates and reminder alerts about future events",
                    ),
                  ),
                  const SizedBox(height: 22),

                  // Confirm Registration Button
                  Obx(() {
                    return SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: controller.isRegistering.value
                            ? null
                            : () async {
                                final name = controller.regNameController.text.trim();
                                final email = controller.regEmailController.text.trim();
                                final phone = controller.regPhoneController.text.trim();

                                if (name.isEmpty) {
                                  CustomSnackBar.showError(message: "Please enter your name");
                                  return;
                                }
                                if (phone.length < 10) {
                                  CustomSnackBar.showError(
                                      message: "Please enter a valid 10-digit mobile number");
                                  return;
                                }

                                final success = await controller.registerForWebinar(webinar.id);

                                if (success) {
                                  Get.back(); // Close registration sheet
                                  WebinarConfirmationDialog.show(Get.context!, webinar);
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: controller.isRegistering.value
                            ? const CupertinoActivityIndicator(color: Colors.white)
                            : const Text(
                                "Confirm Registration",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.3,
                                ),
                              ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputLabel(String label, {bool isRequired = false}) {
    return RichText(
      text: TextSpan(
        text: label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Color(0xFF334155),
        ),
        children: isRequired
            ? const [
                TextSpan(
                  text: " *",
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                )
              ]
            : [],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 14, color: Color(0xFF1E293B)),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(fontSize: 13.5, color: Colors.grey[400]),
          prefixIcon: Icon(icon, size: 18, color: const Color(0xFF94A3B8)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildCheckbox({
    required bool value,
    required ValueChanged<bool?> onChanged,
    required String text,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 22,
          width: 22,
          child: Checkbox(
            value: value,
            activeColor: AppColors.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            onChanged: onChanged,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: GestureDetector(
            onTap: () => onChanged(!value),
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: Color(0xFF475569),
                height: 1.3,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

