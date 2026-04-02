import 'package:edu_cluezer/widgets/custom_snack_bar.dart';
import 'package:get/get.dart';
import '../data/model/res_all_volunteer_model.dart';
import '../domain/usecase/single_volunteer_use_case.dart';

class OpportunityDetailsController extends GetxController {
  final SingleVolunteerUseCase useCase;

  OpportunityDetailsController({required this.useCase});

  var isLoading = false.obs;
  var opportunity = Rxn<Volunteer>();

  @override
  void onInit() {
    super.onInit();
    final arguments = Get.arguments;
    
    if (arguments is int) {
      // If ID is passed, fetch from API
      fetchOpportunity(arguments);
    } else if (arguments is Volunteer) {
      // If Volunteer object is passed directly, use it
      opportunity.value = arguments;
    } else if (arguments != null) {
      // Try to parse as int if it's a string or other type
      try {
        final id = int.parse(arguments.toString());
        fetchOpportunity(id);
      } catch (e) {
        CustomSnackBar.showError(message: 'Invalid opportunity ID: $arguments');
      }
    } else {
      CustomSnackBar.showError(message: 'No opportunity data provided');
    }
  }

  Future<void> fetchOpportunity(int id) async {
    try {
      isLoading.value = true;
      final result = await useCase(id);
      opportunity.value = result;
    } catch (e) {
      CustomSnackBar.showError(message: 'Failed to load opportunity details: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
