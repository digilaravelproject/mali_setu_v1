import 'package:edu_cluezer/core/constent/api_constants.dart';
import 'package:edu_cluezer/features/matrimony/data/model/connection_requests_response.dart';
import 'package:edu_cluezer/features/matrimony/presentation/controller/matrimony_requests_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../widgets/custom_image_view.dart';
import '../../../../core/styles/app_decoration.dart';

class MatrimonyRequestsScreen extends GetWidget<MatrimonyRequestsController> {
  const MatrimonyRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          title:  Text("connection_requests".tr, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
            onPressed: () => Get.back(),
          ),
          bottom:  TabBar(
            labelColor: Colors.purple,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.purple,
            tabs: [
              Tab(text: "received".tr),
              Tab(text: "sent".tr),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildReceivedList(),
            _buildSentList(),
          ],
        ),
      ),
    );
  }

  Widget _buildReceivedList() {
    return Obx(() {
      if (controller.isLoading.value) {
        return _buildLoading();
      }
      if (controller.receivedRequests.isEmpty) {
        return _buildEmptyState("no_received_requests".tr);
      }
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: controller.receivedRequests.length,
        itemBuilder: (context, index) {
          return _buildRequestCard(controller.receivedRequests[index], isSent: false);
        },
      );
    });
  }

  Widget _buildSentList() {
    return Obx(() {
      if (controller.isLoading.value) {
        return _buildLoading();
      }
      if (controller.sentRequests.isEmpty) {
        return _buildEmptyState("no_sent_requests".tr);
      }
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: controller.sentRequests.length,
        itemBuilder: (context, index) {
          return _buildRequestCard(controller.sentRequests[index], isSent: true);
        },
      );
    });
  }

  Widget _buildRequestCard(ConnectionRequest request, {required bool isSent}) {
    final user = isSent ? request.receiver : request.sender;
    final name = user?.name ?? "Anonymous";
    final age = user?.age?.toString() ?? "-";
    final profession = user?.occupation ?? "Professional";
    final location = user?.city ?? user?.state ?? "Unknown";
    final status = request.status?.capitalizeFirst ?? "Pending";
    
    Color statusColor = Colors.orange;
    if (status.toLowerCase() == "accepted") statusColor = Colors.green;
    if (status.toLowerCase() == "rejected") statusColor = Colors.red;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(35),
                    child: user?.profileImage != null && user!.profileImage!.isNotEmpty
                        ? CustomImageView(
                            url: ApiConstants.imageBaseUrl + user.profileImage!,
                            fit: BoxFit.cover,
                            placeHolder: (context, url) => Container(
                              decoration: BoxDecoration(
                                color: Colors.purple.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.person, color: Colors.purple, size: 35),
                            ),
                            errorWidget: (context, url, error) => Container(
                              decoration: BoxDecoration(
                                color: Colors.purple.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.person, color: Colors.purple, size: 35),
                            ),
                          )
                        : Container(
                            decoration: BoxDecoration(
                              color: Colors.purple.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.person, color: Colors.purple, size: 35),
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(status, style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text("$age yrs • $profession", style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 14, color: Colors.grey[400]),
                          const SizedBox(width: 2),
                          Expanded(child: Text(location, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.grey[400], fontSize: 12))),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (request.message != null && request.message!.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              margin: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "\"${request.message}\"",
                style: TextStyle(color: Colors.grey[700], fontStyle: FontStyle.italic, fontSize: 13),
              ),
            ),
          const SizedBox(height: 12),
          if (!isSent && status.toLowerCase() == "pending")
             Padding(
               padding: const EdgeInsets.only(left: 12, right: 12, bottom: 12),
               child: Row(
                 children: [
                   Expanded(
                     child: OutlinedButton(
                       onPressed: () => controller.respondToRequest(request.id!, "rejected"),
                       style: OutlinedButton.styleFrom(
                         foregroundColor: Colors.red,
                         side: const BorderSide(color: Colors.red, width: 1.5),
                         padding: const EdgeInsets.symmetric(vertical: 12),
                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                       ),
                        child: const Text("Decline", style: TextStyle(fontWeight: FontWeight.bold)),
                     ),
                   ),
                   const SizedBox(width: 12),
                   Expanded(
                     child: ElevatedButton(
                       onPressed: () => controller.respondToRequest(request.id!, "accepted"),
                       style: ElevatedButton.styleFrom(
                         backgroundColor: Colors.green,
                         foregroundColor: Colors.white,
                         elevation: 0,
                         padding: const EdgeInsets.symmetric(vertical: 12),
                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                       ),
                        child: const Text("Accept", style: TextStyle(fontWeight: FontWeight.bold)),
                     ),
                   ),
                 ],
               ),
             )
          else
            const SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(color: Colors.purple),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(message, style: TextStyle(color: Colors.grey[500], fontSize: 16)),
        ],
      ),
    );
  }
}
