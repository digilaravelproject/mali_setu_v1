
import 'package:edu_cluezer/core/styles/app_colors.dart';
import 'package:edu_cluezer/features/razorpay/payment_repository.dart';
import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:flutter/material.dart';
import 'package:edu_cluezer/core/routes/app_routes.dart';
import 'package:edu_cluezer/features/donation/domain/repository/donation_repository.dart';
import 'package:edu_cluezer/features/donation/presentation/controller/donation_controller.dart';
import 'package:edu_cluezer/features/donation/binding/donation_binding.dart';
import 'package:edu_cluezer/features/donation/presentation/widget/donation_bottom_sheet.dart';
import 'package:edu_cluezer/features/business/presentation/controller/business_controller.dart';
import 'package:edu_cluezer/core/network/api_response.dart';

class RazorpayController extends GetxController {
  late Razorpay _razorpay;
  final PaymentRepository _paymentRepository = Get.find<PaymentRepository>();


  @override
  void onInit() {
    super.onInit();
    debugPrint("RZP: RazorpayController onInit");

    _razorpay = Razorpay();

    // Payment success
    _razorpay.on(
      Razorpay.EVENT_PAYMENT_SUCCESS,
      (response) {
        debugPrint("RZP: SUCCESS EVENT RECEIVED");
        _handlePaymentSuccess(response);
      },
    );

    // Payment error
    _razorpay.on(
      Razorpay.EVENT_PAYMENT_ERROR,
      (response) {
        debugPrint("RZP: ERROR EVENT RECEIVED");
        _handlePaymentError(response);
      },
    );

    // External wallet
    _razorpay.on(
      Razorpay.EVENT_EXTERNAL_WALLET,
      _handleExternalWallet,
    );
  }

  /// 🔹 Open Razorpay
  void openCheckout({
    required int amount,
    required String name,
    required String description,
    required String mobile,
    required String email,
    String? orderId,
    String? key,
    required int transaction_id,
    String type = 'general', // New parameter to track payment type
  }) {
    var options = {
      'key': key ?? 'rzp_test_S9yXFuXcf0S6Ll',
      'amount': amount * 100,
      'name': name,
      'description': description,
      'prefill': {
        'contact': mobile,
        'email': email,
      },
      'theme': {
        'color': '#2E7D32',
      }
    };

    if (orderId != null) {
      options['order_id'] = orderId;
    }

    _pendingVerification = {
      'transaction_id': transaction_id,
      'amount': amount,
      'order_id': orderId,
      'type': type,
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Razorpay Error: $e');
    }
  }

  Map<String, dynamic>? _pendingVerification;

  /// ✅ SUCCESS
  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    debugPrint("RZP SUCCESS: paymentId=${response.paymentId}, signature=${response.signature}");

    if (_pendingVerification != null) {
      final orderId = _pendingVerification!['order_id'];
      final type = _pendingVerification!['type'];
      final amount = _pendingVerification!['amount'];

      if (orderId == null) {
        print("⚠️ Order ID is null – skipping verification");
        return;
      }

      ApiResponse<Map<String, dynamic>> res;

      if (type == 'donation') {
        final donationRepo = Get.find<DonationRepository>();
        res = await donationRepo.verifyDonationPayment(
          razorpayOrderId: orderId,
          razorpayPaymentId: response.paymentId ?? "",
          razorpaySignature: response.signature ?? '',
          donationId: _pendingVerification!['transaction_id'],
        );
      } else {
        res = await _paymentRepository.verifyPayment(
          razorpayOrderId: orderId,
          razorpayPaymentId: response.paymentId ?? "",
          razorpaySignature: response.signature ?? '',
          transaction_id: _pendingVerification!['transaction_id'],
        );
      }

      if (res.success) {
        PaymentSuccessDialog.show(
          amount: amount.toString(),
          paymentId: response.paymentId ?? '',
          onOkPressed: () {
            if (type == 'matrimony') {
              _showDonationPromptAfterDelay();
            } else if (type == 'donation') {
              Get.back(); // Go back from details page
            } else if (type == 'business') {
              // Refresh business list after successful payment to update status
              if (Get.isRegistered<BusinessController>()) {
                Get.find<BusinessController>().fetchMyBusinesses();
              }
            }
          },
        );
      } else {
        Get.snackbar(
          'Verification Failed',
          res.message ?? 'Payment verification failed',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }

      _pendingVerification = null;
    }
  }

