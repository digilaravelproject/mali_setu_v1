
import 'package:edu_cluezer/features/razorpay/payment_repository.dart';
import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:flutter/material.dart';

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
  }) {
    var options = {
      'key': key ?? 'rzp_test_S9yXFuXcf0S6Ll', // Use key from create-order API
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

    // Store these for verification after success
    _pendingVerification = {
      'transaction_id': transaction_id,
      'amount': amount,
      'order_id': orderId,
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
      debugPrint("RZP PENDING VERIFICATION: $_pendingVerification");

      final orderId = _pendingVerification!['order_id'];

      if (orderId == null) {
        print("⚠️ Order ID is null – skipping verification");
        return;
      }
      // await _verifyPayment(
      //   razorpayOrderId: orderId,
      //   razorpayPaymentId: response.paymentId ?? '',
      //   razorpaySignature: response.signature ?? '',
      //   userId: _pendingVerification!['user_id'],
      //   amount: _pendingVerification!['amount'],
      //   treeIds: List<int>.from(_pendingVerification!['tree_ids']),
      // );


      final res = await _paymentRepository.verifyPayment(
        razorpayOrderId: orderId,
        razorpayPaymentId: response.paymentId ?? "",
        razorpaySignature: response.signature ?? '',
       // userId: _pendingVerification!['user_id'],
        transaction_id:_pendingVerification!['transaction_id'],
      );

      if (res.success) {
        // Show success dialog instead of snackbar
        print("response for verify : "+response.toString());
        
        PaymentSuccessDialog.show(
          amount: _pendingVerification!['amount'].toString(),
          paymentId: response.paymentId ?? '',
          onOkPressed: () {
            // Optional: Navigate back or refresh data
            debugPrint("Payment success dialog OK pressed");
          },
        );
      } else {
        // error toast
        Get.snackbar(
          'Verification Failed',
          res.message ?? 'Payment verification failed',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }


      _pendingVerification = null; // clear after verification
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
      child: Container(
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
                  SizedBox(height: 8),
                  SizedBox(height: 8),
                  _buildDetailRow("Payment ID", paymentId, isPaymentId: true),
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
                      "Your payment has been verified successfully. You can now download your tree data.",
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
}