import 'package:edu_cluezer/widgets/custom_snack_bar.dart';
import 'package:get/get.dart';
import '../data/model/res_all_volunteer_model.dart';
import '../data/model/volunteer_profile_model.dart';
import '../domain/usecase/all_volunteer_use_case.dart';

class AllVolunteerController extends GetxController {
  final VolunteerUseCase useCase;

  AllVolunteerController({required this.useCase});

  var isLoading = false.obs;
  var allVolunteerList = <Volunteer>[].obs; // For opportunities
  var searchResults = <VolunteerSearchProfile>[].obs; // For search results
  var searchText = "".obs; // Search text
  var isSearching = false.obs; // Search loading state
  var hasError = false.obs; // Error state
  var errorMessage = "".obs; // Error message

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
    
    // Debounce search to avoid too many API calls
    debounce(searchText, (query) {
      if (query.isNotEmpty && query.trim().length > 2) {
        searchVolunteers(query);
      } else {
        searchResults.clear();
      }
    }, time: const Duration(milliseconds: 500));
  }

  @override
  void onReady() {
    super.onReady();
    // Fetch data again if list is empty when controller becomes ready
    if (allVolunteerList.isEmpty && !isLoading.value) {
      fetchVolunteers();
    }
  }

  Future<void> fetchVolunteers({bool showLoading = true}) async {
    try {
      if (showLoading) {
        isLoading.value = true;
      }
      hasError.value = false;
      errorMessage.value = "";
      
      final list = await useCase();
      allVolunteerList.assignAll(list);
      
      // Debug print to check if data is received
      print("DEBUG: Fetched ${list.length} volunteers");
      
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
      print("DEBUG: Error fetching volunteers: $e");
      
      // Show error message only if it's not a network timeout
      if (!e.toString().toLowerCase().contains('timeout')) {
        CustomSnackBar.showError(message: "Failed to load volunteers: ${e.toString()}");
      }
    } finally {
      if (showLoading) {
        isLoading.value = false;
      }
    }
  }

  Future<void> refreshVolunteers() async {
    await fetchVolunteers(showLoading: false);
  }

  Future<void> searchVolunteers(String query) async {
    if (query.trim().isEmpty) {
      searchResults.clear();
      return;
    }

    try {
      isSearching.value = true;
      final results = await useCase.repository.searchVolunteers(query.trim());
      searchResults.assignAll(results);
    } catch (e) {
      print("DEBUG: Error searching volunteers: $e");
      CustomSnackBar.showError(message: "Search failed: ${e.toString()}");
      searchResults.clear();
    } finally {
      isSearching.value = false;
    }
  }
}
