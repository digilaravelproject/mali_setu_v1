import 'package:edu_cluezer/features/business/domain/usecase/create_job_usecase.dart';
import 'package:edu_cluezer/features/business/domain/usecase/update_job_usecase.dart';
import 'package:edu_cluezer/features/business/data/model/res_all_business_model.dart';
import 'package:edu_cluezer/features/business/presentation/controller/business_controller.dart';
import 'package:edu_cluezer/widgets/custom_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:edu_cluezer/core/helper/string_extensions.dart';
import 'package:edu_cluezer/features/business/presentation/controller/business_controller.dart';

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

  Future<void> selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      controller.text = picked.toString().split(' ').first;
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
    // Listen to category changes
    categoryCtrl.addListener(_onCategoryChanged);
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

    titleCtrl.text = job.title ?? '';
    descriptionCtrl.text = job.description ?? '';
    requirementsCtrl.text = job.requirements ?? '';
    salaryRangeCtrl.text = job.salaryRange ?? '';
    locationCtrl.text = job.location ?? '';
    
    jobTypeCtrl.text = job.jobType ?? '';
    experienceCtrl.text = (job.experienceLevel ?? '').toTitleCase();
    employmentCtrl.text = (job.employmentType ?? '').replaceAll('-', ' ').toTitleCase();
    categoryCtrl.text = job.category ?? '';
    
    deadlineCtrl.text = job.applicationDeadline != null ? job.applicationDeadline!.split('T').first : '';
    expiryCtrl.text = job.expiresAt != null ? job.expiresAt!.split('T').first : '';

    selectedBenefits.assignAll(job.benefits ?? []);
    selectedSkills.assignAll(job.skillsRequired ?? []);
  }

  void clearFields() {
    isEditMode.value = false;
    editingJobId.value = null;
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
    final businessId = Get.find<BusinessController>().myBusiness.value?.id;
    
    if (businessId == null) {
      CustomSnackBar.showError(message: 'register_business_first'.tr);
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
      "application_deadline": deadlineCtrl.text.trim(),
      "expires_at": expiryCtrl.text.trim()
    };

    try {
      isLoading.value = true;
      final BusinessResponse response;
      if (isEditMode.value && editingJobId.value != null) {
        response = await updateJobUseCase(editingJobId.value!, data);
      } else {
        response = await createJobUseCase(data);
      }
      
      if (response.success == true) {
        Get.back();
        CustomSnackBar.showSuccess(message: response.message ?? (isEditMode.value ? 'job_updated_success'.tr : 'job_created_success'.tr));
        
        // Refresh business jobs list
        final bController = Get.find<BusinessController>();
        final bId = int.tryParse(data['business_id'].toString()) ?? 0;
        bController.fetchBusinessJobs(bId);

        // If we were editing, refresh the job details as well
        if (isEditMode.value && editingJobId.value != null) {
          bController.fetchJobDetails(editingJobId.value!);
        }
      } else {
        CustomSnackBar.showError(message: response.message ?? 'job_save_failed'.tr);
      }
    } catch (e) {
      CustomSnackBar.showError(message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
