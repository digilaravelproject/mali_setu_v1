import 'package:edu_cluezer/widgets/custom_snack_bar.dart';
import 'package:get/get.dart';
import '../data/model/res_all_volunteer_model.dart';
import '../domain/usecase/all_volunteer_use_case.dart';

class AllVolunteerController extends GetxController {
  final VolunteerUseCase useCase;

  AllVolunteerController({required this.useCase});

  var isLoading = false.obs;
  var allVolunteerList = <Volunteer>[].obs; // ✅ Reactive list
  var searchText = "".obs; // ✅ Search text

  List<Volunteer> get filteredVolunteerList {
    if (searchText.isEmpty) {
      return allVolunteerList;
    }
    return allVolunteerList.where((v) {
      final name = (v.contactPerson ?? "").toLowerCase();
      final org = (v.organization ?? "").toLowerCase();
      final loc = (v.location ?? "").toLowerCase();
      final query = searchText.value.toLowerCase();
      return name.contains(query) || org.contains(query) || loc.contains(query);
    }).toList();
  }

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
      CustomSnackBar.showError(message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
