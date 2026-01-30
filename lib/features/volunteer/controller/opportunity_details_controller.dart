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
    final id = Get.arguments as int?;
    if (id != null) {
      fetchOpportunity(id);
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