  void _showDonationPromptAfterDelay() async {
    debugPrint("RZP: _showDonationPromptAfterDelay called");
    try {
      // Give time for the success dialog to fully close
      await Future.delayed(const Duration(milliseconds: 600));
      
      if (!Get.isRegistered<DonationController>()) {
        debugPrint("RZP: Registering DonationBinding");
        final donationBinding = DonationBinding();
        donationBinding.dependencies();
      }
      
      final donationController = Get.find<DonationController>();
      debugPrint("RZP: Fetching donation causes");
      await donationController.fetchDonationCauses();
      
      if (donationController.causes.isNotEmpty) {
        debugPrint("RZP: Showing donation prompt");
        showDonationPrompt(donationController.causes, (cause) {
          Get.toNamed(AppRoutes.donationDetails, arguments: cause);
        });
      } else {
        debugPrint("RZP: No donation causes found");
      }
    } catch (e) {
      debugPrint("Error showing donation prompt: $e");
    }
  }

  /// ❌ FAILURE
  void _handlePaymentError(PaymentFailureResponse response) {
    debugPrint("RZP ERROR: code=${response.code}, message=${response.message}");
    Get.snackbar(
      'Payment Failed',
      response.message ?? 'Payment cancelled',
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }

  /// 💳 WALLET
  void _handleExternalWallet(ExternalWalletResponse response) {
    Get.snackbar(
      'Wallet Selected',
      response.walletName ?? '',
    );
    print("_handleExternalWallet : "+response.walletName.toString());

  }



  @override
  void onClose() {
    _razorpay.clear();
    super.onClose();
  }
}




class PaymentSuccessDialog extends StatelessWidget {
  final String amount;
  final String paymentId;
  final String? orderId;
  final String? paymentMethod;
  final VoidCallback? onOkPressed;

