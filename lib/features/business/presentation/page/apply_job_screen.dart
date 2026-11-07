import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../core/constent/api_constants.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../core/widgets/whatsapp_support_fab.dart';
import '../../../../widgets/custom_snack_bar.dart';
import '../../binding/business_binding.dart';
import '../../data/model/res_all_business_model.dart';
import '../controller/business_controller.dart';
import '../../../jobs/presentation/controller/jobs_controller.dart';

class ApplyJobScreen extends StatefulWidget {
  final Job? job;
  const ApplyJobScreen({Key? key, this.job}) : super(key: key);

  @override
  State<ApplyJobScreen> createState() => _ApplyJobScreenState();
}

class _ApplyJobScreenState extends State<ApplyJobScreen> {
  BusinessController get _businessController {
    if (!Get.isRegistered<BusinessController>()) {
      BusinessBinding().dependencies();
    }
    return Get.find<BusinessController>();
  }

  late Job _job;

  final TextEditingController _coverLetterController = TextEditingController();
  final TextEditingController _additionalInfoController = TextEditingController();

  File? _resumeFile;
  String? _resumeFileName;
  int? _resumeFileSize;
  String? _resumeExtension;
  final RxBool _isSubmitting = false.obs;

  @override
  void initState() {
    super.initState();
    if (widget.job != null) {
      _job = widget.job!;
    } else if (Get.arguments is Job) {
      _job = Get.arguments as Job;
    } else {
      _job = Job(id: 0, title: 'Job Application');
    }
  }

  @override
  void dispose() {
    _coverLetterController.dispose();
    _additionalInfoController.dispose();
    super.dispose();
  }

