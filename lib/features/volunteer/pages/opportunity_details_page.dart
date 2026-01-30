import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/opportunity_details_controller.dart';
import 'package:intl/intl.dart';

class OpportunityDetailsPage extends GetView<OpportunityDetailsController> {
  const OpportunityDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = controller.opportunity.value;
        if (data == null) {
          return Scaffold(
            appBar: AppBar(title: const Text("Details")),
            body: const Center(child: Text("Opportunity not found")),
          );
        }

        return CustomScrollView(
          slivers: [
            // Professional Header with Title and Gradient
            SliverAppBar(
              expandedHeight: 250,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            theme.primaryColor,
                            theme.primaryColor.withOpacity(0.8),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 40,
                      left: 20,
                      right: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              data.status?.toUpperCase() ?? "ACTIVE",
                              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            data.title ?? "Volunteer Opportunity",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.business_center, color: Colors.white70, size: 16),
                              const SizedBox(width: 8),
                              Text(
                                data.organization ?? "Unknown Organization",
                                style: const TextStyle(color: Colors.white70, fontSize: 14),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              leading: GestureDetector(
                onTap: Get.back,
                child: Icon(Icons.arrow_back_ios_rounded, color: theme.cardColor),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Key Info Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildInfoItem(
                          context,
                          Icons.location_on_outlined,
                          "Location",
                          data.location ?? "Remote",
                        ),
                        _buildInfoItem(
                          context,
                          Icons.people_outline,
                          "Needed",
                          "${data.volunteersNeeded ?? 0} spots",
                        ),
                        _buildInfoItem(
                          context,
                          Icons.calendar_month_outlined,
                          "Deadline",
                          _formatDate(data.endDate),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),

                    // Description
                    const Text(
                      "About this Opportunity",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      data.description ?? "No description provided.",
                      style: TextStyle(color: Colors.grey[700], height: 1.6),
                    ),
                    const SizedBox(height: 24),

                    // Requirements
                    if (data.requirements != null && data.requirements!.isNotEmpty) ...[
                      const Text(
                        "Requirements",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        data.requirements!,
                        style: TextStyle(color: Colors.grey[700], height: 1.6),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Contact Section
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: theme.primaryColor.withOpacity(0.1)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Contact Information",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          _buildContactRow(Icons.person_outline, data.contactPerson ?? "Not specified"),
                          const SizedBox(height: 12),
                          _buildContactRow(Icons.email_outlined, data.contactEmail ?? "Not specified"),
                          const SizedBox(height: 12),
                          _buildContactRow(Icons.phone_outlined, data.contactPhone ?? "Not specified"),
                        ],
                      ),
                    ),
                    const SizedBox(height: 100), // Space for button
                  ],
                ),
              ),
            ),
          ],
        );
      }),
      // bottomSheet: Obx(() {
      //   if (controller.isLoading.value || controller.opportunity.value == null) {
      //     return const SizedBox.shrink();
      //   }
      //   return Container(
      //     padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      //     decoration: BoxDecoration(
      //       color: Colors.white,
      //       boxShadow: [
      //         BoxShadow(
      //           color: Colors.black.withOpacity(0.05),
      //           blurRadius: 10,
      //           offset: const Offset(0, -5),
      //         ),
      //       ],
      //     ),
      //     child: ElevatedButton(
      //       onPressed: () {
      //         // Application logic
      //         Get.snackbar("Applied", "You have successfully applied for this opportunity!");
      //       },
      //       style: ElevatedButton.styleFrom(
      //         minimumSize: const Size(double.infinity, 50),
      //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      //       ),
      //       child: const Text("Apply Now", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      //     ),
      //   );
      // }),
    );
  }

  Widget _buildInfoItem(BuildContext context, IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: context.theme.primaryColor, size: 24),
        const SizedBox(height: 8),
        Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
      ],
    );
  }

  Widget _buildContactRow(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Text(value, style: TextStyle(color: Colors.grey[800])),
      ],
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return "TBD";
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }
}
