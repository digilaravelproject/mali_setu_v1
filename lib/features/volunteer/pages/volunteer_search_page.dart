import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:edu_cluezer/features/volunteer/controller/all_volunteer_controller.dart';
import 'package:edu_cluezer/features/volunteer/pages/volunteer_page.dart';

class VolunteerSearchPage extends GetView<AllVolunteerController> {
  const VolunteerSearchPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    
    // Clear search text when entering this page
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.searchText.value = "";
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: TextField(
          autofocus: true,
          onChanged: (value) => controller.searchText.value = value,
          decoration: InputDecoration(
            hintText: "search_volunteers".tr,
            hintStyle: TextStyle(color: Colors.grey[400]),
            border: InputBorder.none,
          ),
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          Obx(() => controller.searchText.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.black, size: 20),
                  onPressed: () {
                    controller.searchText.value = "";
                  },
                )
              : const SizedBox.shrink()),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.filteredVolunteerList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 64, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text(
                  "no_volunteers_found".tr,
                  style: TextStyle(color: Colors.grey[500], fontSize: 16),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: controller.filteredVolunteerList.length,
          itemBuilder: (context, index) {
            final volunteer = controller.filteredVolunteerList[index];
            return VolunteerCard(
              volunteer: volunteer,
              onTap: () {
                Get.toNamed('/volunteerOpportunityDetails', arguments: volunteer);
              },
            );
          },
        );
      }),
    );
  }
}