  Future<void> _pickResume() async {
    HapticFeedback.lightImpact();
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'png', 'jpeg'],
      );

      if (result != null && result.files.isNotEmpty) {
        final path = result.files.single.path;
        if (path != null) {
          final file = File(path);
          final size = await file.length();
          final name = result.files.single.name;
          final ext = result.files.single.extension?.toLowerCase() ?? '';

          // Validate max 5MB
          if (size > 5 * 1024 * 1024) {
            CustomSnackBar.showError(message: "File size exceeds 5MB limit. Please choose a smaller file.");
            return;
          }

          setState(() {
            _resumeFile = file;
            _resumeFileName = name;
            _resumeFileSize = size;
            _resumeExtension = ext;
          });

          CustomSnackBar.showSuccess(message: "Resume uploaded successfully");
        }
      }
    } catch (e) {
      CustomSnackBar.showError(message: "Failed to pick file: $e");
    }
  }

  void _removeResume() {
    setState(() {
      _resumeFile = null;
      _resumeFileName = null;
      _resumeFileSize = null;
      _resumeExtension = null;
    });
  }

  String _formatFileSize(int? bytes) {
    if (bytes == null) return '';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  Future<void> _submitApplication() async {
    if (_coverLetterController.text.trim().isEmpty) {
      CustomSnackBar.showError(message: "please_enter_cover_letter".tr);
      return;
    }
    if (_resumeFile == null) {
      CustomSnackBar.showError(message: "please_upload_resume".tr);
      return;
    }

    _isSubmitting.value = true;
    HapticFeedback.mediumImpact();

    try {
      final Map<String, dynamic> data = {
        'job_posting_id': _job.id,
        'cover_letter': _coverLetterController.text.trim(),
        'additional_info': _additionalInfoController.text.trim(),
        'resume': _resumeFile,
      };

      final bool success = await _businessController.applyJob(data);

      if (success) {
        if (Get.isRegistered<JobsController>()) {
          Get.find<JobsController>().fetchMyApplications(isRefresh: true);
        }
        await Future.delayed(const Duration(milliseconds: 300));
        if (mounted) {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop(true);
          } else {
            Get.back(result: true);
          }
        }
      }
    } catch (e) {
      CustomSnackBar.showError(message: "Failed to submit application: $e");
    } finally {
      _isSubmitting.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF9FAFB),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Color(0xFF1F2937)),
            onPressed: () => Get.back(),
          ),
          title: Text(
            'apply_for_job'.tr,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
        ),
        floatingActionButton: const WhatsAppSupportFab(bottomPadding: 75),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Job Summary Context Card
                    _buildJobOverviewCard(context),

                    const SizedBox(height: 18),

                    // 2. Cover Letter Section
                    _buildSectionContainer(
                      title: "cover_letter".tr.isNotEmpty ? "cover_letter".tr : "Cover Letter",
                      subtitle: "Introduce yourself and explain why you're a great fit",
                      isRequired: true,
                      child: TextField(
                        controller: _coverLetterController,
                        maxLines: 5,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF1F2937),
                          height: 1.4,
                        ),
                        decoration: InputDecoration(
                          hintText: "write_cover_letter".tr.isNotEmpty
                              ? "write_cover_letter".tr
                              : "Describe your relevant skills, recent achievements, and why you are excited about this opportunity...",
                          hintStyle: const TextStyle(
                            fontSize: 13.5,
                            color: Color(0xFF9CA3AF),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF9FAFB),
                          contentPadding: const EdgeInsets.all(14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: primaryColor, width: 1.5),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // 3. Resume / CV Upload Section
                    _buildSectionContainer(
                      title: "resume".tr.isNotEmpty ? "resume".tr : "Resume / CV",
                      subtitle: "Attach your updated resume (PDF, DOC, DOCX, JPG, PNG)",
                      isRequired: true,
                      child: _resumeFile == null
                          ? _buildUploadPlaceholder(context)
                          : _buildUploadedFileCard(context),
                    ),

                    const SizedBox(height: 18),

                    // 4. Additional Information Section (Optional)
                    _buildSectionContainer(
                      title: "additional_info".tr.isNotEmpty ? "additional_info".tr : "Additional Information",
                      subtitle: "Portfolio link, notice period, or any other notes",
                      isRequired: false,
                      child: TextField(
                        controller: _additionalInfoController,
                        maxLines: 3,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF1F2937),
                          height: 1.4,
                        ),
                        decoration: InputDecoration(
                          hintText: "e.g. Portfolio: https://github.com/... or 15 days notice period",
                          hintStyle: const TextStyle(
                            fontSize: 13.5,
                            color: Color(0xFF9CA3AF),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF9FAFB),
                          contentPadding: const EdgeInsets.all(14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: primaryColor, width: 1.5),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),

            // Bottom Sticky Action Bar
            _buildBottomActionBar(context),
          ],
        ),
      ),
    );
  }

  Widget _buildJobOverviewCard(BuildContext context) {
    final companyName = _job.business?.businessName ?? 'Company';
    final location = _job.location ?? (_job.business?.city != null ? "${_job.business?.city}, ${_job.business?.state ?? ''}" : 'Maharashtra');
    final employmentType = _job.employmentType ?? _job.jobType ?? 'Full Time';
    final salary = _job.salaryRange ?? 'Best in Industry';
    final logoUrl = _job.business?.photo;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F2F4), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: (logoUrl != null && logoUrl.isNotEmpty)
                  ? CachedNetworkImage(
                      imageUrl: logoUrl.startsWith('http')
                          ? logoUrl
                          : "${ApiConstants.imageBaseUrl}$logoUrl",
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => _buildFallbackAvatar(companyName),
                    )
                  : _buildFallbackAvatar(companyName),
            ),
          ),
          const SizedBox(width: 14),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Applying for",
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).primaryColor,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _job.title ?? 'Job Title',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  companyName,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF4B5563),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        employmentType,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF059669),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        salary.startsWith('₹') ? salary : '₹ $salary',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1F2937),
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
    );
  }

  Widget _buildSectionContainer({
    required String title,
    required String subtitle,
    required Widget child,
    bool isRequired = false,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F2F4), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                ),
              ),
              if (isRequired)
                const Text(
                  " *",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFEF4444),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _buildUploadPlaceholder(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return InkWell(
      onTap: _pickResume,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 16),
        decoration: BoxDecoration(
          color: primaryColor.withOpacity(0.04),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: primaryColor.withOpacity(0.35),
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                CupertinoIcons.cloud_upload,
                size: 28,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "Tap to Upload Resume / CV",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              "Supported: PDF, DOC, DOCX, JPG, PNG (Max 5MB)",
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFD1D5DB)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.folder_open_rounded, size: 16, color: primaryColor),
                  const SizedBox(width: 6),
                  Text(
                    "Browse File",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: primaryColor,
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

  Widget _buildUploadedFileCard(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final isPdf = _resumeExtension == 'pdf';
    final isDoc = _resumeExtension == 'doc' || _resumeExtension == 'docx';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          // File Icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isPdf
                  ? const Color(0xFFFEE2E2)
                  : isDoc
                      ? const Color(0xFFDBEAFE)
                      : const Color(0xFFE0E7FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isPdf
                  ? Icons.picture_as_pdf_rounded
                  : isDoc
                      ? Icons.description_rounded
                      : Icons.insert_drive_file_rounded,
              color: isPdf
                  ? const Color(0xFFDC2626)
                  : isDoc
                      ? const Color(0xFF2563EB)
                      : const Color(0xFF4F46E5),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),

          // File Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _resumeFileName ?? 'Resume',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      _formatFileSize(_resumeFileSize),
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        "Uploaded",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF059669),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Replace / Delete Buttons
          IconButton(
            icon: Icon(Icons.edit_outlined, size: 20, color: primaryColor),
            tooltip: "Change Resume",
            onPressed: _pickResume,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, size: 20, color: Color(0xFFEF4444)),
            tooltip: "Remove Resume",
            onPressed: _removeResume,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 14,
        bottom: MediaQuery.of(context).padding.bottom + 14,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: Obx(() {
          final isSubmitting = _isSubmitting.value;

          return ElevatedButton(
            onPressed: isSubmitting ? null : _submitApplication,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            child: isSubmitting
                ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        "Submitting...",
                        style: TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.send_rounded, size: 19, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        "Submit Application",
                        style: TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
          );
        }),
      ),
    );
  }

  Widget _buildFallbackAvatar(String name) {
    final initial = name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : 'M';
    return Container(
      color: const Color(0xFFF3F4F6),
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4B5563),
          ),
        ),
      ),
    );
  }
}
