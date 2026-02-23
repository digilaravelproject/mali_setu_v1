import 'package:get/get.dart';
import '../../../../widgets/custom_snack_bar.dart';
import '../../domain/repository/donation_repository.dart';
import '../../data/model/donation_cause_model.dart';
import 'package:edu_cluezer/features/razorpay/razorpay_controller.dart';
import 'package:flutter/material.dart';

class DonationController extends GetxController {
  final DonationRepository _repository = Get.find<DonationRepository>();
  final RazorpayController _razorpayController = Get.find<RazorpayController>();

  var isLoading = false.obs;
  var causes = <DonationCauseItem>[].obs;
  var selectedCause = Rxn<DonationCauseItem>();

  @override
  void onInit() {
    super.onInit();
    fetchDonationCauses();
  }

  Future<void> fetchDonationCauses() async {
    isLoading.value = true;
    try {
      debugPrint("DonationController: Fetching causes...");
      final response = await _repository.getDonationCauses();
      debugPrint("DonationController: Response success: ${response.success}");
      if (response.success && response.data?.data?.data != null) {
        causes.assignAll(response.data!.data!.data!);
        debugPrint("DonationController: Loaded ${causes.length} causes");
      } else {
        debugPrint("DonationController: No causes found or error: ${response.message}");
      }
    } catch (e) {
      debugPrint("DonationController: Exception: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> initiateDonationPayment(DonationCauseItem cause, double amount, String name, String email, String phone) async {
    try {
      Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
      
      final response = await _repository.createDonationOrder(
        causeId: cause.id!,
        amount: amount,
      );

      Get.back(); // Close Loading

      if (response.success && response.data != null) {
        final data = response.data!;

        _razorpayController.openCheckout(
          amount: (data['amount'] as num).toInt(),
          name: name,
          description: "Donation for ${cause.title}",
          mobile: phone,
          email: email,
          orderId: data['order_id'],
          transaction_id: int.tryParse(data['donation_id']?.toString() ?? "0") ?? 0,
          key: data['key'],
          type: 'donation', // Track this for verification logic
        );
      } else {
        CustomSnackBar.showError(message: response.message ?? "Failed to create donation order");
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      CustomSnackBar.showError(message: "Payment initialization failed: $e");
    }
  }
}
