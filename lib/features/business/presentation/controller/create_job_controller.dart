import 'package:edu_cluezer/features/business/domain/usecase/create_job_usecase.dart';
import 'package:edu_cluezer/features/business/domain/usecase/update_job_usecase.dart';
import 'package:edu_cluezer/features/business/data/model/res_all_business_model.dart';
import 'package:edu_cluezer/features/business/presentation/controller/business_controller.dart';
import 'package:edu_cluezer/widgets/custom_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:edu_cluezer/core/helper/string_extensions.dart';
import 'package:edu_cluezer/features/business/presentation/controller/business_controller.dart';
import 'package:edu_cluezer/core/helper/form_validator.dart';

class CreateJobController extends GetxController {
  final CreateJobUseCase createJobUseCase;
  final UpdateJobUseCase updateJobUseCase;

  CreateJobController({
    required this.createJobUseCase,
    required this.updateJobUseCase,
  });

  /// Edit Mode variables
  final isEditMode = false.obs;
  final editingJobId = Rxn<int>();

  /// Business Selection
  final selectedBusinessId = Rxn<int>();
  final businessCtrl = TextEditingController();

  /// Text Controllers
  final titleCtrl = TextEditingController();
  final descriptionCtrl = TextEditingController();
  final requirementsCtrl = TextEditingController();
  final salaryRangeCtrl = TextEditingController();
  final locationCtrl = TextEditingController();
  
  final countryCtrl = TextEditingController();
  final stateCtrl = TextEditingController();
  final cityCtrl = TextEditingController();
  
  final jobTypeCtrl = TextEditingController();
  final experienceCtrl = TextEditingController();
  final employmentCtrl = TextEditingController();
  final categoryCtrl = TextEditingController();

  final deadlineCtrl = TextEditingController();
  final expiryCtrl = TextEditingController();


  final benefitsCtrl = TextEditingController();
  final RxList<String> selectedBenefits = <String>[].obs;
  final RxList<String> popularBenefits = <String>[
    'Health insurance',
    'Flexible working hours',
    'Paid time off',
    'Remote work options',
    'Professional development',
    'Stock options',
  ].obs;

  final skillsCtrl = TextEditingController();
  final RxList<String> selectedSkills = <String>[].obs;
  
  static const List<String> POPULAR_SKILLS = [
    'PHP', 'Laravel', 'MySQL', 'REST API', 'Flutter', 'Dart', 'Android', 
    'React Native', 'Java', 'Python', 'Node.js', 'UI/UX Design'
  ];

  static const List<String> POPULAR_BENEFITS = [
    'Health insurance', 'Flexible working hours', 'Paid time off', 
    'Remote work options', 'Professional development', 'Stock options',
    'Performance Bonus', 'Gym Membership', 'Free Meals'
  ];

  /// Add new benefit
  void addCustomBenefit() {
    final benefit = benefitsCtrl.text.trim();
    if (benefit.isNotEmpty && !selectedBenefits.contains(benefit)) {
      selectedBenefits.add(benefit);
      benefitsCtrl.clear();
    }
  }
  
  /// Validation Errors
  final errors = <String, String>{}.obs;

  /// Add from popular list
  void addPopularBenefit(String benefit) {
    if (!selectedBenefits.contains(benefit)) {
      selectedBenefits.add(benefit);
    }
  }

  /// Remove benefit
  void removeBenefit(String benefit) {
    selectedBenefits.remove(benefit);
  }

  /// Add new skill
  void addCustomSkill() {
    final skill = skillsCtrl.text.trim();
    if (skill.isNotEmpty && !selectedSkills.contains(skill)) {
      selectedSkills.add(skill);
      skillsCtrl.clear();
    }
  }

  /// Add from popular list
  void addPopularSkill(String skill) {
    if (!selectedSkills.contains(skill)) {
      selectedSkills.add(skill);
    }
  }

  /// Remove benefit
  void removeSkill(String skill) {
    selectedSkills.remove(skill);
  }

  /// Convert DD/MM/YYYY → YYYY-MM-DD for API submission
  String _toApiDate(String ddmmyyyy) {
    final parts = ddmmyyyy.split('/');
    if (parts.length == 3 && parts[2].length == 4) {
      return '${parts[2]}-${parts[1]}-${parts[0]}';
    }
    return ddmmyyyy; // fallback: return as-is
  }

