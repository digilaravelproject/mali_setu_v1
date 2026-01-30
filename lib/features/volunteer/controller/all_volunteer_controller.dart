import 'package:get/get.dart';
import '../data/model/res_all_volunteer_model.dart';
import '../domain/usecase/all_volunteer_use_case.dart';

class AllVolunteerController extends GetxController {
  final VolunteerUseCase useCase;

  AllVolunteerController({required this.useCase});

  var isLoading = false.obs;
  var allVolunteerList = <Volunteer>[].obs; // ✅ Reactive list

  @override
  void onInit() {
    super.onInit();
    fetchVolunteers();
  }

  Future<void> fetchVolunteers() async {
    try {
      isLoading.value = true;
      final list = await useCase();
      allVolunteerList.assignAll(list); // ✅ set list data
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
