import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../widgets/custom_snack_bar.dart';
import '../../data/models/webinar_model.dart';
import '../controllers/webinars_controller.dart';
import 'webinar_confirmation_page.dart';

class WebinarRegistrationPage extends StatefulWidget {
  final Webinar? webinar;

  const WebinarRegistrationPage({super.key, this.webinar});

  @override
  State<WebinarRegistrationPage> createState() => _WebinarRegistrationPageState();
}

class _WebinarRegistrationPageState extends State<WebinarRegistrationPage> {
  late Webinar webinar;
  final controller = Get.find<WebinarsController>();

  @override
  void initState() {
    super.initState();
    webinar = widget.webinar ??
        controller.selectedWebinar.value ??
        controller.webinars.first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: const Center(
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 18,
              color: AppColors.lightTextPrimary,
            ),
          ),
        ),
        centerTitle: false,
        titleSpacing: 0,
        title: const Text(
          "Register for Webinar",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.lightTextPrimary,
            letterSpacing: -0.2,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: AppColors.lightDivider,
            height: 1,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Mini Card Summary (Matching Image 3)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.lightBorder, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CachedNetworkImage(
                        imageUrl: webinar.bannerUrl,
                        width: 72,
                        height: 72,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => Container(
                          width: 72,
                          height: 72,
                          color: AppColors.primaryLight,
                          child: const Icon(
                            Icons.video_library_rounded,
                            color: AppColors.primary,
                            size: 28,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            webinar.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.lightTextPrimary,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(
                                CupertinoIcons.calendar,
                                size: 12,
                                color: AppColors.lightTextSecondary,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  "${webinar.dateString} • ${webinar.timeString.split('-').first.trim()}",
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.lightTextSecondary,
                                  ),
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
              const SizedBox(height: 24),

              // Form Section
              _buildInputLabel("Full Name", isRequired: true),
              const SizedBox(height: 8),
              _buildTextInputField(
                controller: controller.regNameController,
                hintText: "Darshan Kondekar",
                icon: CupertinoIcons.person,
              ),
              const SizedBox(height: 18),

              _buildInputLabel("Email Address", isRequired: true),
              const SizedBox(height: 8),
              _buildTextInputField(
                controller: controller.regEmailController,
                hintText: "darshan@gmail.com",
                icon: CupertinoIcons.mail,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 18),

              _buildInputLabel("Phone Number", isRequired: true),
              const SizedBox(height: 8),
              _buildTextInputField(
                controller: controller.regPhoneController,
                hintText: "9876543210",
                icon: CupertinoIcons.phone,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 22),

              // Checkboxes
              Obx(
                () => _buildCheckboxRow(
                  value: controller.isApprovedUserAccepted.value,
                  onChanged: (val) => controller.isApprovedUserAccepted.value = val ?? false,
                  text: "I am a registered and approved user of Mali Setu",
                ),
              ),
              const SizedBox(height: 12),
              Obx(
                () => _buildCheckboxRow(
                  value: controller.isUpdatesAccepted.value,
                  onChanged: (val) => controller.isUpdatesAccepted.value = val ?? false,
                  text: "I agree to receive updates about future events.",
                ),
              ),
              const SizedBox(height: 36),

              // Confirm Registration Button
              Obx(() {
                final isLoading = controller.isRegistering.value;

                return SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () async {
                            final name = controller.regNameController.text.trim();
                            final email = controller.regEmailController.text.trim();
                            final phone = controller.regPhoneController.text.trim();

                            if (name.isEmpty) {
                              CustomSnackBar.showError(message: "Please enter your full name");
                              return;
                            }
                            if (phone.length < 10) {
                              CustomSnackBar.showError(
                                  message: "Please enter a valid 10-digit mobile number");
                              return;
                            }

                            final success = await controller.registerForWebinar(
                              webinarId: webinar.id,
                              name: name,
                              email: email,
                              phone: phone,
                            );

                            if (success) {
                              Get.off(
                                () => WebinarConfirmationPage(webinar: webinar),
                                transition: Transition.fadeIn,
                              );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: isLoading
                        ? const CupertinoActivityIndicator(color: Colors.white)
                        : const Text(
                            "Confirm Registration",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.2,
                            ),
                          ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputLabel(String label, {bool isRequired = false}) {
    return RichText(
      text: TextSpan(
        text: label,
        style: const TextStyle(
          fontSize: 13.5,
          fontWeight: FontWeight.w600,
          color: AppColors.lightTextPrimary,
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

  Widget _buildTextInputField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(
        fontSize: 14,
        color: AppColors.lightTextPrimary,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: hintText,
        hintStyle: const TextStyle(
          fontSize: 13.5,
          color: AppColors.lightTextDisabled,
        ),
        prefixIcon: Icon(icon, size: 18, color: AppColors.lightIcon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.lightBorder, width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.lightBorder, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
    );
  }

  Widget _buildCheckboxRow({
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
            side: const BorderSide(color: AppColors.lightBorder, width: 1.5),
            onChanged: onChanged,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: GestureDetector(
            onTap: () => onChanged(!value),
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.lightTextSecondary,
                height: 1.3,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

