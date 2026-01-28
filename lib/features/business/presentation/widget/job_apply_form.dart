import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/business_controller.dart';

class JobApplyForm extends StatefulWidget {
  final int jobId;
  const JobApplyForm({Key? key, required this.jobId}) : super(key: key);

  @override
  _JobApplyFormState createState() => _JobApplyFormState();
}

class _JobApplyFormState extends State<JobApplyForm> {
  final _controller = Get.find<BusinessController>();
  int _currentStep = 0;
  final _coverLetterController = TextEditingController();
  final _additionalInfoController = TextEditingController();
  File? _resumeFile;
  String? _resumeBase64;
  String? _resumeFileName;
  String? _resumeExtension;

  Future<void> _pickResume() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'png', 'jpeg'],
      );

      if (result != null) {
        File file = File(result.files.single.path!);
        List<int> bytes = await file.readAsBytes();
        String base64String = base64Encode(bytes);
        String extension = result.files.single.extension?.toLowerCase() ?? '';
        
        setState(() {
          _resumeFile = file;
          _resumeBase64 = base64String;
          _resumeFileName = result.files.single.name;
          _resumeExtension = extension;
        });
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to pick file: $e");
    }
  }

  void _submit() async {
    if (_coverLetterController.text.isEmpty) {
      Get.snackbar("Error", "Please enter a cover letter");
      return;
    }

    if (_resumeFile == null) {
      Get.snackbar("Error", "Please upload a resume");
      return;
    }

    final data = {
      'job_posting_id': widget.jobId,
      'cover_letter': _coverLetterController.text,
      'additional_info': _additionalInfoController.text,
      'resume': _resumeFile,
    };

    final success = await _controller.applyJob(data);
    if (success) {
      Get.back(); // Close bottom sheet
    }
  }

  void _nextStep() {
    if (_currentStep < 2) {
      setState(() => _currentStep++);
    } else {
      _submit();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    } else {
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
           const SizedBox(height: 12),
           // Handle bar
           Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header (Fixed at top)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Text(
              "Apply for Job",
              style: context.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(height: 1),

          // Scrollable Content
          Flexible( // Use Flexible to allow shrinking when keyboard appears
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                top: 20,
              ),
              child: Column(
                children: [
                  // Custom Stepper Header
                  _buildCustomStepperHeader(),
                  const SizedBox(height: 30),

                  // Current Step Content
                  _buildCurrentStepContent(),
                  
                  const SizedBox(height: 30),

                  // Actions
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _prevStep,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: BorderSide(color: context.theme.primaryColor),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text(_currentStep == 0 ? "CANCEL" : "BACK"),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _nextStep,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: context.theme.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          child: Text(_currentStep == 2 ? "SUBMIT" : "CONTINUE"),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomStepperHeader() {
    return Row(
      children: [
        _buildStepIndicator(0, "Letter"),
        _buildStepConnector(0),
        _buildStepIndicator(1, "Resume"),
        _buildStepConnector(1),
        _buildStepIndicator(2, "Info"),
      ],
    );
  }

  Widget _buildStepIndicator(int step, String label) {
    bool isActive = _currentStep >= step;
    bool isCompleted = _currentStep > step;
    bool isCurrent = _currentStep == step;

    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? context.theme.primaryColor : Colors.grey[200],
            border: Border.all(
              color: isActive ? context.theme.primaryColor : Colors.grey[300]!,
            ),
          ),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.check, size: 16, color: Colors.white)
                : Text(
                    "${step + 1}",
                    style: TextStyle(
                      color: isActive ? Colors.white : Colors.grey[600],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
            color: isActive ? context.theme.primaryColor : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildStepConnector(int step) {
    bool isActive = _currentStep > step;
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 14), // Align with circle center
        color: isActive ? context.theme.primaryColor : Colors.grey[200],
      ),
    );
  }

  Widget _buildCurrentStepContent() {
    switch (_currentStep) {
      case 0:
        return TextField(
          controller: _coverLetterController,
          maxLines: 6,
          decoration: InputDecoration(
            label: const Text("Cover Letter"),
            alignLabelWithHint: true,
            hintText: "Describe why you are a good fit for this position...",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.grey.withOpacity(0.05),
          ),
        );
      case 1:
        return Column(
          children: [
            if (_resumeFile == null)
              InkWell(
                onTap: _pickResume,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    border: Border.all(color: context.theme.primaryColor.withOpacity(0.5), style: BorderStyle.solid),
                    borderRadius: BorderRadius.circular(12),
                    color: context.theme.primaryColor.withOpacity(0.05),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.cloud_upload_outlined, size: 48, color: context.theme.primaryColor),
                      const SizedBox(height: 12),
                      const Text(
                        "Tap to Upload Resume",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "PDF, DOC, DOCX, JPG, PNG (Max 5MB)",
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              )
            else
              _buildFilePreview(),
          ],
        );
      case 2:
        return TextField(
          controller: _additionalInfoController,
          maxLines: 4,
          decoration: InputDecoration(
            label: const Text("Additional Information"),
            alignLabelWithHint: true,
            hintText: "Any other details? (Optional)",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.grey.withOpacity(0.05),
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildFilePreview() {
    if (_resumeFile == null) return const SizedBox.shrink();

    bool isImage = ['jpg', 'png', 'jpeg'].contains(_resumeExtension);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Selected File:",
                      style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _resumeFileName ?? "Unknown",
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () => setState(() {
                  _resumeFile = null;
                  _resumeBase64 = null;
                  _resumeFileName = null;
                  _resumeExtension = null;
                }),
              )
            ],
          ),
          const Divider(height: 24),
          if (isImage)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                _resumeFile!,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24),
              width: double.infinity,
              color: Colors.grey[50],
              child: Column(
                children: [
                  Icon(
                    _resumeExtension == 'pdf' ? Icons.picture_as_pdf : Icons.description,
                    size: 64,
                    color: _resumeExtension == 'pdf' ? Colors.red : Colors.blue,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _resumeExtension?.toUpperCase() ?? "FILE", 
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