  /// Convert YYYY-MM-DD → DD/MM/YYYY for display
  String _fromApiDate(String yyyymmdd) {
    final parts = yyyymmdd.split('-');
    if (parts.length == 3) {
      return '${parts[2]}/${parts[1]}/${parts[0]}';
    }
    return yyyymmdd;
  }

  Future<void> selectDate(BuildContext context, TextEditingController ctrl) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      fieldHintText: 'dd/mm/yyyy',
      fieldLabelText: 'Date (DD/MM/YYYY)',
      errorFormatText: 'Enter valid date',
      errorInvalidText: 'Date out of range',
    );
    if (picked != null) {
      ctrl.text =
          "${picked.day.toString().padLeft(2, '0')}/"
          "${picked.month.toString().padLeft(2, '0')}/"
          "${picked.year}";
    }
  }

  /// Dropdown Data
  static const List<String> JOB_TYPES = ["On-site", "Remote", "Hybrid"];
  static const List<String> EXP_LEVELS = ["Entry", "Mid", "Senior", "Expert"];
  static const List<String> EMPLOYMENT_TYPES = ["Full-time", "Part-time", "Internship", "Freelance", "Contract"];
  static const List<String> CATEGORIES = ["Software Development", "Marketing", "Sales", "Design", "Finance", "Human Resources"];

  // Methods to get translated lists
  List<String> getJobTypes() {
    return [
      'on_site'.tr,
      'remote'.tr,
      'hybrid'.tr,
    ];
  }

  List<String> getExperienceLevels() {
    return [
      'entry'.tr,
      'mid'.tr,
      'senior'.tr,
      'expert'.tr,
    ];
  }

  List<String> getEmploymentTypes() {
    return [
      'full_time'.tr,
      'part_time'.tr,
      'internship'.tr,
      'freelance'.tr,
      'contract'.tr,
    ];
  }

  List<String> getCategories() {
    return [
      'software_development'.tr,
      'marketing'.tr,
      'sales'.tr,
      'design'.tr,
      'finance'.tr,
      'human_resources'.tr,
      'other'.tr,
    ];
  }

  List<String> getPopularBenefits() {
    return [
      'health_insurance'.tr,
      'flexible_working_hours'.tr,
      'paid_time_off'.tr,
      'remote_work_options'.tr,
      'professional_development'.tr,
      'stock_options'.tr,
      'performance_bonus'.tr,
      'gym_membership'.tr,
      'free_meals'.tr,
    ];
  }

  List<String> getPopularSkills() {
    return [
      'php'.tr,
      'laravel'.tr,
      'mysql'.tr,
      'rest_api'.tr,
      'flutter'.tr,
      'dart'.tr,
      'android'.tr,
      'react_native'.tr,
      'java'.tr,
      'python'.tr,
      'nodejs'.tr,
      'ui_ux_design'.tr,
    ];
  }

  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    
    // Auto-select business if coming from business detail page
    final businessController = Get.find<BusinessController>();
    if (businessController.myBusiness.value != null) {
      selectedBusinessId.value = businessController.myBusiness.value!.id;
      businessCtrl.text = businessController.myBusiness.value!.businessName ?? '';
      debugPrint("🏢 Auto-selected business: ${businessCtrl.text} (ID: ${selectedBusinessId.value})");
    }
    
    // Listen to category changes
    categoryCtrl.addListener(_onCategoryChanged);

    // Reactive error clearing
    titleCtrl.addListener(() => errors.remove('title'));
    descriptionCtrl.addListener(() => errors.remove('description'));
    requirementsCtrl.addListener(() => errors.remove('requirements'));
    salaryRangeCtrl.addListener(() => errors.remove('salary'));
    locationCtrl.addListener(() => errors.remove('location'));
    deadlineCtrl.addListener(() => errors.remove('deadline'));
    expiryCtrl.addListener(() => errors.remove('expiry'));
    jobTypeCtrl.addListener(() => errors.remove('jobType'));
    experienceCtrl.addListener(() => errors.remove('experience'));
    employmentCtrl.addListener(() => errors.remove('employment'));
    categoryCtrl.addListener(() => errors.remove('category'));
  }

  void _onCategoryChanged() {
    if (categoryCtrl.text == 'other'.tr) {
      // Show dialog to enter custom category
      _showCustomCategoryDialog();
    }
  }

  void _showCustomCategoryDialog() {
    final customCategoryCtrl = TextEditingController();
    Get.dialog(
      AlertDialog(
        title: Text('enter_job_category'.tr),
        content: TextField(
          controller: customCategoryCtrl,
          decoration: InputDecoration(
            hintText: 'job_category_hint'.tr,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              categoryCtrl.text = 'other'.tr;
              Get.back();
            },
            child: Text('cancel'.tr),
          ),
          TextButton(
            onPressed: () {
              if (customCategoryCtrl.text.trim().isNotEmpty) {
                categoryCtrl.text = customCategoryCtrl.text.trim();
                Get.back();
              }
            },
            child: Text('submit'.tr),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  void populateFields(Job job) {
    isEditMode.value = true;
    editingJobId.value = job.id;

    // Set business ID
    selectedBusinessId.value = job.businessId ?? job.business?.id;
    if (selectedBusinessId.value != null) {
      final businessController = Get.find<BusinessController>();
      final business = businessController.myBusinesses.firstWhereOrNull(
        (b) => b.id == selectedBusinessId.value
      );
      if (business != null) {
        businessCtrl.text = business.businessName ?? '';
      }
    }

    titleCtrl.text = job.title ?? '';
    descriptionCtrl.text = job.description ?? '';
    requirementsCtrl.text = job.requirements ?? '';
    salaryRangeCtrl.text = job.salaryRange ?? '';
    locationCtrl.text = job.location ?? '';
    
    jobTypeCtrl.text = job.jobType ?? '';
    experienceCtrl.text = (job.experienceLevel ?? '').toTitleCase();
    employmentCtrl.text = (job.employmentType ?? '').replaceAll('-', ' ').toTitleCase();
    categoryCtrl.text = job.category ?? '';
    
    deadlineCtrl.text = job.applicationDeadline != null
        ? _fromApiDate(job.applicationDeadline!.split('T').first)
        : '';
    expiryCtrl.text = job.expiresAt != null
        ? _fromApiDate(job.expiresAt!.split('T').first)
        : '';

    selectedBenefits.assignAll(job.benefits ?? []);
    selectedSkills.assignAll(job.skillsRequired ?? []);
  }

  void clearFields() {
    isEditMode.value = false;
    editingJobId.value = null;
    selectedBusinessId.value = null;
    businessCtrl.clear();
    titleCtrl.clear();
    descriptionCtrl.clear();
    requirementsCtrl.clear();
    salaryRangeCtrl.clear();
    locationCtrl.clear();
    jobTypeCtrl.clear();
    experienceCtrl.clear();
    employmentCtrl.clear();
    categoryCtrl.clear();
    deadlineCtrl.clear();
    expiryCtrl.clear();
    selectedBenefits.clear();
    selectedSkills.clear();
  }

  @override
  void onClose() {
    categoryCtrl.removeListener(_onCategoryChanged);
    businessCtrl.dispose();
    titleCtrl.dispose();
    descriptionCtrl.dispose();
    requirementsCtrl.dispose();
    salaryRangeCtrl.dispose();
    locationCtrl.dispose();
    countryCtrl.dispose();
    stateCtrl.dispose();
    cityCtrl.dispose();
    jobTypeCtrl.dispose();
    experienceCtrl.dispose();
    employmentCtrl.dispose();
    categoryCtrl.dispose();
    deadlineCtrl.dispose();
    expiryCtrl.dispose();
    benefitsCtrl.dispose();
    skillsCtrl.dispose();
    super.onClose();
  }

  Future<void> onRegister() async {
    // Use selected business ID or fallback to current business
    final businessId = selectedBusinessId.value ?? Get.find<BusinessController>().myBusiness.value?.id;
    
    if (businessId == null) {
      CustomSnackBar.showError(message: 'register_business_first');
      return;
    }

    debugPrint("🏢 Using business ID: $businessId");

    // Comprehensive Validation
    errors.clear();
    
    if (titleCtrl.text.trim().isEmpty) {
      errors['title'] = 'please_enter_job_title'.tr;
    }
    if (descriptionCtrl.text.trim().isEmpty) {
      errors['description'] = 'please_enter_job_description'.tr;
    }
    if (requirementsCtrl.text.trim().isEmpty) {
      errors['requirements'] = 'please_enter_requirements'.tr;
    }
    if (salaryRangeCtrl.text.trim().isEmpty) {
      errors['salary'] = 'salary_required'.tr;
    }
    if (jobTypeCtrl.text.trim().isEmpty) {
      errors['jobType'] = 'please_select_job_type'.tr;
    }
    if (locationCtrl.text.trim().isEmpty) {
      errors['location'] = 'location_required'.tr;
    }
    if (experienceCtrl.text.trim().isEmpty) {
      errors['experience'] = 'please_select_experience_level'.tr;
    }
    if (employmentCtrl.text.trim().isEmpty) {
      errors['employment'] = 'please_select_employment_type'.tr;
    }
    if (categoryCtrl.text.trim().isEmpty) {
      errors['category'] = 'please_select_job_category'.tr;
    }
    final deadlineError = FormValidator.date(deadlineCtrl.text.trim(), 'application_deadline'.tr);
    if (deadlineError != null) {
      errors['deadline'] = deadlineError;
    }
    
    final expiryError = FormValidator.date(expiryCtrl.text.trim(), 'job_expiry_date'.tr);
    if (expiryError != null) {
      errors['expiry'] = expiryError;
    }

    if (errors.isNotEmpty) {
      return;
    }

    final data = {
      "business_id": businessId,
      "title": titleCtrl.text.trim(),
      "description": descriptionCtrl.text.trim(),
      "requirements": requirementsCtrl.text.trim(),
      "salary_range": salaryRangeCtrl.text.trim(),
      "job_type": jobTypeCtrl.text.trim(),
      "location": locationCtrl.text.trim(),
      "experience_level": experienceCtrl.text.trim().toLowerCase(),
      "employment_type": employmentCtrl.text.trim().toLowerCase().replaceAll(' ', '-'),
      "category": categoryCtrl.text.trim(),
      "skills_required": selectedSkills,
      "benefits": selectedBenefits,
      "application_deadline": _toApiDate(deadlineCtrl.text.trim()),
      "expires_at": _toApiDate(expiryCtrl.text.trim())
    };

    try {
      isLoading.value = true;
      
      debugPrint("🔧 ${isEditMode.value ? 'Updating' : 'Creating'} job with data:");
      debugPrint("📦 Request data: $data");
      
      final BusinessResponse response;
      if (isEditMode.value && editingJobId.value != null) {
        debugPrint("✏️ Edit mode - Job ID: ${editingJobId.value}");
        response = await updateJobUseCase(editingJobId.value!, data);
      } else {
        debugPrint("➕ Create mode");
        response = await createJobUseCase(data);
      }
      
      debugPrint("📡 API Response:");
      debugPrint("  - Success: ${response.success}");
      debugPrint("  - Message: ${response.message}");
      debugPrint("  - Errors: ${response.errors}");
      
      if (response.success == true) {
        Get.back();
        CustomSnackBar.showSuccess(message: response.message ?? (isEditMode.value ? 'job_updated_success' : 'job_created_success'));
        
        // Refresh business jobs list
        final bController = Get.find<BusinessController>();
        final bId = int.tryParse(data['business_id'].toString()) ?? 0;
        bController.fetchBusinessJobs(bId);

        // If we were editing, refresh the job details as well
        if (isEditMode.value && editingJobId.value != null) {
          bController.fetchJobDetails(editingJobId.value!);
        }
      } else {
        // Handle specific error messages from API
        String errorMessage = response.message ?? 'job_save_failed';
        
        // Check for business verification error
        if (errorMessage.toLowerCase().contains('verified') || 
            errorMessage.toLowerCase().contains('verification')) {
          errorMessage = 'business_verification_required'.tr;
        }
        
        // Handle API error response with proper error extraction
        if (response.errors != null && response.errors!.isNotEmpty) {
          var errors = response.errors!;
          
          // Errors is an OBJECT (Map) - Laravel format
          List<String> allErrors = [];
          errors.forEach((field, messages) {
            if (messages is List && messages.isNotEmpty) {
              allErrors.addAll(messages.map((e) => e.toString()));
            }
          });
          
          if (allErrors.isNotEmpty) {
            errorMessage = allErrors.first;
          }
        }
        
        CustomSnackBar.showError(message: errorMessage);
      }
    } catch (e) {
      debugPrint("❌ Job creation/update error: $e");
      CustomSnackBar.showError(message: 'unexpected_error_occurred');
      print("Job creation error: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