  const PaymentSuccessDialog({
    super.key,
    required this.amount,
    required this.paymentId,
    this.orderId,
    this.paymentMethod,
    this.onOkPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Success Animation/Icon with Pink Theme
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    context.theme.primaryColor,
                    context.theme.primaryColorLight,
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.pink.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Icon(
                Icons.check_circle,
                color: Colors.white,
                size: 70,
              ),
            ),

            const SizedBox(height: 20),

            // Congratulations Text with Pink Theme
            Text(
              "Congratulations! 🎉",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: context.theme.primaryColor,
                letterSpacing: 0.5,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              "Payment Successful",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),

            const SizedBox(height: 24),

            // Payment Details Card with Pink Border
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.pink.shade50,
                    Colors.white,
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: context.theme.primaryColorLight,
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: context.theme.primaryColor.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildDetailRow(
                    "Amount Paid",
                    "₹$amount",
                    icon: Icons.currency_rupee,
                  ),
                  // Padding(
                  //   padding: const EdgeInsets.symmetric(vertical: 12),
                  //   child: Divider(
                  //     color: context.theme.primaryColor,
                  //     thickness: 0.5,
                  //     height: 1,
                  //   ),
                  // ),
                  // _buildDetailRow(
                  //   "Payment ID",
                  //   paymentId,
                  //   icon: Icons.receipt_long,
                  //   isPaymentId: true,
                  // ),
                  if (orderId != null) ...[
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider(
                        color: context.theme.primaryColor,
                        thickness: 0.5,
                        height: 1,
                      ),
                    ),
                    _buildDetailRow(
                      "Order ID",
                      orderId!,
                      icon: Icons.shopping_bag,
                    ),
                  ],
                  if (paymentMethod != null) ...[
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider(
                        color: context.theme.primaryColor,
                        thickness: 0.5,
                        height: 1,
                      ),
                    ),
                    _buildDetailRow(
                      "Payment Method",
                      paymentMethod!,
                      icon: Icons.payment,
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Success Message with Pink Theme
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.pink.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: context.theme.primaryColorLight),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.verified,
                    color:context.theme.primaryColor,
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Payment verified successfully! Your transaction has been completed.",
                      style: TextStyle(
                        color: context.theme.primaryColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // OK Button with Pink Theme
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Get.back(); // Close dialog
                  onOkPressed?.call(); // Execute callback if provided
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.theme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 3,
                  shadowColor: Colors.pink.shade300,
                ),
                child: const Text(
                  "OK, Got It!",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value,
      {bool isPaymentId = false, required IconData icon}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.pink.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 16,
            color: Get.theme.primaryColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  color: Colors.grey.shade800,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
                overflow: isPaymentId ? TextOverflow.ellipsis : null,
                maxLines: isPaymentId ? 2 : 1,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Static method to show the dialog with GetX
  static void show({
    required String amount,
    required String paymentId,
    String? orderId,
    String? paymentMethod,
    VoidCallback? onOkPressed,
  }) {
    Get.dialog(
      PaymentSuccessDialog(
        amount: amount,
        paymentId: paymentId,
        orderId: orderId,
        paymentMethod: paymentMethod,
        onOkPressed: onOkPressed,
      ),
      barrierDismissible: false, // User must click OK to close
      transitionDuration: const Duration(milliseconds: 300),
      // transitionBuilder: (context, animation, secondaryAnimation, child) {
      //   return ScaleTransition(
      //     scale: CurvedAnimation(
      //       parent: animation,
      //       curve: Curves.easeOutBack,
      //     ),
      //     child: child,
      //   );
      // },
    );
  }

  /// Alternative method with custom animation
  static void showWithAnimation({
    required String amount,
    required String paymentId,
    String? orderId,
    String? paymentMethod,
    VoidCallback? onOkPressed,
  }) {
    Get.generalDialog(
      pageBuilder: (context, animation, secondaryAnimation) {
        return PaymentSuccessDialog(
          amount: amount,
          paymentId: paymentId,
          orderId: orderId,
          paymentMethod: paymentMethod,
          onOkPressed: onOkPressed,
        );
      },
      barrierDismissible: false,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 400),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.elasticOut,
        );

        return FadeTransition(
          opacity: curvedAnimation,
          child: ScaleTransition(
            scale: curvedAnimation,
            child: child,
          ),
        );
      },
    );
  }
}


/*
class PaymentSuccessDialog extends StatelessWidget {
  final String amount;
  final String paymentId;
  final VoidCallback? onOkPressed;

  const PaymentSuccessDialog({
    super.key,
    required this.amount,
    required this.paymentId,
    this.onOkPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child:
      Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Success Animation/Icon
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 60,
              ),
            ),

            SizedBox(height: 20),

            // Congratulations Text
            Text(
              "Congratulations!",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green[700],
              ),
            ),

            SizedBox(height: 8),

            Text(
              "Payment Successful",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),

            SizedBox(height: 20),

            // Payment Details Card
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                children: [
                  _buildDetailRow("Amount Paid", "₹$amount"),
                 // SizedBox(height: 8),
                 // SizedBox(height: 8),
                  //_buildDetailRow("Payment ID", paymentId, isPaymentId: true),
                ],
              ),
            ),

            SizedBox(height: 20),

            // Success Message
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.green[600],
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Payment verified successfully",
                      style: TextStyle(
                        color: Colors.green[700],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24),

            // OK Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Get.back(); // Close dialog
                  onOkPressed?.call(); // Execute callback if provided
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 2,
                ),
                child: Text(
                  "OK",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isPaymentId = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: TextStyle(
              color: Colors.grey[800],
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.right,
            overflow: isPaymentId ? TextOverflow.ellipsis : null,
          ),
        ),
      ],
    );
  }

  /// Static method to show the dialog
  static void show({
    required String amount,
    required String paymentId,
    VoidCallback? onOkPressed,
  }) {
    Get.dialog(
      PaymentSuccessDialog(
        amount: amount,
        paymentId: paymentId,
        onOkPressed: onOkPressed,
      ),
      barrierDismissible: false, // User must click OK to close
    );
  }
}*/
