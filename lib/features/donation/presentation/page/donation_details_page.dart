import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/donation_controller.dart';
import '../../data/model/donation_cause_model.dart';
import 'package:edu_cluezer/widgets/custom_image_view.dart';
import 'package:edu_cluezer/core/constent/api_constants.dart';
import 'package:edu_cluezer/features/Auth/service/auth_service.dart';

/*
class DonationDetailsPage extends GetView<DonationController> {
  const DonationDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final DonationCauseItem cause = Get.arguments;
    final authService = Get.find<AuthService>();
    final user = authService.currentUser.value;
    
    final TextEditingController amountController = TextEditingController();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Cause Details", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomImageView(
              url: cause.imageUrl != null ? "${ApiConstants.baseUrl}${cause.imageUrl}" : null,
              width: double.infinity,
              height: 250,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: context.theme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          cause.category?.toUpperCase() ?? "GENERAL",
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: context.theme.primaryColor,
                          ),
                        ),
                      ),
                      Text(
                        cause.urgency?.toUpperCase() ?? "NORMAL",
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    cause.title ?? "Cause Title",
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.business_rounded, size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        cause.organization ?? "Trusted NGO",
                        style: const TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "About the Cause",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    cause.description ?? "No description available.",
                    style: TextStyle(fontSize: 15, color: Colors.grey[700], height: 1.6),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Target Amount to Donate ${cause.targetAmount}",
                    style: TextStyle(fontSize: 15, color: Colors.grey[700], height: 1.6,fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 25),
                  const Text(
                    "Donate Amount",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: "Enter amount (e.g., 500)",
                      prefixIcon: const Icon(Icons.currency_rupee_rounded),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: () {
                        final amount = double.tryParse(amountController.text) ?? 0;
                        if (amount <= 0) {
                          Get.snackbar("Error", "Please enter a valid amount");
                          return;
                        }
                        controller.initiateDonationPayment(
                          cause,
                          amount,
                          user?.name ?? "Guest",
                          user?.email ?? "guest@example.com",
                          user?.phone ?? "0000000000",
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.theme.primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: const Text(
                        "Donate Now",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
*/


import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/donation_controller.dart';
import '../../data/model/donation_cause_model.dart';
import 'package:edu_cluezer/widgets/custom_image_view.dart';
import 'package:edu_cluezer/core/constent/api_constants.dart';
import 'package:edu_cluezer/features/Auth/service/auth_service.dart';

class DonationDetailsPage extends GetView<DonationController> {
  const DonationDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final DonationCauseItem cause = Get.arguments;
    final authService = Get.find<AuthService>();
    final user = authService.currentUser.value;

    final TextEditingController amountController = TextEditingController();

    final double target =
        double.tryParse(cause.targetAmount ?? "0") ?? 0;
    final double raised =
        double.tryParse(cause.raisedAmount ?? "0") ?? 0;
    final double progress =
    target == 0 ? 0 : (raised / target);

    Map<String, dynamic>? contact;
    if (cause.contactInfo != null) {
      contact = jsonDecode(cause.contactInfo!);
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Stack(
        children: [

          /// 🔥 MAIN SCROLL CONTENT
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                /// IMAGE HEADER
                Stack(
                  children: [
                    CustomImageView(
                      url: cause.imageUrl != null
                          ? "${ApiConstants.baseUrl}${cause.imageUrl}"
                          : null,
                      width: double.infinity,
                      height: 300,
                      fit: BoxFit.cover,
                    ),
                    Container(
                      height: 300,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withOpacity(0.6),
                            Colors.transparent
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 25,
                      left: 20,
                      right: 20,
                      child: Text(
                        cause.title ?? "",
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),

                /// CONTENT SECTION
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      /// CATEGORY + URGENCY
                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: [
                          _buildChip(
                            cause.category?.toUpperCase() ??
                            "general".tr.toUpperCase(),
                            Colors.blue,
                          ),
                          _buildChip(
                            cause.urgency?.toUpperCase() ??
                                "normal".tr.toUpperCase(),
                            _getUrgencyColor(
                                cause.urgency),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      /// ORGANIZATION
                      Row(
                        children: [
                          const Icon(Icons.business,
                              size: 18,
                              color: Colors.grey),
                          const SizedBox(width: 8),
                          Text(
                            cause.organization ??
                                "trusted_ngo".tr,
                            style: const TextStyle(
                                fontWeight:
                                FontWeight.w500),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      /// LOCATION
                      Row(
                        children: [
                          const Icon(Icons.location_on,
                              size: 18,
                              color: Colors.red),
                          const SizedBox(width: 8),
                          Text(cause.location ?? ""),
                        ],
                      ),

                      const SizedBox(height: 25),

                      /// PROGRESS CARD
                      Container(
                        padding:
                        const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                          BorderRadius.circular(
                              16),
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 15,
                              color: Colors.black
                                  .withOpacity(0.05),
                            )
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(
                              "raised_of".trParams({
                                'raised': raised.toStringAsFixed(0),
                                'target': target.toStringAsFixed(0),
                              }),
                              style: const TextStyle(
                                  fontWeight:
                                  FontWeight.bold),
                            ),
                            const SizedBox(height: 10),
                            ClipRRect(
                              borderRadius:
                              BorderRadius
                                  .circular(10),
                              child:
                              LinearProgressIndicator(
                                value:
                                progress.clamp(
                                    0, 1),
                                minHeight: 10,
                                backgroundColor:
                                Colors.grey[300],
                                color:
                                Colors.green,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                                "donors_count".trParams({
                                  'count': (cause.donationsCount ?? 0).toString(),
                                })),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      /// DESCRIPTION
                      Text(
                        "about_the_cause".tr,
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight:
                            FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        cause.description ??
                            "no_description_available".tr,
                        style: TextStyle(
                          height: 1.6,
                          color:
                          Colors.grey[700],
                        ),
                      ),

                      const SizedBox(height: 20),

                      /// CONTACT INFO
                      if (contact != null)
                        Row(
                          children: [
                            const Icon(
                                Icons.phone,
                                size: 18,
                                color:
                                Colors.green),
                            const SizedBox(
                                width: 8),
                            Text(
                                contact["phone"]
                                    .toString()),
                          ],
                        ),

                      const SizedBox(height: 220),
                    ],
                  ),
                ),
              ],
            ),
          ),

          /// 💚 FIXED DONATION SECTION
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding:
              const EdgeInsets.all(20),
              decoration:
              const BoxDecoration(
                color: Colors.white,
                borderRadius:
                BorderRadius.vertical(
                    top: Radius.circular(
                        25)),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 20,
                    color: Colors.black12,
                  )
                ],
              ),
              child: Column(
                mainAxisSize:
                MainAxisSize.min,
                children: [
                  TextField(
                    controller:
                    amountController,
                    keyboardType:
                    TextInputType.number,
                    decoration:
                    InputDecoration(
                      hintText:
                      "enter_donation_amount".tr,
                      prefixIcon:
                      const Icon(Icons
                          .currency_rupee_rounded),
                      border:
                      OutlineInputBorder(
                        borderRadius:
                        BorderRadius
                            .circular(14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    width:
                    double.infinity,
                    height: 52,
                    child:
                    ElevatedButton(
                      onPressed: () {
                        final amount =
                            double.tryParse(
                                amountController
                                    .text) ??
                                0;
                        if (amount <=
                            0) {
                          Get.snackbar(
                              "error".tr,
                              "enter_valid_amount".tr);
                          return;
                        }
                        controller
                            .initiateDonationPayment(
                          cause,
                          amount,
                          user?.name ??
                              "guest".tr,
                          user?.email ??
                              "",
                          user?.phone ??
                              "",
                        );
                      },
                      style:
                      ElevatedButton
                          .styleFrom(
                        backgroundColor:
                        context.theme
                            .primaryColor,
                        shape:
                        RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius
                              .circular(
                              14),
                        ),
                      ),
                      child:
                      Text(
                        "contribute".tr,
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight:
                            FontWeight
                                .bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(
      String text, Color color) {
    return Container(
      padding:
      const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius:
        BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight:
          FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Color _getUrgencyColor(
      String? urgency) {
    switch (urgency) {
      case "high":
        return Colors.red;
      case "medium":
        return Colors.orange;
      default:
        return Colors.green;
    }
  }
}
